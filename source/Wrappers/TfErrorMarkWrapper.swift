// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

extension Overlay {
    /// Performs work with a `pxr::TfErrorMark` in scope
    ///
    /// Important: TfErrorMark uses thread-local storage, which is incompatible
    /// with Swift Concurrency's task execution model. Thus, the body of
    /// `withTfErrorMark` is intentionally forced to be synchronous
    public static func withTfErrorMark<T, E>(_ code: (borrowing Overlay.TfErrorMarkWrapper) throws(E) -> T) throws(E) -> T {
        try withExtendedLifetime(__Overlay.makeTfErrorMarkWrapper()) { mark throws(E) -> T in
            try code(mark)
        }
    }
}

@available(*, unavailable) extension Overlay.TfErrorMarkWrapper: @unchecked Sendable {}

extension Overlay.TfErrorMarkWrapper {
    /// Returns a sequence of the errors caught by this mark. 
    /// 
    /// In Swift 6.0, conforming to `Sequence` requires the conforming type
    /// be `Copyable`, but for thread-safety guarantees we want `TfErrorMarkWrapper`
    /// to be non-`Copyable`. So, we provide the `ErrorSequence` type instead
    public var errors: Overlay.TfErrorMarkWrapper.ErrorSequence {
        .init(__beginUnsafe(), __endUnsafe())
    }

    /// A sequence of errors caught by a [`TfErrorMarkWrapper`](doc:/OpenUSD/Overlay/TfErrorMarkWrapper)
    ///
    /// In Swift 6.0, conforming to `Sequence` requires the conforming type
    /// be `Copyable`, but for thread-safety guarantees we want `TfErrorMarkWrapper`
    /// to be non-`Copyable`. So, we provide the `ErrorSequence` type instead
    //
    // Important: TfErrorMark's underlying error sequence is a `std::list<TfError>`,
    // i.e. a doubly linked list. This means that it does not provide O(1) random
    // access, so ErrorSequence should conform to `Sequence` but not `Collection`,
    // which requires a O(1) random access subscript via an index. 
    public struct ErrorSequence: Sequence, IteratorProtocol {
        fileprivate init(_ begin: Overlay.TfErrorMarkWrapper._TfErrorMarkIterator,
                         _ end: Overlay.TfErrorMarkWrapper._TfErrorMarkIterator) {
            self.begin = begin
            self.end = end
        }
        fileprivate var begin: Overlay.TfErrorMarkWrapper._TfErrorMarkIterator
        fileprivate var end: Overlay.TfErrorMarkWrapper._TfErrorMarkIterator

        public mutating func next() -> pxr.TfError? {
            guard begin != end else { return nil }
            let result = begin.pointee
            begin = begin.successor()
            return result
        }
    }
}

extension Overlay.TfErrorMarkWrapper.ErrorSequence: CustomStringConvertible {
   public var description: String {
       String(describing: self.map { String($0.GetCommentary()) })
   }
}