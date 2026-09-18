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

#ifndef LIVERPSSerialization_hpp
#define LIVERPSSerialization_hpp

#include <stdio.h>
#include "pxr/base/js/value.h"
#include "pxr/base/js/json.h"
#include "pxr/usd/sdf/listOp.h"
#include "pxr/usd/sdf/layer.h"
#include "pxr/usd/sdf/variantSetSpec.h"
#include "pxr/usd/sdf/variantSpec.h"
#include "pxr/usd/sdf/reference.h"
#include "pxr/usd/sdf/payload.h"
#include "Diagnostics.hpp"

template <typename Element, typename ConvertElement>
pxr::JsValue writeSdfListProxy(pxr::SdfListProxy<Element> proxy, ConvertElement convertElement) {
    pxr::JsArray result;
    
    for (const auto& element : proxy) {
        result.push_back(convertElement(element));
    }
    return result;
}

template <typename Element, typename ConvertElement>
std::vector<Element> extractSdfListProxy(const pxr::JsValue& js, ConvertElement convertElement) {
    std::vector<Element> result;
    
    for (const auto& it : js.GetJsArray()) {
        result.push_back(convertElement(it));
    }
    
    return result;
}


template <typename Policy, typename ConvertElement>
pxr::JsValue writeSdfListEditorProxy(pxr::SdfListEditorProxy<Policy> proxy, ConvertElement convertElement) {
    using Element = typename pxr::SdfListEditorProxy<Policy>::value_type;
    pxr::JsObject result;
    
    auto handleIndividualListProxy = [&](pxr::SdfListProxy<Policy> list, std::string key){
        if (!list.empty()) {
            result[key] = writeSdfListProxy(list, convertElement);
        }
    };
    
    handleIndividualListProxy(proxy.GetExplicitItems(), "explicit");
    handleIndividualListProxy(proxy.GetAddedItems(), "add");
    handleIndividualListProxy(proxy.GetPrependedItems(), "prepend");
    handleIndividualListProxy(proxy.GetAppendedItems(), "append");
    handleIndividualListProxy(proxy.GetDeletedItems(), "delete");
    handleIndividualListProxy(proxy.GetOrderedItems(), "order");

    if (result.empty() && proxy.IsExplicit()) {
        result["explicit"] = pxr::JsArray();
    }
    
    return result;
}

template <typename Policy, typename ConvertElement>
void extractSdfListEditorProxy(const pxr::JsValue& js, pxr::SdfListEditorProxy<Policy> proxy, ConvertElement convertElement) {
    using Element = typename pxr::SdfListEditorProxy<Policy>::value_type;
    const pxr::JsObject& obj = js.GetJsObject();
    
    auto handleIndividualListProxy = [&](pxr::SdfListProxy<Policy> list, std::string key) {
        ifValueExists(obj, key, [&](const auto& x){
            std::vector<Element> toInsert = extractSdfListProxy<Element>(x, convertElement);
            list.insert(list.end(), toInsert.begin(), toInsert.end());
        });
    };
    
    handleIndividualListProxy(proxy.GetExplicitItems(), "explicit");
    handleIndividualListProxy(proxy.GetAddedItems(), "add");
    handleIndividualListProxy(proxy.GetPrependedItems(), "prepend");
    handleIndividualListProxy(proxy.GetAppendedItems(), "append");
    handleIndividualListProxy(proxy.GetDeletedItems(), "delete");
    handleIndividualListProxy(proxy.GetOrderedItems(), "order");

    if (obj.find("explicit") != obj.end() && !proxy.HasKeys()) {
        proxy.ClearEditsAndMakeExplicit();
    }
}

template <typename Element, typename ConvertElement>
pxr::JsValue writeSdfListOp(pxr::SdfListOp<Element> proxy, ConvertElement convertElement) {
    pxr::JsObject result;
    
    auto writeIndividualArray = [&](const std::vector<Element>& items, std::string key) {
        pxr::JsArray arr;
        for (const auto& x : items) {
            arr.push_back(convertElement(x));
        }
        if (!arr.empty()) {
            result[key] = arr;
        }
    };
    
    writeIndividualArray(proxy.GetExplicitItems(), "explicit");
    writeIndividualArray(proxy.GetAddedItems(), "add");
    writeIndividualArray(proxy.GetPrependedItems(), "prepend");
    writeIndividualArray(proxy.GetAppendedItems(), "append");
    writeIndividualArray(proxy.GetDeletedItems(), "delete");
    writeIndividualArray(proxy.GetOrderedItems(), "order");
    if (result.empty() && proxy.IsExplicit()) {
        result["explicit"] = pxr::JsArray();
    }
    
    return result;
}

template <typename Element, typename ConvertElement>
pxr::SdfListOp<Element> extractSdfListOp(const pxr::JsValue& js, ConvertElement convertElement) {
    pxr::SdfListOp<Element> result;
    const pxr::JsObject& obj = js.GetJsObject();
        
    auto extractIndividualArray = [&](std::string jsKey, auto setter) {
        ifValueExists(obj, jsKey, [&](const auto& x){
            std::vector<Element> result;
            
            for (const auto& it : x.GetJsArray()) {
                result.push_back(convertElement(it));
            }
            
            setter(result);
        });
    };
        
    extractIndividualArray("explicit", [&](const auto& x){ result.SetExplicitItems(x); });
    extractIndividualArray("add", [&](const auto& x){ result.SetAddedItems(x); });
    extractIndividualArray("prepend", [&](const auto& x){ result.SetPrependedItems(x); });
    extractIndividualArray("append", [&](const auto& x){ result.SetAppendedItems(x); });
    extractIndividualArray("delete", [&](const auto& x){ result.SetDeletedItems(x); });
    extractIndividualArray("order", [&](const auto& x){ result.SetOrderedItems(x); });
    
    return result;
}


pxr::SdfLayerOffset extractSdfLayerOffset(const pxr::JsValue& js);
pxr::JsValue writeSdfLayerOffset(const pxr::SdfLayerOffset& x);

pxr::SdfLayerOffsetVector extractSdfLayerOffsetVector(const pxr::JsValue& js);
void writeSubLayerOffsetsIfNeeded(pxr::JsObject& js, const pxr::SdfLayerOffsetVector& offsets);


void extractPrimRelocates(const pxr::JsValue& js, const pxr::SdfPrimSpecHandle& prim);
pxr::JsValue writePrimRelocates(const pxr::SdfRelocatesMapProxy& list);

void extractLayerRelocates(const pxr::SdfLayerRefPtr& layer, const pxr::JsValue& js);
pxr::JsValue writeLayerRelocates(const pxr::SdfRelocates& list);

void extractVariantSelections(const pxr::SdfPrimSpecHandle& prim, const pxr::JsValue& js);
void writeVariantSelectionsIfNeeded(pxr::JsObject& js, const pxr::SdfVariantSelectionProxy& selections);


void readVariantSets(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsValue& js);
void writeVariantSetsIfNeeded(pxr::JsObject& js, const pxr::SdfVariantSetsProxy& sets);


void readVariantSetSpec(const pxr::JsValue& js, const pxr::SdfVariantSetSpecHandle& variantSet);
pxr::JsValue writeVariantSetSpec(const pxr::SdfVariantSetSpecHandle& variantSet);


#endif /* LIVERPSSerialization_hpp */
