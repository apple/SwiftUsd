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

#ifndef SWIFTUSD_SWIFTOVERLAY_SDFSPECHANDLE_H
#define SWIFTUSD_SWIFTOVERLAY_SDFSPECHANDLE_H

#include "pxr/usd/sdf/spec.h"
#include "pxr/usd/sdf/propertySpec.h"
#include "pxr/usd/sdf/primSpec.h"
#include "pxr/usd/sdf/variantSetSpec.h"
#include "pxr/usd/sdf/variantSpec.h"
#include "pxr/usd/sdf/attributeSpec.h"
#include "pxr/usd/sdf/relationshipSpec.h"
#include "pxr/usd/sdf/pseudoRootSpec.h"

namespace __Overlay {
    pxr::SdfSpec operatorArrow(const pxr::SdfSpecHandle& x);
    pxr::SdfPropertySpec operatorArrow(const pxr::SdfPropertySpecHandle& x);
    pxr::SdfPrimSpec operatorArrow(const pxr::SdfPrimSpecHandle& x);
    pxr::SdfVariantSetSpec operatorArrow(const pxr::SdfVariantSetSpecHandle& x);
    pxr::SdfVariantSpec operatorArrow(const pxr::SdfVariantSpecHandle& x);
    pxr::SdfAttributeSpec operatorArrow(const pxr::SdfAttributeSpecHandle& x);
    pxr::SdfRelationshipSpec operatorArrow(const pxr::SdfRelationshipSpecHandle& x);
    pxr::SdfPseudoRootSpec operatorArrow(const pxr::SdfPseudoRootSpecHandle& x);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_SDFSPECHANDLE_H */
