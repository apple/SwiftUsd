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

#ifndef SdfTemplateProtocols_hpp
#define SdfTemplateProtocols_hpp

#include <stdio.h>
#include <utility>
#include <map>
#include "pxr/usd/sdf/proxyTypes.h"
#include "pxr/usd/sdf/variantSetSpec.h"
#include "swiftUsd/Wrappers/SdfProxyTypesIteratorWrapper.h"

// See the note in ProxyTypeSequenceWoarkarounds.swift,
// this is just what it takes sometimes to conform C++ types
// to the right Swift protocols

namespace Overlay {
    typedef std::pair<pxr::SdfRelocatesMapProxy::iterator, bool> SdfRelocatesMapProxy_Iterator_Bool_Pair;
    typedef std::pair<pxr::SdfVariantSelectionProxy::iterator, bool> SdfVariantSelectionProxy_Iterator_Bool_Pair;
    typedef std::pair<pxr::SdfTimeSampleMap::iterator, bool> SdfTimeSampleMap_Iterator_Bool_Pair;
}

namespace __Overlay {
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfNameEditorProxy::ListProxy> SdfNameEditorProxyListProxyIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfPathEditorProxy::ListProxy> SdfPathEditorProxyListProxyIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfPayloadEditorProxy::ListProxy> SdfPayloadEditorProxyListProxyIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfReferenceEditorProxy::ListProxy> SdfReferenceEditorProxyListProxyIteratorWrapper;

    
    bool manual_operatorEqualsEquals(pxr::SdfVariantSetsProxy::const_iterator const& a, pxr::SdfVariantSetsProxy::const_iterator const& b);
    
    bool manual_operatorEqualsEquals(pxr::SdfRelocatesMapProxy::const_iterator const& a, pxr::SdfRelocatesMapProxy::const_iterator const& b);
    bool manual_operatorEqualsEquals(pxr::SdfRelocatesMapProxy::iterator const& a, pxr::SdfRelocatesMapProxy::iterator const& b);
        
    std::pair<pxr::SdfRelocatesMapProxy::iterator, bool> insert(pxr::SdfRelocatesMapProxy&, pxr::SdfRelocatesMapProxy::value_type const&);
    pxr::SdfRelocatesMapProxy::iterator erase(pxr::SdfRelocatesMapProxy&, pxr::SdfRelocatesMapProxy::iterator const&);
    pxr::SdfRelocatesMapProxy::value_type operatorStar(pxr::SdfRelocatesMapProxy::iterator const&);
    void operatorStarSet(pxr::SdfRelocatesMapProxy::iterator&, pxr::SdfRelocatesMapProxy::value_type const&);
    
    bool manual_operatorEqualsEquals(pxr::SdfVariantSelectionProxy::const_iterator const& a, pxr::SdfVariantSelectionProxy::const_iterator const& b);
    bool manual_operatorEqualsEquals(pxr::SdfVariantSelectionProxy::iterator const& a, pxr::SdfVariantSelectionProxy::iterator const& b);
    
    std::pair<pxr::SdfVariantSelectionProxy::iterator, bool> insert(pxr::SdfVariantSelectionProxy&, pxr::SdfVariantSelectionProxy::value_type const&);
    pxr::SdfVariantSelectionProxy::iterator erase(pxr::SdfVariantSelectionProxy&, pxr::SdfVariantSelectionProxy::iterator const&);
    pxr::SdfVariantSelectionProxy::value_type operatorStar(pxr::SdfVariantSelectionProxy::iterator const&);
    void operatorStarSet(pxr::SdfVariantSelectionProxy::iterator&, pxr::SdfVariantSelectionProxy::value_type const&);

}

#endif /* SdfTemplateProtocols_hpp */
