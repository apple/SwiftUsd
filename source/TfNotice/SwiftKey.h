//
//  SwiftKey.h
//  SwiftUsd
//
//  Created by Maddy Adams on 12/20/24.
//

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
