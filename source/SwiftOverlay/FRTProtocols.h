//
//  FRTProtocols.h
//
//  Created by Maddy Adams on 12/6/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_FRTPROTOCOLS_H
#define SWIFTUSD_SWIFTOVERLAY_FRTPROTOCOLS_H

#include "pxr/base/tf/retainReleaseHelper.h"
#include "pxr/base/tf/refBase.h"
#include "swiftUsd/SwiftOverlay/SwiftCxxMacros.h"

namespace __Overlay {
    template <typename T>
    T* _Nullable dynamic_cast_raw_to_frt(void* _Nullable p) SWIFT_RETURNS_RETAINED {
        // You can't dynamic_cast from a void* because it has
        // no RTTI. TfRefBase has RTTI but TfWeakBase doesn't unless
        // we decide to make its dtor virtual, unlike vanilla OpenUSD. 
        // So for now, let's just assume we'll have a TfRefBase* that
        // we're trying to cast.

        if constexpr(std::is_base_of_v<pxr::TfRefBase, T>) {
            T* result = dynamic_cast<T*>(static_cast<pxr::TfRefBase*>(p));
            if (result) {
                pxr::Tf_RetainReleaseHelper::retain(result);
            }
            return result;
        } else {
            static_assert(false, "__Overlay::__dynamic_cast only supports TfRefBase subclasses");
        }
    }
}

#endif /* SWIFTUSD_SWIFTOVERLAY_FRTPROTOCOLS_H */
