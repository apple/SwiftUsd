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

#ifndef SWIFTUSD_SWIFTOVERLAY_MATH_H
#define SWIFTUSD_SWIFTOVERLAY_MATH_H

#include "pxr/pxr.h"
#include "pxr/base/gf/rotation.h"
#include "pxr/base/gf/matrix4d.h"

namespace __Overlay {
    // Workaround for https://github.com/swiftlang/swift/issues/83112 (Calling Swift subscript across module boundary accesses uninitialized memory in Release (C++ interop))
    const double* GfMatrix4d_subscript_workaround(const pxr::GfMatrix4d& x, int i);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_MATH_H */
