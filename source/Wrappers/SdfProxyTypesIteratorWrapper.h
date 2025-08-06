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

#ifndef SWIFTUSD_WRAPPERS_SDFPROXYTYPESITERATORWRAPPER_H
#define SWIFTUSD_WRAPPERS_SDFPROXYTYPESITERATORWRAPPER_H

#include "pxr/usd/sdf/proxyTypes.h"
#include <memory>



namespace __Overlay {
    // For whatever reason, the compiler resolves `begin()` for SdfListProxy specializations to
    // the non-const version. So, select what type the IteratorWrappers' iterator should be
    // based on what the RangeType is. 
    template <typename RangeType>
    struct SdfProxyTypesIteratorTraits {};

    template <typename T>
    struct SdfProxyTypesIteratorTraits<pxr::SdfListProxy<T>> {
        typedef typename pxr::SdfListProxy<T>::iterator iterator;
    };

    template <typename T, typename U>
    struct SdfProxyTypesIteratorTraits<pxr::SdfChildrenView<T, U>> {
        typedef typename pxr::SdfChildrenView<T, U>::const_iterator iterator;
    };


    // For most iterators, their operator* returns their value_type (or rather const value_type&).
    // For whatever reason, SdfSubLayerProxy, i.e. SdfListProxy<SdfSubLayerTypePolicy>, has an
    // underlying type of std::string but should be converted to SdfAssetPath upon use. So,
    // select what the the IteratorWrappers' value_type should be based on what the RangeType is. 
    template <typename RangeType>
    struct SdfProxyTypesValueTypeTraits {
        typedef typename RangeType::value_type value_type;
    };
    template <>
    struct SdfProxyTypesValueTypeTraits<pxr::SdfListProxy<pxr::SdfSubLayerTypePolicy>> {
        typedef pxr::SdfAssetPath value_type;
    };

    
    template <typename RangeType>
    struct SdfProxyTypesIteratorWrapper {
    private:
        std::shared_ptr<RangeType> range;
        typename SdfProxyTypesIteratorTraits<RangeType>::iterator iterator;
        bool shouldAdvanceBeforeGettingCurrent;

    public:
        typedef typename SdfProxyTypesValueTypeTraits<RangeType>::value_type value_type;

        SdfProxyTypesIteratorWrapper(RangeType range) :
            range(std::make_shared<RangeType>(range)),
            iterator(this->range->begin()),
            shouldAdvanceBeforeGettingCurrent(false) {}

        value_type advanceAndGetCurrent(bool* _Nonnull resultIsValid) {
            if (shouldAdvanceBeforeGettingCurrent) {
                ++iterator;
            }
            shouldAdvanceBeforeGettingCurrent = true;

            *resultIsValid = iterator != range->end();
            return *resultIsValid ? (value_type) *iterator : value_type();
        }
    };

    typedef SdfProxyTypesIteratorWrapper<pxr::SdfNameOrderProxy> SdfNameOrderProxyIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfSubLayerProxy> SdfSubLayerProxyIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfAttributeSpecView> SdfAttributeSpecViewIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfPrimSpecView> SdfPrimSpecViewIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfPropertySpecView> SdfPropertySpecViewIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfRelationalAttributeSpecView> SdfRelationalAttributeSpecViewIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfRelationshipSpecView> SdfRelationshipSpecViewIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfVariantView> SdfVariantViewIteratorWrapper;
    typedef SdfProxyTypesIteratorWrapper<pxr::SdfVariantSetView> SdfVariantSetViewIteratorWrapper;
}

#endif /* SWIFTUSD_WRAPPERS_SDFPROXYTYPESITERATORWRAPPER_H */
