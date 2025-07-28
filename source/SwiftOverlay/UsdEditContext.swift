//
//  UsdEditContext.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 1/30/24.
//

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

