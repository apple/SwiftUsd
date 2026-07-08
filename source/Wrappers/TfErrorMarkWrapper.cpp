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

#include "swiftUsd/Wrappers/TfErrorMarkWrapper.h"

void Overlay::TfErrorMarkWrapper::SetMark() const {
    _impl->SetMark();
}

bool Overlay::TfErrorMarkWrapper::IsClean() const {
    return _impl->IsClean();
}

bool Overlay::TfErrorMarkWrapper::Clear() const {
    return _impl->Clear();
}

pxr::TfErrorTransport Overlay::TfErrorMarkWrapper::Transport() const {
    return _impl->Transport();
}

void Overlay::TfErrorMarkWrapper::TransportTo(pxr::TfErrorTransport& dest) const {
    _impl->TransportTo(dest);
}

pxr::TfErrorMark::Iterator Overlay::TfErrorMarkWrapper::GetBegin(size_t*_Nullable nErrors) const {
    return _impl->GetBegin(nErrors);
}

pxr::TfErrorMark::Iterator Overlay::TfErrorMarkWrapper::GetEnd() const {
    return _impl->GetEnd();
}

pxr::TfErrorMark::Iterator Overlay::TfErrorMarkWrapper::begin() const {
    return _impl->begin();
}

pxr::TfErrorMark::Iterator Overlay::TfErrorMarkWrapper::end() const {
    return _impl->end();
}


Overlay::TfErrorMarkWrapper __Overlay::makeTfErrorMarkWrapper_friend() {
    return {};
}

Overlay::TfErrorMarkWrapper::TfErrorMarkWrapper() : _impl(std::make_unique<pxr::TfErrorMark>()) {}

Overlay::TfErrorMarkWrapper __Overlay::makeTfErrorMarkWrapper() {
    return makeTfErrorMarkWrapper_friend();
}
