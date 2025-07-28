//
//  SwiftKey.cpp
//  SwiftUsd
//
//  Created by Maddy Adams on 12/20/24.
//

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
