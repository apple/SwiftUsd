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

#include "swiftUsd/TfNotice/SwiftKey.h"
#include "swiftUsd/TfNotice/ListenerHolder.h"

pxr::TfNotice::SwiftKey::SwiftKey(pxr::TfNotice::Key registrationKey) : _listener(nullptr), _key(registrationKey) {}

bool pxr::TfNotice::SwiftKey::IsValid() const {
    return _key.IsValid();
}

pxr::TfNotice::SwiftKey::operator bool() const {
    return IsValid();
}

bool pxr::TfNotice::SwiftKey::operator<(const SwiftKey& other) const {
    return _key._deliverer < other._key._deliverer;
}

pxr::TfNotice::SwiftKey::SwiftKey() : _listener(nullptr), _key(pxr::TfNotice::Key()) {}

pxr::TfNotice::SwiftKey::SwiftKey(pxr::TfWeakPtr<__SwiftUsd::TfNotice::ListenerBase> listener,
                                  pxr::TfNotice::Key registrationKey) :
_listener(listener), _key(registrationKey) {}


#ifndef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS
// We stub out definitions for these in the header for DocC purposes,
// but can't redefine a function, so put them in a #ifndef
bool pxr::TfNotice::Revoke(pxr::TfNotice::SwiftKey key) {
    return __SwiftUsd::TfNotice::ListenerHolder::GetInstance().Revoke(key);
}

void pxr::TfNotice::Revoke(pxr::TfNotice::SwiftKeys* keys) {
    for (const auto& key : *keys) {
        pxr::TfNotice::Revoke(key);
    }
    keys->clear();
}

bool pxr::TfNotice::RevokeAndWait(pxr::TfNotice::SwiftKey key) {
    return __SwiftUsd::TfNotice::ListenerHolder::GetInstance().RevokeAndWait(key);
}
void pxr::TfNotice::RevokeAndWait(pxr::TfNotice::SwiftKeys* keys) {
    for (const auto& key : *keys) {
        pxr::TfNotice::RevokeAndWait(key);
    }
    keys->clear();
}
#endif // #ifndef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS
