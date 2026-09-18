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

#include <cuchar>
#include "pxr/usd/sdf/types.h"
#include "pxr/base/js/value.h"
#include "pxr/base/tf/errorMark.h"
#include "VtSerialization.hpp"
#include "Diagnostics.hpp"
#include "FundementalTypes.hpp"
#include "SdfSerialization.hpp"
#include "LIVERPSSerialization.hpp"
#include "TfSerialization.hpp"

TypedValue TypedValue::forVtValue(pxr::VtValue v) {
    TypedValue result;
    result.value = v;
    result.valueTypeName = pxr::SdfGetValueTypeNameForValue(v);
    result.otherTypeName = v.GetTypeName();
    return result;
}

TypedValue TypedValue::forTypeName(pxr::SdfValueTypeName x) {
    TypedValue result;
    result.value = pxr::VtValue();
    result.valueTypeName = x;
    result.otherTypeName = "";
    return result;
}

TypedValue TypedValue::withOtherTypeName(std::string s) {
    TypedValue result;
    result.value = pxr::VtValue();
    result.valueTypeName = pxr::SdfValueTypeName();
    result.otherTypeName = s;
    return result;
}


pxr::VtDictionary extractVtDictionary(const pxr::JsValue& js) {
    pxr::VtDictionary result;
    
    for (const auto& it : js.GetJsObject()) {
        TypedValue x = extractTypeHintAndValue(it.second);
        result.insert({it.first, x.value});
    }

    return result;
}
pxr::JsValue writeVtDictionary(const pxr::VtDictionary& x) {
    pxr::JsObject result;
    for (const auto& it : x) {
        TypedValue v = TypedValue::forVtValue(it.second);
        result[it.first] = writeTypeHintAndValue(v);
    }
    return result;
}

