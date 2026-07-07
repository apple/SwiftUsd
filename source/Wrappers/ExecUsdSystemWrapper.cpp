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

#include "swiftUsd/Wrappers/ExecUsdSystemWrapper.h"

#include <algorithm>

// MARK: Construction

Overlay::ExecUsdSystemWrapper::ExecUsdSystemWrapper(const pxr::UsdStageRefPtr &stage) :
    _impl(std::make_shared<pxr::ExecUsdSystem>(stage))
{
}

// MARK: Time

void Overlay::ExecUsdSystemWrapper::ChangeTime(pxr::UsdTimeCode time) {
    _impl->ChangeTime(time);
}

// MARK: Requests

pxr::ExecUsdRequest Overlay::ExecUsdSystemWrapper::BuildRequest(std::vector<pxr::ExecUsdValueKey> &&valueKeys,
                                                                pxr::ExecRequestComputedValueInvalidationCallback &&valueCallback,
                                                                pxr::ExecRequestTimeChangeInvalidationCallback &&timeCallback) {
    return _impl->BuildRequest(std::move(valueKeys),
                               std::move(valueCallback),
                               std::move(timeCallback));
}

void Overlay::ExecUsdSystemWrapper::PrepareRequest(const pxr::ExecUsdRequest &request) {
    _impl->PrepareRequest(request);
}

pxr::ExecUsdCacheView Overlay::ExecUsdSystemWrapper::Compute(const pxr::ExecUsdRequest &request) {
    return _impl->Compute(request);
}

pxr::ExecUsdCacheView Overlay::ExecUsdSystemWrapper::ComputeWithOverrides(const pxr::ExecUsdRequest &request,
                                                                          pxr::ExecUsdValueOverrideVector &&valueOverrides) {
    return _impl->ComputeWithOverrides(request, std::move(valueOverrides));
}

// MARK: SwiftUsd implementation access

pxr::ExecUsdSystem* Overlay::ExecUsdSystemWrapper::get() const {
    return _impl.get();
}

std::shared_ptr<pxr::ExecUsdSystem> Overlay::ExecUsdSystemWrapper::get_shared() const {
    return _impl;
}

Overlay::ExecUsdSystemWrapper::operator bool() const {
    return (bool)_impl;
}

Overlay::ExecUsdSystemWrapper::ExecUsdSystemWrapper(std::shared_ptr<pxr::ExecUsdSystem> impl) :
    _impl(impl) {}

pxr::ExecUsdCacheView __Overlay::ComputeUnsafe(Overlay::ExecUsdSystemWrapper &system,
                                               const pxr::ExecUsdRequest &request) {
    return system.Compute(request);
}

pxr::ExecUsdCacheView __Overlay::ComputeWithOverridesUnsafe(Overlay::ExecUsdSystemWrapper &system,
                                                            const pxr::ExecUsdRequest &request,
                                                            pxr::ExecUsdValueOverrideVector &&valueOverrides) {
    return system.ComputeWithOverrides(request, std::move(valueOverrides));
}
