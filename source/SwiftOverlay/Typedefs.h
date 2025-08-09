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

#ifndef SWIFTUSD_SWIFTOVERLAY_TYPEDEFS_H
#define SWIFTUSD_SWIFTOVERLAY_TYPEDEFS_H

#include "swiftUsd/defines.h"


#include <memory>
#include <vector>
#include <string>
#include <utility>
#include "pxr/pxr.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
#include "pxr/imaging/hgi/blitCmds.h"
#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
#include "pxr/usd/usd/stage.h"
#include "pxr/usd/usd/editTarget.h"
#include "pxr/base/vt/dictionary.h"
#include "pxr/base/gf/vec4f.h"
#include "pxr/usd/usdGeom/xformOp.h"
#include "pxr/usd/usd/attribute.h"
#include "pxr/usd/usd/relationship.h"
#include "pxr/usd/sdf/layer.h"
#include "pxr/usd/usdShade/input.h"
#include "pxr/base/tf/diagnosticBase.h"
#include "pxr/base/vt/array.h"
#include "pxr/usd/sdf/assetPath.h"

namespace Overlay {
    #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
    typedef std::shared_ptr<pxr::HgiBlitCmds> HgiBlitCmds_SharedPtr;
    #endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

    typedef std::pair<pxr::UsdStagePtr, pxr::UsdEditTarget> UsdStagePtr_UsdEditTarget_Pair;
    typedef std::pair<pxr::VtDictionary::iterator, bool> VtDictionary_Iterator_Bool_Pair;
  
    typedef std::vector<std::string> String_Vector;
    typedef std::vector<double> Double_Vector;
    typedef std::vector<std::pair<std::string, std::string>> String_String_Pair_Vector;

    typedef std::vector<pxr::GfVec4f> GfVec4f_Vector;
    typedef std::vector<pxr::UsdGeomXformOp> UsdGeomXformOp_Vector;
    typedef std::vector<pxr::UsdProperty> UsdProperty_Vector;
    typedef std::vector<pxr::UsdAttribute> UsdAttribute_Vector;
    typedef std::vector<pxr::UsdRelationship> UsdRelationship_Vector;
    typedef std::vector<std::shared_ptr<pxr::TfDiagnosticBase>> TfDiagnosticBase_Shared_Ptr_Vector;
    typedef std::vector<std::unique_ptr<pxr::TfDiagnosticBase>> TfDiagnosticBase_Unique_Ptr_Vector;
    typedef std::vector<pxr::UsdShadeInput> UsdShadeInput_Vector;
    typedef std::vector<pxr::TfRefPtr<pxr::SdfLayer>> SdfLayer_RefPtr_Vector;

    typedef std::set<std::string> String_Set;
    typedef std::set<pxr::SdfLayerHandle> SdfLayerHandle_Set;

    typedef std::shared_ptr<pxr::TfDiagnosticBase> TfDiagnosticBase_Shared_Ptr;

    typedef pxr::VtArray<pxr::SdfAssetPath> SdfAssetPath_VtArray;
}

#endif /* SWIFTUSD_SWIFTOVERLAY_TYPEDEFS_H */
