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
