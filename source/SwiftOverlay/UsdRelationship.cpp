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
