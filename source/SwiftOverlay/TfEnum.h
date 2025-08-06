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

#ifndef SWIFTUSD_SWIFTOVERLAY_TFENUM_H
#define SWIFTUSD_SWIFTOVERLAY_TFENUM_H

#include "pxr/base/tf/enum.h"

namespace Overlay {
    // https://github.com/swiftlang/swift/issues/83081 (Templated C++ function incorrectly imported as returning Void in Swift)
    // Without that, we could do `template <typename T> pxr::TfEnum TfEnum(T x) { return pxr::TfEnum(x); }`
    template <typename T>
    void formTfEnum(T x, pxr::TfEnum& y) {
        y = x;
    }
}

#endif /* SWIFTUSD_SWIFTOVERLAY_TFENUM_H */
