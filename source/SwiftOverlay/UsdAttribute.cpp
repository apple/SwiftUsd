// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

#include "swiftUsd/SwiftOverlay/UsdAttribute.h"

bool Overlay::allowedTokensForAttribute(const pxr::UsdAttribute& attr, pxr::VtArray<pxr::TfToken>* result) {
    const pxr::UsdPrimDefinition& definition = attr.GetPrim().GetPrimDefinition();
    pxr::UsdPrimDefinition::Attribute attrDef = definition.GetAttributeDefinition(attr.GetName());
    if (!attrDef) {
        return false;
    }
    return attrDef.GetMetadata(pxr::TfToken("allowedTokens"), result);
}
pxr::UsdStagePtr Overlay::GetStage(const pxr::UsdAttribute& a) {
    return a.GetStage();
}
pxr::UsdAttribute Overlay::GetAttr(const pxr::UsdGeomXformOp& op) {
    return op.GetAttr();
}

pxr::UsdAttribute Overlay::CreateExtentAttr(const pxr::UsdGeomMesh& mesh, const pxr::VtValue& defaultValue, bool writeSparsely) {
    return mesh.CreateExtentAttr(defaultValue, writeSparsely);
}
pxr::SdfPath Overlay::GetPath(const pxr::UsdAttribute& x) {
    return x.GetPath();
}
bool Overlay::Get(const pxr::UsdAttribute& attr, pxr::VtValue* value, const pxr::UsdTimeCode& timeCode) {
    return attr.Get(value, timeCode);
}
bool Overlay::Set(const pxr::UsdAttribute& attr, const pxr::VtValue& value, const pxr::UsdTimeCode& timeCode) {
    return attr.Set(value, timeCode);
}

