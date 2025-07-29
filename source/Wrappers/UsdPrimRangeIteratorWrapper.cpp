//
//  UsdPrimRangeIteratorWrapper.cpp
//
//  Created by Maddy Adams on 3/28/24.h

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
