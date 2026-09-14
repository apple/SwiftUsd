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

#include "swiftUsd/SwiftOverlay/Math.h"


const double* __Overlay::GfMatrix2d_subscript_workaround(const pxr::GfMatrix2d &x, int i) {
    return x[i];
}

double* __Overlay::GfMatrix2d_mutable_subscript_workaround(pxr::GfMatrix2d &x, int i) {
    return x[i];
}

const double* __Overlay::GfMatrix3d_subscript_workaround(const pxr::GfMatrix3d &x, int i) {
    return x[i];
}

double* __Overlay::GfMatrix3d_mutable_subscript_workaround(pxr::GfMatrix3d &x, int i) {
    return x[i];
}

const double* __Overlay::GfMatrix4d_subscript_workaround(const pxr::GfMatrix4d &x, int i) {
    return x[i];
}

double* __Overlay::GfMatrix4d_mutable_subscript_workaround(pxr::GfMatrix4d &x, int i) {
    return x[i];
}
