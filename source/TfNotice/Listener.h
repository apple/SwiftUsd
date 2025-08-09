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

#ifndef SWIFTUSD_TFNOTICE_LISTENER_H
#define SWIFTUSD_TFNOTICE_LISTENER_H

#include "pxr/base/tf/refBase.h"
#include "pxr/base/tf/weakBase.h"
#include "pxr/base/tf/anyWeakPtr.h"
#include "pxr/base/tf/notice.h"

namespace __SwiftUsd {
    namespace TfNotice {
        /// Makes it possible for the ListenerHolder to hold all Listeners in a map without template arguments
        class ListenerBase: public pxr::TfRefBase, public pxr::TfWeakBase {
        protected:
            ~ListenerBase() = default;
        };
        
        /// Represents a notification listener registered from Swift
        // Use Sender=bool to indicate no Sender is passed to the callback,
        // regardless of whether or not registration uses a sender
        template <typename Notice, typename Sender>
        class Listener: public ListenerBase {
        public:
            typedef Listener<Notice, Sender> This;
            typedef pxr::TfRefPtr<This> StrongThis;
            typedef pxr::TfWeakPtr<This> WeakThis;

            /// Global registration
            static std::pair<StrongThis, pxr::TfNotice::Key> NewListener(std::function<void(const Notice&)> callback) {
                auto wrappedCallback = [callback](const Notice& notice, const Sender& sender){ callback(notice); };

                StrongThis strongThis = pxr::TfCreateRefPtr(new This(wrappedCallback));
                WeakThis weakThis = WeakThis(strongThis);
                pxr::TfNotice::Key key = pxr::TfNotice::Register<WeakThis, void(This::*)(const Notice&)>(weakThis, &This::HandleNotification);
                return {strongThis, key};
            }

            /// Sender specific registration, no sender in callback
            static std::pair<StrongThis, pxr::TfNotice::Key> NewListener(std::function<void(const Notice&)> callback, const pxr::TfAnyWeakPtr& sender) {
                auto wrappedCallback = [callback](const Notice& notice, const Sender& sender) { callback(notice); };

                StrongThis strongThis = pxr::TfCreateRefPtr(new This(wrappedCallback));
                WeakThis weakThis = WeakThis(strongThis);
                using MethodPtr = void(This::*)(const pxr::TfNotice& notice, const pxr::TfType&,
                                                pxr::TfWeakBase*, const void*, const std::type_info&);
                pxr::TfNotice::Key key = pxr::TfNotice::Register<WeakThis, MethodPtr>(weakThis, &This::HandleNotification, pxr::TfType::Find<Notice>(), sender);
                return {strongThis, key};
            }

            /// Sender specific registration, with sender in callback
            static std::pair<StrongThis, pxr::TfNotice::Key> NewListener(std::function<void(const Notice&, const pxr::TfAnyWeakPtr&)> callback, const pxr::TfAnyWeakPtr& sender) {
                StrongThis strongThis = pxr::TfCreateRefPtr(new This(callback));
                WeakThis weakThis = WeakThis(strongThis);
                using MethodPtr = void(This::*)(const pxr::TfNotice& notice, const pxr::TfType&,
                                                pxr::TfWeakBase*, const void*, const std::type_info&);
                pxr::TfNotice::Key key = pxr::TfNotice::Register<WeakThis, MethodPtr>(weakThis, &This::HandleNotification, pxr::TfType::Find<Notice>(), sender);
                return {strongThis, key};
            }
            
        private:
            /// Called by C++ when a notification is sent
            // Global listeners only
            void HandleNotification(const Notice& notice) {
                _callback(notice, false);
            }

            /// Called by C++ when a notification is sent
            // Sender specific listeners only. OpenUSD gives us the sender,
            // but the Swift listener might or might not want the sender in their callback
            void HandleNotification(const pxr::TfNotice& _notice, const pxr::TfType& noticeType,
                                    pxr::TfWeakBase* sender, const void* senderUniqueId,
                                    const std::type_info& senderType) {
                const Notice& notice = dynamic_cast<const Notice&>(_notice);
                if constexpr (std::is_same_v<Sender, bool>) {
                    _callback(notice, false);
                } else {
                    _callback(notice, pxr::TfAnyWeakPtr(pxr::TfCreateWeakPtr(sender)));
                }
            }
            
            Listener(std::function<void(const Notice&, const Sender&)> callback) : _callback(callback) {
                static_assert(std::is_same_v<Sender, bool> ||
                              std::is_same_v<Sender, pxr::TfAnyWeakPtr>,
                              "Listener only supports TfAnyWeakPtr as the sender type");
            }
            
            std::function<void(const Notice&, const Sender&)> _callback;
            
            friend class ListenerHolder;
        };
    }
}

#endif /* SWIFTUSD_TFNOTICE_LISTENER_H */
