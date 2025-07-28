//
//  UsdAttribute.cpp
//
//  Created by Maddy Adams on 3/28/24

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

