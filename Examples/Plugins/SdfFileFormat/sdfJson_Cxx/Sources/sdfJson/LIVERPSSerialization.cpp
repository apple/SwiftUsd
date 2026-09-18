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

#include "LIVERPSSerialization.hpp"
#include "CoreSpecSerialization.hpp"
#include "Diagnostics.hpp"
#include "FundementalTypes.hpp"


pxr::SdfLayerOffset extractSdfLayerOffset(const pxr::JsValue& js) {
    const pxr::JsArray& arr = js.GetJsArray();
    if (arr.size() != 2) {
        MY_RUNTIME_ERROR_AND_RETURN("SdfLayerOffset should be 2-element array, had length %zu", arr.size()) pxr::SdfLayerOffset();
    }
    
    return pxr::SdfLayerOffset(arr[0].GetReal(),
                               arr[1].GetReal());
}
pxr::JsValue writeSdfLayerOffset(const pxr::SdfLayerOffset& x) {
    return pxr::JsArray({
        pxr::JsValue(x.GetOffset()),
        pxr::JsValue(x.GetScale())
    });
}


pxr::SdfLayerOffsetVector extractSdfLayerOffsetVector(const pxr::JsValue& js) {
    pxr::SdfLayerOffsetVector result;
    const pxr::JsArray& arr = js.GetJsArray();

    for (const auto& x : arr) {
        result.push_back(extractSdfLayerOffset(x));
    }
    return result;
}
void writeSubLayerOffsetsIfNeeded(pxr::JsObject& js, const pxr::SdfLayerOffsetVector& offsets) {
    pxr::JsArray result;
    bool shouldWrite = false;
    
    for (const auto& x : offsets) {
        shouldWrite = shouldWrite || !x.IsIdentity();
        result.push_back(writeSdfLayerOffset(x));
    }
    
    if (shouldWrite) {
        js["subLayerOffsets"] = result;
    }
}

void extractPrimRelocates(const pxr::JsValue& js, const pxr::SdfPrimSpecHandle& prim) {
    const pxr::JsObject& obj = js.GetJsObject();

    pxr::SdfRelocatesMapProxy proxy = prim->GetRelocates();
    
    ifValueExists(obj, "relocates", [&](const auto& x){
        for (const auto& it : x.GetJsObject()) {
            proxy.insert({pxr::SdfPath(it.first), pxr::SdfPath(it.second.GetString())});
        }
        if (x.GetJsObject().empty()) {
            prim->SetField(pxr::SdfFieldKeys->Relocates, pxr::VtValue(pxr::SdfRelocatesMap()));
        }
    });
}

pxr::JsValue writePrimRelocates(const pxr::SdfRelocatesMapProxy& list) {
    pxr::JsObject result;
    for (const auto& it : list) {
        result[it.first.GetString()] = pxr::JsValue(it.second.GetString());
    }
    return result;
}

void extractLayerRelocates(const pxr::SdfLayerRefPtr& layer, const pxr::JsValue& js) {
    
    const pxr::JsObject& obj = js.GetJsObject();

    ifValueExists(obj, "relocates", [&](const auto& x){
        pxr::SdfRelocates relocates;
        for (const auto& entry : x.GetJsArray()) {
            const pxr::JsArray& subArr = entry.GetJsArray();
            MY_VERIFY(subArr.size() == 2,
                      "Layer relocates entry must be string-string pair");
            if (subArr.size() == 2) {
                relocates.push_back({pxr::SdfPath(subArr[0].GetString()), pxr::SdfPath(subArr[1].GetString())});
            }
        }
        if (!relocates.empty()) {
            layer->SetRelocates(relocates);
        }
    });
}
pxr::JsValue writeLayerRelocates(const pxr::SdfRelocates& list) {
    pxr::JsArray result;
    for (const auto& it : list) {
        result.push_back(pxr::JsArray({
            pxr::JsValue(it.first.GetString()),
            pxr::JsValue(it.second.GetString())
        }));
    }
    return result;
}

