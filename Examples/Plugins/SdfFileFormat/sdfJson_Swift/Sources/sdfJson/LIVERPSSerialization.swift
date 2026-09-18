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
import TemporaryImplementations_Cxx
import TemporaryImplementations_Swift

func writeSdfListProxy<T>(_ proxy: T, _ convertElement: (T.value_type) throws -> JsAny) throws -> JsAny where T: Overlay._SdfListProxyProtocol {
    var result = [JsAny]()
    for element in proxy {
        result.append(try convertElement(element))
    }
    
    return .array(result)
}

func extractSdfListProxy<T>(_: T.Type, _ js: JsAny, _ convertElement: (JsAny) throws -> T.value_type) throws -> T.value_vector_type where T: Overlay._SdfListProxyProtocol {
    var result = T.value_vector_type()
    
    for x in try js.castAsArray() {
        result.push_back(try convertElement(x))
    }
    
    return result
}

func writeSdfListEditorProxy<T>(_ proxy: T, _ convertElement: (T.value_type) throws -> JsAny) throws -> JsAny where T: Overlay._SdfListEditorProxyProtocol {
    var result = [String : JsAny]()
    
    func handleIndividualListProxy(_ list: T.ListProxy, _ key: String) throws {
        if !list.empty() {
            result[key] = try writeSdfListProxy(list, convertElement)
        }
    }
    
    try handleIndividualListProxy(proxy.GetExplicitItems(), "explicit")
    try handleIndividualListProxy(proxy.GetAddedItems(), "add")
    try handleIndividualListProxy(proxy.GetPrependedItems(), "prepend")
    try handleIndividualListProxy(proxy.GetAppendedItems(), "append")
    try handleIndividualListProxy(proxy.GetDeletedItems(), "delete")
    try handleIndividualListProxy(proxy.GetOrderedItems(), "order")
    
    if result.isEmpty && proxy.IsExplicit() {
        result["explicit"] = []
    }
    
    return .object(result)
}

func extractSdfListEditorProxy<T>(_ js: JsAny, _ proxy: T, _ convertElement: (JsAny) throws -> T.value_type) throws where T: Overlay._SdfListEditorProxyProtocol {
    var proxy = proxy
    let obj = try js.castAsObject()
    
    func handleIndividualListProxy(_ list: T.ListProxy, _ key: String) throws {
        var list = list
        guard let x = obj[key] else { return }
        let toInsert = try extractSdfListProxy(T.ListProxy.self, x, convertElement)
        for y in toInsert {
            list.push_back(y)
        }
    }
    
    try handleIndividualListProxy(proxy.GetExplicitItems(), "explicit")
    try handleIndividualListProxy(proxy.GetAddedItems(), "add")
    try handleIndividualListProxy(proxy.GetPrependedItems(), "prepend")
    try handleIndividualListProxy(proxy.GetAppendedItems(), "append")
    try handleIndividualListProxy(proxy.GetDeletedItems(), "delete")
    try handleIndividualListProxy(proxy.GetOrderedItems(), "order")

    if obj["explicit"] != nil && !proxy.HasKeys() {
        proxy.ClearEditsAndMakeExplicit()
    }
}

func writeSdfListOp<T>(_ proxy: T, _ convertElement: (T.value_type) throws -> JsAny) throws -> JsAny where T: Overlay._SdfListOpProtocol {
    var result = [String : JsAny]()
    
    func writeIndividualArray(_ items: T.value_vector_type, _ key: String) throws {
        var arr = [JsAny]()
        for x in items {
            arr.append(try convertElement(x))
        }
        if !arr.isEmpty {
            result[key] = .array(arr)
        }
    }
    
    try writeIndividualArray(proxy.GetExplicitItems(), "explicit")
    try writeIndividualArray(proxy.GetAddedItems(), "add")
    try writeIndividualArray(proxy.GetPrependedItems(), "prepend")
    try writeIndividualArray(proxy.GetAppendedItems(), "append")
    try writeIndividualArray(proxy.GetDeletedItems(), "delete")
    try writeIndividualArray(proxy.GetOrderedItems(), "order")

    if result.isEmpty && proxy.IsExplicit() {
        result["explicit"] = []
    }
    
    return .object(result)
}

