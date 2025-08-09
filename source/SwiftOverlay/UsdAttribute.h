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

#ifndef SWIFTUSD_SWIFTOVERLAY_USDATTRIBUTE_H
#define SWIFTUSD_SWIFTOVERLAY_USDATTRIBUTE_H

#include "pxr/pxr.h"
#include "pxr/usd/usd/attribute.h"
#include "pxr/base/tf/token.h"
#include "pxr/base/vt/array.h"
#include "pxr/base/tf/weakPtr.h"
#include "pxr/usd/usd/stage.h"
#include "pxr/usd/usdGeom/xformOp.h"
#include "pxr/usd/usdGeom/mesh.h"
#include "pxr/base/vt/value.h"
#include "pxr/usd/sdf/path.h"
#include "pxr/usd/usd/timeCode.h"

namespace Overlay {
   bool allowedTokensForAttribute(const pxr::UsdAttribute& attr, pxr::VtArray<pxr::TfToken>* result);

    pxr::UsdStagePtr GetStage(const pxr::UsdAttribute& a);
    
    pxr::UsdAttribute GetAttr(const pxr::UsdGeomXformOp& op);
    
    // UsdGeomMesh.CreateExtentAttr is ambiguous to the swift compiler.
    // might be because UsdGeomBoundable (which it inherits from) declares it?
    // there are also several classes between UsdGeomBoundable and UsdGeomMesh in the inheritance list
    pxr::UsdAttribute CreateExtentAttr(const pxr::UsdGeomMesh& mesh, const pxr::VtValue& defaultValue, bool writeSparsely);

    pxr::SdfPath GetPath(const pxr::UsdAttribute& x);

    bool Get(const pxr::UsdAttribute& attr, pxr::VtValue* value, const pxr::UsdTimeCode& timeCode);
    bool Set(const pxr::UsdAttribute& attr, const pxr::VtValue& value, const pxr::UsdTimeCode& timeCode);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_USDATTRIBUTE_H */
