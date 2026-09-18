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

#include "CoreSpecSerialization.hpp"
#include "FundementalTypes.hpp"
#include "Diagnostics.hpp"
#include "TfSerialization.hpp"
#include "pxr/base/js/json.h"
#include "pxr/usd/ar/resolver.h"
#include "pxr/usd/ar/asset.h"

void readLayer(const pxr::SdfLayerRefPtr& layer, const pxr::JsValue& value) {
    readPrim(layer, layer->GetPseudoRoot(), value);
}

void writeLayer(std::string* s, const pxr::SdfLayer& layer, const std::string& comment) {
    pxr::JsObject js;
    writePrim(js, layer.GetPseudoRoot());
    *s = pxr::JsWriteToString(pxr::JsValue(js));
}

void readMetadata(const pxr::JsValue& js, const pxr::SdfSpecHandle& spec) {
    const pxr::JsObject& metadata = js.GetJsObject();
    
    for (const auto& it : metadata) {
        const pxr::JsObject& jsMetadataValue = it.second.GetJsObject();
        
        TypedValue value = extractTypeHintAndValue(jsMetadataValue);
        
        MY_VERIFY(spec->SetField(pxr::TfToken(it.first), value.value),
                  "Failed to set metadata '%s' on '%s' to '%s'", it.first.c_str(), spec->GetPath().GetText(), pxr::TfStringify(value.value).c_str());
    }
}

void writeMetadata(pxr::JsObject& js, const pxr::SdfSpecHandle& spec) {
    pxr::JsObject metadata;
    for (const auto& key : spec->GetMetaDataInfoKeys()) {
        if (spec->GetField(key).IsEmpty()) { continue; }
        if (key == "typeName" && spec->GetSpecType() == pxr::SdfSpecTypePrim) { continue; }
        if (key == "payload") {
            // For whatever reason, payloads appear as metadata in GetMetaDataInfoKeys. No other
            // composition arcs appear this way. We handle payloads as part of the general LIVERPS handling
            continue;
        }
        
        TypedValue v = TypedValue::forVtValue(spec->GetField(key));
        metadata[key] = writeTypeHintAndValue(v);
    }
    
    // GetMetaDataInfoKeys only handles known/registered metadata, but
    // specs can have unknown metadata on them, e.g. test case one-unknown-metadata.usda.
    // So, pull out all the fields on this spec, and then write out the ones
    // that aren't registered.
    pxr::TfTokenVector registeredFields = spec->GetSchema().GetFields(spec->GetSpecType());
    for (const auto& field : spec->ListFields()) {
        bool isRegistered = false;
        for (const auto& x : registeredFields) {
            if (x == field) {
                if (field == pxr::SdfFieldKeys->Comment && !spec->GetField(field).IsEmpty()) {
                    // pass. Comment isn't provided by GetMetaDataInfoKeys, but is a registered field.
                    // prim specs and property specs can have it.
                } else {
                    isRegistered = true;
                    break;
                }
            }
        }
        if (isRegistered) { continue; }
        
        TypedValue v = TypedValue::forVtValue(spec->GetField(field));
        metadata[field] = writeTypeHintAndValue(v);
    }
    
    if (!metadata.empty()) {
        js["metadata"] = metadata;
    }
}

void dispatchObjectsUnderPrimForReading(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsObject& js, const std::string& key) {
    ifValueExists(js, key, [&](const auto& x){
        for (const auto& it : x.GetJsArray()) {
            const pxr::JsObject& subObject = it.GetJsObject();
            std::string name;
            try {
                name = subObject.at("name").GetString();
            } catch (const std::out_of_range&) {
                MY_RUNTIME_ERROR_AND_RETURN("'%s' must have a name key-value pair at '%s'", key.c_str(), path.GetText());
            }
            
            pxr::SdfPath subPath;
            if (key == "children") {
                subPath = path.AppendChild(pxr::TfToken(name));
            } else {
                subPath = path.AppendProperty(pxr::TfToken(name));
            }
            
            if (key == "children") {
                pxr::SdfCreatePrimInLayer(layer, subPath);
                readPrim(layer, layer->GetPrimAtPath(subPath), subObject);
            } else if (key == "attributes") {
                readAttribute(layer, subPath, subObject);
            } else if (key == "relationships") {
                readRelationship(layer, subPath, subObject);
            } else {
                MY_FATAL_CODING_ERROR("Internal error, invalid dispatch key '%s'", key.c_str());
            }
        }
    });
}

