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

/*
 A word on pxr::SdfHandle and pxr::SdfSpec:
 
 This Swift target deals with pxr::SdfHandle<SpecType> a lot by virtue of working at the Sdf layer.
 In C++, you can easily do `myHandle->method()`, but in Swift, that has to be spelt `myHandle.pointee.method()`.
 Doing that everywhere can be pretty noisy to no real benefit, so instead we write our methods to take spec types
 (e.g. pxr.SdfSpec, pxr.SdfPrimSpec) directly instead of having handles.
 
 The downside of this is that `myHandle->method()` will automatically check if the handle is dormant on each acccess,
 and safely terminate the program if that is the case. By working with SdfSpecs directly, we avoid doing that dormancy
 check as frequently, which in some circumstances could open us up to memory safety issues. However, nothing that we do
 would delete/destroy a spec (during the SdfFileFormat.WriteToFile/WriteToString phase, we are creating JsAny objects but
 only reading from the SdfLayer; during the SdfFileFormat.Read phase, we are creating specs but never removing them), so
 we do not need to worry that our own code will invalidate a spec we are still using. And, OpenUSD's threading model is
 many readers or one writer; during SdfFileFormat.WriteToFile/WriteToString, we're reading the layer, so no other part of
 OpenUSD is allowed to be modifying the layer, and during SdfFileFormat.Read, we're writing to the layer, so no other part
 of OpenUSD is allowed to be accessing the layer. So in short, the fact that we are not doing as frequent checks for
 dormancy does not make our Swift code less safe than the C++ version.
 
 Finally, we use the added computed property `pointeeOrThrow` to throw a Swift error if we try to dereference an invalid handle,
 rather than let `myHandle->method()` safely terminate the program, so that we can report errors to the user without (safely) crashing.
 */

func readLayer(_ layer: pxr.SdfLayer, _ data: Data) throws {
    let jsAny: JsAny
    do {
        jsAny = try JsAny.decodeFromData(data)
    } catch {
        TF_RUNTIME_ERROR(std.string("Can't read layer, JS decode failed with \(error)"))
        throw error
    }
    
    if jsAny.isNull {
        TF_RUNTIME_ERROR("Can't read layer, JsAny parse was null")
        throw JsDecodingError.jsAnyParseWasNull
    }
    
    return try readPrim(layer, layer.GetPseudoRoot().pointeeOrThrow, jsAny)
}
func writeLayer(_ layer: pxr.SdfLayer, _ comment: std.string) throws -> Data {
    let jsAny = try writePrim(layer.GetPseudoRoot().pointeeOrThrow)
    return try JsAny.encodeToData(jsAny)
}

func readMetadata(_ js: JsAny, _ spec: pxr.SdfSpec) throws {
    var spec = spec
    for (k, v) in try js.castAsObject() {
        let value = try extractTypeHintAndValue(v)
        
        guard spec.SetField(pxr.TfToken(k), value.value) else {
             throw JsDecodingError.failedToSetMetadataOnPrim(k, spec.GetPath(), value.value)
        }
    }
}

func writeMetadata(_ spec: pxr.SdfSpec) throws -> JsAny {
    var result = [String : JsAny]()
    
    for key in spec.GetMetaDataInfoKeys() {
        if spec.GetField(key).IsEmpty() { continue }
        if key == pxr.TfToken("typeName") && spec.GetSpecType() == .SdfSpecTypePrim {
            continue
        }
        if key == pxr.TfToken("payload") {
            // For whatever reason, payloads appear as metadata in GetMetaDataInfoKeys. No other
            // composition arcs appear this way. We handle payloads as part of the general LIVERPS handling
            continue
        }
        
        let v = TypedValue(vtValue: spec.GetField(key))
        result[String(key)] = try writeTypeHintAndValue(v)
    }
    
    // GetMetaDataInfoKeys only handles known/registered metadata, but
    // specs can have unknown metadata on them, e.g. test case one-unknown-metadata.usda.
    // So, pull out all the fields on this spec, and then write out the ones
    // that aren't registered.
    let registeredFields = spec.GetSchema().GetFields(spec.GetSpecType())
    fieldLoop: for field in spec.ListFields() {
        for x in registeredFields {
            if x == field {
                if (field == .SdfFieldKeys.Comment && !spec.GetField(field).IsEmpty()) {
                    // pass. Comment isn't provided by GetMetaDataInfoKeys, but is a registered field.
                    // prim specs and property specs can have it.
                } else {
                    continue fieldLoop
                }
            }
        }
        
        let v = TypedValue(vtValue: spec.GetField(field))
        result[String(field)] = try writeTypeHintAndValue(v)
    }
    
    return .object(result)
}

