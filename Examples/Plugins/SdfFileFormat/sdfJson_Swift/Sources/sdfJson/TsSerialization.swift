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
import CxxStdlib
import OpenUSD
import TemporaryImplementations_Cxx
import TemporaryImplementations_Swift

func extractTsSpline(_ js: JsAny, _ type: pxr.SdfValueTypeName) throws -> pxr.TsSpline {
    var result = pxr.TsSpline(type.GetType())
    let obj = try js.castAsObject()
    
    let curveType = try obj["curveType", errorMessage: "TsSpline"].castAsInt()
    result.SetCurveType(pxr.TsCurveType(rawValue: UInt32(curveType)))
    
    let preExtrapolation = try extractTsExtrapolation(obj["preExtrapolation", errorMessage: "TsSpline"])
    result.SetPreExtrapolation(preExtrapolation)
    
    let postExtrapolation = try extractTsExtrapolation(obj["postExtrapolation", errorMessage: "TsSpline"])
    result.SetPostExtrapolation(postExtrapolation)
    
    let loopParams = try extractTsLoopParams(obj["innerLoopParams", errorMessage: "TsSpline"])
    result.SetInnerLoopParams(loopParams)
    
    let knots = try extractTsKnotMap(obj["knots", errorMessage: "TsSpline"], type)
    if !knots.empty() {
        // TsSpline::SetKnots checks if the spline's type matches the knot map's type.
        // However, empty knot maps return the unknown type, so the comparison erronously fails.
        // Arguably, TsSpline::SetKnots shouldn't report an error in this case, but we can
        // just not set the knots with empty knot maps.
        result.SetKnots(knots)
    }
    
    return result
}
func writeTsSpline(_ x: pxr.TsSpline) throws -> JsAny {
    [
        "curveType" : .int(Int(x.GetCurveType().rawValue)),
        "preExtrapolation" : writeTsExtrapolation(x.GetPreExtrapolation()),
        "postExtrapolation" : writeTsExtrapolation(x.GetPostExtrapolation()),
        "innerLoopParams" : writeTsLoopParams(x.GetInnerLoopParams()),
        "knots" : try writeTsKnotMap(x.GetKnots()),
    ]
}

func extractTsExtrapolation(_ js: JsAny) throws -> pxr.TsExtrapolation {
    var result = pxr.TsExtrapolation()
    let obj = try js.castAsObject()
    
    let mode = try obj["mode", errorMessage: "TsExtrapolation"].castAsInt()
    result.mode = pxr.TsExtrapMode(rawValue: UInt32(mode))
    
    result.slope = try obj["slope", errorMessage: "TsExtrapolation"].castAsNumber()
    
    if let x = try obj["loopBoundaryTime"]?.castAsNumber() {
        // Starting in Swift 6.3 (or 6.4?), it becomes easier to work with std::optional in Swift thanks to
        // https://github.com/swiftlang/swift/commit/26e9907c8a10f79de06360db53778b436acc3dc9,
        // but since we want to support before that, we need to handle things ourselves
        result.loopBoundaryTime = .init(x)
    } else {
        result.loopBoundaryTime = nil
    }
    
    return result
}
func writeTsExtrapolation(_ x: pxr.TsExtrapolation) -> JsAny {
    var result = [String : JsAny]()
    
    result["mode"] = .int(Int(x.mode.rawValue))
    result["slope"] = .number(x.slope)
    if x.loopBoundaryTime.has_value() {
        result["loopBoundaryTime"] = .number(x.loopBoundaryTime.pointee)
    }
    
    return .object(result)
}

func extractTsLoopParams(_ js: JsAny) throws -> pxr.TsLoopParams {
    var result = pxr.TsLoopParams()
    let obj = try js.castAsObject()
    
    result.protoStart = try obj["protoStart", errorMessage: "TsLoopParams"].castAsNumber()
    result.protoEnd = try obj["protoEnd", errorMessage: "TsLoopParams"].castAsNumber()
    result.numPreLoops = Int32(try obj["numPreLoops", errorMessage: "TsLoopParams"].castAsInt())
    result.numPostLoops = Int32(try obj["numPostLoops", errorMessage: "TsLoopParams"].castAsInt())
    result.valueOffset = try obj["valueOffset", errorMessage: "TsLoopParams"].castAsNumber()
    
    return result
}
func writeTsLoopParams(_ x: pxr.TsLoopParams) -> JsAny {
    [
        "protoStart": .number(x.protoStart),
        "protoEnd": .number(x.protoEnd),
        "numPreLoops": .int(Int(x.numPreLoops)),
        "numPostLoops": .int(Int(x.numPostLoops)),
        "valueOffset": .number(x.valueOffset),
    ]
}

