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

#ifndef SWIFTUSD_TFNOTICE_SWIFTKEY_H
#define SWIFTUSD_TFNOTICE_SWIFTKEY_H

#include "pxr/base/tf/notice.h"
#include "pxr/base/tf/weakPtr.h"
#include <swift/bridging>
#include "swiftUsd/SwiftOverlay/SwiftCxxMacros.h"

namespace __SwiftUsd {
    namespace TfNotice {
        class ListenerBase;
        class ListenerHolder;
    }
}

class pxr::TfNotice::SwiftKey {
public:
    SwiftKey(pxr::TfNotice::Key registrationKey);
    
    bool IsValid() const;
    
    operator bool() const;
    
    bool operator<(const SwiftKey& other) const;
    
    SwiftKey();
    
private:
    SwiftKey(pxr::TfWeakPtr<__SwiftUsd::TfNotice::ListenerBase> listener, pxr::TfNotice::Key registrationKey);
    
private:
    friend class __SwiftUsd::TfNotice::ListenerHolder;
    
private:
    pxr::TfWeakPtr<__SwiftUsd::TfNotice::ListenerBase> _listener;
    pxr::TfNotice::Key _key;
};

#ifdef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS
// Stub out these definitions in the header so they're picked up for documentation
bool pxr::TfNotice::Revoke(pxr::TfNotice::SwiftKey key) { exit(0); }
void pxr::TfNotice::Revoke(pxr::TfNotice::SwiftKeys* keys) { exit(0); }
bool pxr::TfNotice::RevokeAndWait(pxr::TfNotice::SwiftKey key) { exit(0); }
void pxr::TfNotice::RevokeAndWait(pxr::TfNotice::SwiftKeys* keys) { exit(0); }
#endif // #ifdef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS


#endif /* SWIFTUSD_TFNOTICE_SWIFTKEY_H */