func extractSdfListOp<T>(_: T.Type, _ js: JsAny, _ convertElement: (JsAny) throws -> T.value_type) throws -> T where T: Overlay._SdfListOpProtocol {
    var result = T()
    let obj = try js.castAsObject()
    
    func extractIndividualArray(_ jsKey: String, _ setter: (T.value_vector_type) -> ()) throws {
        guard let x = obj[jsKey] else { return }
        var result = T.value_vector_type()
        for y in try x.castAsArray() {
            result.push_back(try convertElement(y))
        }
        
        setter(result)
    }
    
    try extractIndividualArray("explicit") { result.SetExplicitItems($0, nil) }
    try extractIndividualArray("add") { result.SetAddedItems($0) }
    try extractIndividualArray("prepend") { result.SetPrependedItems($0, nil) }
    try extractIndividualArray("append") { result.SetAppendedItems($0, nil) }
    try extractIndividualArray("delete") { result.SetDeletedItems($0, nil) }
    try extractIndividualArray("order") { result.SetOrderedItems($0) }
    
    return result
}

func extractSdfLayerOffset(_ js: JsAny) throws -> pxr.SdfLayerOffset {
    let arr = try js.castAsArray()
    guard arr.count == 2 else {
        throw JsDecodingError.invalidSdfLayerOffset
    }
    
    return pxr.SdfLayerOffset(try arr[0].castAsNumber(),
                              try arr[1].castAsNumber())
}
func writeSdfLayerOffset(_ x: pxr.SdfLayerOffset) -> JsAny {
    [
        .number(x.GetOffset()),
        .number(x.GetScale())
    ]
}

func extractSdfLayerOffsetVector(_ js: JsAny) throws -> pxr.SdfLayerOffsetVector {
    let arr = try js.castAsArray()
    var result = pxr.SdfLayerOffsetVector()
    for x in arr {
        result.push_back(try extractSdfLayerOffset(x))
    }
    return result
}
func writeSubLayerOffsets(_ offsets: pxr.SdfLayerOffsetVector) -> JsAny? {
    var result = [JsAny]()
    var hadNonIdentity = false
    for x in offsets {
        hadNonIdentity = hadNonIdentity || !x.IsIdentity()
        result.append(writeSdfLayerOffset(x))
    }
    
    return hadNonIdentity ? .array(result) : nil
}

func extractPrimRelocates(_ js: JsAny, _ prim: pxr.SdfPrimSpec) throws {
    var prim = prim
    let obj = try js.castAsObject()
    
    var proxy = prim.GetRelocates()
    guard let x = obj["relocates"] else { return }
    for (k, v) in try x.castAsObject() {
        proxy.insert(.init(first: pxr.SdfPath(k), second: pxr.SdfPath(try v.castAsString())))
    }
    if try x.castAsObject().isEmpty {
        prim.SetField(.SdfFieldKeys.Relocates, pxr.VtValue(pxr.SdfRelocatesMap()))
    }
}

func writePrimRelocates(_ list: pxr.SdfRelocatesMapProxy) -> JsAny {
    var result = [String : JsAny]()
    for x in list {
        result[String(x.first)] = .string(String(x.second))
    }
    return .object(result)
}

func extractLayerRelocates(_ layer: pxr.SdfLayer, _ js: JsAny) throws {
    let obj = try js.castAsObject()
    guard let x = obj["relocates"] else { return }
    
    var relocates = pxr.SdfRelocates()
    for entry in try x.castAsArray() {
        let subArr = try entry.castAsArray()
        guard subArr.count == 2 else {
            throw JsDecodingError.layerRelocatesEntryInvalid
        }
        relocates.push_back(.init(first: pxr.SdfPath(try subArr[0].castAsString()),
                                  second: pxr.SdfPath(try subArr[1].castAsString())))
    }
    if !relocates.empty() {
        layer.SetRelocates(relocates)
    }
}
func writeLayerRelocates(_ list: pxr.SdfRelocates) -> JsAny {
    var result = [JsAny]()
    for x in list {
        result.append([
            .string(String(x.first)),
            .string(String(x.second))
        ])
    }
    return .array(result)
}

