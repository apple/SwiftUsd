//===----------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0
//===----------------------------------------------------------------------===//

extension _Overlay {
    /// A Swift class that can be strongly held by C++, making detached copies to
    /// provide value semantics. 
    ///
    /// This type can be used by internal code to give C++ a value-semantics handle to a
    /// Swift value type held by a Swift class.
    /// See also: _Overlay::CopyableSwiftClass, _Overlay.RetainableByCxx
    internal class _CopyableByCxx {
        /// Staticly casts the result of _Overlay::CopyableSwiftClass::get() to Swift.
        /// Use this function to ensure that retains/releases are properly balanced
        /// in C function pointers. 
        public static func takeSelfFromCxx(_ raw: UnsafeRawPointer) -> Self {
            Unmanaged<Self>.fromOpaque(raw).takeUnretainedValue()
        }

        // Using a protocol can allow us to require subclasses override makeCopy()
        public protocol PureVirtuals {
            /// Construct a new instance with separate (deep) copies of the values
            /// it holds. You must implement this method
            func makeCopy() -> Self
        }

        /// Gives the return value shared ownership of this class instance.
        /// Use this function to move this instance into C++ in a type-erased fashion
        public func giveCxxOwnership() -> _Overlay.CopyableSwiftClass {
            .init(Unmanaged<_CopyableByCxx>.passRetained(self).toOpaque(),
                  { let slf = _CopyableByCxx.takeSelfFromCxx($0) as! _Overlay.CopyableByCxx
                    let copy = slf.makeCopy()
                    let result = Unmanaged<_CopyableByCxx>.passRetained(copy).toOpaque()
                    return UnsafeRawPointer(result) },
                  { Unmanaged<_CopyableByCxx>.fromOpaque($0).release() })
        }
    }

    /// A Swift class that can be strongly held by C++, making detached copies to
    /// provide value semantics. 
    ///
    /// This type can be used by internal code to give C++ a value-semantics handle to a
    /// Swift value type held by a Swift class.
    /// See also: _Overlay::CopyableSwiftClass, _Overlay.RetainableByCxx    
    internal typealias CopyableByCxx = _CopyableByCxx & _CopyableByCxx.PureVirtuals




    /// A Swift class that can be strongly held by C++, performing retains/releases in C++
    /// as needed. 
    ///
    /// This type can be used by internal code to give C++ a handle to a Swift class.
    /// See also: _Overlay::RetainableSwiftClass, _Overlay.CopyableByCxx
    internal class RetainableByCxx {
        /// Staticly casts the result of _Overlay::RetainableSwiftClass::get() to Swift.
        /// Use this function to ensure that retains/releases are properly balanced
        /// in C function pointers. 
        public static func takeSelfFromCxx(_ raw: UnsafeRawPointer) -> Self {
            Unmanaged<Self>.fromOpaque(raw).takeUnretainedValue()
        }

        /// Gives the return value shared ownership of this class instance.
        /// Use this function to move this instance into C++ in a type-erased fashion
        public func giveCxxOwnership() -> _Overlay.RetainableSwiftClass {
             .init(Unmanaged<RetainableByCxx>.passRetained(self).toOpaque(),
                   { _ = Unmanaged<RetainableByCxx>.fromOpaque($0).retain() },
                   { Unmanaged<RetainableByCxx>.fromOpaque($0).release() })
        }
    }

    /// Holds an arbitrary generic value in C++ with reference semantics.
    /// Important: C function pointers can't capture generic metatypes, so you must
    /// cast to RetainableValueHolder<T> outside the C function pointer
    final internal class RetainableValueHolder<T: ~Copyable>: _Overlay.RetainableByCxx {
        /// The value held by this instance
        public var value: T

        /// Creates a value holder holding the given value
        public init(_ value: consuming T) {
            self.value = value
        }
    }

    /// Holds an arbitrary generic value in C++ with value semantics.
    /// Important: C function pointers can't capture generic metatypes, so you must
    /// cast to CopyableValueHolder<T> outside the C function pointer
    final internal class CopyableValueHolder<T>: _Overlay.CopyableByCxx {
         /// The value held by this instance
         public var value: T
         var _makeCopy: (T) -> T

         /// Creates a value holder holding the given value, using the given
         /// closure to make detached copies
         public init(_ value: T, _ makeCopy: @escaping (T) -> T) {
             self.value = value
             self._makeCopy = makeCopy
         }

         /// Creates a value holder holding the given value, using
         /// Swift's built in copy operation
         public init(_ value: T) {
             self.value = value
             self._makeCopy = { $0 }
         }

         public func makeCopy() -> Self {
             CopyableValueHolder<T>(_makeCopy(value), _makeCopy) as! Self
         }
    }
}