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

#include "TsSerialization.hpp"
#include "Diagnostics.hpp"
#include "VtSerialization.hpp"
#include "FundementalTypes.hpp"

pxr::TsSpline extractTsSpline(const pxr::JsValue& js, const pxr::SdfValueTypeName& type) {
    
    pxr::TsSpline result = pxr::TsSpline(type.GetType());
    const pxr::JsObject& obj = js.GetJsObject();
    
    int curveType;
    try {
        curveType = obj.at("curveType").GetInt();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsSpline requires curveType key") pxr::TsSpline();
    }
    result.SetCurveType(static_cast<pxr::TsCurveType>(curveType));
    
    try {
        pxr::TsExtrapolation preExtrapolation = extractTsExtrapolation(obj.at("preExtrapolation"));
        result.SetPreExtrapolation(preExtrapolation);
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsSpline requires preExtrapolation key") pxr::TsSpline();
    }

    try {
        pxr::TsExtrapolation postExtrapolation = extractTsExtrapolation(obj.at("postExtrapolation"));
        result.SetPostExtrapolation(postExtrapolation);
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsSpline requires postExtrapolation key") pxr::TsSpline();
    }

    try {
        pxr::TsLoopParams loopParams = extractTsLoopParams(obj.at("innerLoopParams"));
        result.SetInnerLoopParams(loopParams);
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsSpline requires innerLoopParams key") pxr::TsSpline();
    }

    
    try {
        pxr::TsKnotMap knots = extractTsKnotMap(obj.at("knots"), type);
        if (!knots.empty()) {
            // TsSpline::SetKnots checks if the spline's type matches the knot map's type.
            // However, empty knot maps return the unknown type, so the comparison erronously fails.
            // Arguably, TsSpline::SetKnots shouldn't report an error in this case, but we can
            // just not set the knots with empty knot maps.
            result.SetKnots(knots);
        }
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsSpline requires knots key") pxr::TsSpline();
    }
    
    return result;
}
pxr::JsValue writeTsSpline(const pxr::TsSpline& x) {
    pxr::JsObject result;
    
    result["curveType"] = pxr::JsValue(x.GetCurveType());
    result["preExtrapolation"] = writeTsExtrapolation(x.GetPreExtrapolation());
    result["postExtrapolation"] = writeTsExtrapolation(x.GetPostExtrapolation());
    result["innerLoopParams"] = writeTsLoopParams(x.GetInnerLoopParams());
    result["knots"] = writeTsKnotMap(x.GetKnots());
    
    return result;
}

pxr::TsExtrapolation extractTsExtrapolation(const pxr::JsValue& js) {
    pxr::TsExtrapolation result;
    const pxr::JsObject& obj = js.GetJsObject();
    
    try {
        int mode = obj.at("mode").GetInt();
        result.mode = static_cast<pxr::TsExtrapMode>(mode);
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsExtrapolation mode") pxr::TsExtrapolation();
    }
    
    try {
        double slope = obj.at("slope").GetReal();
        result.slope = slope;
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsExtrapolation slope") pxr::TsExtrapolation();
    }
    
    result.loopBoundaryTime = std::nullopt;
    ifValueExists(obj, "loopBoundaryTime", [&](const auto& x){
        result.loopBoundaryTime = x.GetReal();
    });
    

    return result;
}
pxr::JsValue writeTsExtrapolation(const pxr::TsExtrapolation& x) {
    pxr::JsObject result;
    
    result["mode"] = pxr::JsValue(x.mode);
    result["slope"] = pxr::JsValue(x.slope);
    if (x.loopBoundaryTime.has_value()) {
        result["loopBoundaryTime"] = pxr::JsValue(*x.loopBoundaryTime);
    }
    
    return result;
}

pxr::TsLoopParams extractTsLoopParams(const pxr::JsValue& js) {
    pxr::TsLoopParams result;
    const pxr::JsObject& obj = js.GetJsObject();
    try {
        result.protoStart = obj.at("protoStart").GetReal();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsLoopParams protoStart") pxr::TsLoopParams();
    }
    try {
        result.protoEnd = obj.at("protoEnd").GetReal();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsLoopParams protoEnd") pxr::TsLoopParams();
    }
    try {
        result.numPreLoops = obj.at("numPreLoops").GetInt();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsLoopParams numPreLoops") pxr::TsLoopParams();
    }
    try {
        result.numPostLoops = obj.at("numPostLoops").GetInt();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsLoopParams numPostLoops") pxr::TsLoopParams();
    }
    try {
        result.valueOffset = obj.at("valueOffset").GetReal();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsLoopParams valueOffset") pxr::TsLoopParams();
    }

    return result;
}

pxr::JsValue writeTsLoopParams(const pxr::TsLoopParams& x) {
    pxr::JsObject result;
    
    result["protoStart"] = pxr::JsValue(x.protoStart);
    result["protoEnd"] = pxr::JsValue(x.protoEnd);
    result["numPreLoops"] = pxr::JsValue(x.numPreLoops);
    result["numPostLoops"] = pxr::JsValue(x.numPostLoops);
    result["valueOffset"] = pxr::JsValue(x.valueOffset);
    
    return result;
}

