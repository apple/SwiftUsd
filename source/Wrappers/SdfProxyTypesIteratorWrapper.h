//
//  SdfProxyTypesIteratorWrapper.h
//  SwiftUsd
//
//  Created by Maddy Adams on 6/2/25.
//

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
