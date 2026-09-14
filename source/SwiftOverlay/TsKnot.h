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

#ifndef SWIFTUSD_SWIFTOVERLAY_TSKNOT_H
#define SWIFTUSD_SWIFTOVERLAY_TSKNOT_H

#include "pxr/base/ts/knot.h"
#include "pxr/base/vt/value.h"

namespace Overlay {
    bool GetValue(const pxr::TsKnot& knot, pxr::VtValue* valueOut);
    bool GetPreValue(const pxr::TsKnot& knot, pxr::VtValue* valueOut);
    bool GetPreTanSlope(const pxr::TsKnot& knot, pxr::VtValue* valueOut);
    bool GetPostTanSlope(const pxr::TsKnot& knot, pxr::VtValue* valueOut);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_TSKNOT_H */
