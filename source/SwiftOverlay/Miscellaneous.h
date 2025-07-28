//
//  Miscellaneous.h
//
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_MISCELLANEOUS_H
#define SWIFTUSD_SWIFTOVERLAY_MISCELLANEOUS_H

#include <functional>
#include "pxr/pxr.h"
#include "pxr/usd/usd/common.h"
#include "pxr/base/vt/value.h"
#include "pxr/base/tf/token.h"
#include "pxr/base/vt/array.h"
#include "pxr/usd/usdGeom/xformOp.h"
#include "pxr/usd/sdf/path.h"
#include "pxr/usd/sdf/layerStateDelegate.h"
#include "pxr/usd/usd/notice.h"

namespace SwiftUsd {}

namespace Overlay {
    extern const std::function<bool (const pxr::TfToken& propertyName)> DefaultPropertyPredicateFunc;
}

namespace __Overlay {
    // Workaround for rdar://124105392 (UsdMetadataValueMap subscript getter is mutating (5.10 regression))
    pxr::VtValue operatorSubscript(const pxr::UsdMetadataValueMap& m, const pxr::TfToken& x, bool* isValid);
    
    // SdfPathSet is std::set<SdfPath>, which isn't caught by Equatable codegen
    bool operatorEqualsEquals(const pxr::SdfPathSet& l, const pxr::SdfPathSet& r);
    
}

#endif /* SWIFTUSD_SWIFTOVERLAY_MISCELLANEOUS_H */
