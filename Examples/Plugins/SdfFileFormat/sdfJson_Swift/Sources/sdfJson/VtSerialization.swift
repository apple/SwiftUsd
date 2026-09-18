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
import OpenUSD

/// Represents a VtValue along with some type information,
/// such as a role or non-value type name, or an empty VtValue
/// that is expected to later be filled in to match a given type
struct TypedValue {
    var value: pxr.VtValue
    var valueTypeName: pxr.SdfValueTypeName
    var otherTypeName: String
    
    init(vtValue: pxr.VtValue) {
        self.value = vtValue
        self.valueTypeName = pxr.SdfGetValueTypeNameForValue(vtValue)
        self.otherTypeName = String(vtValue.GetTypeName())
    }
    init(typeName: pxr.SdfValueTypeName) {
        self.value = pxr.VtValue()
        self.valueTypeName = typeName
        self.otherTypeName = ""
    }
    init(otherTypeName: String) {
        self.value = pxr.VtValue()
        self.valueTypeName = pxr.SdfValueTypeName()
        self.otherTypeName = otherTypeName
    }
}

func extractVtDictionary(_ js: JsAny) throws -> pxr.VtDictionary {
    var result = pxr.VtDictionary()
    
    for (k, v) in try js.castAsObject() {
        let x = try extractTypeHintAndValue(v)
        result[std.string(k)] = x.value
    }
    
    return result
}
func writeVtDictionary(_ x: pxr.VtDictionary) throws -> JsAny {
    var result = [String : JsAny]()
    for kvPair in x {
        let v = TypedValue(vtValue: kvPair.second)
        result[String(kvPair.first)] = try writeTypeHintAndValue(v)
    }
    return .object(result)
}

