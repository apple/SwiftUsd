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


extension pxr.TfToken {
    @_documentation(visibility: internal)
    public func GetString() -> std.string {
        __GetStringUnsafe().pointee
    }
}

extension pxr.TfType {
    @_documentation(visibility: internal)
    public func GetTypeName() -> std.string {
        __GetTypeNameUnsafe().pointee
    }
}

extension pxr.GfRange2f {
    @_documentation(visibility: internal)
    public func GetMin() -> pxr.GfVec2f {
        __GetMinUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetMax() -> pxr.GfVec2f {
        __GetMaxUnsafe().pointee
    }
}

extension pxr.GfRange3f {
    @_documentation(visibility: internal)
    public func GetMin() -> pxr.GfVec3f {
        __GetMinUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetMax() -> pxr.GfVec3f {
        __GetMaxUnsafe().pointee
    }
}

extension pxr.GfQuatf {
    @_documentation(visibility: internal)
    public func GetImaginary() -> pxr.GfVec3f {
        __GetImaginaryUnsafe().pointee
    }
}

extension pxr.GfQuath {
    @_documentation(visibility: internal)
    public func GetImaginary() -> pxr.GfVec3h {
        __GetImaginaryUnsafe().pointee
    }
}

extension pxr.GfRect2i {
    @_documentation(visibility: internal)
    public func GetMin() -> pxr.GfVec2i {
        __GetMinUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetMax() -> pxr.GfVec2i {
        __GetMaxUnsafe().pointee
    }
}

extension pxr.GfRange2d {
    @_documentation(visibility: internal)
    public func GetMin() -> pxr.GfVec2d {
        __GetMinUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetMax() -> pxr.GfVec2d {
        __GetMaxUnsafe().pointee
    }
}

extension pxr.GfQuaternion {
    @_documentation(visibility: internal)
    public func GetImaginary() -> pxr.GfVec3d {
        __GetImaginaryUnsafe().pointee
    }
}

extension pxr.GfRotation {
    @_documentation(visibility: internal)
    public func GetAxis() -> pxr.GfVec3d {
        __GetAxisUnsafe().pointee
    }
}

extension pxr.GfRange3d {
    @_documentation(visibility: internal)
    public func GetMin() -> pxr.GfVec3d {
        __GetMinUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetMax() -> pxr.GfVec3d {
        __GetMaxUnsafe().pointee
    }
}

extension pxr.GfQuatd {
    @_documentation(visibility: internal)
    public func GetImaginary() -> pxr.GfVec3d {
        __GetImaginaryUnsafe().pointee
    }
}

extension pxr.GfBBox3d {
    @_documentation(visibility: internal)
    public func GetRange() -> pxr.GfRange3d {
        __GetRangeUnsafe().pointee
    }
}

extension pxr.SdfPath {
    @_documentation(visibility: internal)
    public func GetString() -> std.string {
        __GetStringUnsafe().pointee
    }
}

extension pxr.UsdGeomPrimvar {
    @_documentation(visibility: internal)
    public func GetAttr() -> pxr.UsdAttribute {
        __GetAttrUnsafe().pointee
    }
}

extension pxr.UsdGeomXformOp {
    @_documentation(visibility: internal)
    public func GetAttr() -> pxr.UsdAttribute {
        __GetAttrUnsafe().pointee
    }
}

extension pxr.UsdPrim {
    @_documentation(visibility: internal)
    public func GetTypeName() -> pxr.TfToken {
        __GetTypeNameUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetAppliedSchemas() -> pxr.TfTokenVector {
        __GetAppliedSchemasUnsafe().pointee
    }
}

extension pxr.UsdStage {
    @_documentation(visibility: internal)
    public func GetLoadRules() -> pxr.UsdStageLoadRules {
        __GetLoadRulesUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetEditTarget() -> pxr.UsdEditTarget {
        __GetEditTargetUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetMutedLayers() -> Overlay.String_Vector {
        __GetMutedLayersUnsafe().pointee
    }
}

extension pxr.UsdEditTarget {
    @_documentation(visibility: internal)
    public func GetLayer() -> pxr.SdfLayerHandle {
        __GetLayerUnsafe().pointee
    }
}

extension pxr.UsdStagePopulationMask {
    @_documentation(visibility: internal)
    public mutating func Add(_ other: borrowing pxr.UsdStagePopulationMask) -> pxr.UsdStagePopulationMask {
        __AddUnsafe(other).pointee
    }

    @_documentation(visibility: internal)
    public mutating func Add(_ path: borrowing pxr.SdfPath) -> pxr.UsdStagePopulationMask {
        __AddUnsafe(path).pointee
    }
}

extension pxr.SdfValueTypeName {
    @_documentation(visibility: internal)
    public func GetType() -> pxr.TfType {
        __GetTypeUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetCPPTypeName() -> std.string {
        __GetCPPTypeNameUnsafe().pointee
    }

    @_documentation(visibility: internal)
    public func GetRole() -> pxr.TfToken {
        __GetRoleUnsafe().pointee
    }
}

extension pxr.SdfLayer {
    @_documentation(visibility: internal)
    public func GetIdentifier() -> std.string {
        __GetIdentifierUnsafe().pointee
    }
}

#if canImport(SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT)
extension Overlay.HioImageWrapper {
    @_documentation(visibility: internal)
    public func GetFilename() -> std.string {
        __GetFilenameUnsafe().pointee
    }
}
#endif // #if canImport(SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT)

extension pxr.SdfSpecHandle {
    @_documentation(visibility: internal)
    public func GetSpec() -> pxr.SdfSpec {
        __GetSpecUnsafe().pointee
    }
}

extension pxr.UsdNotice.StageNotice {
    @_documentation(visibility: internal)
    public func GetStage() -> pxr.UsdStageWeakPtr {
        __GetStageUnsafe().pointee
    }
}

extension pxr.UsdNotice.LayerMutingChanged {
    @_documentation(visibility: internal)
    public func GetStage() -> pxr.UsdStageWeakPtr {
        __GetStageUnsafe().pointee
    }
    @_documentation(visibility: internal)
    public func GetMutedLayers() -> Overlay.String_Vector {
        __GetMutedLayersUnsafe().pointee
    }
    @_documentation(visibility: internal)
    public func GetUnmutedLayers() -> Overlay.String_Vector {
        __GetUnmutedLayersUnsafe().pointee
    }
}

extension pxr.UsdNotice.StageContentsChanged {
    @_documentation(visibility: internal)
    public func GetStage() -> pxr.UsdStageWeakPtr {
        __GetStageUnsafe().pointee
    }
}

extension pxr.UsdNotice.ObjectsChanged {
    @_documentation(visibility: internal)
    public func GetStage() -> pxr.UsdStageWeakPtr {
        __GetStageUnsafe().pointee
    }
}

extension pxr.UsdNotice.StageEditTargetChanged {
    @_documentation(visibility: internal)
    public func GetStage() -> pxr.UsdStageWeakPtr {
        __GetStageUnsafe().pointee
    }
}

extension pxr.TfDiagnosticBase {
    @_documentation(visibility: internal)
    public func GetCommentary() -> std.string {
        __GetCommentaryUnsafe().pointee
    }
}
extension pxr.TfError {
    @_documentation(visibility: internal)
    public func GetCommentary() -> std.string {
        __GetCommentaryUnsafe().pointee
    }
}
extension pxr.TfStatus {
    @_documentation(visibility: internal)
    public func GetCommentary() -> std.string {
        __GetCommentaryUnsafe().pointee
    }
}
extension pxr.TfWarning {
    @_documentation(visibility: internal)
    public func GetCommentary() -> std.string {
        __GetCommentaryUnsafe().pointee
    }
}

extension pxr.SdfAssetPathParams {
    @_documentation(visibility: internal)
    public func Authored(_ authoredPath_: std.string) -> pxr.SdfAssetPathParams {
        var copy = self
        return copy.__AuthoredUnsafe(authoredPath_).pointee
    }
    @_documentation(visibility: internal)
    public func Evaluated(_ evaluatedPath_: std.string) -> pxr.SdfAssetPathParams {
        var copy = self
        return copy.__EvaluatedUnsafe(evaluatedPath_).pointee
    }
    @_documentation(visibility: internal)
    public func Resolved(_ resolvedPath_: std.string) -> pxr.SdfAssetPathParams {
        var copy = self
        return copy.__ResolvedUnsafe(resolvedPath_).pointee
    }
}