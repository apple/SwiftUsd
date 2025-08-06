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

#include "swiftUsd/SwiftOverlay/SdfSpecHandle.h"

pxr::SdfSpec __Overlay::operatorArrow(const pxr::SdfSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfPropertySpec __Overlay::operatorArrow(const pxr::SdfPropertySpecHandle& x) {
    return *x.operator->();
}
pxr::SdfPrimSpec __Overlay::operatorArrow(const pxr::SdfPrimSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfVariantSetSpec __Overlay::operatorArrow(const pxr::SdfVariantSetSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfVariantSpec __Overlay::operatorArrow(const pxr::SdfVariantSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfAttributeSpec __Overlay::operatorArrow(const pxr::SdfAttributeSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfRelationshipSpec __Overlay::operatorArrow(const pxr::SdfRelationshipSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfPseudoRootSpec __Overlay::operatorArrow(const pxr::SdfPseudoRootSpecHandle& x) {
    return *x.operator->();
}
