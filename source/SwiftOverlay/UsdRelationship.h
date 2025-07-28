//
//  UsdRelationship.h
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_USDRELATIONSHIP_H
#define SWIFTUSD_SWIFTOVERLAY_USDRELATIONSHIP_H

#include "pxr/pxr.h"
#include "pxr/usd/usd/relationship.h"
#include "pxr/usd/usd/property.h"
#include "pxr/usd/sdf/path.h"
#include "pxr/base/tf/token.h"
#include "pxr/base/vt/value.h"

namespace Overlay {
    pxr::UsdRelationship UsdProperty_As(const pxr::UsdProperty& r);
    pxr::SdfPath GetPath(const pxr::UsdRelationship& x);
    bool GetMetadata(const pxr::UsdRelationship& rel, const pxr::TfToken& key, pxr::VtValue* value);    
    bool SetMetadata(const pxr::UsdRelationship& r, const pxr::TfToken& key, const pxr::VtValue& value);
    bool HasMetadata(const pxr::UsdRelationship& rel, const pxr::TfToken& key);
    bool ClearMetadata(const pxr::UsdRelationship& r, const pxr::TfToken& key);
    bool HasAuthoredMetadata(const pxr::UsdRelationship& rel, const pxr::TfToken& key);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_USDRELATIONSHIP_H */
