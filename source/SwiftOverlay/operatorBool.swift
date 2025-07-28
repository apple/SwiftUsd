//
//  SwiftOverlay_operatorBool.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation


extension Bool {
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfPropertySpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfPrimSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfVariantSetSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfVariantSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfAttributeSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfRelationshipSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }
    /// Returns `true` is the spec has not expired
    public init(_ handle: pxr.SdfPseudoRootSpecHandle) {
        self = __Overlay.convertToBool(handle)
    }

    /// Returns `true` if the `UsdObject` is valid
    public init(_ object: pxr.UsdObject) {
        self = object.IsValid()
    }

    /// Returns `true` if the `UsdPrim` is valid
    public init(_ prim: pxr.UsdPrim) {
        self = prim.IsValid()
    }

    /// Returns `true` if the `UsdProperty` is valid
    public init(_ property: pxr.UsdProperty) {
        self = property.IsValid()
    }

    /// Returns `true` if the `UsdAttribute` is valid
    public init(_ a: pxr.UsdAttribute) {
        self.init(__Overlay.convertToBool(a))
    }

    /// Returns `true` if the `UsdRelationship` is valid
    public init(_ relationship: pxr.UsdRelationship) {
        self = __Overlay.convertToBool(relationship)
    }

    /// Returns `true` if the `UsdShadeInput` is valid
    public init(_ s: pxr.UsdShadeInput) {
        self.init(__Overlay.convertToBool(s))
    }

    /// Returns `true` if the `UsdShadeOutput` is valid
    public init(_ s: pxr.UsdShadeOutput) {
        self.init(__Overlay.convertToBool(s))
    }

    /// Returns `true` if the `UsdGeomXformOp` is valid
    public init(_ x: pxr.UsdGeomXformOp) {
        self.init(__Overlay.convertToBool(x))
    }

    /// Returns `true` if the resolved path is non-empty
    public init(_ x: pxr.ArResolvedPath) {
        self = x.__convertToBool()
    }

    /// Returns `true` if the zip file is valid
    public init(_ x: pxr.UsdZipFile) {
        self = x.__convertToBool()
    }

    #if canImport(SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT)
    /// Returns `true` if the `HioImage` is valid
    public init(_ x: Overlay.HioImageWrapper) {
        self.init(x.__convertToBool())
    }
    #endif // #if canImport(SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT)
}
