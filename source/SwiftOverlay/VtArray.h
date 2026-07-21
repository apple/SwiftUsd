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

#ifndef SWIFTUSD_SWIFTOVERLAY_VTARRAY_H
#define SWIFTUSD_SWIFTOVERLAY_VTARRAY_H

#include <type_traits>
#include "pxr/base/vt/array.h"

namespace __Overlay {
    // expose `assign` in a way Swift will import. VtArray uses copy-on-write
    // storage, so this constructs the array with a single copy of the source
    // range, rather than the element-by-element push_back the Collection
    // initializer falls back to.
    template <typename VtArray, typename Element>
    inline void VtArray_assign(VtArray& array, const Element* first, const Element* last) {
        static_assert(std::is_same_v<VtArray, pxr::VtArray<Element>>);
        array.assign(first, last);
    }
}

#endif // SWIFTUSD_SWIFTOVERLAY_VTARRAY_H
