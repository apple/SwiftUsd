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

import Foundation

extension Overlay {
    /// Non-escaping, move-only wrapper around `pxr.ExecUsdCacheView`.
    ///
    /// Only valid for the duration of the closure passed to
    /// `Overlay.Compute(_:_:_:)`. `~Copyable` + `borrowing` at the call site
    /// prevent it from escaping, since `ExecUsdCacheView` must not outlive
    /// the `ExecUsdSystem`/`ExecUsdRequest` that created it.
    public struct ExecUsdCacheViewNoncopyableWrapper: ~Copyable {
        var cacheView: pxr.ExecUsdCacheView

        init(_ cacheView: consuming pxr.ExecUsdCacheView) {
            self.cacheView = cacheView
        }

        public func Get(_ index: CInt) -> pxr.VtValue {
            cacheView.Get(index)
        }
    }
}

extension Overlay {
    public static func Compute<T, E: Error>(_ system: inout Overlay.ExecUsdSystemWrapper,
                                            _ request: consuming pxr.ExecUsdRequest,
                                            _ body: (borrowing ExecUsdCacheViewNoncopyableWrapper) throws(E) -> T
    ) throws(E) -> T {
        try withExtendedLifetime(request) { _ throws(E) -> T in
            let rawView = __Overlay.ComputeUnsafe(&system, request)
            return try body(ExecUsdCacheViewNoncopyableWrapper(rawView))
        }
    }
    
    #if compiler(>=6.2)
    // Swift-Cxx interop only gained rvalue reference support in Swift 6.2;
    // __Overlay.ComputeWithOverridesUnsafe(_:_:consuming:) relies on it.
    public static func ComputeWithOverrides<T, E: Error>(_ system: inout Overlay.ExecUsdSystemWrapper,
                                                         _ request: consuming pxr.ExecUsdRequest,
                                                         consuming valueOverrides: consuming pxr.ExecUsdValueOverrideVector,
                                                         _ body: (borrowing ExecUsdCacheViewNoncopyableWrapper) throws(E) -> T
    ) throws(E) -> T {
        let localOverrides = consume valueOverrides

        return try withExtendedLifetime(request) { _ throws(E) -> T in
            let rawView = __Overlay.ComputeWithOverridesUnsafe(&system, request, consuming: localOverrides)
            return try body(ExecUsdCacheViewNoncopyableWrapper(rawView))
        }
    }
    #endif // #if compiler(>=6.2)
}
