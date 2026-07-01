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

// Original documentation for pxr::ExecUsdSystem from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.05/pxr/exec/execUsd/system.h

#ifndef SWIFTUSD_WRAPPERS_EXECUSDSYSTEMWRAPPER_H
#define SWIFTUSD_WRAPPERS_EXECUSDSYSTEMWRAPPER_H

#include "swiftUsd/defines.h"
#include "swiftUsd/SwiftOverlay/SwiftCxxMacros.h"

#include <memory>
#include <vector>
#include <cstdint>

#include "pxr/pxr.h"
#include "pxr/usd/usd/stage.h"
#include "pxr/usd/usd/timeCode.h"

#include "pxr/exec/ef/timeInterval.h"

#include "pxr/exec/execUsd/system.h"
#include "pxr/exec/execUsd/request.h"
#include "pxr/exec/execUsd/valueKey.h"
#include "pxr/exec/execUsd/valueOverride.h"
#include "pxr/exec/execUsd/cacheView.h"

namespace Overlay {
    /// \class ExecUsdSystem
    ///
    /// The implementation of a system to procedurally compute values based on
    /// USD scene description and computation definitions.
    ///
    /// ExecUsdSystem specializes the base ExecSystem class and owns
    /// USD-specific structures and logic necessary to compile, schedule and
    /// evaluate requested computation values.
    ///
    /// The ExecUsdSystem extends the lifetime of the UsdStage it is
    /// constructed with, although it is atypical for an ExecUsdSystem to
    /// outlive its stage in practice. As a rule of thumb, the ExecUsdSystem
    /// lives right alongside the UsdStage in most use-cases.
    ///
    class ExecUsdSystemWrapper {
    public:
        ExecUsdSystemWrapper(const pxr::UsdStageRefPtr &stage);

        /// Changes the \p time at which values are computed.
        ///
        /// Calling this method re-resolves time-dependent inputs from the
        /// scene graph at the new \p time, and determines which of these
        /// inputs are *actually* changing between the old and new time.
        /// Computed values that are dependent on the changing inputs are then
        /// invalidated, and requests are notified of the time change.
        void ChangeTime(pxr::UsdTimeCode time);

        /// Builds a request for the given \p valueKeys.
        ///
        /// The optionally provided \p valueCallback will be invoked when
        /// previously computed value keys become invalid as a result of authored
        /// value changes or structural invalidation of the scene. If multiple
        /// value keys become invalid at the same time, they may be batched into a
        /// single invocation of the callback.
        pxr::ExecUsdRequest BuildRequest(
            std::vector<pxr::ExecUsdValueKey> &&valueKeys,
            pxr::ExecRequestComputedValueInvalidationCallback &&valueCallback =
                pxr::ExecRequestComputedValueInvalidationCallback(),
            pxr::ExecRequestTimeChangeInvalidationCallback &&timeCallback =
                pxr::ExecRequestTimeChangeInvalidationCallback());

        /// Prepares a given \p request for execution.
        ///
        /// This ensures the exec network is compiled and scheduled for the
        /// value keys in the request. Compute() will implicitly prepare the
        /// request if needed, but calling PrepareRequest() separately enables
        /// clients to front-load compilation and scheduling cost.
        void PrepareRequest(const pxr::ExecUsdRequest &request);

        /// Executes the given \p request and returns a cache view for
        /// extracting the computed values.
        ///
        /// This implicitly calls PrepareRequest(), though clients may choose
        /// to call PrepareRequest() ahead of time and front-load the
        /// associated compilation and scheduling cost.
        pxr::ExecUsdCacheView Compute(const pxr::ExecUsdRequest &request)
        SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Compute(_:_:_:) instead");

        /// Executes the given \p request in the presence of
        /// \p valueOverrides, and returns a cache view for extracting the
        /// computed values.
        ///
        /// The overrides only apply for a single invocation of
        /// ComputeWithOverrides, and do not affect subsequent calls to
        /// Compute or ComputeWithOverrides.
        pxr::ExecUsdCacheView ComputeWithOverrides(const pxr::ExecUsdRequest &request,
                                                   pxr::ExecUsdValueOverrideVector &&valueOverrides)
        SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.ComputeWithOverrides(_:_:consuming:_:) instead");

        /// MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor
        ExecUsdSystemWrapper(std::shared_ptr<pxr::ExecUsdSystem> impl);

        /// Gets the underlying ExecUsdSystem instance
        pxr::ExecUsdSystem*_Nullable get() const;

        /// Gets the underlying ExecUsdSystem instance
        std::shared_ptr<pxr::ExecUsdSystem> get_shared() const;

        /// Returns `true` if the underlying instance is valid
        explicit operator bool() const;

    private:
        std::shared_ptr<pxr::ExecUsdSystem> _impl;
    };
}

namespace __Overlay {
    pxr::ExecUsdCacheView ComputeUnsafe(Overlay::ExecUsdSystemWrapper &system,
                                        const pxr::ExecUsdRequest &request);

    pxr::ExecUsdCacheView ComputeWithOverridesUnsafe(Overlay::ExecUsdSystemWrapper &system,
                                                     const pxr::ExecUsdRequest &request,
                                                     pxr::ExecUsdValueOverrideVector &&valueOverrides);
}

#endif /* SWIFTUSD_WRAPPERS_EXECUSDSYSTEMWRAPPER_H */
