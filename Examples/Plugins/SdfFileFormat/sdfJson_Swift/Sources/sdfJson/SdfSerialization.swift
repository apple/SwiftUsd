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

func extractSdfAnimationBlock(_ js: JsAny) throws -> pxr.SdfAnimationBlock {
    guard js == ["AnimationBlock" : .null] else {
        throw JsDecodingError.sdfAnimationBlockDeserializationError
    }
    return pxr.SdfAnimationBlock()
}
func writeSdfAnimationBlock(_ x: pxr.SdfAnimationBlock) -> JsAny {
    ["AnimationBlock" : .null]
}

func extractSdfPath(_ js: JsAny) throws -> pxr.SdfPath {
    pxr.SdfPath(try js.castAsString())
}
func writeSdfPath(_ x: pxr.SdfPath) -> JsAny {
    .string(String(x))
}

func extractSdfUnregisteredValue(_ js: JsAny) throws -> pxr.SdfUnregisteredValue {
    let obj = try js.castAsObject()
    guard obj.count == 2 else {
        throw JsDecodingError.sdfUnregisteredValueDeserializationError
    }

    let type = try obj["type", errorMessage: "SdfUnregisteredValue"].castAsString()
    
    let value = try obj["SdfUnregisteredValue", errorMessage: "SdfUnregisteredValue"]
    
    if type == "string" {
        return pxr.SdfUnregisteredValue(std.string(try value.castAsString()))
    } else if type == "VtDictionary" {
        return pxr.SdfUnregisteredValue(try extractVtDictionary(value))
    } else if type == "SdfUnregisteredValueListOp" {
        let l = try extractSdfListOp(pxr.SdfUnregisteredValueListOp.self, value, extractSdfUnregisteredValue)
        return pxr.SdfUnregisteredValue(l)
    } else {
        throw JsDecodingError.sdfUnregisteredValueDeserializationError
    }
}
func writeSdfUnregisteredValue(_ x: pxr.SdfUnregisteredValue) throws -> JsAny {
    var copy = x.GetValue()
    
    if copy.IsHolding(T: std.string.self) {
        return [
            "SdfUnregisteredValue" : .string(String(copy.Get() as std.string)),
            "type" : "string"
        ]
    } else if copy.IsHolding(T: pxr.VtDictionary.self) {
        return [
            "SdfUnregisteredValue" : try writeVtDictionary(copy.Get() as pxr.VtDictionary),
            "type" : "VtDictionary"
        ]
    } else if copy.IsHolding(T: pxr.SdfUnregisteredValueListOp.self) {
        return [
            "SdfUnregisteredValue" : try writeSdfListOp(copy.Get() as pxr.SdfUnregisteredValueListOp, writeSdfUnregisteredValue),
            "type" : "SdfUnregisteredValueListOp"
        ]
    } else {
        TF_WARN("Unknown contents of SdfUnregisteredValue")
    }
    return [:]
}

func extractSdfReference(_ js: JsAny) throws -> pxr.SdfReference {
    let obj = try js.castAsObject()
    var result = pxr.SdfReference(std.string(), pxr.SdfPath(), pxr.SdfLayerOffset(0, 1), pxr.VtDictionary())
    
    if let x = obj["asset"] {
        result.SetAssetPath(std.string(try x.castAsString()))
    }
    if let x = obj["prim"] {
        result.SetPrimPath(try extractSdfPath(x))
    }
    if let x = obj["offset"] {
        result.SetLayerOffset(try extractSdfLayerOffset(x))
    }
    if let x = obj["customData"] {
        result.SetCustomData(try extractVtDictionary(x))
    }
    
    return result
}
func writeSdfReference(_ x: pxr.SdfReference) throws -> JsAny {
    var result = [String : JsAny]()
    
    if !x.GetAssetPath().empty() {
        result["asset"] = .string(String(x.GetAssetPath()))
    }
    if !x.GetPrimPath().IsEmpty() {
        result["prim"] = writeSdfPath(x.GetPrimPath())
    }
    if !x.GetLayerOffset().IsIdentity() {
        result["offset"] = writeSdfLayerOffset(x.GetLayerOffset())
    }
    if !x.GetCustomData().empty() {
        result["customData"] = try writeVtDictionary(x.GetCustomData())
    }
    
    return .object(result)
}

func extractSdfPayload(_ js: JsAny) throws -> pxr.SdfPayload {
    let obj = try js.castAsObject()
    var result = pxr.SdfPayload(std.string(), pxr.SdfPath(), pxr.SdfLayerOffset(0, 1))
    
    if let x = obj["asset"] {
        result.SetAssetPath(std.string(try x.castAsString()))
    }
    if let x = obj["prim"] {
        result.SetPrimPath(try extractSdfPath(x))
    }
    if let x = obj["offset"] {
        result.SetLayerOffset(try extractSdfLayerOffset(x))
    }
    
    return result
}
func writeSdfPayload(_ x: pxr.SdfPayload) -> JsAny {
    var result = [String : JsAny]()
    
    if !x.GetAssetPath().empty() {
        result["asset"] = .string(String(x.GetAssetPath()))
    }
    if !x.GetPrimPath().IsEmpty() {
        result["prim"] = writeSdfPath(x.GetPrimPath())
    }
    if !x.GetLayerOffset().IsIdentity() {
        result["offset"] = writeSdfLayerOffset(x.GetLayerOffset())
    }
    
    return .object(result)
}
