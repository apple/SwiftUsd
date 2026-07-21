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
    //
    // Swift 6.3 fixes https://github.com/swiftlang/swift/pull/82161, but on Swift 6.1 and Swift 6.2,
    // templated methods taking pointers without nullability annotations are assumed to be non-null,
    // and templated methods taking pointers with nullability annotations aren't imported. So,
    // use ptrdiff_t instead
    template <typename VtArray>
    inline void VtArray_assign(VtArray& array, ptrdiff_t frontPtr, ptrdiff_t backPtr) {
        using Element = typename VtArray::ElementType;
        static_assert(std::is_same_v<VtArray, pxr::VtArray<Element>>);
        const Element* front = reinterpret_cast<const Element*>(frontPtr);
        const Element* back = reinterpret_cast<const Element*>(backPtr);
        array.assign(front, back);
    }
}

#endif // SWIFTUSD_SWIFTOVERLAY_VTARRAY_H
