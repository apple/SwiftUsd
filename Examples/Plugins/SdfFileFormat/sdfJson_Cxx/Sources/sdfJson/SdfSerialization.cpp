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

#include "SdfSerialization.hpp"
#include "Diagnostics.hpp"
#include "FundementalTypes.hpp"
#include "VtSerialization.hpp"
#include "pxr/usd/sdf/reference.h"
#include "pxr/usd/sdf/payload.h"

pxr::SdfAnimationBlock extractSdfAnimationBlock(const pxr::JsValue& js) {
    if (js == pxr::JsObject({ {"AnimationBlock", pxr::JsValue()} })) {
        return pxr::SdfAnimationBlock();
    }
    MY_RUNTIME_ERROR_AND_RETURN("SdfAnimationBlock deserialization error") pxr::SdfAnimationBlock();
}
pxr::JsValue writeSdfAnimationBlock(const pxr::SdfAnimationBlock& x) {
    return pxr::JsObject({ {"AnimationBlock", pxr::JsValue()} });
}

pxr::SdfPath extractSdfPath(const pxr::JsValue& x) {
    return pxr::SdfPath(x.GetString());
}
pxr::JsValue writeSdfPath(const pxr::SdfPath& x) {
    return pxr::JsValue(x.GetString());
}

pxr::SdfUnregisteredValue extractSdfUnregisteredValue(const pxr::JsValue& js) {
    const pxr::JsObject& obj = js.GetJsObject();
    
    MY_VERIFY(obj.size() == 2, "SdfUnregisteredValue expects two keys");

    std::string type;
    try {
        type = obj.at("type").GetString();
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("SdfUnregisteredValue must have 'type' key") pxr::SdfUnregisteredValue();
    }
    
    try {
        const pxr::JsValue& value = obj.at("SdfUnregisteredValue");
        
        if (type == "string") {
            return pxr::SdfUnregisteredValue(value.GetString());
        } else if (type == "VtDictionary") {
            return pxr::SdfUnregisteredValue(extractVtDictionary(value));
        } else if (type == "SdfUnregisteredValueListOp") {
            pxr::SdfUnregisteredValueListOp l = extractSdfListOp<pxr::SdfUnregisteredValue>(value, extractSdfUnregisteredValue);
            return pxr::SdfUnregisteredValue(l);
        } else {
            MY_RUNTIME_ERROR_AND_RETURN("Unknown type '%s' for SdfUnregisteredValue", type.c_str()) pxr::SdfUnregisteredValue();
        }
    } catch (const std::out_of_range&) {
        MY_RUNTIME_ERROR_AND_RETURN("SdfUnregistered value must have 'SdfUnregisteredValue' key") pxr::SdfUnregisteredValue();
    }
}

pxr::JsValue writeSdfUnregisteredValue(const pxr::SdfUnregisteredValue &value) {
    pxr::JsObject result;

    if (value.GetValue().IsHolding<std::string>()) {
        std::string contents = value.GetValue().Get<std::string>();
        result["SdfUnregisteredValue"] = pxr::JsValue(contents);
        result["type"] = pxr::JsValue("string");
        return result;
    } else if (value.GetValue().IsHolding<pxr::VtDictionary>()) {
        pxr::VtDictionary contents = value.GetValue().Get<pxr::VtDictionary>();
        result["SdfUnregisteredValue"] = writeVtDictionary(contents);
        result["type"] = pxr::JsValue("VtDictionary");
        return result;
    } else if (value.GetValue().IsHolding<pxr::SdfUnregisteredValueListOp>()) {
        pxr::SdfUnregisteredValueListOp contents = value.GetValue().Get<pxr::SdfUnregisteredValueListOp>();
        result["SdfUnregisteredValue"] = writeSdfListOp(contents, writeSdfUnregisteredValue);
        result["type"] = pxr::JsValue("SdfUnregisteredValueListOp");
        return result;
    } else {
        MY_WARN("Unknown contents of SdfUnregisteredValue");
    }
    return result;
}

pxr::SdfReference extractSdfReference(const pxr::JsValue& js) {
    const pxr::JsObject& obj = js.GetJsObject();
    pxr::SdfReference result;
    
    ifValueExists(obj, "asset", [&](const auto& x){
        result.SetAssetPath(x.GetString());
    });
    ifValueExists(obj, "prim", [&](const auto& x){
        result.SetPrimPath(extractSdfPath(x));
    });
    ifValueExists(obj, "offset", [&](const auto& x){
        result.SetLayerOffset(extractSdfLayerOffset(x));
    });
    ifValueExists(obj, "customData", [&](const auto& x){
        result.SetCustomData(extractVtDictionary(x));
    });
    
    return result;
}

pxr::JsValue writeSdfReference(const pxr::SdfReference& reference) {
    pxr::JsObject result;
    
    if (!reference.GetAssetPath().empty()) {
        result["asset"] = pxr::JsValue(reference.GetAssetPath());
    }
    if (!reference.GetPrimPath().IsEmpty()) {
        result["prim"] = writeSdfPath(reference.GetPrimPath());
    }
    if (!reference.GetLayerOffset().IsIdentity()) {
        result["offset"] = writeSdfLayerOffset(reference.GetLayerOffset());
    }
    if (!reference.GetCustomData().empty()) {
        result["customData"] = writeVtDictionary(reference.GetCustomData());
    }
    
    return result;
}

pxr::SdfPayload extractSdfPayload(const pxr::JsValue& js) {
    const pxr::JsObject& obj = js.GetJsObject();
    pxr::SdfPayload result;
    
    ifValueExists(obj, "asset", [&](const auto& x){
        result.SetAssetPath(x.GetString());
    });
    ifValueExists(obj, "prim", [&](const auto& x){
        result.SetPrimPath(extractSdfPath(x));
    });
    ifValueExists(obj, "offset", [&](const auto& x){
        result.SetLayerOffset(extractSdfLayerOffset(x));
    });
    
    return result;
}

pxr::JsValue writeSdfPayload(const pxr::SdfPayload& payload) {
    pxr::JsObject result;
    
    if (!payload.GetAssetPath().empty()) {
        result["asset"] = pxr::JsValue(payload.GetAssetPath());
    }
    if (!payload.GetPrimPath().IsEmpty()) {
        result["prim"] = writeSdfPath(payload.GetPrimPath());
    }
    if (!payload.GetLayerOffset().IsIdentity()) {
        result["offset"] = writeSdfLayerOffset(payload.GetLayerOffset());
    }
    
    return result;
}
