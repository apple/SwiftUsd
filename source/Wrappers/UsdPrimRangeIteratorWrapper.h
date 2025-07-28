//
//  UsdPrimRangeIteratorWrapper.h
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_WRAPPERS_USDPRIMRANGEITERATORWRAPPER_H
#define SWIFTUSD_WRAPPERS_USDPRIMRANGEITERATORWRAPPER_H

#include <memory>
#include "pxr/usd/usd/primRange.h"
#include "pxr/usd/usd/prim.h"

namespace Overlay {
    struct UsdPrimRangeIteratorWrapper {
    private:
        std::shared_ptr<pxr::UsdPrimRange> range;
        pxr::UsdPrimRange::iterator iterator;
        bool shouldAdvanceBeforeGettingCurrent;
    public:
        UsdPrimRangeIteratorWrapper(pxr::UsdPrimRange range);
        pxr::UsdPrim advanceAndGetCurrent();
        bool IsPostVisit() const;
        void PruneChildren();
    };
}

#endif /* SWIFTUSD_WRAPPERS_USDPRIMRANGEITERATORWRAPPER_H */