func extractVariantSelections(_ prim: pxr.SdfPrimSpec, _ js: JsAny) throws {
    var prim = prim
    for (k, v) in try js.castAsObject() {
        prim.SetVariantSelection(std.string(k), std.string(try v.castAsString()))
    }
}
func writeVariantSelections(_ selections: pxr.SdfVariantSelectionProxy) -> JsAny {
    guard Bool(selections) && !selections.empty() else { return [] }
    
    var result = [String : JsAny]()
    for x in selections {
        result[String(x.first)] = .string(String(x.second))
    }
    
    return .object(result)
}

func readVariantSets(_ layer: pxr.SdfLayer, _ path: pxr.SdfPath, _ js: JsAny) throws {
    let arr = try js.castAsArray()
    
    let prim = try layer.GetPrimAtPath(path).pointeeOrThrow
    
    for variantSetSuperObjectElement in arr {
        let variantSetSuperObject = try variantSetSuperObjectElement.castAsObject()
        
        guard variantSetSuperObject.count == 2 else {
            throw JsDecodingError.variantSetSuperObjectInvalid
        }
        let variantSetName = try variantSetSuperObject["name", errorMessage: "Variant set super object"].castAsString()
        
        let jsVariantSet = try variantSetSuperObject["contents", errorMessage: "Variant set super object"]
        
        
        let vsets = prim.GetVariantSets()
        
        let firstMatch = vsets.first(where: { $0.first == std.string(variantSetName) })
        let sdfVset: pxr.SdfVariantSetSpec = try firstMatch?.second.pointeeOrThrow ?? pxr.SdfVariantSetSpec.New(pxr.SdfPrimSpecHandle(prim), std.string(variantSetName)).pointeeOrThrow
        
        try readVariantSetSpec(jsVariantSet, sdfVset)
    }
}


func writeVariantSets(_ sets: pxr.SdfVariantSetsProxy) throws -> JsAny {
    guard Bool(sets) && !sets.empty() else { return [] }
    
    var result = [JsAny]()
    
    for x in sets {
        result.append([
            "name" : .string(String(x.first)),
            "contents" : try writeVariantSetSpec(x.second.pointeeOrThrow),
        ])
    }
    
    return .array(result)
}

func readVariantSetSpec(_ js: JsAny, _ variantSet: pxr.SdfVariantSetSpec) throws {
    let jsVariantSet = try js.castAsObject()
    
    for (k, v) in jsVariantSet {
        let variantView = variantSet.GetVariants()

        let firstMatch = try variantView.first(where: { try $0.pointeeOrThrow.GetName() == std.string(k) })
        // Important: Use variantSet->GetOwner()->GetPath() and not variantSet->GetPath().StripAllVariantSelections(),
        // because the latter does not handle nested variant sets correctly but the former does.
        let ownerPath = try variantSet.GetOwner().pointeeOrThrow.GetPath()
        let vspec = try firstMatch?.pointeeOrThrow ?? pxr.SdfCreateVariantInLayer(variantSet.GetLayer(), ownerPath, variantSet.GetName(), std.string(k)).pointeeOrThrow
        
        
        let jsVspecPrimSpec = try v.castAsObject()
        try readPrim(Overlay.Dereference(variantSet.GetLayer()), vspec.GetPrimSpec().pointeeOrThrow, .object(jsVspecPrimSpec))
    }
}
func writeVariantSetSpec(_ variantSet: pxr.SdfVariantSetSpec) throws -> JsAny {
    var result = [String : JsAny]()
    
    for variant in variantSet.GetVariants() {
        try result[String(variant.pointeeOrThrow.GetName())] = try writePrim(variant.pointeeOrThrow.GetPrimSpec().pointeeOrThrow)
    }
    
    return .object(result)
}