func extractTypeHint(_ js: JsAny) throws -> TypedValue {
    let obj = try js.castAsObject()
    
    let s = try obj["type", errorMessage: "extractTypeHint"].castAsString()
    if false {}
    
    // Taken from `class Sdf_ValueTypeNamesType` in OpenUSD/pxr/usd/sdf/types.h
    else if s == "Bool" { return .init(typeName: .Bool) }
    else if s == "UChar" { return .init(typeName: .UChar) }
    else if s == "Int" { return .init(typeName: .Int) }
    else if s == "UInt" { return .init(typeName: .UInt) }
    else if s == "Int64" { return .init(typeName: .Int64) }
    else if s == "UInt64" { return .init(typeName: .UInt64) }
    else if s == "Half" { return .init(typeName: .Half) }
    else if s == "Float" { return .init(typeName: .Float) }
    else if s == "Double" { return .init(typeName: .Double) }
    else if s == "TimeCode" { return .init(typeName: .TimeCode) }
    else if s == "String" { return .init(typeName: .String) }
    else if s == "Token" { return .init(typeName: .Token) }
    else if s == "Asset" { return .init(typeName: .Asset) }
    else if s == "Int2" { return .init(typeName: .Int2) }
    else if s == "Int3" { return .init(typeName: .Int3) }
    else if s == "Int4" { return .init(typeName: .Int4) }
    else if s == "Half2" { return .init(typeName: .Half2) }
    else if s == "Half3" { return .init(typeName: .Half3) }
    else if s == "Half4" { return .init(typeName: .Half4) }
    else if s == "Float2" { return .init(typeName: .Float2) }
    else if s == "Float3" { return .init(typeName: .Float3) }
    else if s == "Float4" { return .init(typeName: .Float4) }
    else if s == "Double2" { return .init(typeName: .Double2) }
    else if s == "Double3" { return .init(typeName: .Double3) }
    else if s == "Double4" { return .init(typeName: .Double4) }
    else if s == "Point3h" { return .init(typeName: .Point3h) }
    else if s == "Point3f" { return .init(typeName: .Point3f) }
    else if s == "Point3d" { return .init(typeName: .Point3d) }
    else if s == "Vector3h" { return .init(typeName: .Vector3h) }
    else if s == "Vector3f" { return .init(typeName: .Vector3f) }
    else if s == "Vector3d" { return .init(typeName: .Vector3d) }
    else if s == "Normal3h" { return .init(typeName: .Normal3h) }
    else if s == "Normal3f" { return .init(typeName: .Normal3f) }
    else if s == "Normal3d" { return .init(typeName: .Normal3d) }
    else if s == "Color3h" { return .init(typeName: .Color3h) }
    else if s == "Color3f" { return .init(typeName: .Color3f) }
    else if s == "Color3d" { return .init(typeName: .Color3d) }
    else if s == "Color4h" { return .init(typeName: .Color4h) }
    else if s == "Color4f" { return .init(typeName: .Color4f) }
    else if s == "Color4d" { return .init(typeName: .Color4d) }
    else if s == "Quath" { return .init(typeName: .Quath) }
    else if s == "Quatf" { return .init(typeName: .Quatf) }
    else if s == "Quatd" { return .init(typeName: .Quatd) }
    else if s == "Matrix2d" { return .init(typeName: .Matrix2d) }
    else if s == "Matrix3d" { return .init(typeName: .Matrix3d) }
    else if s == "Matrix4d" { return .init(typeName: .Matrix4d) }
    else if s == "Frame4d" { return .init(typeName: .Frame4d) }
    else if s == "TexCoord2h" { return .init(typeName: .TexCoord2h) }
    else if s == "TexCoord2f" { return .init(typeName: .TexCoord2f) }
    else if s == "TexCoord2d" { return .init(typeName: .TexCoord2d) }
    else if s == "TexCoord3h" { return .init(typeName: .TexCoord3h) }
    else if s == "TexCoord3f" { return .init(typeName: .TexCoord3f) }
    else if s == "TexCoord3d" { return .init(typeName: .TexCoord3d) }
    else if s == "Opaque" { return .init(typeName: .Opaque) }
    else if s == "Group" { return .init(typeName: .Group) }
    else if s == "PathExpression" { return .init(typeName: .PathExpression) }
    else if s == "BoolArray" { return .init(typeName: .BoolArray) }
    else if s == "UCharArray" { return .init(typeName: .UCharArray) }
    else if s == "IntArray" { return .init(typeName: .IntArray) }
    else if s == "UIntArray" { return .init(typeName: .UIntArray) }
    else if s == "Int64Array" { return .init(typeName: .Int64Array) }
    else if s == "UInt64Array" { return .init(typeName: .UInt64Array) }
    else if s == "HalfArray" { return .init(typeName: .HalfArray) }
    else if s == "FloatArray" { return .init(typeName: .FloatArray) }
    else if s == "DoubleArray" { return .init(typeName: .DoubleArray) }
    else if s == "TimeCodeArray" { return .init(typeName: .TimeCodeArray) }
    else if s == "StringArray" { return .init(typeName: .StringArray) }
    else if s == "TokenArray" { return .init(typeName: .TokenArray) }
    else if s == "AssetArray" { return .init(typeName: .AssetArray) }
    else if s == "Int2Array" { return .init(typeName: .Int2Array) }
    else if s == "Int3Array" { return .init(typeName: .Int3Array) }
    else if s == "Int4Array" { return .init(typeName: .Int4Array) }
    else if s == "Half2Array" { return .init(typeName: .Half2Array) }
    else if s == "Half3Array" { return .init(typeName: .Half3Array) }
    else if s == "Half4Array" { return .init(typeName: .Half4Array) }
    else if s == "Float2Array" { return .init(typeName: .Float2Array) }
    else if s == "Float3Array" { return .init(typeName: .Float3Array) }
    else if s == "Float4Array" { return .init(typeName: .Float4Array) }
    else if s == "Double2Array" { return .init(typeName: .Double2Array) }
    else if s == "Double3Array" { return .init(typeName: .Double3Array) }
    else if s == "Double4Array" { return .init(typeName: .Double4Array) }
    else if s == "Point3hArray" { return .init(typeName: .Point3hArray) }
    else if s == "Point3fArray" { return .init(typeName: .Point3fArray) }
    else if s == "Point3dArray" { return .init(typeName: .Point3dArray) }
    else if s == "Vector3hArray" { return .init(typeName: .Vector3hArray) }
    else if s == "Vector3fArray" { return .init(typeName: .Vector3fArray) }
    else if s == "Vector3dArray" { return .init(typeName: .Vector3dArray) }
    else if s == "Normal3hArray" { return .init(typeName: .Normal3hArray) }
    else if s == "Normal3fArray" { return .init(typeName: .Normal3fArray) }
    else if s == "Normal3dArray" { return .init(typeName: .Normal3dArray) }
    else if s == "Color3hArray" { return .init(typeName: .Color3hArray) }
    else if s == "Color3fArray" { return .init(typeName: .Color3fArray) }
    else if s == "Color3dArray" { return .init(typeName: .Color3dArray) }
    else if s == "Color4hArray" { return .init(typeName: .Color4hArray) }
    else if s == "Color4fArray" { return .init(typeName: .Color4fArray) }
    else if s == "Color4dArray" { return .init(typeName: .Color4dArray) }
    else if s == "QuathArray" { return .init(typeName: .QuathArray) }
    else if s == "QuatfArray" { return .init(typeName: .QuatfArray) }
    else if s == "QuatdArray" { return .init(typeName: .QuatdArray) }
    else if s == "Matrix2dArray" { return .init(typeName: .Matrix2dArray) }
    else if s == "Matrix3dArray" { return .init(typeName: .Matrix3dArray) }
    else if s == "Matrix4dArray" { return .init(typeName: .Matrix4dArray) }
    else if s == "Frame4dArray" { return .init(typeName: .Frame4dArray) }
    else if s == "TexCoord2hArray" { return .init(typeName: .TexCoord2hArray) }
    else if s == "TexCoord2fArray" { return .init(typeName: .TexCoord2fArray) }
    else if s == "TexCoord2dArray" { return .init(typeName: .TexCoord2dArray) }
    else if s == "TexCoord3hArray" { return .init(typeName: .TexCoord3hArray) }
    else if s == "TexCoord3fArray" { return .init(typeName: .TexCoord3fArray) }
    else if s == "TexCoord3dArray" { return .init(typeName: .TexCoord3dArray) }
    else if s == "PathExpressionArray" { return .init(typeName: .PathExpressionArray) }
    
    // Edge cases not from OpenUSD/pxr/usd/sdf/types.h
    else if s == "SdfListOp<TfToken>" { return .init(otherTypeName: s) }
    else if s == "SdfListOp<long long>" { return .init(otherTypeName: s) }
    else if s == "SdfListOp<string>" { return .init(otherTypeName: s) }
    else if s == "VtDictionary" { return .init(otherTypeName: s) }
    else if s == "SdfUnregisteredValue" { return .init(otherTypeName: s) }
    else if s == "PointIndex" || s == "PointIndex[]" { return .init(otherTypeName: s) }
    else if s == "SdfPermission" { return .init(otherTypeName: s) }
    else if s == "SdfPath" { return .init(otherTypeName: s) }
    else if !s.isEmpty {
        // Important: Lots of code depends on extractTypeHint, and the vast majority of it
        // doesn't know how to handle unknown type hints. Emit an error that could be caught
        // by TfErrorMark and return a valid TypedValue, so that sophisticated callers can
        // handle this case if they want, while simpler callers can simply error out

        TF_RUNTIME_ERROR(std.string("Deserializing unknown type hint '\(s)'"))
        return .init(otherTypeName: s)
    } else {
        throw JsDecodingError.typeHintWasEmpty
    }
}
func writeTypeHint(_ value: TypedValue) -> JsAny {
    if false {}
    
    else if value.valueTypeName == .Bool { return "Bool" }
    else if value.valueTypeName == .UChar { return "UChar" }
    else if value.valueTypeName == .Int { return "Int" }
    else if value.valueTypeName == .UInt { return "UInt" }
    else if value.valueTypeName == .Int64 { return "Int64" }
    else if value.valueTypeName == .UInt64 { return "UInt64" }
    else if value.valueTypeName == .Half { return "Half" }
    else if value.valueTypeName == .Float { return "Float" }
    else if value.valueTypeName == .Double { return "Double" }
    else if value.valueTypeName == .TimeCode { return "TimeCode" }
    else if value.valueTypeName == .String { return "String" }
    else if value.valueTypeName == .Token { return "Token" }
    else if value.valueTypeName == .Asset { return "Asset" }
    else if value.valueTypeName == .Int2 { return "Int2" }
    else if value.valueTypeName == .Int3 { return "Int3" }
    else if value.valueTypeName == .Int4 { return "Int4" }
    else if value.valueTypeName == .Half2 { return "Half2" }
    else if value.valueTypeName == .Half3 { return "Half3" }
    else if value.valueTypeName == .Half4 { return "Half4" }
    else if value.valueTypeName == .Float2 { return "Float2" }
    else if value.valueTypeName == .Float3 { return "Float3" }
    else if value.valueTypeName == .Float4 { return "Float4" }
    else if value.valueTypeName == .Double2 { return "Double2" }
    else if value.valueTypeName == .Double3 { return "Double3" }
    else if value.valueTypeName == .Double4 { return "Double4" }
    else if value.valueTypeName == .Point3h { return "Point3h" }
    else if value.valueTypeName == .Point3f { return "Point3f" }
    else if value.valueTypeName == .Point3d { return "Point3d" }
    else if value.valueTypeName == .Vector3h { return "Vector3h" }
    else if value.valueTypeName == .Vector3f { return "Vector3f" }
    else if value.valueTypeName == .Vector3d { return "Vector3d" }
    else if value.valueTypeName == .Normal3h { return "Normal3h" }
    else if value.valueTypeName == .Normal3f { return "Normal3f" }
    else if value.valueTypeName == .Normal3d { return "Normal3d" }
    else if value.valueTypeName == .Color3h { return "Color3h" }
    else if value.valueTypeName == .Color3f { return "Color3f" }
    else if value.valueTypeName == .Color3d { return "Color3d" }
    else if value.valueTypeName == .Color4h { return "Color4h" }
    else if value.valueTypeName == .Color4f { return "Color4f" }
    else if value.valueTypeName == .Color4d { return "Color4d" }
    else if value.valueTypeName == .Quath { return "Quath" }
    else if value.valueTypeName == .Quatf { return "Quatf" }
    else if value.valueTypeName == .Quatd { return "Quatd" }
    else if value.valueTypeName == .Matrix2d { return "Matrix2d" }
    else if value.valueTypeName == .Matrix3d { return "Matrix3d" }
    else if value.valueTypeName == .Matrix4d { return "Matrix4d" }
    else if value.valueTypeName == .Frame4d { return "Frame4d" }
    else if value.valueTypeName == .TexCoord2h { return "TexCoord2h" }
    else if value.valueTypeName == .TexCoord2f { return "TexCoord2f" }
    else if value.valueTypeName == .TexCoord2d { return "TexCoord2d" }
    else if value.valueTypeName == .TexCoord3h { return "TexCoord3h" }
    else if value.valueTypeName == .TexCoord3f { return "TexCoord3f" }
    else if value.valueTypeName == .TexCoord3d { return "TexCoord3d" }
    else if value.valueTypeName == .Opaque { return "Opaque" }
    else if value.valueTypeName == .Group { return "Group" }
    else if value.valueTypeName == .PathExpression { return "PathExpression" }
    else if value.valueTypeName == .BoolArray { return "BoolArray" }
    else if value.valueTypeName == .UCharArray { return "UCharArray" }
    else if value.valueTypeName == .IntArray { return "IntArray" }
    else if value.valueTypeName == .UIntArray { return "UIntArray" }
    else if value.valueTypeName == .Int64Array { return "Int64Array" }
    else if value.valueTypeName == .UInt64Array { return "UInt64Array" }
    else if value.valueTypeName == .HalfArray { return "HalfArray" }
    else if value.valueTypeName == .FloatArray { return "FloatArray" }
    else if value.valueTypeName == .DoubleArray { return "DoubleArray" }
    else if value.valueTypeName == .TimeCodeArray { return "TimeCodeArray" }
    else if value.valueTypeName == .StringArray { return "StringArray" }
    else if value.valueTypeName == .TokenArray { return "TokenArray" }
    else if value.valueTypeName == .AssetArray { return "AssetArray" }
    else if value.valueTypeName == .Int2Array { return "Int2Array" }
    else if value.valueTypeName == .Int3Array { return "Int3Array" }
    else if value.valueTypeName == .Int4Array { return "Int4Array" }
    else if value.valueTypeName == .Half2Array { return "Half2Array" }
    else if value.valueTypeName == .Half3Array { return "Half3Array" }
    else if value.valueTypeName == .Half4Array { return "Half4Array" }
    else if value.valueTypeName == .Float2Array { return "Float2Array" }
    else if value.valueTypeName == .Float3Array { return "Float3Array" }
    else if value.valueTypeName == .Float4Array { return "Float4Array" }
    else if value.valueTypeName == .Double2Array { return "Double2Array" }
    else if value.valueTypeName == .Double3Array { return "Double3Array" }
    else if value.valueTypeName == .Double4Array { return "Double4Array" }
    else if value.valueTypeName == .Point3hArray { return "Point3hArray" }
    else if value.valueTypeName == .Point3fArray { return "Point3fArray" }
    else if value.valueTypeName == .Point3dArray { return "Point3dArray" }
    else if value.valueTypeName == .Vector3hArray { return "Vector3hArray" }
    else if value.valueTypeName == .Vector3fArray { return "Vector3fArray" }
    else if value.valueTypeName == .Vector3dArray { return "Vector3dArray" }
    else if value.valueTypeName == .Normal3hArray { return "Normal3hArray" }
    else if value.valueTypeName == .Normal3fArray { return "Normal3fArray" }
    else if value.valueTypeName == .Normal3dArray { return "Normal3dArray" }
    else if value.valueTypeName == .Color3hArray { return "Color3hArray" }
    else if value.valueTypeName == .Color3fArray { return "Color3fArray" }
    else if value.valueTypeName == .Color3dArray { return "Color3dArray" }
    else if value.valueTypeName == .Color4hArray { return "Color4hArray" }
    else if value.valueTypeName == .Color4fArray { return "Color4fArray" }
    else if value.valueTypeName == .Color4dArray { return "Color4dArray" }
    else if value.valueTypeName == .QuathArray { return "QuathArray" }
    else if value.valueTypeName == .QuatfArray { return "QuatfArray" }
    else if value.valueTypeName == .QuatdArray { return "QuatdArray" }
    else if value.valueTypeName == .Matrix2dArray { return "Matrix2dArray" }
    else if value.valueTypeName == .Matrix3dArray { return "Matrix3dArray" }
    else if value.valueTypeName == .Matrix4dArray { return "Matrix4dArray" }
    else if value.valueTypeName == .Frame4dArray { return "Frame4dArray" }
    else if value.valueTypeName == .TexCoord2hArray { return "TexCoord2hArray" }
    else if value.valueTypeName == .TexCoord2fArray { return "TexCoord2fArray" }
    else if value.valueTypeName == .TexCoord2dArray { return "TexCoord2dArray" }
    else if value.valueTypeName == .TexCoord3hArray { return "TexCoord3hArray" }
    else if value.valueTypeName == .TexCoord3fArray { return "TexCoord3fArray" }
    else if value.valueTypeName == .TexCoord3dArray { return "TexCoord3dArray" }
    else if value.valueTypeName == .PathExpressionArray { return "PathExpressionArray" }
    
    else if value.valueTypeName.GetAsToken() == .SdfValueRoleNames.PointIndex {
        return .string(String(pxr.TfToken.SdfValueRoleNames.PointIndex))
    } else if value.valueTypeName.GetScalarType().GetAsToken() == .SdfValueRoleNames.PointIndex {
        return .string(String(pxr.TfToken.SdfValueRoleNames.PointIndex) + "[]")
    } else if value.otherTypeName.isEmpty && !value.valueTypeName.GetAsToken().IsEmpty() {
        // Important: Some type names may be invalid but should still round-trip.
        // See extent-wrong-type-name.usda
        return .string(String(value.valueTypeName.GetAsToken()))
    } else {
        return .string(String(value.otherTypeName))
    }
}