void readPrim(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPrimSpecHandle& handle, const pxr::JsValue& js) {
    if (!handle) { MY_RUNTIME_ERROR_AND_RETURN("readPrim called with an invalid prim handle"); }
    const pxr::JsObject& obj = js.GetJsObject();
    std::string spec;
    try {
        spec = obj.at("spec").GetString();
    } catch (const std::out_of_range&) {
        if (!handle->GetPath().IsAbsoluteRootPath()) {
            MY_RUNTIME_ERROR_AND_RETURN("readPrim requires spec key");
        }
    }
    
    if (spec == "def") {
        handle->SetSpecifier(pxr::SdfSpecifierDef);
    } else if (spec == "over") {
        handle->SetSpecifier(pxr::SdfSpecifierOver);
    } else if (spec == "class") {
        handle->SetSpecifier(pxr::SdfSpecifierClass);
    } else {
        if (handle->GetPath() != pxr::SdfPath::AbsoluteRootPath()) {
            MY_RUNTIME_ERROR_AND_RETURN("Unknown specifier '%s'", spec.c_str());
        }
    }
        
    
    // LIVERPS
    if (handle->GetPath().IsAbsoluteRootPath()) {
        ifValueExists(obj, "subLayers", [&](const auto& x){
            layer->SetSubLayerPaths(extractSdfListProxy<std::string>(x, extractString));
        });

        ifValueExists(obj, "subLayerOffsets", [&](const auto& x){
            pxr::SdfLayerOffsetVector offsets = extractSdfLayerOffsetVector(x);
            for (size_t i = 0; i < offsets.size(); i++) {
                layer->SetSubLayerOffset(offsets[i], i);
            }
        });
    }
    ifValueExists(obj, "inherits", [&](const auto& x){
        extractSdfListEditorProxy(x, handle->GetInheritPathList(), extractSdfPath);
    });
    ifValueExists(obj, "variantSetNames", [&](const auto& x){
        extractSdfListEditorProxy(x, handle->GetVariantSetNameList(), extractString);
    });

    ifValueExists(obj, "variantSelections", [&](const auto& x){
        extractVariantSelections(handle, x);
    });
    
    ifValueExists(obj, "variantSets", [&](const auto& x){
        readVariantSets(handle->GetLayer(), handle->GetPath(), x);
    });


    if (handle->GetPath().IsAbsoluteRootPath()) {
        extractLayerRelocates(handle->GetLayer(), obj);
    } else {
        extractPrimRelocates(obj, handle);
    }
    ifValueExists(obj, "references", [&](const auto& x){
        extractSdfListEditorProxy(x, handle->GetReferenceList(), extractSdfReference);
    });
    ifValueExists(obj, "payloads", [&](const auto& x){
        extractSdfListEditorProxy(x, handle->GetPayloadList(), extractSdfPayload);
    });
    ifValueExists(obj, "specializes", [&](const auto& x){
        extractSdfListEditorProxy(x, handle->GetSpecializesList(), extractSdfPath);
    });
    
    
    dispatchObjectsUnderPrimForReading(layer, handle->GetPath(), obj, "attributes");
    dispatchObjectsUnderPrimForReading(layer, handle->GetPath(), obj, "relationships");
    dispatchObjectsUnderPrimForReading(layer, handle->GetPath(), obj, "children");
    
    if (!handle->GetPath().IsAbsoluteRootPath()) {
        // Important: Set the type last.
        // @pxr/usdImaging/usdImagingGL/testenv/testUsdImagingGLPointInstancer/pi_pi_xform.usda@</World/Outer.ids>
        // is specified as int[] instead of int64[] as expected by the UsdGeomPointInstancer schema.
        // If we set the type before decoding attributes, trying to set the type of attributes will fail.
        // By setting the type at the end, we can handle this slightly-incorrect file in a lossless manner
        std::string type;
        ifValueExists(obj, "type", [&](const auto& x){ type = x.GetString(); });
        if (!type.empty()) {
            handle->SetTypeName(type);
        }
    }
    
    ifValueExists(obj, "propertyOrder", [&](const auto& x){
        pxr::TfTokenVector propertyOrder = extractTfTokenVector(x);
        if (!propertyOrder.empty()) {
            handle->SetPropertyOrder(propertyOrder);
        }
    });

    ifValueExists(obj, "nameChildrenOrder", [&](const auto& x){
        pxr::TfTokenVector nameChildrenOrder = extractTfTokenVector(x);
        if (!nameChildrenOrder.empty()) {
            handle->SetNameChildrenOrder(nameChildrenOrder);
        }
    });
    
    
    // Similar to setting type at the end, set metadata at the end.
    // Metadata can include API Schemas, which can e.g. make attributes
    // be uniform when they weren't authored as such (technically out of spec
    // with the API schema). See lossless-attr-collection-api.usda
    ifValueExists(obj, "metadata", [&](const auto& x){
        readMetadata(x, handle);
    });    
}

