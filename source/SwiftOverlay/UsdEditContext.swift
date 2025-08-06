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

import Foundation

extension Overlay {
    /// Performs an edit using the edit target.
    ///
    /// Replaces `pxr.UsdEditContext` which is unavailable in Swift
    ///
    /// - Parameters:
    ///   - stage: The stage whose current edit target will be modified and restored
    ///   - target: The edit target to use for the duration of `body`
    ///   - body: The edit to perform in `target`
    @discardableResult
    public static func withUsdEditContext<T>(_ stage: pxr.UsdStage, _ target: pxr.UsdEditTarget, _ body: () throws -> (T)) rethrows -> T {
        let old = stage.GetEditTarget()
        defer { stage.SetEditTarget(old) }
        stage.SetEditTarget(target)
        return try body()
    }

    /// Performs an edit using the edit target
    /// - Parameters:
    ///   - pair: The pair of stage and edit target
    ///   - body: The edit to perform in the edit target
    @discardableResult
    public static func withUsdEditContext<T>(_ pair: Overlay.UsdStagePtr_UsdEditTarget_Pair, _ body: () throws -> (T)) rethrows -> T {
        try withUsdEditContext(Overlay.Dereference(pair.first), pair.second, body)
    }
}

