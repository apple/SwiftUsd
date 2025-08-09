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

#ifndef SWIFTUSD_TFNOTICE_LISTENERHOLDER_H
#define SWIFTUSD_TFNOTICE_LISTENERHOLDER_H

#include <map>
#include <mutex>
#include "swiftUsd/TfNotice/SwiftKey.h"
#include "swiftUsd/TfNotice/Listener.h"

namespace __SwiftUsd {
    namespace TfNotice {
        /// The pointer is only valid for the duration of the `pxr::TfNotice::Register` callback
        // Workaround for rdar://142423230 (Swiftc crash passing closure to templated function with pointer argument)
        struct PointerHolder {
            const pxr::TfNotice* _Nonnull notice;
        };
        
        // Swift dynamic casting function, for TfNotice subclasses.
        // Takes return value as second argument, because of https://github.com/swiftlang/swift/issues/83081 (Templated C++ function incorrectly imported as returning Void in Swift)
        template <typename T, typename U>
        void dyn_cast(const U* u, T* t) {
            *t = dynamic_cast<T>(u);
        }
    }
}

namespace __SwiftUsd {
    namespace TfNotice {
        /// Singleton managing the lifetime of swift Listeners
        // ListenerHolder must be threadsafe: All public methods must start by grabbing the _mutex,
        // and no private methods should grab the mutex
        class ListenerHolder {
        public:
            static ListenerHolder& GetInstance();
            
            /// Global registration
            template <typename Notice>
            pxr::TfNotice::SwiftKey Register(std::function<void(const Notice&)> callback) {
                std::lock_guard<std::mutex> lock(_mutex);
                return _insertListener(Listener<Notice, bool>::NewListener(callback));
            }
            
            /// Sender specific registration, no sender in callback
            template <typename Notice>
            pxr::TfNotice::SwiftKey Register(std::function<void(const Notice&)> callback, const pxr::TfAnyWeakPtr& sender) {
                std::lock_guard<std::mutex> lock(_mutex);
                return _insertListener(Listener<Notice, bool>::NewListener(callback, sender));
            }
            
            /// Sender specific registration, with sender in callback
            template <typename Notice>
            pxr::TfNotice::SwiftKey Register(std::function<void(const Notice&, const pxr::TfAnyWeakPtr&)> callback, const pxr::TfAnyWeakPtr& sender) {
                std::lock_guard<std::mutex> lock(_mutex);
                return _insertListener(Listener<Notice, pxr::TfAnyWeakPtr>::NewListener(callback, sender));
            }
            
            bool Revoke(pxr::TfNotice::SwiftKey key);
            bool RevokeAndWait(pxr::TfNotice::SwiftKey key);
            
        private:
            ListenerHolder();
            ListenerHolder(const ListenerHolder&) = delete;
            ListenerHolder& operator=(const ListenerHolder&) = delete;
            
            /// Holds on to the given listener until the returned `Key` is `Revoke`d
            pxr::TfNotice::SwiftKey _insertListener(std::pair<pxr::TfRefPtr<__SwiftUsd::TfNotice::ListenerBase>, pxr::TfNotice::Key>);
            
        private:
            std::map<pxr::TfNotice::SwiftKey, pxr::TfRefPtr<__SwiftUsd::TfNotice::ListenerBase>> _keysAndListeners;
            std::mutex _mutex;
        };
    }
}

// Internal Swift registration entry point
namespace __SwiftUsd {
    namespace TfNotice {
        // These use dependent types, so they can't be called from Swift 6.0
        // Take in ObjC blocks, and just pass them along to the ListenerHolder as std::functions

        /// Global registration
        template <typename Notice>
        pxr::TfNotice::SwiftKey _Register(void (^_Nonnull callback)(__SwiftUsd::TfNotice::PointerHolder)) {
            std::function<void(const Notice&)> convertedCallback = [callback](const Notice& notice) {
                callback({&notice});
            };
            return __SwiftUsd::TfNotice::ListenerHolder::GetInstance().Register(convertedCallback);
        }
        /// Sender specific registration, no sender
        template <typename Notice>
        pxr::TfNotice::SwiftKey _Register(void (^_Nonnull callback)(__SwiftUsd::TfNotice::PointerHolder), const pxr::TfAnyWeakPtr& sender) {
            std::function<void(const Notice&)> convertedCallback = [callback](const Notice& notice) {
                callback({&notice});
            };
            return __SwiftUsd::TfNotice::ListenerHolder::GetInstance().Register(convertedCallback, sender);
        }
        /// Sender specific registration, with sender
        template <typename Notice>
        pxr::TfNotice::SwiftKey _Register(void (^_Nonnull callback)(pxr::TfAnyWeakPtr, __SwiftUsd::TfNotice::PointerHolder), const pxr::TfAnyWeakPtr& sender) {
            std::function<void(const Notice&, const pxr::TfAnyWeakPtr&)> convertedCallback = [callback](const Notice& notice, const pxr::TfAnyWeakPtr& sender) {
                callback(sender, {&notice});
            };
            return __SwiftUsd::TfNotice::ListenerHolder::GetInstance().Register(convertedCallback, sender);
        }

        // Wrap each _Register while hiding the dependent types. Take the key by ref,
        // to work around https://github.com/swiftlang/swift/issues/83081 (Templated C++ function incorrectly imported as returning Void in Swift)
        template <typename T, typename Notice>
        void Register(T callback, pxr::TfNotice::SwiftKey& outKey) {
            outKey = _Register<Notice>(callback);
        }
        template <typename T, typename Notice>
        void Register(T callback, pxr::TfAnyWeakPtr sender, pxr::TfNotice::SwiftKey& outKey) {
            outKey = _Register<Notice>(callback, sender);
        }
    }
}



#endif /* SWIFTUSD_TFNOTICE_LISTENERHOLDER_H */
