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
