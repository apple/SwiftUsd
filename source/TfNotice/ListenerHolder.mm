//
//  ListenerHolder.mm
//  SwiftUsd
//
//  Created by Maddy Adams on 12/20/24.
//

#include "swiftUsd/TfNotice/ListenerHolder.h"

/* static */
__SwiftUsd::TfNotice::ListenerHolder& __SwiftUsd::TfNotice::ListenerHolder::GetInstance() {
    static ListenerHolder instance;
    return instance;
}


bool __SwiftUsd::TfNotice::ListenerHolder::Revoke(pxr::TfNotice::SwiftKey key) {
    {
        std::lock_guard<std::mutex> lock(_mutex);

        // Drop the last strong reference to a listener, if we have one.
        // Because the listener inherits from TfRefBase and TfWeakBase,
        // dropping it like this is safe.
        auto it = _keysAndListeners.find(key);
        if (it != _keysAndListeners.end()) {
            _keysAndListeners.erase(it);
        }
    }
    
    // Always tell C++ to revoke the underlying C++ key,
    // because the Swift key could be from Swift or C++
    return pxr::TfNotice::Revoke(key._key);
}

bool __SwiftUsd::TfNotice::ListenerHolder::RevokeAndWait(pxr::TfNotice::SwiftKey key) {
    {
        std::lock_guard<std::mutex> lock(_mutex);

        auto it = _keysAndListeners.find(key);
        if (it != _keysAndListeners.end()) {
            _keysAndListeners.erase(it);
        }
    }
    return pxr::TfNotice::RevokeAndWait(key._key);
}

__SwiftUsd::TfNotice::ListenerHolder::ListenerHolder() {}

pxr::TfNotice::SwiftKey __SwiftUsd::TfNotice::ListenerHolder::_insertListener(std::pair<pxr::TfRefPtr<__SwiftUsd::TfNotice::ListenerBase>, pxr::TfNotice::Key> pair) {
    pxr::TfNotice::SwiftKey result(pair.first, pair.second);
    _keysAndListeners.insert({result, pair.first});
    return result;
}
