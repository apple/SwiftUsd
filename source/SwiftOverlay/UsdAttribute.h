//
//  UsdAttribute.h
//
//  Created by Maddy Adams on 3/28/24.
//

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
