//
//  UsdRelationship.cpp
//
//  Created by Maddy Adams on 3/28/24

#include "swiftUsd/SwiftOverlay/UsdRelationship.h"

pxr::UsdRelationship Overlay::UsdProperty_As(const pxr::UsdProperty& r) {
    return r.As<pxr::UsdRelationship>();
}
pxr::SdfPath Overlay::GetPath(const pxr::UsdRelationship& x) {
    return x.GetPath();
}
bool Overlay::GetMetadata(const pxr::UsdRelationship& rel, const pxr::TfToken& key, pxr::VtValue* value) {
    return rel.GetMetadata(key, value);
}
bool Overlay::SetMetadata(const pxr::UsdRelationship& r, const pxr::TfToken& key, const pxr::VtValue& value) {
    return r.SetMetadata(key, value);
}
bool Overlay::HasMetadata(const pxr::UsdRelationship& rel, const pxr::TfToken& key) {
    return rel.HasMetadata(key);
}
bool Overlay::ClearMetadata(const pxr::UsdRelationship& r, const pxr::TfToken& key) {
    return r.ClearMetadata(key);
}
bool Overlay::HasAuthoredMetadata(const pxr::UsdRelationship& rel, const pxr::TfToken& key) {
    return rel.HasAuthoredMetadata(key);
}
