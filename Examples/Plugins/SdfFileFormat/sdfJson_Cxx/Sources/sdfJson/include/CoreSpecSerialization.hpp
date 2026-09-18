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

#ifndef CoreSpecSerialization_hpp
#define CoreSpecSerialization_hpp

#include <stdio.h>
#include "pxr/base/js/value.h"
#include "pxr/usd/sdf/spec.h"
#include "pxr/usd/sdf/primSpec.h"
#include "pxr/usd/sdf/attributeSpec.h"
#include "pxr/usd/sdf/relationshipSpec.h"
#include "pxr/usd/sdf/layer.h"

void readLayer(const pxr::SdfLayerRefPtr& layer, const pxr::JsValue& value);
void writeLayer(std::string* s, const pxr::SdfLayer& layer, const std::string& comment);

void readPrim(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPrimSpecHandle& prim, const pxr::JsValue& js);
void writePrim(pxr::JsObject& js, const pxr::SdfPrimSpecHandle& prim);

void readAttribute(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsValue& js);
void writeAttribute(pxr::JsObject& js, const pxr::SdfAttributeSpecHandle& attr);

void readRelationship(const pxr::SdfLayerRefPtr& layer, const pxr::SdfPath& path, const pxr::JsValue& js);
void writeRelationship(pxr::JsObject& js, const pxr::SdfRelationshipSpecHandle& rel);

// Note: VariantSpec and VariantSetSpec are handled in LIVERPSSerialization

#endif /* CoreSpecSerialization_hpp */