TypedValue extractTypeHint(const pxr::JsValue &js) {
    const pxr::JsObject& obj = js.GetJsObject();
    
    std::string s;
    try {
        s = obj.at("type").GetString();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("extractTypeHint requires type key") TypedValue();
    }
    
#define EXTRACT_TYPE_HINT(TYPE_STRING) \
    else if (s == #TYPE_STRING) { return TypedValue::forTypeName(pxr::SdfValueTypeNames->TYPE_STRING); }
    
    // Taken from `class Sdf_ValueTypeNamesType` in OpenUSD/pxr/usd/sdf/types.h
    
    if (false) {}
    EXTRACT_TYPE_HINT(Bool)
    EXTRACT_TYPE_HINT(UChar)
    EXTRACT_TYPE_HINT(Int)
    EXTRACT_TYPE_HINT(UInt)
    EXTRACT_TYPE_HINT(Int64)
    EXTRACT_TYPE_HINT(UInt64)
    EXTRACT_TYPE_HINT(Half)
    EXTRACT_TYPE_HINT(Float)
    EXTRACT_TYPE_HINT(Double)
    EXTRACT_TYPE_HINT(TimeCode)
    EXTRACT_TYPE_HINT(String)
    EXTRACT_TYPE_HINT(Token)
    EXTRACT_TYPE_HINT(Asset)
    EXTRACT_TYPE_HINT(Int2)
    EXTRACT_TYPE_HINT(Int3)
    EXTRACT_TYPE_HINT(Int4)
    EXTRACT_TYPE_HINT(Half2)
    EXTRACT_TYPE_HINT(Half3)
    EXTRACT_TYPE_HINT(Half4)
    EXTRACT_TYPE_HINT(Float2)
    EXTRACT_TYPE_HINT(Float3)
    EXTRACT_TYPE_HINT(Float4)
    EXTRACT_TYPE_HINT(Double2)
    EXTRACT_TYPE_HINT(Double3)
    EXTRACT_TYPE_HINT(Double4)
    EXTRACT_TYPE_HINT(Point3h)
    EXTRACT_TYPE_HINT(Point3f)
    EXTRACT_TYPE_HINT(Point3d)
    EXTRACT_TYPE_HINT(Vector3h)
    EXTRACT_TYPE_HINT(Vector3f)
    EXTRACT_TYPE_HINT(Vector3d)
    EXTRACT_TYPE_HINT(Normal3h)
    EXTRACT_TYPE_HINT(Normal3f)
    EXTRACT_TYPE_HINT(Normal3d)
    EXTRACT_TYPE_HINT(Color3h)
    EXTRACT_TYPE_HINT(Color3f)
    EXTRACT_TYPE_HINT(Color3d)
    EXTRACT_TYPE_HINT(Color4h)
    EXTRACT_TYPE_HINT(Color4f)
    EXTRACT_TYPE_HINT(Color4d)
    EXTRACT_TYPE_HINT(Quath)
    EXTRACT_TYPE_HINT(Quatf)
    EXTRACT_TYPE_HINT(Quatd)
    EXTRACT_TYPE_HINT(Matrix2d)
    EXTRACT_TYPE_HINT(Matrix3d)
    EXTRACT_TYPE_HINT(Matrix4d)
    EXTRACT_TYPE_HINT(Frame4d)
    EXTRACT_TYPE_HINT(TexCoord2h)
    EXTRACT_TYPE_HINT(TexCoord2f)
    EXTRACT_TYPE_HINT(TexCoord2d)
    EXTRACT_TYPE_HINT(TexCoord3h)
    EXTRACT_TYPE_HINT(TexCoord3f)
    EXTRACT_TYPE_HINT(TexCoord3d)
    EXTRACT_TYPE_HINT(Opaque)
    EXTRACT_TYPE_HINT(Group)
    EXTRACT_TYPE_HINT(PathExpression)
    EXTRACT_TYPE_HINT(BoolArray)
    EXTRACT_TYPE_HINT(UCharArray)
    EXTRACT_TYPE_HINT(IntArray)
    EXTRACT_TYPE_HINT(UIntArray)
    EXTRACT_TYPE_HINT(Int64Array)
    EXTRACT_TYPE_HINT(UInt64Array)
    EXTRACT_TYPE_HINT(HalfArray)
    EXTRACT_TYPE_HINT(FloatArray)
    EXTRACT_TYPE_HINT(DoubleArray)
    EXTRACT_TYPE_HINT(TimeCodeArray)
    EXTRACT_TYPE_HINT(StringArray)
    EXTRACT_TYPE_HINT(TokenArray)
    EXTRACT_TYPE_HINT(AssetArray)
    EXTRACT_TYPE_HINT(Int2Array)
    EXTRACT_TYPE_HINT(Int3Array)
    EXTRACT_TYPE_HINT(Int4Array)
    EXTRACT_TYPE_HINT(Half2Array)
    EXTRACT_TYPE_HINT(Half3Array)
    EXTRACT_TYPE_HINT(Half4Array)
    EXTRACT_TYPE_HINT(Float2Array)
    EXTRACT_TYPE_HINT(Float3Array)
    EXTRACT_TYPE_HINT(Float4Array)
    EXTRACT_TYPE_HINT(Double2Array)
    EXTRACT_TYPE_HINT(Double3Array)
    EXTRACT_TYPE_HINT(Double4Array)
    EXTRACT_TYPE_HINT(Point3hArray)
    EXTRACT_TYPE_HINT(Point3fArray)
    EXTRACT_TYPE_HINT(Point3dArray)
    EXTRACT_TYPE_HINT(Vector3hArray)
    EXTRACT_TYPE_HINT(Vector3fArray)
    EXTRACT_TYPE_HINT(Vector3dArray)
    EXTRACT_TYPE_HINT(Normal3hArray)
    EXTRACT_TYPE_HINT(Normal3fArray)
    EXTRACT_TYPE_HINT(Normal3dArray)
    EXTRACT_TYPE_HINT(Color3hArray)
    EXTRACT_TYPE_HINT(Color3fArray)
    EXTRACT_TYPE_HINT(Color3dArray)
    EXTRACT_TYPE_HINT(Color4hArray)
    EXTRACT_TYPE_HINT(Color4fArray)
    EXTRACT_TYPE_HINT(Color4dArray)
    EXTRACT_TYPE_HINT(QuathArray)
    EXTRACT_TYPE_HINT(QuatfArray)
    EXTRACT_TYPE_HINT(QuatdArray)
    EXTRACT_TYPE_HINT(Matrix2dArray)
    EXTRACT_TYPE_HINT(Matrix3dArray)
    EXTRACT_TYPE_HINT(Matrix4dArray)
    EXTRACT_TYPE_HINT(Frame4dArray)
    EXTRACT_TYPE_HINT(TexCoord2hArray)
    EXTRACT_TYPE_HINT(TexCoord2fArray)
    EXTRACT_TYPE_HINT(TexCoord2dArray)
    EXTRACT_TYPE_HINT(TexCoord3hArray)
    EXTRACT_TYPE_HINT(TexCoord3fArray)
    EXTRACT_TYPE_HINT(TexCoord3dArray)
    EXTRACT_TYPE_HINT(PathExpressionArray)
    #undef EXTRACT_TYPE_HINT
    else if (s == "SdfListOp<TfToken>") { return TypedValue::withOtherTypeName(s); }
    else if (s == "SdfListOp<long long>") { return TypedValue::withOtherTypeName(s); }
    else if (s == "SdfListOp<string>") { return TypedValue::withOtherTypeName(s); }
    else if (s == "VtDictionary") { return TypedValue::withOtherTypeName(s); }
    else if (s == "SdfUnregisteredValue") { return TypedValue::withOtherTypeName(s); }
    else if (s == "PointIndex" || s == "PointIndex[]") { return TypedValue::withOtherTypeName(s); }
    else if (s == "SdfPermission") { return TypedValue::withOtherTypeName(s); }
    else if (s == "SdfPath") { return TypedValue::withOtherTypeName(s); }
    else if (!s.empty()) {
        // Important: Lots of code depends on extractTypeHint, and the vast majority of it
        // doesn't know how to handle unknown type hints. Emit an error that could be caught
        // by TfErrorMark and return a valid TypedValue, so that sophisticated callers can
        // handle this case if they want, while simpler callers can simply error out

        MY_RUNTIME_ERROR("Deserializing unknown type hint '%s'", s.c_str());
        return TypedValue::withOtherTypeName(s);
    } else {
        MY_RUNTIME_ERROR_AND_RETURN("Unknown type hint '%s'", s.c_str()) TypedValue();
    }
}

pxr::JsValue writeTypeHint(const TypedValue& value) {
    #define WRITE_TYPE_HINT(TYPE_STRING) \
    else if (value.valueTypeName == pxr::SdfValueTypeNames->TYPE_STRING) {\
        return pxr::JsValue(#TYPE_STRING); }
    
    if (false) {}
    WRITE_TYPE_HINT(Bool)
    WRITE_TYPE_HINT(UChar)
    WRITE_TYPE_HINT(Int)
    WRITE_TYPE_HINT(UInt)
    WRITE_TYPE_HINT(Int64)
    WRITE_TYPE_HINT(UInt64)
    WRITE_TYPE_HINT(Half)
    WRITE_TYPE_HINT(Float)
    WRITE_TYPE_HINT(Double)
    WRITE_TYPE_HINT(TimeCode)
    WRITE_TYPE_HINT(String)
    WRITE_TYPE_HINT(Token)
    WRITE_TYPE_HINT(Asset)
    WRITE_TYPE_HINT(Int2)
    WRITE_TYPE_HINT(Int3)
    WRITE_TYPE_HINT(Int4)
    WRITE_TYPE_HINT(Half2)
    WRITE_TYPE_HINT(Half3)
    WRITE_TYPE_HINT(Half4)
    WRITE_TYPE_HINT(Float2)
    WRITE_TYPE_HINT(Float3)
    WRITE_TYPE_HINT(Float4)
    WRITE_TYPE_HINT(Double2)
    WRITE_TYPE_HINT(Double3)
    WRITE_TYPE_HINT(Double4)
    WRITE_TYPE_HINT(Point3h)
    WRITE_TYPE_HINT(Point3f)
    WRITE_TYPE_HINT(Point3d)
    WRITE_TYPE_HINT(Vector3h)
    WRITE_TYPE_HINT(Vector3f)
    WRITE_TYPE_HINT(Vector3d)
    WRITE_TYPE_HINT(Normal3h)
    WRITE_TYPE_HINT(Normal3f)
    WRITE_TYPE_HINT(Normal3d)
    WRITE_TYPE_HINT(Color3h)
    WRITE_TYPE_HINT(Color3f)
    WRITE_TYPE_HINT(Color3d)
    WRITE_TYPE_HINT(Color4h)
    WRITE_TYPE_HINT(Color4f)
    WRITE_TYPE_HINT(Color4d)
    WRITE_TYPE_HINT(Quath)
    WRITE_TYPE_HINT(Quatf)
    WRITE_TYPE_HINT(Quatd)
    WRITE_TYPE_HINT(Matrix2d)
    WRITE_TYPE_HINT(Matrix3d)
    WRITE_TYPE_HINT(Matrix4d)
    WRITE_TYPE_HINT(Frame4d)
    WRITE_TYPE_HINT(TexCoord2h)
    WRITE_TYPE_HINT(TexCoord2f)
    WRITE_TYPE_HINT(TexCoord2d)
    WRITE_TYPE_HINT(TexCoord3h)
    WRITE_TYPE_HINT(TexCoord3f)
    WRITE_TYPE_HINT(TexCoord3d)
    WRITE_TYPE_HINT(Opaque)
    WRITE_TYPE_HINT(Group)
    WRITE_TYPE_HINT(PathExpression)
    WRITE_TYPE_HINT(BoolArray)
    WRITE_TYPE_HINT(UCharArray)
    WRITE_TYPE_HINT(IntArray)
    WRITE_TYPE_HINT(UIntArray)
    WRITE_TYPE_HINT(Int64Array)
    WRITE_TYPE_HINT(UInt64Array)
    WRITE_TYPE_HINT(HalfArray)
    WRITE_TYPE_HINT(FloatArray)
    WRITE_TYPE_HINT(DoubleArray)
    WRITE_TYPE_HINT(TimeCodeArray)
    WRITE_TYPE_HINT(StringArray)
    WRITE_TYPE_HINT(TokenArray)
    WRITE_TYPE_HINT(AssetArray)
    WRITE_TYPE_HINT(Int2Array)
    WRITE_TYPE_HINT(Int3Array)
    WRITE_TYPE_HINT(Int4Array)
    WRITE_TYPE_HINT(Half2Array)
    WRITE_TYPE_HINT(Half3Array)
    WRITE_TYPE_HINT(Half4Array)
    WRITE_TYPE_HINT(Float2Array)
    WRITE_TYPE_HINT(Float3Array)
    WRITE_TYPE_HINT(Float4Array)
    WRITE_TYPE_HINT(Double2Array)
    WRITE_TYPE_HINT(Double3Array)
    WRITE_TYPE_HINT(Double4Array)
    WRITE_TYPE_HINT(Point3hArray)
    WRITE_TYPE_HINT(Point3fArray)
    WRITE_TYPE_HINT(Point3dArray)
    WRITE_TYPE_HINT(Vector3hArray)
    WRITE_TYPE_HINT(Vector3fArray)
    WRITE_TYPE_HINT(Vector3dArray)
    WRITE_TYPE_HINT(Normal3hArray)
    WRITE_TYPE_HINT(Normal3fArray)
    WRITE_TYPE_HINT(Normal3dArray)
    WRITE_TYPE_HINT(Color3hArray)
    WRITE_TYPE_HINT(Color3fArray)
    WRITE_TYPE_HINT(Color3dArray)
    WRITE_TYPE_HINT(Color4hArray)
    WRITE_TYPE_HINT(Color4fArray)
    WRITE_TYPE_HINT(Color4dArray)
    WRITE_TYPE_HINT(QuathArray)
    WRITE_TYPE_HINT(QuatfArray)
    WRITE_TYPE_HINT(QuatdArray)
    WRITE_TYPE_HINT(Matrix2dArray)
    WRITE_TYPE_HINT(Matrix3dArray)
    WRITE_TYPE_HINT(Matrix4dArray)
    WRITE_TYPE_HINT(Frame4dArray)
    WRITE_TYPE_HINT(TexCoord2hArray)
    WRITE_TYPE_HINT(TexCoord2fArray)
    WRITE_TYPE_HINT(TexCoord2dArray)
    WRITE_TYPE_HINT(TexCoord3hArray)
    WRITE_TYPE_HINT(TexCoord3fArray)
    WRITE_TYPE_HINT(TexCoord3dArray)
    WRITE_TYPE_HINT(PathExpressionArray)
    #undef WRITE_TYPE_HINT
    else if (value.valueTypeName.GetAsToken() == pxr::SdfValueRoleNames->PointIndex) {
        return pxr::JsValue(pxr::SdfValueRoleNames->PointIndex.GetString());
    } else if (value.valueTypeName.GetScalarType().GetAsToken() == pxr::SdfValueRoleNames->PointIndex) {
        return pxr::JsValue(pxr::SdfValueRoleNames->PointIndex.GetString() + "[]");
        
    } else if (value.otherTypeName.empty() && !value.valueTypeName.GetAsToken().IsEmpty()) {
        // Important: Some type names may be invalid but should still round-trip.
        // See extent-wrong-type-name.usda
        return pxr::JsValue(value.valueTypeName.GetAsToken().GetString());
    }
    else {
        return pxr::JsValue(value.otherTypeName);
    }
}

template <typename T>
void _extractGfVec(TypedValue* out, const pxr::JsValue& js) {
    const pxr::JsArray& arr = js.GetJsArray();
    if (arr.size() != T::dimension) {
        MY_VERIFY(arr.size() == T::dimension,
                  "Decoding type failure (%s)", out->valueTypeName.GetAsToken().GetText());
        return;
    }
    
    T v;
    for (size_t i = 0; i < arr.size(); i++) {
        if constexpr (std::is_same_v<typename T::ScalarType, int>) {
            v[i] = arr[i].GetInt();
        } else {
            v[i] = arr[i].GetReal();
        }
    }
    out->value = pxr::VtValue(v);
}

template <typename T>
void _extractGfMatrixd(TypedValue* out, const pxr::JsValue& js) {
    const pxr::JsArray& arr = js.GetJsArray();
    if (arr.size() != T::numRows * T::numColumns) {
        MY_VERIFY(arr.size() == T::numRows * T::numColumns,
                  "Decoding type failure (%s)", out->valueTypeName.GetAsToken().GetText());
        return;
    }

    T m;
    for (size_t i = 0; i < arr.size(); i++) {
        m[i / T::numRows][i % T::numRows] = arr[i].GetReal();
    }
    out->value = pxr::VtValue(m);
}

template <typename T>
void _extractArray(TypedValue* out, const pxr::JsValue& js) {
    T decoded;
    for (const auto& x : js.GetJsArray()) {
        TypedValue temp = TypedValue::forTypeName(out->valueTypeName.GetScalarType());
        extractValueWithTypeHint(&temp, x);
        decoded.push_back(temp.value.Get<typename T::ElementType>());
    }
    out->value = pxr::VtValue(decoded);
}

void extractValueWithTypeHint(TypedValue* out, const pxr::JsValue& js) {
    if (js.IsNull()) {
        out->value = pxr::VtValue(pxr::SdfValueBlock());
        return;
    }
    
    // Speculatively try to decode SdfUnregisteredValue
    {
        pxr::TfErrorMark m;
        out->value = pxr::VtValue(extractSdfUnregisteredValue(js));
        if (m.IsClean()) {
            return;
        } else {
            m.Clear();
        }
    }
    
    // Speculatively try to decode SdfAnimationBlock
    {
        pxr::TfErrorMark m;
        out->value = pxr::VtValue(extractSdfAnimationBlock(js));
        if (m.IsClean()) {
            return;
        } else {
            m.Clear();
        }
    }
    
    
    if (out->valueTypeName == pxr::SdfValueTypeNames->Bool) {
        bool x = js.GetBool();
        out->value = pxr::VtValue(x);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->UChar) {
        int x = js.GetInt();
        out->value = pxr::VtValue(static_cast<unsigned char>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Int) {
        int x = js.GetInt();
        out->value = pxr::VtValue(static_cast<int>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->UInt) {
        uint64_t x = js.GetUInt64();
        out->value = pxr::VtValue(static_cast<uint>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Int64) {
        int64_t x = js.GetInt64();
        out->value = pxr::VtValue(static_cast<int64_t>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->UInt64) {
        uint64_t x = js.GetUInt64();
        out->value = pxr::VtValue(static_cast<uint64_t>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Half) {
        double x = js.GetReal();
        out->value = pxr::VtValue(pxr::GfHalf(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Float) {
        double x = js.GetReal();
        out->value = pxr::VtValue(static_cast<float>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Double) {
        double x = js.GetReal();
        out->value = pxr::VtValue(static_cast<double>(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TimeCode) {
        double x = js.GetReal();
        out->value = pxr::VtValue(pxr::GfTimeCode(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->String) {
        std::string x = js.GetString();
        out->value = pxr::VtValue(x);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Token) {
        std::string x = js.GetString();
        out->value = pxr::VtValue(pxr::TfToken(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Asset) {
        std::string x = js.GetString();
        out->value = pxr::VtValue(pxr::SdfAssetPath(x));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Int2) {
        _extractGfVec<pxr::GfVec2i>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Int3) {
        _extractGfVec<pxr::GfVec3i>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Int4) {
        _extractGfVec<pxr::GfVec4i>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Half2) {
        _extractGfVec<pxr::GfVec2h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Half3) {
        _extractGfVec<pxr::GfVec3h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Half4) {
        _extractGfVec<pxr::GfVec4h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Float2) {
        _extractGfVec<pxr::GfVec2f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Float3) {
        _extractGfVec<pxr::GfVec3f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Float4) {
        _extractGfVec<pxr::GfVec4f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Double2) {
        _extractGfVec<pxr::GfVec2d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Double3) {
        _extractGfVec<pxr::GfVec3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Double4) {
        _extractGfVec<pxr::GfVec4d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Point3h) {
        _extractGfVec<pxr::GfVec3h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Point3f) {
        _extractGfVec<pxr::GfVec3f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Point3d) {
        _extractGfVec<pxr::GfVec3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Vector3h) {
        _extractGfVec<pxr::GfVec3h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Vector3f) {
        _extractGfVec<pxr::GfVec3f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Vector3d) {
        _extractGfVec<pxr::GfVec3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Normal3h) {
        _extractGfVec<pxr::GfVec3h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Normal3f) {
        _extractGfVec<pxr::GfVec3f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Normal3d) {
        _extractGfVec<pxr::GfVec3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Color3h) {
        _extractGfVec<pxr::GfVec3h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Color3f) {
        _extractGfVec<pxr::GfVec3f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Color3d) {
        _extractGfVec<pxr::GfVec3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Color4h) {
        _extractGfVec<pxr::GfVec4h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Color4f) {
        _extractGfVec<pxr::GfVec4f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Color4d) {
        _extractGfVec<pxr::GfVec4d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Quath) {
        TypedValue v;
        _extractGfVec<pxr::GfVec4h>(&v, js);
        out->value = pxr::VtValue(pxr::GfQuath(v.value.Get<pxr::GfVec4h>()[0],
                                               v.value.Get<pxr::GfVec4h>()[1],
                                               v.value.Get<pxr::GfVec4h>()[2],
                                               v.value.Get<pxr::GfVec4h>()[3]));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Quatf) {
        TypedValue v;
        _extractGfVec<pxr::GfVec4f>(&v, js);
        out->value = pxr::VtValue(pxr::GfQuatf(v.value.Get<pxr::GfVec4f>()[0],
                                               v.value.Get<pxr::GfVec4f>()[1],
                                               v.value.Get<pxr::GfVec4f>()[2],
                                               v.value.Get<pxr::GfVec4f>()[3]));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Quatd) {
        TypedValue v;
        _extractGfVec<pxr::GfVec4d>(&v, js);
        out->value = pxr::VtValue(pxr::GfQuatd(v.value.Get<pxr::GfVec4d>()[0],
                                               v.value.Get<pxr::GfVec4d>()[1],
                                               v.value.Get<pxr::GfVec4d>()[2],
                                               v.value.Get<pxr::GfVec4d>()[3]));
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Matrix2d) {
        _extractGfMatrixd<pxr::GfMatrix2d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Matrix3d) {
        _extractGfMatrixd<pxr::GfMatrix3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Matrix4d) {
        _extractGfMatrixd<pxr::GfMatrix4d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Frame4d) {
        _extractGfMatrixd<pxr::GfMatrix4d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TexCoord2h) {
        _extractGfVec<pxr::GfVec2h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TexCoord2f) {
        _extractGfVec<pxr::GfVec2f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TexCoord2d) {
        _extractGfVec<pxr::GfVec2d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TexCoord3h) {
        _extractGfVec<pxr::GfVec3h>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TexCoord3f) {
        _extractGfVec<pxr::GfVec3f>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->TexCoord3d) {
        _extractGfVec<pxr::GfVec3d>(out, js);
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Opaque) {
        MY_RUNTIME_ERROR_AND_RETURN("Decoding type failure (Opaque)");
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->Group) {
        MY_RUNTIME_ERROR_AND_RETURN("Decoding type failure (Group)");
    } else if (out->valueTypeName == pxr::SdfValueTypeNames->PathExpression) {
        std::string x = js.GetString();
        out->value = pxr::VtValue(pxr::SdfPathExpression(x));
    }
    #define EXTRACT_ARRAY(TYPENAME, VTARRAY) \
    else if (out->valueTypeName == pxr::SdfValueTypeNames->TYPENAME) {\
        _extractArray<pxr::VTARRAY>(out, js);\
    }
    EXTRACT_ARRAY(BoolArray, VtBoolArray)
    EXTRACT_ARRAY(UCharArray, VtUCharArray)
    EXTRACT_ARRAY(IntArray, VtIntArray)
    EXTRACT_ARRAY(UIntArray, VtUIntArray)
    EXTRACT_ARRAY(Int64Array, VtInt64Array)
    EXTRACT_ARRAY(UInt64Array, VtUInt64Array)
    EXTRACT_ARRAY(HalfArray, VtHalfArray)
    EXTRACT_ARRAY(FloatArray, VtFloatArray)
    EXTRACT_ARRAY(DoubleArray, VtDoubleArray)
    EXTRACT_ARRAY(TimeCodeArray, VtTimeCodeArray)
    EXTRACT_ARRAY(StringArray, VtStringArray)
    EXTRACT_ARRAY(TokenArray, VtTokenArray)
    EXTRACT_ARRAY(AssetArray, VtArray<pxr::SdfAssetPath>)
    EXTRACT_ARRAY(Int2Array, VtVec2iArray)
    EXTRACT_ARRAY(Int3Array, VtVec3iArray)
    EXTRACT_ARRAY(Int4Array, VtVec4iArray)
    EXTRACT_ARRAY(Half2Array, VtVec2hArray)
    EXTRACT_ARRAY(Half3Array, VtVec3hArray)
    EXTRACT_ARRAY(Half4Array, VtVec4hArray)
    EXTRACT_ARRAY(Float2Array, VtVec2fArray)
    EXTRACT_ARRAY(Float3Array, VtVec3fArray)
    EXTRACT_ARRAY(Float4Array, VtVec4fArray)
    EXTRACT_ARRAY(Double2Array, VtVec2dArray)
    EXTRACT_ARRAY(Double3Array, VtVec3dArray)
    EXTRACT_ARRAY(Double4Array, VtVec4dArray)
    EXTRACT_ARRAY(Point3hArray, VtVec3hArray)
    EXTRACT_ARRAY(Point3fArray, VtVec3fArray)
    EXTRACT_ARRAY(Point3dArray, VtVec3dArray)
    EXTRACT_ARRAY(Vector3hArray, VtVec3hArray)
    EXTRACT_ARRAY(Vector3fArray, VtVec3fArray)
    EXTRACT_ARRAY(Vector3dArray, VtVec3dArray)
    EXTRACT_ARRAY(Normal3hArray, VtVec3hArray)
    EXTRACT_ARRAY(Normal3fArray, VtVec3fArray)
    EXTRACT_ARRAY(Normal3dArray, VtVec3dArray)
    EXTRACT_ARRAY(Color3hArray, VtVec3hArray)
    EXTRACT_ARRAY(Color3fArray, VtVec3fArray)
    EXTRACT_ARRAY(Color3dArray, VtVec3dArray)
    EXTRACT_ARRAY(Color4hArray, VtVec4hArray)
    EXTRACT_ARRAY(Color4fArray, VtVec4fArray)
    EXTRACT_ARRAY(Color4dArray, VtVec4dArray)
    EXTRACT_ARRAY(QuathArray, VtQuathArray)
    EXTRACT_ARRAY(QuatfArray, VtQuatfArray)
    EXTRACT_ARRAY(QuatdArray, VtQuatdArray)
    EXTRACT_ARRAY(Matrix2dArray, VtMatrix2dArray)
    EXTRACT_ARRAY(Matrix3dArray, VtMatrix3dArray)
    EXTRACT_ARRAY(Matrix4dArray, VtMatrix4dArray)
    EXTRACT_ARRAY(Frame4dArray, VtMatrix4dArray)
    EXTRACT_ARRAY(TexCoord2hArray, VtVec2hArray)
    EXTRACT_ARRAY(TexCoord2fArray, VtVec2fArray)
    EXTRACT_ARRAY(TexCoord2dArray, VtVec2dArray)
    EXTRACT_ARRAY(TexCoord3hArray, VtVec3hArray)
    EXTRACT_ARRAY(TexCoord3fArray, VtVec3fArray)
    EXTRACT_ARRAY(TexCoord3dArray, VtVec3dArray)
    EXTRACT_ARRAY(PathExpressionArray, VtArray<pxr::SdfPathExpression>)
    #undef EXTRACT_ARRAY
    
#warning todo: 6 listops
    else if (out->otherTypeName == "SdfListOp<TfToken>") {
        pxr::SdfListOp<pxr::TfToken> x = extractSdfListOp<pxr::TfToken>(js, extractTfToken);
        out->value = pxr::VtValue(x);
    } else if (out->otherTypeName == "SdfListOp<long long>") {
        pxr::SdfListOp<long long> x = extractSdfListOp<long long>(js, extractLongLong);
        out->value = pxr::VtValue(x);
    } else if (out->otherTypeName == "SdfListOp<string>") {
        pxr::SdfListOp<std::string> x = extractSdfListOp<std::string>(js, extractString);
        out->value = pxr::VtValue(x);
    } else if (out->otherTypeName == "VtDictionary") {
        pxr::VtDictionary x = extractVtDictionary(js);
        out->value = pxr::VtValue(x);
    } else if (out->otherTypeName == "SdfUnregisteredValue") {
        pxr::SdfUnregisteredValue x = extractSdfUnregisteredValue(js);
        out->value = pxr::VtValue(x);
    } else if (out->otherTypeName == "PointIndex") {
        TypedValue temp = TypedValue::forTypeName(pxr::SdfValueTypeNames->Int);
        extractValueWithTypeHint(&temp, js);
        out->value = temp.value;
    } else if (out->otherTypeName == "PointIndex[]") {
        TypedValue temp = TypedValue::forTypeName(pxr::SdfValueTypeNames->IntArray);
        extractValueWithTypeHint(&temp, js);
        out->value = temp.value;
    } else if (out->otherTypeName == "SdfPermission") {
        TypedValue temp = TypedValue::forTypeName(pxr::SdfValueTypeNames->Int);
        extractValueWithTypeHint(&temp, js);
        out->value = pxr::VtValue(static_cast<pxr::SdfPermission>(temp.value.Get<int>()));
    } else if (out->otherTypeName == "Transform") {
        TypedValue temp = TypedValue::forTypeName(pxr::SdfValueTypeNames->Matrix4d);
        extractValueWithTypeHint(&temp, js);
        out->value = temp.value;
    } else {
        MY_RUNTIME_ERROR_AND_RETURN("Unknown type name '%s'/'%s'", out->valueTypeName.GetAsToken().GetText(), out->otherTypeName.c_str());
    }
}

template <typename T>
pxr::JsValue _writeGfVec(const TypedValue& value) {
    T v = value.value.Get<T>();
    pxr::JsArray arr;
    for (size_t i = 0; i < T::dimension; i++) {
        arr.push_back(pxr::JsValue(v[i]));
    }
    return arr;
}

template <typename T>
pxr::JsValue _writeGfMatrixd(const TypedValue& value) {
    T m = value.value.Get<T>();
    pxr::JsArray arr;
    for (size_t r = 0; r < T::numRows; r++) {
        for (size_t c = 0; c < T::numColumns; c++) {
            arr.push_back(pxr::JsValue(m[r][c]));
        }
    }
    return arr;
}

template <typename T>
pxr::JsValue _writeArray(const TypedValue& value) {
    const T& arr = value.value.Get<T>();
    pxr::JsArray result;
    for (const auto& x : arr) {
        TypedValue temp;
        temp.value = pxr::VtValue(x);
        temp.valueTypeName = value.valueTypeName.GetScalarType();
        result.push_back(writeValueWithoutTypeHint(temp));
    }
    return result;
}

pxr::JsValue writeValueWithoutTypeHint(const TypedValue& value) {
    // Important: Use value.value.IsHolding instead of comparing to value.valueTypeName because
    // of e.g. mismatched-types.usda
    if (value.value.IsHolding<pxr::SdfValueBlock>()) {
        return pxr::JsValue();
    }
        
    if (value.value.IsHolding<bool>()) {
        return pxr::JsValue(value.value.Get<bool>());
    } else if (value.value.IsHolding<unsigned char>()) {
        return pxr::JsValue(value.value.Get<unsigned char>());
    } else if (value.value.IsHolding<int>()) {
        return pxr::JsValue(value.value.Get<int>());
    } else if (value.value.IsHolding<uint>()) {
        return pxr::JsValue(static_cast<uint64_t>(value.value.Get<uint>()));
    } else if (value.value.IsHolding<int64_t>()) {
        return pxr::JsValue(value.value.Get<int64_t>());
    } else if (value.value.IsHolding<uint64_t>()) {
        return pxr::JsValue(value.value.Get<uint64_t>());
    } else if (value.value.IsHolding<pxr::GfHalf>()) {
        return pxr::JsValue(value.value.Get<pxr::GfHalf>());
    } else if (value.value.IsHolding<float>()) {
        return pxr::JsValue(value.value.Get<float>());
    } else if (value.value.IsHolding<double>()) {
        return pxr::JsValue(value.value.Get<double>());
    } else if (value.value.IsHolding<pxr::GfTimeCode>()) {
        return pxr::JsValue(value.value.Get<pxr::GfTimeCode>().GetValue());
    } else if (value.value.IsHolding<std::string>()) {
        return pxr::JsValue(value.value.Get<std::string>());
    } else if (value.value.IsHolding<pxr::TfToken>()) {
        return pxr::JsValue(value.value.Get<pxr::TfToken>().GetString());
    } else if (value.value.IsHolding<pxr::SdfAssetPath>()) {
        return pxr::JsValue(value.value.Get<pxr::SdfAssetPath>().GetAuthoredPath());
    } else if (value.value.IsHolding<pxr::GfVec2i>()) {
        return _writeGfVec<pxr::GfVec2i>(value);
    } else if (value.value.IsHolding<pxr::GfVec3i>()) {
        return _writeGfVec<pxr::GfVec3i>(value);
    } else if (value.value.IsHolding<pxr::GfVec4i>()) {
        return _writeGfVec<pxr::GfVec4i>(value);
    } else if (value.value.IsHolding<pxr::GfVec2h>()) {
        return _writeGfVec<pxr::GfVec2h>(value);
    } else if (value.value.IsHolding<pxr::GfVec3h>()) {
        return _writeGfVec<pxr::GfVec3h>(value);
    } else if (value.value.IsHolding<pxr::GfVec4h>()) {
        return _writeGfVec<pxr::GfVec4h>(value);
    } else if (value.value.IsHolding<pxr::GfVec2f>()) {
        return _writeGfVec<pxr::GfVec2f>(value);
    } else if (value.value.IsHolding<pxr::GfVec3f>()) {
        return _writeGfVec<pxr::GfVec3f>(value);
    } else if (value.value.IsHolding<pxr::GfVec4f>()) {
        return _writeGfVec<pxr::GfVec4f>(value);
    } else if (value.value.IsHolding<pxr::GfVec2d>()) {
        return _writeGfVec<pxr::GfVec2d>(value);
    } else if (value.value.IsHolding<pxr::GfVec3d>()) {
        return _writeGfVec<pxr::GfVec3d>(value);
    } else if (value.value.IsHolding<pxr::GfVec4d>()) {
        return _writeGfVec<pxr::GfVec4d>(value);
    } else if (value.value.IsHolding<pxr::GfQuath>()) {
        pxr::GfQuath q = value.value.Get<pxr::GfQuath>();
        TypedValue temp = TypedValue::forVtValue(pxr::VtValue(pxr::GfVec4h(q.GetReal(), q.GetImaginary()[0], q.GetImaginary()[1], q.GetImaginary()[2])));
        return _writeGfVec<pxr::GfVec4h>(temp);
    } else if (value.value.IsHolding<pxr::GfQuatf>()) {
        pxr::GfQuatf q = value.value.Get<pxr::GfQuatf>();
        TypedValue temp = TypedValue::forVtValue(pxr::VtValue(pxr::GfVec4f(q.GetReal(), q.GetImaginary()[0], q.GetImaginary()[1], q.GetImaginary()[2])));
        return _writeGfVec<pxr::GfVec4f>(temp);
    } else if (value.value.IsHolding<pxr::GfQuatd>()) {
        pxr::GfQuatd q = value.value.Get<pxr::GfQuatd>();
        TypedValue temp = TypedValue::forVtValue(pxr::VtValue(pxr::GfVec4d(q.GetReal(), q.GetImaginary()[0], q.GetImaginary()[1], q.GetImaginary()[2])));
        return _writeGfVec<pxr::GfVec4d>(temp);
    } else if (value.value.IsHolding<pxr::GfMatrix2d>()) {
        return _writeGfMatrixd<pxr::GfMatrix2d>(value);
    } else if (value.value.IsHolding<pxr::GfMatrix3d>()) {
        return _writeGfMatrixd<pxr::GfMatrix3d>(value);
    } else if (value.value.IsHolding<pxr::GfMatrix4d>()) {
        return _writeGfMatrixd<pxr::GfMatrix4d>(value);
    } else if (value.value.IsHolding<pxr::SdfOpaqueValue>()) {
        return pxr::JsValue();
    } else if (value.value.IsHolding<pxr::SdfPathExpression>()) {
        return pxr::JsValue(value.value.Get<pxr::SdfPathExpression>().GetText());
    }
    
    #define WRITE_ARRAY(TYPENAME, VTARRAY) \
    else if (value.value.IsHolding<pxr::VTARRAY>()) {\
        return _writeArray<pxr::VTARRAY>(value);\
    }
    WRITE_ARRAY(BoolArray, VtBoolArray)
    WRITE_ARRAY(UCharArray, VtUCharArray)
    WRITE_ARRAY(IntArray, VtIntArray)
    WRITE_ARRAY(UIntArray, VtUIntArray)
    WRITE_ARRAY(Int64Array, VtInt64Array)
    WRITE_ARRAY(UInt64Array, VtUInt64Array)
    WRITE_ARRAY(HalfArray, VtHalfArray)
    WRITE_ARRAY(FloatArray, VtFloatArray)
    WRITE_ARRAY(DoubleArray, VtDoubleArray)
    WRITE_ARRAY(TimeCodeArray, VtTimeCodeArray)
    WRITE_ARRAY(StringArray, VtStringArray)
    WRITE_ARRAY(TokenArray, VtTokenArray)
    WRITE_ARRAY(AssetArray, VtArray<pxr::SdfAssetPath>)
    WRITE_ARRAY(Int2Array, VtVec2iArray)
    WRITE_ARRAY(Int3Array, VtVec3iArray)
    WRITE_ARRAY(Int4Array, VtVec4iArray)
    WRITE_ARRAY(Half2Array, VtVec2hArray)
    WRITE_ARRAY(Half3Array, VtVec3hArray)
    WRITE_ARRAY(Half4Array, VtVec4hArray)
    WRITE_ARRAY(Float2Array, VtVec2fArray)
    WRITE_ARRAY(Float3Array, VtVec3fArray)
    WRITE_ARRAY(Float4Array, VtVec4fArray)
    WRITE_ARRAY(Double2Array, VtVec2dArray)
    WRITE_ARRAY(Double3Array, VtVec3dArray)
    WRITE_ARRAY(Double4Array, VtVec4dArray)
    WRITE_ARRAY(Point3hArray, VtVec3hArray)
    WRITE_ARRAY(Point3fArray, VtVec3fArray)
    WRITE_ARRAY(Point3dArray, VtVec3dArray)
    WRITE_ARRAY(Vector3hArray, VtVec3hArray)
    WRITE_ARRAY(Vector3fArray, VtVec3fArray)
    WRITE_ARRAY(Vector3dArray, VtVec3dArray)
    WRITE_ARRAY(Normal3hArray, VtVec3hArray)
    WRITE_ARRAY(Normal3fArray, VtVec3fArray)
    WRITE_ARRAY(Normal3dArray, VtVec3dArray)
    WRITE_ARRAY(Color3hArray, VtVec3hArray)
    WRITE_ARRAY(Color3fArray, VtVec3fArray)
    WRITE_ARRAY(Color3dArray, VtVec3dArray)
    WRITE_ARRAY(Color4hArray, VtVec4hArray)
    WRITE_ARRAY(Color4fArray, VtVec4fArray)
    WRITE_ARRAY(Color4dArray, VtVec4dArray)
    WRITE_ARRAY(QuathArray, VtQuathArray)
    WRITE_ARRAY(QuatfArray, VtQuatfArray)
    WRITE_ARRAY(QuatdArray, VtQuatdArray)
    WRITE_ARRAY(Matrix2dArray, VtMatrix2dArray)
    WRITE_ARRAY(Matrix3dArray, VtMatrix3dArray)
    WRITE_ARRAY(Matrix4dArray, VtMatrix4dArray)
    WRITE_ARRAY(Frame4dArray, VtMatrix4dArray)
    WRITE_ARRAY(TexCoord2hArray, VtVec2hArray)
    WRITE_ARRAY(TexCoord2fArray, VtVec2fArray)
    WRITE_ARRAY(TexCoord2dArray, VtVec2dArray)
    WRITE_ARRAY(TexCoord3hArray, VtVec3hArray)
    WRITE_ARRAY(TexCoord3fArray, VtVec3fArray)
    WRITE_ARRAY(TexCoord3dArray, VtVec3dArray)
    WRITE_ARRAY(PathExpressionArray, VtArray<pxr::SdfPathExpression>)
    #undef WRITE_ARRAY
        
    else if (value.value.IsHolding<pxr::SdfListOp<pxr::TfToken>>()) {
        return writeSdfListOp(value.value.Get<pxr::SdfListOp<pxr::TfToken>>(), writeTfToken);
    } else if (value.value.IsHolding<pxr::SdfListOp<long long>>()) {
        return writeSdfListOp(value.value.Get<pxr::SdfListOp<long long>>(), writeLongLong);
    } else if (value.value.IsHolding<pxr::SdfListOp<std::string>>()) {
        return writeSdfListOp(value.value.Get<pxr::SdfListOp<std::string>>(), writeString);
        
        
    } else if (value.value.IsHolding<pxr::VtDictionary>()) {
        return writeVtDictionary(value.value.Get<pxr::VtDictionary>());
    } else if (value.value.IsHolding<pxr::SdfUnregisteredValue>()) {
        return writeSdfUnregisteredValue(value.value.Get<pxr::SdfUnregisteredValue>());
        
        
    } else if (value.valueTypeName.GetAsToken() == pxr::SdfValueRoleNames->PointIndex ||
               value.valueTypeName.GetScalarType() == pxr::SdfValueRoleNames->PointIndex) {
        return writeValueWithoutTypeHint(TypedValue::forVtValue(value.value));
    } else if (value.value.IsHolding<pxr::SdfPermission>()) {
        return writeValueWithoutTypeHint(TypedValue::forVtValue(pxr::VtValue(static_cast<int>(value.value.Get<pxr::SdfPermission>()))));
    } else if (value.value.IsHolding<pxr::SdfPath>()) {
        // Important: Needs "<" and ">" for mismatched-types.usda,
        // so default-relationship.usda has to filter them out later.
        // Very tricky to handle misencoded types in Sdf in all cases.
        std::string s = value.value.Get<pxr::SdfPath>().GetString();
        s = "<" + s + ">";
        return writeValueWithoutTypeHint(TypedValue::forVtValue(pxr::VtValue(pxr::SdfUnregisteredValue(s))));
    } else if (value.value.IsHolding<pxr::SdfAnimationBlock>()) {
        return writeSdfAnimationBlock(value.value.Get<pxr::SdfAnimationBlock>());
    }
    else {
        MY_RUNTIME_ERROR("Unknown type name '%s'/'%s'/'%s' for value '%s'", value.valueTypeName.GetAsToken().GetText(), value.otherTypeName.c_str(), value.value.GetTypeName().c_str(), pxr::TfStringify(value.value).c_str());
        return pxr::JsValue();
    }
}


TypedValue extractTypeHintAndValue(const pxr::JsValue& js) {
    const pxr::JsObject& obj = js.GetJsObject();
    TypedValue result = extractTypeHint(js);
    try {
        extractValueWithTypeHint(&result, obj.at("value"));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("extractTypeHintAndValue requires value key") TypedValue();
    }

    
    if (result.value.IsHolding<pxr::SdfUnregisteredValue>()) {
        pxr::SdfUnregisteredValue unregistered = result.value.Get<pxr::SdfUnregisteredValue>();
        if (result.otherTypeName == "SdfPath") {
            if (!unregistered.GetValue().IsHolding<std::string>()) {
                MY_RUNTIME_ERROR_AND_RETURN("SdfPath SdfUnregisteredValue wasn't holding a string") TypedValue();
            }
            
            // Important: mismatched-types.usda needs to add "<" and ">",
            // so default-relationship.usda has to filter them out here.
            // Very tricky to handle misencoded types in Sdf in all cases.
            std::string unregisteredString = unregistered.GetValue().Get<std::string>();
            if (unregisteredString.size() >= 2 && unregisteredString.front() == '<' && unregisteredString.back() == '>') {
                unregisteredString = unregisteredString.substr(1, unregisteredString.size() - 2);
            }
            result.value = pxr::VtValue(pxr::SdfPath(unregisteredString));
        }
    }
    
    
    return result;
}

pxr::JsValue writeTypeHintAndValue(const TypedValue& value) {
    pxr::JsObject result;
    result["type"] = writeTypeHint(value);
    result["value"] = writeValueWithoutTypeHint(value);
    return result;
}

std::map<double, pxr::VtValue> extractTimeCodeValueMapWithTypeHint(const pxr::JsValue& js, const TypedValue& type) {
    std::map<double, pxr::VtValue> result;

    for (const auto& it : js.GetJsObject()) {
        try {
            std::size_t pos = 0;
            double d = std::stod(it.first, &pos);
            if (pos != it.first.size()) {
                MY_RUNTIME_ERROR_AND_RETURN("Failed to convert timesample key '%s' to double", it.first.c_str()) {};
            }
            TypedValue v = type;
            extractValueWithTypeHint(&v, it.second);
            result[d] = v.value;
        } catch (const std::invalid_argument&) {
            MY_RUNTIME_ERROR_AND_RETURN("Failed to convert timesample key '%s' to double", it.first.c_str()) {};
        }
    }

    return result;
}

pxr::JsValue writeTimeCodeValueMapWithoutTypeHint(const std::map<double, pxr::VtValue>& samples, const TypedValue& type) {
    pxr::JsObject result;
    for (const auto& sample : samples) {
        TypedValue temp = type;
        temp.value = sample.second;
        result[std::to_string(sample.first)] = writeValueWithoutTypeHint(temp);
    }
    return result;
}