void writePrim(pxr::JsObject& js, const pxr::SdfPrimSpecHandle& prim) {
    js["name"] = pxr::JsValue(prim->GetName());
    if (prim->GetSpecType() != pxr::SdfSpecTypePseudoRoot) {
        switch (prim->GetSpecifier()) {
            case pxr::SdfSpecifierDef:
                js["spec"] = pxr::JsValue("def");
                break;
            case pxr::SdfSpecifierOver:
                js["spec"] = pxr::JsValue("over");
                break;
            case pxr::SdfSpecifierClass:
                js["spec"] = pxr::JsValue("class");
                break;
            case pxr::SdfNumSpecifiers:
                MY_FATAL_CODING_ERROR("Prim '%s' has specifier SdfNumSpecifiers", prim->GetPath().GetText());
                break;
        }
    }
    if (!prim->GetTypeName().IsEmpty()) {
        js["type"] = pxr::JsValue(prim->GetTypeName().GetString());
    }
    
    writeMetadata(js, prim);
    
    // LIVERPS. Local is handled by GetAttributes, GetRelationships, and GetNameChildren
    if (prim->GetSpecType() == pxr::SdfSpecTypePseudoRoot && prim->GetLayer()->GetNumSubLayerPaths() != 0) {
        js["subLayers"] = writeSdfListProxy(prim->GetLayer()->GetSubLayerPaths(), writeString);
        writeSubLayerOffsetsIfNeeded(js, prim->GetLayer()->GetSubLayerOffsets());
    }
    if (prim->HasInheritPaths()) {
        js["inherits"] = writeSdfListEditorProxy(prim->GetInheritPathList(), writeSdfPath);
    }
    if (prim->HasVariantSetNames()) {
        js["variantSetNames"] = writeSdfListEditorProxy(prim->GetVariantSetNameList(), writeString);
    }
    writeVariantSelectionsIfNeeded(js, prim->GetVariantSelections());
    writeVariantSetsIfNeeded(js, prim->GetVariantSets());
    if (prim->HasRelocates()) {
        js["relocates"] = writePrimRelocates(prim->GetRelocates());
    }
    if (prim->GetSpecType() == pxr::SdfSpecTypePseudoRoot && prim->GetLayer()->HasRelocates()) {
        js["relocates"] = writeLayerRelocates(prim->GetLayer()->GetRelocates());
    }
    
    if (prim->HasReferences()) {
        js["references"] = writeSdfListEditorProxy(prim->GetReferenceList(), writeSdfReference);
    }
    if (prim->HasPayloads()) {
        js["payloads"] = writeSdfListEditorProxy(prim->GetPayloadList(), writeSdfPayload);
    }
    if (prim->HasSpecializes()) {
        js["specializes"] = writeSdfListEditorProxy(prim->GetSpecializesList(), writeSdfPath);
    }
    
    pxr::JsArray attrs;
    for (const auto& attr : prim->GetAttributes()) {
        pxr::JsObject jsAttr;
        writeAttribute(jsAttr, attr);
        attrs.push_back(jsAttr);
    }
    if (!attrs.empty()) {
        js["attributes"] = attrs;
    }
    
    pxr::JsArray rels;
    for (const auto& rel : prim->GetRelationships()) {
        pxr::JsObject jsRel;
        writeRelationship(jsRel, rel);
        rels.push_back(jsRel);
    }
    if (!rels.empty()) {
        js["relationships"] = rels;
    }
    
    pxr::JsArray children;
    for (const auto& child : prim->GetNameChildren()) {
        pxr::JsObject jsChild;
        writePrim(jsChild, child);
        children.push_back(jsChild);
    }
    if (!children.empty()) {
        js["children"] = children;
    }
    
    if (prim->HasPropertyOrder()) {
        js["propertyOrder"] = writeSdfListProxy(prim->GetPropertyOrder(), writeTfToken);
    }
    
    if (prim->HasNameChildrenOrder()) {
        js["nameChildrenOrder"] = writeSdfListProxy(prim->GetNameChildrenOrder(), writeTfToken);
    }
}

