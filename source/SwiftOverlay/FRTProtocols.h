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
