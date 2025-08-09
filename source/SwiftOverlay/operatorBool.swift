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
