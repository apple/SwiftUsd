//
//  ConvenientExtensions.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation

extension pxr.SdfLayer {
    /// Wrapper for `pxr.SdfLayer.ExportToString()`
    ///
    /// Returns `nil` if exporting the string failed
    public func ExportToString() -> String? {
        var tmp = std.string()
        if self.ExportToString(&tmp) {
            return String(tmp)
        } else {
            return nil
        }
    }
}

extension pxr.UsdStage {
    /// Wrapper for `pxr.UsdStage.ExportToString()`
    ///
    /// Returns `nil` if exporting the string failed
    public func ExportToString(addSourceFileComment: Bool = true) -> String? {
        var tmp = std.string()
        if self.ExportToString(&tmp, addSourceFileComment) {
            return String(tmp)
        } else {
            return nil
        }
    }
}


