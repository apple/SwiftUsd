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

#include "swiftUsd/SwiftOverlay/operatorBool.h"

#define BOOL_DEF(TYPE) \
    bool Overlay::_operatorBool(const TYPE& x) {\
        return (bool) x;\
    }


bool __Overlay::convertToBool(const pxr::TfRefPtr<pxr::UsdStage>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::TfRefPtr<pxr::SdfLayer>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::TfWeakPtr<pxr::UsdStage>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::TfWeakPtr<pxr::SdfLayer>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdShadeInput& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdShadeOutput& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdAttribute& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdGeomXformOp& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdRelationship& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfPropertySpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfPrimSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfVariantSetSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfVariantSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfAttributeSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfRelationshipSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfPseudoRootSpecHandle& x) {
    return (bool) x;
}
