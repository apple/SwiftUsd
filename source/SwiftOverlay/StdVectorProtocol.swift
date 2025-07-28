//
//  StdVectorProtocol.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

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