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

#ifndef SWIFTUSD_UTIL_UTIL_H
#define SWIFTUSD_UTIL_UTIL_H

#include <swift/bridging>
#include <utility>
#include <type_traits>
#include "swiftUsd/Util/TypeTraits.h"

namespace _Overlay {
    /// Strongly holds a type-erased Swift class, invoking the makeCopy closure when copied.
    ///
    /// This type can be used by internal code to give C++ a value-semantics handle to a
    /// Swift value type held by a Swift class.
    /// See also: _Overlay.CopyableByCxx, _Overlay::RetainableSwiftClass.
    struct CopyableSwiftClass final {
        typedef const void*_Nonnull object_t;
        /// The return value must be already retained
        typedef object_t (*_Nonnull makeCopy_t)(object_t);
        typedef void (*_Nonnull release_t)(object_t);

        /// Important: `obj` must already be retained
        CopyableSwiftClass(object_t obj, makeCopy_t makeCopy, release_t release);

        CopyableSwiftClass(const CopyableSwiftClass&);
        CopyableSwiftClass& operator=(const CopyableSwiftClass&);
        
        CopyableSwiftClass(CopyableSwiftClass&&);
        CopyableSwiftClass& operator=(CopyableSwiftClass&&);
        
        ~CopyableSwiftClass();

        operator object_t() const;

        /// Important: the Swift caller must not consume an unbalanced retain
        /// while casting the return value
        object_t get() const SWIFT_RETURNS_INDEPENDENT_VALUE;

    private:
        object_t _obj;
        makeCopy_t _makeCopy;
        release_t _release;
    };

    /// Strongly holds a type-erased Swift class, performing retains/releases
    /// when copied/destroyed.
    ///
    /// This type can be used by internal code to give C++ a handle to a Swift class.
    /// See also: _Overlay.RetainableByCxx, _Overlay::CopyableSwiftClass.
    struct RetainableSwiftClass final {
        typedef const void*_Nonnull object_t;
        typedef void (*_Nonnull retain_t)(object_t);
        typedef void (*_Nonnull release_t)(object_t);

        /// Important `obj` must already be retained, i.e. this constructor does not perform a retain
        RetainableSwiftClass(object_t obj, retain_t retain, release_t release);

        RetainableSwiftClass(const RetainableSwiftClass&);
        RetainableSwiftClass& operator=(const RetainableSwiftClass&);
        
        RetainableSwiftClass(RetainableSwiftClass&&);
        RetainableSwiftClass& operator=(RetainableSwiftClass&&);
        
        ~RetainableSwiftClass();
        
        operator object_t() const;

        /// Important: the Swift caller must not consume an unbalanced retain
        /// while casting the return value
        object_t get() const SWIFT_RETURNS_INDEPENDENT_VALUE;

    private:
        object_t _obj;
        retain_t _retain;
        release_t _release;
    };

    /// Strongly holds a Swift closure.
    ///
    /// This type can be used by internal code to give C++ a handle to a Swift closure.
    /// To use, create a Swift subclass of _Overlay.RetainableByCxx that holds the closure,
    /// then pass the class instance and a C function pointer invoking the closure
    /// to this type's constructor. 
    template <typename Callback>
    struct SwiftClosure {
        // rdar://158808673 (size_t imported as UInt instead of Int when passed through class template)
        // Workaround: manually replace size_t with ssize_t when we know we're passing things through
        // a template. Only do this for the constructor, because that's the only part that Swift
        // interacts with
        static_assert(std::is_same_v<size_t, unsigned long>);
        typedef replace_all_t<Callback, size_t, signed long> replaced_callback_t;
        typedef Callback callback_t;

        SwiftClosure(RetainableSwiftClass obj, replaced_callback_t callback)
            : _obj(obj), _callback((callback_t)callback) {}

        template <typename... Args>
        decltype(auto) operator()(Args &&... args) const {
            return _callback(_obj, std::forward<Args>(args)...);
        }

    private:
        RetainableSwiftClass _obj;
        callback_t _callback;
    };
}

#endif /* SWIFTUSD_UTIL_UTIL_H */