func _extractArray<T: _VtArrayExtractionWritingProtocol>(_ out: inout TypedValue, _ js: JsAny, _ t: T.Type) throws {
    var decoded = T.init()
    for x in try js.castAsArray() {
        var temp = TypedValue(typeName: out.valueTypeName.GetScalarType())
        try extractValueWithTypeHint(&temp, x)
        decoded.push_back(T.scalarFromVtValue(temp.value))
    }
    out.value = decoded.asVtValue
}

/// Expects the type hint to be provided. See also extractTypeHintAndValue
func extractValueWithTypeHint(_ out: inout TypedValue, _ js: JsAny) throws {
    if js.isNull {
        out.value = pxr.VtValue(pxr.SdfValueBlock())
        return
    }
    
    // Speculatively try to decode SdfUnregisteredValue
    if let x = try? extractSdfUnregisteredValue(js) {
        out.value = pxr.VtValue(x)
        return
    }
    
    // Speculatively try to decode SdfAnimationBlock
    if let x = try? extractSdfAnimationBlock(js) {
        out.value = pxr.VtValue(x)
        return
    }
    
    if out.valueTypeName == .Bool {
        let x = try js.castAsBool()
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .UChar {
        let x = try js.castAsInt()
        out.value = pxr.VtValue(UInt8(x))
    } else if out.valueTypeName == .Int {
        let x = try js.castAsInt()
        out.value = pxr.VtValue(Int32(x))
    } else if out.valueTypeName == .UInt {
        let x = try js.castAsInt()
        out.value = pxr.VtValue(UInt32(x))
    } else if out.valueTypeName == .Int64 {
        let x = try js.castAsInt()
        out.value = pxr.VtValue(Int64(x))
    } else if out.valueTypeName == .UInt64 {
        let x = try js.castAsInt()
        out.value = pxr.VtValue(UInt64(x))
    } else if out.valueTypeName == .Half {
        let x = try js.castAsNumber()
        out.value = pxr.VtValue(pxr.GfHalf(x))
    } else if out.valueTypeName == .Float {
        let x = try js.castAsNumber()
        out.value = pxr.VtValue(Float(x))
    } else if out.valueTypeName == .Double {
        let x = try js.castAsNumber()
        out.value = pxr.VtValue(Double(x))
    } else if out.valueTypeName == .TimeCode {
        let x = try js.castAsNumber()
        out.value = pxr.VtValue(pxr.GfTimeCode(x))
    } else if out.valueTypeName == .String {
        let x = try js.castAsString()
        out.value = pxr.VtValue(std.string(x))
    } else if out.valueTypeName == .Token {
        let x = try js.castAsString()
        out.value = pxr.VtValue(pxr.TfToken(x))
    } else if out.valueTypeName == .Asset {
        let x = try js.castAsString()
        out.value = pxr.VtValue(pxr.SdfAssetPath(x))
        
    } else if out.valueTypeName == .Int2 {
        var x = pxr.GfVec2i()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Int32(try arr[0].castAsInt())
        x[1] = Int32(try arr[1].castAsInt())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Int3 {
        var x = pxr.GfVec3i()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Int32(try arr[0].castAsInt())
        x[1] = Int32(try arr[1].castAsInt())
        x[2] = Int32(try arr[2].castAsInt())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Int4 {
        var x = pxr.GfVec4i()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Int32(try arr[0].castAsInt())
        x[1] = Int32(try arr[1].castAsInt())
        x[2] = Int32(try arr[2].castAsInt())
        x[3] = Int32(try arr[3].castAsInt())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Half2 {
        var x = pxr.GfVec2h()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Half3 {
        var x = pxr.GfVec3h()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Half4 {
        var x = pxr.GfVec4h()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        x[3] = pxr.GfHalf(try arr[3].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Float2 {
        var x = pxr.GfVec2f()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Float3 {
        var x = pxr.GfVec3f()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Float4 {
        var x = pxr.GfVec4f()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        x[3] = Float(try arr[3].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Double2 {
        var x = pxr.GfVec2d()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Double3 {
        var x = pxr.GfVec3d()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Double4 {
        var x = pxr.GfVec4d()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        x[3] = Double(try arr[3].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Point3h {
        var x = pxr.GfVec3h()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Point3f {
        var x = pxr.GfVec3f()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Point3d {
        var x = pxr.GfVec3d()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Vector3h {
        var x = pxr.GfVec3h()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Vector3f {
        var x = pxr.GfVec3f()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Vector3d {
        var x = pxr.GfVec3d()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Normal3h {
        var x = pxr.GfVec3h()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Normal3f {
        var x = pxr.GfVec3f()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Normal3d {
        var x = pxr.GfVec3d()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Color3h {
        var x = pxr.GfVec3h()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Color3f {
        var x = pxr.GfVec3f()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Color3d {
        var x = pxr.GfVec3d()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Color4h {
        var x = pxr.GfVec4h()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        x[3] = pxr.GfHalf(try arr[3].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Color4f {
        var x = pxr.GfVec4f()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        x[3] = Float(try arr[3].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Color4d {
        var x = pxr.GfVec4d()
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        x[3] = Double(try arr[3].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .Quath {
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        let x = pxr.GfQuath(
            pxr.GfHalf(try arr[0].castAsNumber()),
            pxr.GfHalf(try arr[1].castAsNumber()),
            pxr.GfHalf(try arr[2].castAsNumber()),
            pxr.GfHalf(try arr[3].castAsNumber()),
        )
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Quatf {
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        let x = pxr.GfQuatf(
            Float(try arr[0].castAsNumber()),
            Float(try arr[1].castAsNumber()),
            Float(try arr[2].castAsNumber()),
            Float(try arr[3].castAsNumber()),
        )
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .Quatd {
        let arr = try js.castAsArray()
        guard arr.count == 4 else { throw JsDecodingError.mismatchedVecLength }
        let x = pxr.GfQuatd(
            Double(try arr[0].castAsNumber()),
            Double(try arr[1].castAsNumber()),
            Double(try arr[2].castAsNumber()),
            Double(try arr[3].castAsNumber()),
        )
        out.value = pxr.VtValue(x)
    }
    
    else if (out.valueTypeName == .Matrix2d) {
        var x = pxr.GfMatrix2d()
        let arr = try js.castAsArray()
        let (numRows, numColumns) = (2, 2)
        guard arr.count == numRows * numColumns else { throw JsDecodingError.mismatchedMatLength }
        for i in 0..<arr.count {
            x[i / numRows][i % numRows] = try arr[i].castAsNumber()
        }
        out.value = pxr.VtValue(x)
    } else if (out.valueTypeName == .Matrix3d) {
        var x = pxr.GfMatrix3d()
        let arr = try js.castAsArray()
        let (numRows, numColumns) = (3, 3)
        guard arr.count == numRows * numColumns else { throw JsDecodingError.mismatchedMatLength }
        for i in 0..<arr.count {
            x[i / numRows][i % numRows] = try arr[i].castAsNumber()
        }
        out.value = pxr.VtValue(x)
    } else if (out.valueTypeName == .Matrix4d) {
        var x = pxr.GfMatrix4d()
        let arr = try js.castAsArray()
        let (numRows, numColumns) = (4, 4)
        guard arr.count == numRows * numColumns else { throw JsDecodingError.mismatchedMatLength }
        for i in 0..<arr.count {
            x[i / numRows][i % numRows] = try arr[i].castAsNumber()
        }
        out.value = pxr.VtValue(x)
    }
    
    else if (out.valueTypeName == .Frame4d) {
        var x = pxr.GfMatrix4d()
        let arr = try js.castAsArray()
        let (numRows, numColumns) = (4, 4)
        guard arr.count == numRows * numColumns else { throw JsDecodingError.mismatchedMatLength }
        for i in 0..<arr.count {
            x[i / numRows][i % numRows] = try arr[i].castAsNumber()
        }
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .TexCoord2h {
        var x = pxr.GfVec2h()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .TexCoord2f {
        var x = pxr.GfVec2f()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .TexCoord2d {
        var x = pxr.GfVec2d()
        let arr = try js.castAsArray()
        guard arr.count == 2 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        out.value = pxr.VtValue(x)
    }
    
    else if out.valueTypeName == .TexCoord3h {
        var x = pxr.GfVec3h()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = pxr.GfHalf(try arr[0].castAsNumber())
        x[1] = pxr.GfHalf(try arr[1].castAsNumber())
        x[2] = pxr.GfHalf(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .TexCoord3f {
        var x = pxr.GfVec3f()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Float(try arr[0].castAsNumber())
        x[1] = Float(try arr[1].castAsNumber())
        x[2] = Float(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    } else if out.valueTypeName == .TexCoord3d {
        var x = pxr.GfVec3d()
        let arr = try js.castAsArray()
        guard arr.count == 3 else { throw JsDecodingError.mismatchedVecLength }
        x[0] = Double(try arr[0].castAsNumber())
        x[1] = Double(try arr[1].castAsNumber())
        x[2] = Double(try arr[2].castAsNumber())
        out.value = pxr.VtValue(x)
    }

    else if out.valueTypeName == .Opaque {
        throw JsDecodingError.decodingTypeFailure("Opaque")
    } else if out.valueTypeName == .Group {
        throw JsDecodingError.decodingTypeFailure("Group")
    } else if out.valueTypeName == .PathExpression {
        let x = try js.castAsString()
        out.value = pxr.VtValue(pxr.SdfPathExpression(std.string(x), ""))
    }
    
    else if out.valueTypeName == .BoolArray {
        try _extractArray(&out, js, pxr.VtBoolArray.self)
    } else if out.valueTypeName == .UCharArray {
        try _extractArray(&out, js, pxr.VtUCharArray.self)
    } else if out.valueTypeName == .IntArray {
        try _extractArray(&out, js, pxr.VtIntArray.self)
    } else if out.valueTypeName == .UIntArray {
        try _extractArray(&out, js, pxr.VtUIntArray.self)
    } else if out.valueTypeName == .Int64Array {
        try _extractArray(&out, js, pxr.VtInt64Array.self)
    } else if out.valueTypeName == .UInt64Array {
        try _extractArray(&out, js, pxr.VtUInt64Array.self)
    } else if out.valueTypeName == .HalfArray {
        try _extractArray(&out, js, pxr.VtHalfArray.self)
    } else if out.valueTypeName == .FloatArray {
        try _extractArray(&out, js, pxr.VtFloatArray.self)
    } else if out.valueTypeName == .DoubleArray {
        try _extractArray(&out, js, pxr.VtDoubleArray.self)
    } else if out.valueTypeName == .TimeCodeArray {
        try _extractArray(&out, js, pxr.VtTimeCodeArray.self)
    } else if out.valueTypeName == .StringArray {
        try _extractArray(&out, js, pxr.VtStringArray.self)
    } else if out.valueTypeName == .TokenArray {
        try _extractArray(&out, js, pxr.VtTokenArray.self)
    } else if out.valueTypeName == .AssetArray {
        try _extractArray(&out, js, Overlay.SdfAssetPath_VtArray.self)
    } else if out.valueTypeName == .Int2Array {
        try _extractArray(&out, js, pxr.VtVec2iArray.self)
    } else if out.valueTypeName == .Int3Array {
        try _extractArray(&out, js, pxr.VtVec3iArray.self)
    } else if out.valueTypeName == .Int4Array {
        try _extractArray(&out, js, pxr.VtVec4iArray.self)
    } else if out.valueTypeName == .Half2Array {
        try _extractArray(&out, js, pxr.VtVec2hArray.self)
    } else if out.valueTypeName == .Half3Array {
        try _extractArray(&out, js, pxr.VtVec3hArray.self)
    } else if out.valueTypeName == .Half4Array {
        try _extractArray(&out, js, pxr.VtVec4hArray.self)
    } else if out.valueTypeName == .Float2Array {
        try _extractArray(&out, js, pxr.VtVec2fArray.self)
    } else if out.valueTypeName == .Float3Array {
        try _extractArray(&out, js, pxr.VtVec3fArray.self)
    } else if out.valueTypeName == .Float4Array {
        try _extractArray(&out, js, pxr.VtVec4fArray.self)
    } else if out.valueTypeName == .Double2Array {
        try _extractArray(&out, js, pxr.VtVec2dArray.self)
    } else if out.valueTypeName == .Double3Array {
        try _extractArray(&out, js, pxr.VtVec3dArray.self)
    } else if out.valueTypeName == .Double4Array {
        try _extractArray(&out, js, pxr.VtVec4dArray.self)
    } else if out.valueTypeName == .Point3hArray {
        try _extractArray(&out, js, pxr.VtVec3hArray.self)
    } else if out.valueTypeName == .Point3fArray {
        try _extractArray(&out, js, pxr.VtVec3fArray.self)
    } else if out.valueTypeName == .Point3dArray {
        try _extractArray(&out, js, pxr.VtVec3dArray.self)
    } else if out.valueTypeName == .Vector3hArray {
        try _extractArray(&out, js, pxr.VtVec3hArray.self)
    } else if out.valueTypeName == .Vector3fArray {
        try _extractArray(&out, js, pxr.VtVec3fArray.self)
    } else if out.valueTypeName == .Vector3dArray {
        try _extractArray(&out, js, pxr.VtVec3dArray.self)
    } else if out.valueTypeName == .Normal3hArray {
        try _extractArray(&out, js, pxr.VtVec3hArray.self)
    } else if out.valueTypeName == .Normal3fArray {
        try _extractArray(&out, js, pxr.VtVec3fArray.self)
    } else if out.valueTypeName == .Normal3dArray {
        try _extractArray(&out, js, pxr.VtVec3dArray.self)
    } else if out.valueTypeName == .Color3hArray {
        try _extractArray(&out, js, pxr.VtVec3hArray.self)
    } else if out.valueTypeName == .Color3fArray {
        try _extractArray(&out, js, pxr.VtVec3fArray.self)
    } else if out.valueTypeName == .Color3dArray {
        try _extractArray(&out, js, pxr.VtVec3dArray.self)
    } else if out.valueTypeName == .Color4hArray {
        try _extractArray(&out, js, pxr.VtVec4hArray.self)
    } else if out.valueTypeName == .Color4fArray {
        try _extractArray(&out, js, pxr.VtVec4fArray.self)
    } else if out.valueTypeName == .Color4dArray {
        try _extractArray(&out, js, pxr.VtVec4dArray.self)
    } else if out.valueTypeName == .QuathArray {
        try _extractArray(&out, js, pxr.VtQuathArray.self)
    } else if out.valueTypeName == .QuatfArray {
        try _extractArray(&out, js, pxr.VtQuatfArray.self)
    } else if out.valueTypeName == .QuatdArray {
        try _extractArray(&out, js, pxr.VtQuatdArray.self)
    } else if out.valueTypeName == .Matrix2dArray {
        try _extractArray(&out, js, pxr.VtMatrix2dArray.self)
    } else if out.valueTypeName == .Matrix3dArray {
        try _extractArray(&out, js, pxr.VtMatrix3dArray.self)
    } else if out.valueTypeName == .Matrix4dArray {
        try _extractArray(&out, js, pxr.VtMatrix4dArray.self)
    } else if out.valueTypeName == .Frame4dArray {
        try _extractArray(&out, js, pxr.VtMatrix4dArray.self)
    } else if out.valueTypeName == .TexCoord2hArray {
        try _extractArray(&out, js, pxr.VtVec2hArray.self)
    } else if out.valueTypeName == .TexCoord2fArray {
        try _extractArray(&out, js, pxr.VtVec2fArray.self)
    } else if out.valueTypeName == .TexCoord2dArray {
        try _extractArray(&out, js, pxr.VtVec2dArray.self)
    } else if out.valueTypeName == .TexCoord3hArray {
        try _extractArray(&out, js, pxr.VtVec3hArray.self)
    } else if out.valueTypeName == .TexCoord3fArray {
        try _extractArray(&out, js, pxr.VtVec3fArray.self)
    } else if out.valueTypeName == .TexCoord3dArray {
        try _extractArray(&out, js, pxr.VtVec3dArray.self)
    } else if out.valueTypeName == .PathExpressionArray {
        try _extractArray(&out, js, Overlay.SdfPathExpression_VtArray.self)
    }
    
    else if false { #warning("todo: 6 listops")
    }
    else if out.otherTypeName == "SdfListOp<TfToken>" {
        let x: pxr.SdfTokenListOp = try extractSdfListOp(pxr.SdfTokenListOp.self, js, extractTfToken)
        out.value = pxr.VtValue(x)
    } else if out.otherTypeName == "SdfListOp<long long>" {
        let x: pxr.SdfInt64ListOp = try extractSdfListOp(pxr.SdfInt64ListOp.self, js, extractLongLong)
        out.value = pxr.VtValue(x)
    } else if out.otherTypeName == "SdfListOp<string>" {
        let x: pxr.SdfStringListOp = try extractSdfListOp(pxr.SdfStringListOp.self, js, extractString)
        out.value = pxr.VtValue(x)
    } else if out.otherTypeName == "VtDictionary" {
        out.value = try pxr.VtValue(extractVtDictionary(js))
    } else if out.otherTypeName == "SdfUnregisteredValue" {
        out.value = try pxr.VtValue(extractSdfUnregisteredValue(js))
    } else if out.otherTypeName == "PointIndex" {
        var temp = TypedValue(typeName: .Int)
        try extractValueWithTypeHint(&temp, js)
        out.value = temp.value
    } else if out.otherTypeName == "PointIndex[]" {
        var temp = TypedValue(typeName: .IntArray)
        try extractValueWithTypeHint(&temp, js)
        out.value = temp.value
    } else if out.otherTypeName == "SdfPermission" {
        var temp = TypedValue(typeName: .Int)
        try extractValueWithTypeHint(&temp, js)
        var copy = temp.value
        let x = copy.Get() as Int32
        out.value = pxr.VtValue(pxr.SdfPermission(rawValue: UInt32(x)))
    } else if out.otherTypeName == "Transform" {
        var temp = TypedValue(typeName: .Matrix4d)
        try extractValueWithTypeHint(&temp, js)
        out.value = temp.value
    } else {
        throw JsDecodingError.unknownTypeName(out.valueTypeName.GetAsToken(), out.otherTypeName)
    }
}

func _writeArray<T: _VtArrayExtractionWritingProtocol>(_ arr: T, _ value: TypedValue) throws -> JsAny {
    var result = [JsAny]()
    for x in arr {
        var temp = TypedValue(vtValue: T.scalarAsVtValue(x))
        temp.valueTypeName = value.valueTypeName.GetScalarType()
        try result.append(writeValueWithoutTypeHint(temp))
    }
    return .array(result)
}


func writeValueWithoutTypeHint(_ value: TypedValue) throws -> JsAny {
    // Important: Use value.value.IsHolding instead of comparing to value.valueTypeName because
    // of e.g. mismatched-types.usda
    var copy = value.value
    
    if copy.IsHolding(T: pxr.SdfValueBlock.self) {
        return .null
    }
    
    if copy.IsHolding(T: Bool.self) {
        return .bool(copy.Get() as Bool)
    } else if copy.IsHolding(T: UInt8.self) {
        return .int(Int(copy.Get() as UInt8))
    } else if copy.IsHolding(T: Int32.self) {
        return .int(Int(copy.Get() as Int32))
    } else if copy.IsHolding(T: UInt32.self) {
        return .int(Int(copy.Get() as UInt32))
    } else if copy.IsHolding(T: Int64.self) {
        return .int(Int(copy.Get() as Int64))
    } else if copy.IsHolding(T: UInt64.self) {
        return .int(Int(copy.Get() as UInt64))
    } else if copy.IsHolding(T: pxr.GfHalf.self) {
        return .number(Double(copy.Get() as pxr.GfHalf))
    } else if copy.IsHolding(T: Float.self) {
        return .number(Double(copy.Get() as Float))
    } else if copy.IsHolding(T: Double.self) {
        return .number(Double(copy.Get() as Double))
    } else if copy.IsHolding(T: pxr.GfTimeCode.self) {
        return .number(Double(copy.Get() as pxr.GfTimeCode))
    } else if copy.IsHolding(T: std.string.self) {
         return .string(String(copy.Get() as std.string))
    } else if copy.IsHolding(T: pxr.TfToken.self) {
        return .string(String(copy.Get() as pxr.TfToken))
    } else if copy.IsHolding(T: pxr.SdfAssetPath.self) {
        return .string(String((copy.Get() as pxr.SdfAssetPath).GetAuthoredPath()))
    } else if copy.IsHolding(T: pxr.GfVec2i.self) {
        let x = copy.Get() as pxr.GfVec2i
        return [
            .int(Int(x[0])),
            .int(Int(x[1]))
        ]
    } else if copy.IsHolding(T: pxr.GfVec3i.self) {
        let x = copy.Get() as pxr.GfVec3i
        return [
            .int(Int(x[0])),
            .int(Int(x[1])),
            .int(Int(x[2])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec4i.self) {
        let x = copy.Get() as pxr.GfVec4i
        return [
            .int(Int(x[0])),
            .int(Int(x[1])),
            .int(Int(x[2])),
            .int(Int(x[3])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec2h.self) {
        let x = copy.Get() as pxr.GfVec2h
        return [
            .number(Double(x[0])),
            .number(Double(x[1]))
        ]
    } else if copy.IsHolding(T: pxr.GfVec3h.self) {
        let x = copy.Get() as pxr.GfVec3h
        return [
            .number(Double(x[0])),
            .number(Double(x[1])),
            .number(Double(x[2])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec4h.self) {
        let x = copy.Get() as pxr.GfVec4h
        return [
            .number(Double(x[0])),
            .number(Double(x[1])),
            .number(Double(x[2])),
            .number(Double(x[3])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec2f.self) {
        let x = copy.Get() as pxr.GfVec2f
        return [
            .number(Double(x[0])),
            .number(Double(x[1]))
        ]
    } else if copy.IsHolding(T: pxr.GfVec3f.self) {
        let x = copy.Get() as pxr.GfVec3f
        return [
            .number(Double(x[0])),
            .number(Double(x[1])),
            .number(Double(x[2])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec4f.self) {
        let x = copy.Get() as pxr.GfVec4f
        return [
            .number(Double(x[0])),
            .number(Double(x[1])),
            .number(Double(x[2])),
            .number(Double(x[3])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec2d.self) {
        let x = copy.Get() as pxr.GfVec2d
        return [
            .number(Double(x[0])),
            .number(Double(x[1]))
        ]
    } else if copy.IsHolding(T: pxr.GfVec3d.self) {
        let x = copy.Get() as pxr.GfVec3d
        return [
            .number(Double(x[0])),
            .number(Double(x[1])),
            .number(Double(x[2])),
        ]
    } else if copy.IsHolding(T: pxr.GfVec4d.self) {
        let x = copy.Get() as pxr.GfVec4d
        return [
            .number(Double(x[0])),
            .number(Double(x[1])),
            .number(Double(x[2])),
            .number(Double(x[3])),
        ]
    } else if copy.IsHolding(T: pxr.GfQuath.self) {
        let x = copy.Get() as pxr.GfQuath
        return [
            .number(Double(x.GetReal())),
            .number(Double(x.GetImaginary()[0])),
            .number(Double(x.GetImaginary()[1])),
            .number(Double(x.GetImaginary()[2]))
        ]
    } else if copy.IsHolding(T: pxr.GfQuatf.self) {
        let x = copy.Get() as pxr.GfQuatf
        return [
            .number(Double(x.GetReal())),
            .number(Double(x.GetImaginary()[0])),
            .number(Double(x.GetImaginary()[1])),
            .number(Double(x.GetImaginary()[2]))
        ]
    } else if copy.IsHolding(T: pxr.GfQuatd.self) {
        let x = copy.Get() as pxr.GfQuatd
        return [
            .number(Double(x.GetReal())),
            .number(Double(x.GetImaginary()[0])),
            .number(Double(x.GetImaginary()[1])),
            .number(Double(x.GetImaginary()[2]))
        ]
    } else if copy.IsHolding(T: pxr.GfMatrix2d.self) {
        let x = copy.Get() as pxr.GfMatrix2d
        return [
            .number(x[0][0]),
            .number(x[0][1]),
            .number(x[1][0]),
            .number(x[1][1]),
        ]
    } else if copy.IsHolding(T: pxr.GfMatrix3d.self) {
        let x = copy.Get() as pxr.GfMatrix3d
        return [
            .number(x[0][0]),
            .number(x[0][1]),
            .number(x[0][2]),
            .number(x[1][0]),
            .number(x[1][1]),
            .number(x[1][2]),
            .number(x[2][0]),
            .number(x[2][1]),
            .number(x[2][2]),
        ]
    } else if copy.IsHolding(T: pxr.GfMatrix4d.self) {
        let x = copy.Get() as pxr.GfMatrix4d
        return [
            .number(x[0][0]),
            .number(x[0][1]),
            .number(x[0][2]),
            .number(x[0][3]),
            .number(x[1][0]),
            .number(x[1][1]),
            .number(x[1][2]),
            .number(x[1][3]),
            .number(x[2][0]),
            .number(x[2][1]),
            .number(x[2][2]),
            .number(x[2][3]),
            .number(x[3][0]),
            .number(x[3][1]),
            .number(x[3][2]),
            .number(x[3][3]),
        ]
    } else if copy.IsHolding(T: pxr.SdfOpaqueValue.self) {
        return .null
    } else if copy.IsHolding(T: pxr.SdfPathExpression.self) {
        return .string(String((copy.Get() as pxr.SdfPathExpression).GetText()))
    }
    
    else if (copy.IsHolding(T: pxr.VtBoolArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtBoolArray, value)
    } else if (copy.IsHolding(T: pxr.VtUCharArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtUCharArray, value)
    } else if (copy.IsHolding(T: pxr.VtIntArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtIntArray, value)
    } else if (copy.IsHolding(T: pxr.VtUIntArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtUIntArray, value)
    } else if (copy.IsHolding(T: pxr.VtInt64Array.self)) {
        return try _writeArray(copy.Get() as pxr.VtInt64Array, value)
    } else if (copy.IsHolding(T: pxr.VtUInt64Array.self)) {
        return try _writeArray(copy.Get() as pxr.VtUInt64Array, value)
    } else if (copy.IsHolding(T: pxr.VtHalfArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtHalfArray, value)
    } else if (copy.IsHolding(T: pxr.VtFloatArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtFloatArray, value)
    } else if (copy.IsHolding(T: pxr.VtDoubleArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtDoubleArray, value)
    } else if (copy.IsHolding(T: pxr.VtTimeCodeArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtTimeCodeArray, value)
    } else if (copy.IsHolding(T: pxr.VtStringArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtStringArray, value)
    } else if (copy.IsHolding(T: pxr.VtTokenArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtTokenArray, value)
    } else if (copy.IsHolding(T: Overlay.SdfAssetPath_VtArray.self)) {
        return try _writeArray(copy.Get() as Overlay.SdfAssetPath_VtArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec2iArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec2iArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec3iArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec3iArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec4iArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec4iArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec2hArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec2hArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec3hArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec3hArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec4hArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec4hArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec2fArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec2fArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec3fArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec3fArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec4fArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec4fArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec2dArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec2dArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec3dArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec3dArray, value)
    } else if (copy.IsHolding(T: pxr.VtVec4dArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtVec4dArray, value)
    } else if (copy.IsHolding(T: pxr.VtQuathArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtQuathArray, value)
    } else if (copy.IsHolding(T: pxr.VtQuatfArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtQuatfArray, value)
    } else if (copy.IsHolding(T: pxr.VtQuatdArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtQuatdArray, value)
    } else if (copy.IsHolding(T: pxr.VtMatrix2dArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtMatrix2dArray, value)
    } else if (copy.IsHolding(T: pxr.VtMatrix3dArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtMatrix3dArray, value)
    } else if (copy.IsHolding(T: pxr.VtMatrix4dArray.self)) {
        return try _writeArray(copy.Get() as pxr.VtMatrix4dArray, value)
    } else if (copy.IsHolding(T: Overlay.SdfAssetPath_VtArray.self)) {
        return try _writeArray(copy.Get() as Overlay.SdfAssetPath_VtArray, value)
    } else if (copy.IsHolding(T: Overlay.SdfPathExpression_VtArray.self)) {
        return try _writeArray(copy.Get() as Overlay.SdfPathExpression_VtArray, value)
    }
    
    else if copy.IsHolding(T: pxr.SdfTokenListOp.self) {
        return try writeSdfListOp(copy.Get() as pxr.SdfTokenListOp, writeTfToken)
    } else if copy.IsHolding(T: pxr.SdfInt64ListOp.self) {
        return try writeSdfListOp(copy.Get() as pxr.SdfInt64ListOp, writeLongLong)
    } else if copy.IsHolding(T: pxr.SdfStringListOp.self) {
        return try writeSdfListOp(copy.Get() as pxr.SdfStringListOp, writeString)
    } else if copy.IsHolding(T: pxr.VtDictionary.self) {
        return try writeVtDictionary(copy.Get() as pxr.VtDictionary)
    } else if copy.IsHolding(T: pxr.SdfUnregisteredValue.self) {
        return try writeSdfUnregisteredValue(copy.Get() as pxr.SdfUnregisteredValue)
    } else if value.valueTypeName.GetAsToken() == .SdfValueRoleNames.PointIndex || value.valueTypeName.GetScalarType() == .SdfValueRoleNames.PointIndex {
        return try writeValueWithoutTypeHint(.init(vtValue: copy))
    } else if copy.IsHolding(T: pxr.SdfPermission.self) {
        let x = Int32((copy.Get() as pxr.SdfPermission).rawValue)
        return try writeValueWithoutTypeHint(.init(vtValue: pxr.VtValue(x)))
    } else if copy.IsHolding(T: pxr.SdfPath.self) {
        // Important: Needs "<" and ">" for mismatched-types.usda,
        // so default-relationship.usda has to filter them out later.
        // Very tricky to handle misencoded types in Sdf in all cases.
        let s = "<\(copy.Get() as pxr.SdfPath)>"
        return try writeValueWithoutTypeHint(.init(vtValue: pxr.VtValue(pxr.SdfUnregisteredValue(std.string(s)))))
    } else if copy.IsHolding(T: pxr.SdfAnimationBlock.self) {
        return writeSdfAnimationBlock(copy.Get() as pxr.SdfAnimationBlock)
    } else {
        throw JsDecodingError.unknownTypeNameAndValue(value.valueTypeName.GetAsToken(), value.otherTypeName, copy.GetTypeName(), String(pxr.TfStringify(copy)))
    }
}

/// Will try to decode the type hint first before decoding the value. See also extractValueWithTypeHint
func extractTypeHintAndValue(_ js: JsAny) throws -> TypedValue {
    let obj = try js.castAsObject()
    var result = try extractTypeHint(js)
    try extractValueWithTypeHint(&result, obj["value", errorMessage: "extractTypeHintAndValue"])
    
    if result.value.IsHolding(T: pxr.SdfUnregisteredValue.self) {
        var copy = result.value
        let unregistered = copy.Get() as pxr.SdfUnregisteredValue
        if result.otherTypeName == "SdfPath" {
            if !unregistered.GetValue().IsHolding(T: std.string.self) {
                throw JsDecodingError.sdfPathSdfUnregisteredValueWasntHoldingAString
                
            }
            
            // Important: mismatched-types.usda needs to add "<" and ">",
            // so default-relationship.usda has to filter them out here.
            // Very tricky to handle misencoded types in Sdf in all cases.
            copy = unregistered.GetValue()
            var unregisteredString = String(copy.Get() as std.string)
            if unregisteredString.first == "<" && unregisteredString.last == ">" {
                unregisteredString = String(unregisteredString.dropFirst().dropLast())
            }
            result.value = pxr.VtValue(pxr.SdfPath(unregisteredString))
        }
    }
    
    return result
}
func writeTypeHintAndValue(_ value: TypedValue) throws -> JsAny {
    [
        "type" : writeTypeHint(value),
        "value" : try writeValueWithoutTypeHint(value)
    ]
}

func extractTimeCodeValueMapWithTypeHint(_ js: JsAny, _ type: TypedValue) throws -> pxr.SdfTimeSampleMap {
    var result = pxr.SdfTimeSampleMap()
    
    for (k, v) in try js.castAsObject() {
        guard let d = Double(k) else {
            throw JsDecodingError.timeSampleMapKeyWasntDouble(k)
        }
        var type = type
        try extractValueWithTypeHint(&type, v)
        result[d] = type.value
    }
    
    return result
}
func writeTimeCodeValueMapWithoutTypeHint(_ samples: pxr.SdfTimeSampleMap, _ type: TypedValue) throws -> JsAny {
    var result = [String : JsAny]()
    for kvPair in samples {
        var temp = type
        temp.value = kvPair.second
        result[String(kvPair.first)] = try writeValueWithoutTypeHint(temp)
    }
    return .object(result)
}
