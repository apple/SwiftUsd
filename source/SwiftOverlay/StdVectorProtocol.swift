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
import CxxStdlib

extension __Overlay {
    public protocol StdVector_Equatable: Equatable {
        associatedtype Element: Equatable
        func size() -> Int
        subscript(_: Int) -> Element { get }
    }
}
extension __Overlay.StdVector_Equatable {
    static public func ==(lhs: Self, rhs: Self) -> Bool {
        guard lhs.size() == rhs.size() else { return false }
        for i in 0..<lhs.size() {
            guard lhs[i] == rhs[i] else { return false }
        }
        return true
    }
}

extension __Overlay {
    public protocol StdVector_CustomStringConvertible: CustomStringConvertible, Sequence where Element: CustomStringConvertible {}
}
extension __Overlay.StdVector_CustomStringConvertible {
    public var description: String {
        "[" + map { $0.description }.joined(separator: ", ") + "]"
    }
}

extension __Overlay {
    public protocol StdVectorProtocol: StdVector_Equatable,
                                       StdVector_CustomStringConvertible {
    }
}

extension pxr.SdfLayerOffsetVector: __Overlay.StdVectorProtocol {}
extension pxr.SdfPropertySpecHandleVector: __Overlay.StdVectorProtocol {}
extension pxr.SdfPrimSpecHandleVector: __Overlay.StdVectorProtocol {}
extension Overlay.GfVec4f_Vector: __Overlay.StdVectorProtocol {}
extension Overlay.UsdProperty_Vector: __Overlay.StdVectorProtocol {}
extension Overlay.UsdAttribute_Vector: __Overlay.StdVectorProtocol {}
extension Overlay.UsdRelationship_Vector: __Overlay.StdVectorProtocol {}
extension Overlay.UsdGeomXformOp_Vector: __Overlay.StdVectorProtocol {}
extension Overlay.String_Vector: __Overlay.StdVectorProtocol {}
extension pxr.TfTokenVector: __Overlay.StdVectorProtocol {}
extension pxr.SdfPathVector: __Overlay.StdVectorProtocol {}
extension Overlay.Double_Vector: __Overlay.StdVectorProtocol {}


#if canImport(SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT)
extension pxr.GlfSimpleLightVector: CxxSequence {}
#endif // #if canImport(SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT)