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

#include "swiftUsd/SwiftOverlay/UsdUtilsTimeCodeRange.h"

pxr::UsdUtilsTimeCodeRange::const_iterator::reference __Overlay::UsdUtilsTimeCodeRange_const_iterator__operatorStar(const pxr::UsdUtilsTimeCodeRange::const_iterator& x) {
    // Despite being a const_iterator, its operator* and operator-> are not marked as const
    // when they should be, so just const cast. (We're returning a reference, so we can't
    // make a local copy we can mutate and return the reference from that.)
    return const_cast<pxr::UsdUtilsTimeCodeRange::const_iterator&>(x).operator*();
}
