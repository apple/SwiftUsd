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

#include "SdfProxyTypes.hpp"

bool __Overlay::manual_operatorEqualsEquals(pxr::SdfVariantSetsProxy::const_iterator const& a, pxr::SdfVariantSetsProxy::const_iterator const& b) {
    return a == b;
}


bool __Overlay::manual_operatorEqualsEquals(pxr::SdfRelocatesMapProxy::const_iterator const& a, pxr::SdfRelocatesMapProxy::const_iterator const& b) {
    return a == b;
}

bool __Overlay::manual_operatorEqualsEquals(pxr::SdfRelocatesMapProxy::iterator const& a, pxr::SdfRelocatesMapProxy::iterator const& b) {
    return a == b;
}

std::pair<pxr::SdfRelocatesMapProxy::iterator, bool> __Overlay::insert(pxr::SdfRelocatesMapProxy& p, pxr::SdfRelocatesMapProxy::value_type const& x) {
    return p.insert(x);
}

pxr::SdfRelocatesMapProxy::iterator __Overlay::erase(pxr::SdfRelocatesMapProxy& proxy, pxr::SdfRelocatesMapProxy::iterator const& it) {
#warning SdfRelocatesMapProxy::erase doesn't return its iterator. this workaround might be unsafe or incorrect
    auto result = it;
    result++;
    proxy.erase(it);
    return result;
}

pxr::SdfRelocatesMapProxy::value_type __Overlay::operatorStar(pxr::SdfRelocatesMapProxy::iterator const& it) {
    return *it;
}
void __Overlay::operatorStarSet(pxr::SdfRelocatesMapProxy::iterator& it, pxr::SdfRelocatesMapProxy::value_type const& newValue) {
    it->second = newValue.second;
}




bool __Overlay::manual_operatorEqualsEquals(pxr::SdfVariantSelectionProxy::const_iterator const& a, pxr::SdfVariantSelectionProxy::const_iterator const& b) {
    return a == b;
}

bool __Overlay::manual_operatorEqualsEquals(pxr::SdfVariantSelectionProxy::iterator const& a, pxr::SdfVariantSelectionProxy::iterator const& b) {
    return a == b;
}

std::pair<pxr::SdfVariantSelectionProxy::iterator, bool> __Overlay::insert(pxr::SdfVariantSelectionProxy& p, pxr::SdfVariantSelectionProxy::value_type const& x) {
    return p.insert(x);
}

pxr::SdfVariantSelectionProxy::iterator __Overlay::erase(pxr::SdfVariantSelectionProxy& proxy, pxr::SdfVariantSelectionProxy::iterator const& it) {
#warning SdfVariantSelectionProxy::erase doesn't return its iterator. this workaround might be unsafe or incorrect
    auto result = it;
    result++;
    proxy.erase(it);
    return result;
}

pxr::SdfVariantSelectionProxy::value_type __Overlay::operatorStar(pxr::SdfVariantSelectionProxy::iterator const& it) {
    return *it;
}
void __Overlay::operatorStarSet(pxr::SdfVariantSelectionProxy::iterator& it, pxr::SdfVariantSelectionProxy::value_type const& newValue) {
    it->second = newValue.second;
}