void extractVariantSelections(const pxr::SdfPrimSpecHandle& prim, const pxr::JsValue& js) {
    for (const auto& it : js.GetJsObject()) {
        prim->SetVariantSelection(it.first, it.second.GetString());
    }

    return;
}

void writeVariantSelectionsIfNeeded(pxr::JsObject& js, const pxr::SdfVariantSelectionProxy& selections) {
    if (!selections || selections.empty()) { return; }

    pxr::JsObject result;

    for (const auto& x : selections) {
        result[x.first] = pxr::JsValue(x.second);
    }

    js["variantSelections"] = result;
}

void readVariantSets(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsValue& js) {
    const pxr::JsArray& arr = js.GetJsArray();
    
    const pxr::SdfPrimSpecHandle& prim = layer->GetPrimAtPath(path);
    
    for (const auto& variantSetSuperObjectElement : arr) {
        const pxr::JsObject& variantSetSuperObject = variantSetSuperObjectElement.GetJsObject();
        
        MY_VERIFY(variantSetSuperObject.size() == 2,
                  "Variant set super object must have size 2");
        std::string variantSetName;
        try {
            variantSetName = variantSetSuperObject.at("name").GetString();
        } catch (const std::out_of_range&) {
            MY_RUNTIME_ERROR_AND_RETURN("Variant set super object must have name key");
        }
        
        try {
            const pxr::JsObject& jsVariantSet = variantSetSuperObject.at("contents").GetJsObject();
            
            pxr::SdfVariantSetSpecHandle sdfVset;
            auto it = prim->GetVariantSets().find(variantSetName);
            if (it == prim->GetVariantSets().end()) {
                sdfVset = pxr::SdfVariantSetSpec::New(prim, variantSetName);
            } else {
                sdfVset = it->second;
            }

            readVariantSetSpec(jsVariantSet, sdfVset);

        } catch (const std::out_of_range&){
            MY_RUNTIME_ERROR_AND_RETURN("Variant set super object must have contents key");
        }
    }
    
    return;
}


void writeVariantSetsIfNeeded(pxr::JsObject& js, const pxr::SdfVariantSetsProxy& sets) {
    if (!sets || sets.empty()) { return; }
    
    pxr::JsArray result;
    
    for (const auto& x : sets) {
        pxr::JsObject temp;
        temp["name"] = pxr::JsValue(x.first);
        temp["contents"] = writeVariantSetSpec(x.second);
        result.push_back(temp);
    }
    
    js["variantSets"] = result;
}


void readVariantSetSpec(const pxr::JsValue& js, const pxr::SdfVariantSetSpecHandle& variantSet) {
    
    const pxr::JsObject& jsVariantSet = js.GetJsObject();
    
    for (const auto& it : jsVariantSet) {
        const pxr::SdfVariantView& variantView = variantSet->GetVariants();
        pxr::SdfVariantSpecHandle vspecHandle;
        if (variantView.find(it.first) == variantView.end()) {
            // Important: Use variantSet->GetOwner()->GetPath() and not variantSet->GetPath().StripAllVariantSelections(),
            // because the latter does not handle nested variant sets correctly but the former does.
            pxr::SdfPath ownerPath = variantSet->GetOwner()->GetPath();
            vspecHandle = pxr::SdfCreateVariantInLayer(variantSet->GetLayer(), ownerPath, variantSet->GetName(), it.first);
        } else {
            vspecHandle = *variantView.find(it.first);
        }

        
        const pxr::JsObject& jsVspecPrimSpec = it.second.GetJsObject();
        readPrim(variantSet->GetLayer(), vspecHandle->GetPrimSpec(), jsVspecPrimSpec);
    }
}

pxr::JsValue writeVariantSetSpec(const pxr::SdfVariantSetSpecHandle& variantSet) {
    pxr::JsObject result;
    
    for (const auto& variant : variantSet->GetVariants()) {
        pxr::JsObject jsVariant;
        writePrim(jsVariant, variant->GetPrimSpec());
        result[variant->GetName()] = jsVariant;
    }
    
    return result;
}