void readAttribute(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsValue& js) {
    const pxr::JsObject& obj = js.GetJsObject();
    
    // extractTypeHint might emit an error if there's an unknown type hint,
    // but we know how to handle it.
    pxr::TfErrorMark m;
    TypedValue type = extractTypeHint(js);
    m.Clear();
    
    bool custom = false;
    ifValueExists(obj, "custom", [&](const auto& x){
        custom = x.GetBool();
    });
    
    pxr::SdfVariability variability = pxr::SdfVariabilityVarying;
    ifValueExists(obj, "variability", [&](const auto& x){
        variability = static_cast<pxr::SdfVariability>(x.GetInt());
    });
    
    pxr::SdfAttributeSpecHandle attrSpec = pxr::SdfCreatePrimAttributeInLayer(layer, path, type.valueTypeName, variability, custom);
    if (!type.valueTypeName) {
        // This could be PointIndex or PointIndex[], which we can't create a SdfValueTypeName for
        attrSpec->SetField(pxr::SdfFieldKeys->TypeName, pxr::VtValue(pxr::TfToken(type.otherTypeName)));
    }
    
    TypedValue defaultValue = type;
    ifValueExists(obj, "default", [&](const auto& x){
        extractValueWithTypeHint(&defaultValue, x);
    });

    if (!defaultValue.value.IsEmpty()) {
        if (!attrSpec->SetField(pxr::SdfFieldKeys->Default, defaultValue.value)) {
            MY_RUNTIME_ERROR_AND_RETURN("Failed to set default value for attribute of '%s' at '%s'", attrSpec->GetTypeName().GetAsToken().GetText(), path.GetText());
        }
    }
    
    ifValueExists(obj, "timesamples", [&](const auto& x){
        auto timeSamples = extractTimeCodeValueMapWithTypeHint(x, type);
        for (const auto& it : timeSamples) {
            attrSpec->SetTimeSample(it.first, it.second);
        }
        
        if (timeSamples.size() == 0) {
            // empty-timesamples.usda. If we encoded an empty time sample map,
            // the above for loop will be empty, but we still want to set the TimeSamples field
            attrSpec->SetField(pxr::SdfFieldKeys->TimeSamples, pxr::VtValue(pxr::SdfTimeSampleMap()));

        }
    });
    
    ifValueExists(obj, "connections", [&](const auto& x){
        extractSdfListEditorProxy(x, attrSpec->GetConnectionPathList(), extractSdfPath);
    });
    
    ifValueExists(obj, "spline", [&](const auto& x){
        attrSpec->SetSpline(extractTsSpline(x, type.valueTypeName));
    });
        
    ifValueExists(obj, "displayUnit", [&](const auto& x){
        attrSpec->SetDisplayUnit(extractTfEnum(x));
    });
    
    ifValueExists(obj, "metadata", [&](const auto& x){
        readMetadata(x, attrSpec);
    });
}

