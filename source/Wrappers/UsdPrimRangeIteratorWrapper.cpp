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

#include "swiftUsd/Wrappers/UsdPrimRangeIteratorWrapper.h"

Overlay::UsdPrimRangeIteratorWrapper::UsdPrimRangeIteratorWrapper(pxr::UsdPrimRange rangeArgument) :
    range(std::make_shared<pxr::UsdPrimRange>(rangeArgument)),
    iterator(this->range->begin()), // note! not using rangeArgument, because iterators from different ranges never compare equal!
    shouldAdvanceBeforeGettingCurrent(false) // iterator is pointing at range.begin(), so we want to return that prim first
{
}


pxr::UsdPrim Overlay::UsdPrimRangeIteratorWrapper::advanceAndGetCurrent() {
    // C++ for-loops have the iterator advancement occur at the very end of the loop,
    // which is important for pruning because pruning happens on the "current" item, changing what the next item would be
    // Thus, we need to
    if (shouldAdvanceBeforeGettingCurrent) {
        ++iterator;
    }
    shouldAdvanceBeforeGettingCurrent = true;
    
    return iterator == range->end() ? pxr::UsdPrim() : *iterator;
}

bool Overlay::UsdPrimRangeIteratorWrapper::IsPostVisit() const {
    return iterator.IsPostVisit();
}

void Overlay::UsdPrimRangeIteratorWrapper::PruneChildren() {
    iterator.PruneChildren();
}
