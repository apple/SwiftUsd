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

extension pxr.TfNotice {
    /// Utility struct that lets uses cast `pxr::TfNotice` subclasses in a `pxr::TfNotice::Register` callback
    public struct NoticeCaster: ~Copyable {
        /// The pointer is only valid for the duration of the `pxr::TfNotice::Register` callback
        internal init(_ p: UnsafePointer<pxr.TfNotice>) {
            self.p = p
        }
        
        private var p: UnsafePointer<pxr.TfNotice>
        
        /// Casting operator.
        ///
        /// Returns the casted `pxr::TfNotice` during a `pxr::TfNotice::Register` callback, or null if casting failed
        public func cast<T: SwiftUsd.TfNoticeProtocol>(to: T.Type = T.self) -> T? {
            T._dynamic_cast(p)?.pointee
        }
        
        /// Casting operator.
        ///
        /// Returns the casted `pxr::TfNotice` during a `pxr::TfNotice::Register` callback, or null if casting failed.
        /// Equivalent to ``cast(to:)``
        public func callAsFunction<T: SwiftUsd.TfNoticeProtocol>(_ to: T.Type = T.self) -> T? {
            cast(to: to)
        }
    }
}