void writeAttribute(pxr::JsObject& js, const pxr::SdfAttributeSpecHandle& attr) {
    js["name"] = pxr::JsValue(attr->GetName());
    TypedValue type = TypedValue::forTypeName(attr->GetTypeName());
    js["type"] = writeTypeHint(type);
    if (attr->IsCustom()) {
        js["custom"] = pxr::JsValue(true);
    }
    js["variability"] = pxr::JsValue(attr->GetVariability());
    
    type.value = attr->GetDefaultValue();
    if (!attr->GetDefaultValue().IsEmpty()) {
        js["default"] = writeValueWithoutTypeHint(type);
    }
    
    // Check if we have a field instead of GetNumTimeSamples() != 0 for
    // empty-timesamples.usda
    if (attr->HasField(pxr::SdfFieldKeys->TimeSamples)) {
        js["timesamples"] = writeTimeCodeValueMapWithoutTypeHint(attr->GetTimeSampleMap(), type);
    }
    
    if (attr->HasConnectionPaths()) {
        js["connections"] = writeSdfListEditorProxy(attr->GetConnectionPathList(), writeSdfPath);
    }
    
    if (attr->HasSpline()) {
        js["spline"] = writeTsSpline(attr->GetSpline());
    }
    
    if (attr->HasDisplayUnit()) {
        js["displayUnit"] = writeTfEnum(attr->GetDisplayUnit());
    }
    
    writeMetadata(js, attr);
}

void readRelationship(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsValue& js) {
    const pxr::JsObject& obj = js.GetJsObject();
        
    bool custom = false;
    ifValueExists(obj, "custom", [&](const auto& x){
        custom = x.GetBool();
    });
    
    pxr::SdfVariability variability = pxr::SdfVariabilityVarying;
    ifValueExists(obj, "variability", [&](const auto& x){
        variability = static_cast<pxr::SdfVariability>(x.GetInt());
    });
    
    pxr::SdfRelationshipSpecHandle relSpec = pxr::SdfCreateRelationshipInLayer(layer, path, variability, custom);
    if (!relSpec) {
        MY_RUNTIME_ERROR_AND_RETURN("Failed to create relationship at '%s'", path.GetText());
    }
    
    ifValueExists(obj, "targets", [&](const auto& x){
        extractSdfListEditorProxy(x, relSpec->GetTargetPathList(), extractSdfPath);
    });
    
    ifValueExists(obj, "default", [&](const auto& x){
        TypedValue defaultValue = extractTypeHintAndValue(x);
        relSpec->SetDefaultValue(defaultValue.value);
    });
    
    ifValueExists(obj, "metadata", [&](const auto& x){
        readMetadata(x, relSpec);
    });
}

void writeRelationship(pxr::JsObject& js, const pxr::SdfRelationshipSpecHandle& rel) {
    js["name"] = pxr::JsValue(rel->GetName());
    if (rel->IsCustom()) {
        js["custom"] = pxr::JsValue(true);
    }
    const auto& targets = rel->GetTargetPathList();
    js["targets"] = writeSdfListEditorProxy(targets, writeSdfPath);
        
    js["variability"] = pxr::JsValue(rel->GetVariability());

    if (rel->HasDefaultValue()) {
        js["default"] = writeTypeHintAndValue(TypedValue::forVtValue(rel->GetDefaultValue()));
    }
    
    writeMetadata(js, rel);
}




