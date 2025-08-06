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

#ifndef SWIFTUSD_SWIFTOVERLAY_OPERATORBOOL_H
#define SWIFTUSD_SWIFTOVERLAY_OPERATORBOOL_H

#include "pxr/pxr.h"
#include "pxr/base/tf/refPtr.h"
#include "pxr/base/tf/weakPtr.h"
#include "pxr/usd/usd/stage.h"
#include "pxr/usd/sdf/layer.h"
#include "pxr/usd/usdShade/input.h"
#include "pxr/usd/usdShade/output.h"
#include "pxr/usd/usd/attribute.h"
#include "pxr/usd/usdGeom/xformOp.h"
#include "pxr/usd/usd/relationship.h"
#include "pxr/usd/sdf/spec.h"
#include "pxr/usd/sdf/propertySpec.h"
#include "pxr/usd/sdf/primSpec.h"
#include "pxr/usd/sdf/variantSetSpec.h"
#include "pxr/usd/sdf/variantSpec.h"
#include "pxr/usd/sdf/attributeSpec.h"
#include "pxr/usd/sdf/relationshipSpec.h"
#include "pxr/usd/sdf/pseudoRootSpec.h"

namespace __Overlay {
    bool convertToBool(const pxr::TfRefPtr<pxr::UsdStage>& x);
    bool convertToBool(const pxr::TfRefPtr<pxr::SdfLayer>& x);
    bool convertToBool(const pxr::TfWeakPtr<pxr::UsdStage>& x);
    bool convertToBool(const pxr::TfWeakPtr<pxr::SdfLayer>& x);
    bool convertToBool(const pxr::UsdShadeInput& x);
    bool convertToBool(const pxr::UsdShadeOutput& x);
    bool convertToBool(const pxr::UsdAttribute& x);
    bool convertToBool(const pxr::UsdGeomXformOp& x);
    bool convertToBool(const pxr::UsdRelationship& x);
    bool convertToBool(const pxr::SdfSpecHandle& x);
    bool convertToBool(const pxr::SdfPropertySpecHandle& x);
    bool convertToBool(const pxr::SdfPrimSpecHandle& x);
    bool convertToBool(const pxr::SdfVariantSetSpecHandle& x);
    bool convertToBool(const pxr::SdfVariantSpecHandle& x);
    bool convertToBool(const pxr::SdfAttributeSpecHandle& x);
    bool convertToBool(const pxr::SdfRelationshipSpecHandle& x);
    bool convertToBool(const pxr::SdfPseudoRootSpecHandle& x);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_OPERATORBOOL_H */