enum DispatchKey: String {
    case children
    case attributes
    case relationships
}

func dispatchObjectsUnderPrimForReading(_ layer: pxr.SdfLayer, _ path: pxr.SdfPath, _ js: [String : JsAny], _ key: DispatchKey) throws {
    guard let x = js[key.rawValue] else { return }
    
    for element in try x.castAsArray() {
        let subObject = try element.castAsObject()
        let name = try subObject["name", errorMessage: "\(path)"].castAsString()
        
        let subPath: pxr.SdfPath
        if key == .children {
            subPath = path.AppendChild(pxr.TfToken(name))
        } else {
            subPath = path.AppendProperty(pxr.TfToken(name))
        }
        
        switch key {
        case .children:
            pxr.SdfCreatePrimInLayer(Overlay.TfWeakPtr(layer), subPath)
            try readPrim(layer, layer.GetPrimAtPath(subPath).pointeeOrThrow, element)

        case .attributes:
            try readAttribute(layer, subPath, element)

        case .relationships:
            try readRelationship(layer, subPath, element)
        }
    }
}

func readPrim(_ layer: pxr.SdfLayer, _ prim: pxr.SdfPrimSpec, _ js: JsAny) throws {
    var prim = prim
    let obj = try js.castAsObject()
    let spec: String
    do {
        spec = try obj["spec", errorMessage: "readPrim"].castAsString()
    } catch where prim.GetPath().IsAbsoluteRootPath() {
        spec = ""
    }
    
    if spec == "def" {
        prim.SetSpecifier(.SdfSpecifierDef)
    } else if spec == "over" {
        prim.SetSpecifier(.SdfSpecifierOver)
    } else if spec == "class" {
        prim.SetSpecifier(.SdfSpecifierClass)
    } else {
        if !prim.GetPath().IsAbsoluteRootPath() {
            throw JsDecodingError.unknownSpecifier(spec, prim.GetPath())
        }
    }
    
    // LIVERPS
    if prim.GetPath().IsAbsoluteRootPath() {
        if let x = obj["subLayers"] {
            try layer.SetSubLayerPaths(extractSdfListProxy(pxr.SdfSubLayerProxy.self, x, extractString))
        }
        
        if let x = obj["subLayerOffsets"] {
            let offsets = try extractSdfLayerOffsetVector(x)
            for i in 0..<offsets.count {
                layer.SetSubLayerOffset(offsets[i], Int32(i))
            }
        }
    }
    if let x = obj["inherits"] {
        try extractSdfListEditorProxy(x, prim.GetInheritPathList(), extractSdfPath)
    }
    if let x = obj["variantSetNames"] {
        try extractSdfListEditorProxy(x, prim.GetVariantSetNameList(), extractString)
    }
    
    if let x = obj["variantSelections"] {
        try extractVariantSelections(prim, x)
    }
    
    if let x = obj["variantSets"] {
        try readVariantSets(Overlay.Dereference(prim.GetLayer()), prim.GetPath(), x)
    }
    
    if prim.GetPath().IsAbsoluteRootPath() {
        try extractLayerRelocates(Overlay.Dereference(prim.GetLayer()), .object(obj))
    } else {
        try extractPrimRelocates(.object(obj), prim)
    }
    if let x = obj["references"] {
        try extractSdfListEditorProxy(x, prim.GetReferenceList(), extractSdfReference)
    }
    if let x = obj["payloads"] {
        try extractSdfListEditorProxy(x, prim.GetPayloadList(), extractSdfPayload)
    }
    if let x = obj["specializes"] {
        try extractSdfListEditorProxy(x, prim.GetSpecializesList(), extractSdfPath)
    }
    
    try dispatchObjectsUnderPrimForReading(layer, prim.GetPath(), obj, .attributes)
    try dispatchObjectsUnderPrimForReading(layer, prim.GetPath(), obj, .relationships)
    try dispatchObjectsUnderPrimForReading(layer, prim.GetPath(), obj, .children)
    
    if !prim.GetPath().IsAbsoluteRootPath() {
        // Important: Set the type last.
        // @pxr/usdImaging/usdImagingGL/testenv/testUsdImagingGLPointInstancer/pi_pi_xform.usda@</World/Outer.ids>
        // is specified as int[] instead of int64[] as expected by the UsdGeomPointInstancer schema.
        // If we set the type before decoding attributes, trying to set the type of attributes will fail.
        // By setting the type at the end, we can handle this slightly-incorrect file in a lossless manner

        if let x = try obj["type"]?.castAsString(), !x.isEmpty {
            prim.SetTypeName(std.string(x))
        }
    }
    
    if let x = obj["propertyOrder"] {
        let propertyOrder = try extractTfTokenVector(x)
        if !propertyOrder.empty() {
            prim.SetPropertyOrder(propertyOrder)
        }
    }
    
    if let x = obj["nameChildrenOrder"] {
        let nameChildrenOrder = try extractTfTokenVector(x)
        if !nameChildrenOrder.empty() {
            prim.SetNameChildrenOrder(nameChildrenOrder)
        }
    }
    
    // Similar to setting type at the end, set metadata at the end.
    // Metadata can include API Schemas, which can e.g. make attributes
    // be uniform when they weren't authored as such (technically out of spec
    // with the API schema). See lossless-attr-collection-api.usda
    if let x = obj["metadata"] {
        try readMetadata(x, pxr.SdfSpec(prim))
    }
}
func writePrim(_ prim: pxr.SdfPrimSpec) throws -> JsAny {
    var result = [String : JsAny]()
    result["name"] = .string(String(prim.GetName()))
    if prim.GetSpecType() != .SdfSpecTypePseudoRoot {
        switch prim.GetSpecifier() {
        case .SdfSpecifierDef: result["spec"] = "def"
        case .SdfSpecifierOver: result["spec"] = "over"
        case .SdfSpecifierClass: result["spec"] = "class"
        default: fatalError("Prim '\(prim.GetPath())' has specifier \(prim.GetSpecifier())")
        }
    }
    if !prim.GetTypeName().IsEmpty() {
        result["type"] = .string(String(prim.GetTypeName()))
    }
    
    result.insert(at: "metadata", ifIsNonEmptyContainer: try writeMetadata(pxr.SdfSpec(prim)))
    
    // LIVERPS. Local is handled by GetAttributes, GetRelationships, and GetNameChildren
    if prim.GetSpecType() == .SdfSpecTypePseudoRoot && Overlay.Dereference(prim.GetLayer()).GetNumSubLayerPaths() != 0 {
         result["subLayers"] = try writeSdfListProxy(Overlay.Dereference(prim.GetLayer()).GetSubLayerPaths(), writeString)
        if let offsets = writeSubLayerOffsets(Overlay.Dereference(prim.GetLayer()).GetSubLayerOffsets()) {
            result.insert(at: "subLayerOffsets", ifIsNonEmptyContainer: offsets)
        }
    }
    if prim.HasInheritPaths() {
        result["inherits"] = try writeSdfListEditorProxy(prim.GetInheritPathList(), writeSdfPath)
    }
    if prim.HasVariantSetNames() {
        result["variantSetNames"] = try writeSdfListEditorProxy(prim.GetVariantSetNameList(), writeString)
    }
    result.insert(at: "variantSelections", ifIsNonEmptyContainer: writeVariantSelections(prim.GetVariantSelections()))
    result.insert(at: "variantSets", ifIsNonEmptyContainer: try writeVariantSets(prim.GetVariantSets()))
    if prim.HasRelocates() {
        result["relocates"] = writePrimRelocates(prim.GetRelocates())
    }
    if prim.GetSpecType() == .SdfSpecTypePseudoRoot && Overlay.Dereference(prim.GetLayer()).HasRelocates() {
        result["relocates"] = writeLayerRelocates(Overlay.Dereference(prim.GetLayer()).GetRelocates())
    }
    
    if prim.HasReferences() {
        result["references"] = try writeSdfListEditorProxy(prim.GetReferenceList(), writeSdfReference)
    }
    if prim.HasPayloads() {
        result["payloads"] = try writeSdfListEditorProxy(prim.GetPayloadList(), writeSdfPayload)
    }
    if prim.HasSpecializes() {
        result["specializes"] = try writeSdfListEditorProxy(prim.GetSpecializesList(), writeSdfPath)
    }
    
    let attrs = try prim.GetAttributes().map { try writeAttribute($0.pointeeOrThrow) }
    result.insert(at: "attributes", ifIsNonEmptyContainer: .array(attrs))
    
    let rels = try prim.GetRelationships().map { try writeRelationship($0.pointeeOrThrow) }
    result.insert(at: "relationships", ifIsNonEmptyContainer: .array(rels))
    
    let children = try prim.GetNameChildren().map { try writePrim($0.pointeeOrThrow) }
    result.insert(at: "children", ifIsNonEmptyContainer: .array(children))
    
    if prim.HasPropertyOrder() {
         result["propertyOrder"] = try writeSdfListProxy(prim.GetPropertyOrder(), writeTfToken)
    }
    
    if prim.HasNameChildrenOrder() {
         result["nameChildrenOrder"] = try writeSdfListProxy(prim.GetNameChildrenOrder(), writeTfToken)
    }
    
    return .object(result)
}

