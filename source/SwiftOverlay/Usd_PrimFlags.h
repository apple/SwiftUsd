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

#ifndef SWIFTUSD_SWIFTOVERLAY_USD_PRIMFLAGS_H
#define SWIFTUSD_SWIFTOVERLAY_USD_PRIMFLAGS_H

#include "pxr/usd/usd/primFlags.h"

namespace Overlay {
  extern const pxr::Usd_PrimFlags Usd_PrimActiveFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimLoadedFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimModelFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimGroupFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimComponentFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimAbstractFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimDefinedFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimHasDefiningSpecifierFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimInstanceFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimHasPayloadFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimClipsFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimDeadFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimPrototypeFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimInstanceProxyFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimPseudoRootFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimNumFlags;
}
namespace Overlay {
  extern const pxr::Usd_PrimFlagsPredicate UsdPrimDefaultPredicate;
}


#endif /* SWIFTUSD_SWIFTOVERLAY_USD_PRIMFLAGS_H */