pxr::TsKnotMap extractTsKnotMap(const pxr::JsValue& js, const pxr::SdfValueTypeName& type) {
    pxr::TsKnotMap result;
    const pxr::JsArray& arr = js.GetJsArray();

    for (const auto& it : arr) {
        result.insert(extractTsKnot(it, type));
    }
    return result;
}
pxr::JsValue writeTsKnotMap(const pxr::TsKnotMap& x) {
    pxr::JsArray arr;
    for (const auto& it : x) {
        arr.push_back(writeTsKnot(it));
    }
    return arr;
}

pxr::TsKnot extractTsKnot(const pxr::JsValue& js, const pxr::SdfValueTypeName& type) {
    pxr::TsKnot result = pxr::TsKnot(type.GetType());
    const pxr::JsObject& obj = js.GetJsObject();
    
    try {
        result.SetTime(obj.at("time").GetReal());
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot time") pxr::TsKnot();
    }
    
    try {
        int nextInterpolation = obj.at("nextInterpolation").GetInt();
        result.SetNextInterpolation(static_cast<pxr::TsInterpMode>(nextInterpolation));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot nextInterpolation") pxr::TsKnot();
    }

    TypedValue value = TypedValue::forTypeName(type);
    try {
        extractValueWithTypeHint(&value, obj.at("value"));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot value") pxr::TsKnot();
    }
    result.SetValue(value.value);

    ifValueExists(obj, "preValue", [&](const auto& x){
        TypedValue preValue = TypedValue::forTypeName(type);
        extractValueWithTypeHint(&preValue, x);
        result.SetPreValue(preValue.value);
    });
    
    try {
        result.SetPreTanWidth(obj.at("preTanWidth").GetReal());
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot preTanWidth") pxr::TsKnot();
    }

    
    TypedValue preTanSlope = TypedValue::forTypeName(type);
    try {
        extractValueWithTypeHint(&preTanSlope, obj.at("preTanSlope"));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot preTanSlope") pxr::TsKnot();
    }
    result.SetPreTanSlope(preTanSlope.value);
    
    try {
        int preTanAlgorithm = obj.at("preTanAlgorithm").GetInt();
        result.SetPreTanAlgorithm(static_cast<pxr::TsTangentAlgorithm>(preTanAlgorithm));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot preTanAlgorithm") pxr::TsKnot();
    }
    
    try {
        pxr::TsTime postTanWidth = obj.at("postTanWidth").GetReal();
        result.SetPostTanWidth(postTanWidth);
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot postTanWidth") pxr::TsKnot();
    }
    
    TypedValue postTanSlope = TypedValue::forTypeName(type);
    try {
        extractValueWithTypeHint(&postTanSlope, obj.at("postTanSlope"));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot postTanSlope") pxr::TsKnot();
    }
    result.SetPostTanSlope(postTanSlope.value);
    
    try {
        int postTanAlgorithm = obj.at("postTanAlgorithm").GetInt();
        result.SetPostTanAlgorithm(static_cast<pxr::TsTangentAlgorithm>(postTanAlgorithm));
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("TsKnot postTanAlgorithm") pxr::TsKnot();
    }
    
    ifValueExists(obj, "customData", [&](const auto& x){
        result.SetCustomData(extractVtDictionary(x));
    });
    
    return result;
}
pxr::JsValue writeTsKnot(const pxr::TsKnot& x) {
    pxr::JsObject result;
    
    result["time"] = pxr::JsValue(x.GetTime());
    result["nextInterpolation"] = pxr::JsValue(x.GetNextInterpolation());
    
    pxr::VtValue value;
    x.GetValue(&value);
    result["value"] = writeValueWithoutTypeHint(TypedValue::forVtValue(value));
    
    if (x.IsDualValued()) {
        pxr::VtValue pre;
        x.GetPreValue(&pre);
        result["preValue"] = writeValueWithoutTypeHint(TypedValue::forVtValue(pre));
    }
    result["preTanWidth"] = pxr::JsValue(x.GetPreTanWidth());
    
    pxr::VtValue preTanSlope;
    x.GetPreTanSlope(&preTanSlope);
    result["preTanSlope"] = writeValueWithoutTypeHint(TypedValue::forVtValue(preTanSlope));
    
    result["preTanAlgorithm"] = pxr::JsValue(x.GetPreTanAlgorithm());
    
    result["postTanWidth"] = pxr::JsValue(x.GetPostTanWidth());
    
    pxr::VtValue postTanSlope;
    x.GetPostTanSlope(&postTanSlope);
    result["postTanSlope"] = writeValueWithoutTypeHint(TypedValue::forVtValue(postTanSlope));
    
    result["postTanAlgorithm"] = pxr::JsValue(x.GetPostTanAlgorithm());
    
    result["customData"] = writeVtDictionary(x.GetCustomData());
    
    return result;
}