func extractTsKnotMap(_ js: JsAny, _ type: pxr.SdfValueTypeName) throws -> pxr.TsKnotMap {
    var result = pxr.TsKnotMap()
    let arr = try js.castAsArray()
    
    for x in arr {
        result.insert(try extractTsKnot(x, type))
    }
    return result
}
func writeTsKnotMap(_ x: pxr.TsKnotMap) throws -> JsAny {
    var arr = [JsAny]()
    for y in x {
        arr.append(try writeTsKnot(y))
    }
    return .array(arr)
}

func extractTsKnot(_ js: JsAny, _ type: pxr.SdfValueTypeName) throws -> pxr.TsKnot {
    var result = pxr.TsKnot(type.GetType())
    let obj = try js.castAsObject()
    
    result.SetTime(try obj["time", errorMessage: "TsKnot"].castAsNumber())
    
    let nextInterpolation = try obj["nextInterpolation", errorMessage: "TsKnot"].castAsInt()
    result.SetNextInterpolation(pxr.TsInterpMode(rawValue: UInt32(nextInterpolation)))
    
    var value = TypedValue(typeName: type)
    try extractValueWithTypeHint(&value, obj["value", errorMessage: "TsKnot"])
    result.SetValue(value.value)
    
    if let x = obj["preValue"] {
        var preValue = TypedValue(typeName: type)
        try extractValueWithTypeHint(&preValue, x)
        result.SetPreValue(preValue.value)
    }
    
    result.SetPreTanWidth(try obj["preTanWidth", errorMessage: "TsKnot"].castAsNumber())
    
    var preTanSlope = TypedValue(typeName: type)
    try extractValueWithTypeHint(&preTanSlope, obj["preTanSlope", errorMessage: "TsKnot"])
    result.SetPreTanSlope(preTanSlope.value)
    
    let preTanAlgorithm = try obj["preTanAlgorithm", errorMessage: "TsKnot"].castAsInt()
    result.SetPreTanAlgorithm(pxr.TsTangentAlgorithm(rawValue: UInt32(preTanAlgorithm)))
    

    result.SetPostTanWidth(try obj["postTanWidth", errorMessage: "TsKnot"].castAsNumber())
    
    var postTanSlope = TypedValue(typeName: type)
    try extractValueWithTypeHint(&postTanSlope, obj["postTanSlope", errorMessage: "TsKnot"])
    result.SetPostTanSlope(postTanSlope.value)
    
    let postTanAlgorithm = try obj["postTanAlgorithm", errorMessage: "TsKnot"].castAsInt()
    result.SetPostTanAlgorithm(pxr.TsTangentAlgorithm(rawValue: UInt32(postTanAlgorithm)))
    
    if let x = obj["customData"] {
        result.SetCustomData(try extractVtDictionary(x))
    }
    
    return result
}

func writeTsKnot(_ x: pxr.TsKnot) throws -> JsAny {
    var result = [String : JsAny]()
    
    result["time"] = .number(x.GetTime())
    result["nextInterpolation"] = .int(Int(x.GetNextInterpolation().rawValue))
    
    var value = pxr.VtValue()
    Overlay.GetValue(x, &value)
    result["value"] = try writeValueWithoutTypeHint(TypedValue(vtValue: value))
    
    if x.IsDualValued() {
        var pre = pxr.VtValue()
        Overlay.GetPreValue(x, &pre)
        result["preValue"] = try writeValueWithoutTypeHint(TypedValue(vtValue: pre))
    }
    
    result["preTanWidth"] = .number(x.GetPreTanWidth())
    
    var preTanSlope = pxr.VtValue()
    Overlay.GetPreTanSlope(x, &preTanSlope)
    result["preTanSlope"] = try writeValueWithoutTypeHint(TypedValue(vtValue: preTanSlope))
    
    result["preTanAlgorithm"] = .int(Int(x.GetPreTanAlgorithm().rawValue))
    
    result["postTanWidth"] = .number(x.GetPostTanWidth())
    
    var postTanSlope = pxr.VtValue()
    Overlay.GetPostTanSlope(x, &postTanSlope)
    result["postTanSlope"] = try writeValueWithoutTypeHint(TypedValue(vtValue: postTanSlope))
    
    result["postTanAlgorithm"] = .int(Int(x.GetPostTanAlgorithm().rawValue))
    
    result["customData"] = try writeVtDictionary(x.GetCustomData())
    
    return .object(result)
}

