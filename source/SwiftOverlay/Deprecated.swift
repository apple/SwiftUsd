//
//  Deprecated.swift
//
//
//  Created by Maddy Adams on 3/27/24.
//

import Foundation


// We want to give clients at least one full Swift release cycle (about 6 months) to
// migrate to the replacements for deprecations whenever possible.
// So, if we deprecate a symbol while the latest release is N,
// we should mark it as obsoleted in N+2, to ensure that the client has the entirity
// of N+1 to fix their code.




// MARK: Deprecated in Swift 6.0, obsoleted in Swift 6.2

// MARK: Deprecated in Swift 6.1, obsoleted in Swift 6.3
extension Overlay.SdfLayer {
    #if compiler(<6.3)
    @available(*, deprecated, message: "Use pxr.SdfLayer.IsMuted(_:) instead")
    #else
    @available(*, unavailable, message: "Use pxr.SdfLayer.IsMuted(_:) instead")
    #endif
    public static func IsMuted(_ x: std.string) -> Bool {
        pxr.SdfLayer.IsMuted(x)
    }
}

extension Overlay {
    #if compiler(<6.3)
    @available(*, deprecated, message: "Use pxr.UsdZipFileWriter instead")
    #else
    @available(*, unavailable, message: "Use pxr.UsdZipFileWriter instead")
    #endif
    public typealias UsdZipFileWriterWrapper = pxr.UsdZipFileWriter
}

extension Overlay {
    #if compiler(<6.3)
    @available(*, deprecated, message: "Usd pxr.VtValue.init(_:) instead")
    #else
    @available(*, unavailable, message: "Use pxr.VtValue.init(_:) instead")
    #endif
    public static func VtValue(_ x: Bool) -> pxr.VtValue {
        pxr.VtValue(x)
    }

    #if compiler(<6.3)
    @available(*, deprecated, message: "Use VtArray.push_back(_:) instead")
    #else
    @available(*, unavailable, message: "Use VtArray.push_back(_:) instead")
    #endif
    public static func push_back(_ v: inout pxr.VtBoolArray, _ x: Bool) {
        v.push_back(x)
    }

    #if compiler(<6.3)
    @available(*, deprecated, message: "Use UsdGeomXformOp.GetOpType() instead")
    #else
    @available(*, unavailable, message: "Use UsdGeomXformOp.GetOpType() instead")
    #endif
    public static func GetOpType(_ op: pxr.UsdGeomXformOp) -> pxr.UsdGeomXformOp.`Type` {
        op.GetOpType()
    }

    #if compiler(<6.3)
    @available(*, deprecated, message: "Dereference the pointer, then use `as(_:)` to cast it and rewrap instead")
    #else
    @available(*, unavailable, message: "Dereference the pointer, then use `as(_:)` to cast it and rewrap instead")
    #endif
    public static func SdfLayerStateDelegateBaseRefPtr(_ p: pxr.SdfSimpleLayerStateDelegateRefPtr) -> pxr.SdfLayerStateDelegateBaseRefPtr {
        Overlay.TfRefPtr(Overlay.DereferenceOrNil(p)?.as(pxr.SdfLayerStateDelegateBase.self))
    }

    #if compiler(<6.3)
    @available(*, deprecated, message: "Dereference the pointer, then use `as(_:)` to cast it and rewrap instead")
    #else
    @available(*, unavailable, message: "Dereference the pointer, then use `as(_:)` to cast it and rewrap instead")
    #endif
    public static func SdfLayerStateDelegateBasePtr(_ p: pxr.SdfSimpleLayerStateDelegateRefPtr) -> pxr.SdfLayerStateDelegateBasePtr {
        Overlay.TfWeakPtr(Overlay.DereferenceOrNil(p)?.as(pxr.SdfLayerStateDelegateBase.self))
    }
}