func readAttribute(_ layer: pxr.SdfLayer, _ path: pxr.SdfPath, _ js: JsAny) throws {
    let obj = try js.castAsObject()
    
    // extractTypeHint might emit an error if there's an unknown type hint,
    // but we know how to handle it.
    let type = try Overlay.withTfErrorMark { m in
        let type = try extractTypeHint(js)
        m.Clear()
        return type
    }
    
    var custom = false
    if let x = obj["custom"] {
        custom = try x.castAsBool()
    }
    
    var variability = Overlay.SdfVariabilityVarying
    if let x = obj["variability"] {
        variability = pxr.SdfVariability(rawValue: UInt32(try x.castAsInt()))
    }
    
    var attr = try pxr.SdfCreatePrimAttributeInLayer(Overlay.TfWeakPtr(layer), path, type.valueTypeName, variability, custom).pointeeOrThrow
    if !Bool(type.valueTypeName) {
        // This could be PointIndex or PointIndex[], which we can't create a SdfValueTypeName for
        attr.SetField(.SdfFieldKeys.TypeName, pxr.VtValue(pxr.TfToken(type.otherTypeName)))
    }
    
    var defaultValue = type
    if let x = obj["default"] {
        try extractValueWithTypeHint(&defaultValue, x)
    }
    
    if !defaultValue.value.IsEmpty() {
        guard attr.SetField(.SdfFieldKeys.Default, defaultValue.value) else {
            throw JsDecodingError.failedToSetDefaultAttributeValue(String(attr.GetTypeName().GetAsToken()), path, defaultValue.value)
        }
    }
    
    if let x = obj["timesamples"] {
        let timeSamples = try extractTimeCodeValueMapWithTypeHint(x, type)
        for kvPair in timeSamples {
            attr.SetTimeSample(kvPair.first, kvPair.second)
        }
        
        if timeSamples.empty() {
            // empty-timesamples.usda. If we encoded an empty time sample map,
            // the above for loop will be empty, but we still want to set the TimeSamples field

            attr.SetField(.SdfFieldKeys.TimeSamples, pxr.VtValue(pxr.SdfTimeSampleMap()))
        }
    }
    
    if let x = obj["connections"] {
        try extractSdfListEditorProxy(x, attr.GetConnectionPathList(), extractSdfPath)
    }
    
    if let x = obj["spline"] {
        attr.SetSpline(try extractTsSpline(x, type.valueTypeName))
    }
    
    if let x = obj["displayUnit"] {
        attr.SetDisplayUnit(try extractTfEnum(x))
    }
    
    if let x = obj["metadata"] {
        try readMetadata(x, pxr.SdfSpec(attr))
    }
}
func writeAttribute(_ attr: pxr.SdfAttributeSpec) throws -> JsAny {
    var result = [String : JsAny]()
    
    result["name"] = .string(String(attr.GetName()))
    var type = TypedValue(typeName: attr.GetTypeName())
    result["type"] = writeTypeHint(type)
    if attr.IsCustom() {
        result["custom"] = true
    }
    result["variability"] = .int(Int(attr.GetVariability().rawValue))
    
    type.value = attr.GetDefaultValue()
    if !attr.GetDefaultValue().IsEmpty() {
        result["default"] = try writeValueWithoutTypeHint(type)
    }
    
    // Check if we have a field instead of GetNumTimeSamples() != 0 for
    // empty-timesamples.usda
    if attr.HasField(.SdfFieldKeys.TimeSamples) {
        result["timesamples"] = try writeTimeCodeValueMapWithoutTypeHint(attr.GetTimeSampleMap(), type)
    }
    
    if attr.HasConnectionPaths() {
        result["connections"] = try writeSdfListEditorProxy(attr.GetConnectionPathList(), writeSdfPath)
    }
    
    if attr.HasSpline() {
        result["spline"] = try writeTsSpline(attr.GetSpline())
    }
    
    if attr.HasDisplayUnit() {
        result["displayUnit"] = writeTfEnum(attr.GetDisplayUnit())
    }
    
    result.insert(at: "metadata", ifIsNonEmptyContainer: try writeMetadata(pxr.SdfSpec(attr)))
    
    return .object(result)
}

func readRelationship(_ layer: pxr.SdfLayer, _ path: pxr.SdfPath, _ js: JsAny) throws {
    let obj = try js.castAsObject()
    
    var custom = false
    if let x = obj["custom"] {
        custom = try x.castAsBool()
    }
    
    var variability = Overlay.SdfVariabilityVarying
    if let x = obj["variability"] {
        variability = pxr.SdfVariability(rawValue: UInt32(try x.castAsInt()))
    }
    
    var rel = try pxr.SdfCreateRelationshipInLayer(Overlay.TfWeakPtr(layer), path, variability, custom).pointeeOrThrow
    
    if let x = obj["targets"] {
        try extractSdfListEditorProxy(x, rel.GetTargetPathList(), extractSdfPath)
    }
    
    if let x = obj["default"] {
        let defaultValue = try extractTypeHintAndValue(x)
        rel.SetDefaultValue(defaultValue.value)
    }
    
    if let x = obj["metadata"] {
        try readMetadata(x, pxr.SdfSpec(rel))
    }
}
func writeRelationship(_ rel: pxr.SdfRelationshipSpec) throws -> JsAny {
    var result = [String : JsAny]()
    result["name"] = .string(String(rel.GetName()))
    if rel.IsCustom() {
        result["custom"] = true
    }
    result["targets"] = try writeSdfListEditorProxy(rel.GetTargetPathList(), writeSdfPath)
    
    
    result["variability"] = .int(Int(rel.GetVariability().rawValue))
    
    if rel.HasDefaultValue() {
        result["default"] = try writeTypeHintAndValue(.init(vtValue: rel.GetDefaultValue()))
    }
    
    result.insert(at: "metadata", ifIsNonEmptyContainer: try writeMetadata(pxr.SdfSpec(rel)))
    
    return .object(result)
}

// Note: VariantSpec and VariantSetSpec are handled in LIVERPSSerialization
