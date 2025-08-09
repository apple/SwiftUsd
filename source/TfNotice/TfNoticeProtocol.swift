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

extension SwiftUsd {
    /// Protocol representing `pxr::TfNotice` subclasses.
    ///
    /// If you create custom `pxr::TfNotice` subclasses, you can enable SwiftUsd's ``pxr.TfNotice.Register`` for them
    /// by conforming to this protocol and following the patterns in `SwiftUsd/source/generated/TfNoticeProtocol.swift` by rote.
    public protocol TfNoticeProtocol {
        static func _Register(_ callback: @escaping (borrowing pxr.TfNotice.NoticeCaster) -> ()) -> pxr.TfNotice.SwiftKey
        static func _Register(_ sender: pxr.TfAnyWeakPtr, _ callback: @escaping (borrowing pxr.TfNotice.NoticeCaster) -> ()) -> pxr.TfNotice.SwiftKey
        static func _Register(_ sender: pxr.TfAnyWeakPtr, _ callback: @escaping (pxr.TfAnyWeakPtr, borrowing pxr.TfNotice.NoticeCaster) -> ()) -> pxr.TfNotice.SwiftKey
        static func _dynamic_cast(_ p: UnsafePointer<pxr.TfNotice>) -> UnsafePointer<Self>?
    }
}

extension pxr.TfNotice {
    // Take a metatype argument to allow for type inference in the trailing closure
    
    /// Register a listener as being interested in a TfNotice.
    ///
    /// Registration of interest in a notice class `N` automatically
    /// registers  interest in all classes derived from `N`. When a notice of
    /// appropriate type is received, the `callback` is called with the notice.
    ///
    /// Supports several forms of registration
    ///
    /// - Listening for a notice globally. Prefer listening to a notice from a
    /// particular sender whenever possible (see below)
    ///
    /// - Listening for a notice from a particular sender, without receiving the sender
    ///
    /// - Listening for a notice from a particular sender, while receiving the sender
    ///
    /// Additionally, all of the registration forms can also support dynamically downcasting notice types in the callback
    ///
    /// The sender being registered for (if any) must be derived
    /// from `pxr::TfWeakBase`
    ///
    /// To reverse the registration, call ``OpenUSD/Revoke-31sr0`` on the `Key`
    /// object returned by this call.

    // Global, no casting
    @discardableResult
    public static func Register<Notice: SwiftUsd.TfNoticeProtocol>(_ type: Notice.Type = Notice.self,
                                                                   _ callback: @escaping @Sendable (Notice) -> ()) -> pxr.TfNotice.SwiftKey {
        return Notice._Register { caster in
            callback(caster(Notice.self)!)
        }
    }
    
    // Specific, no sender, no casting
    @discardableResult
    public static func Register<Notice: SwiftUsd.TfNoticeProtocol, Sender: Overlay._TfWeakBaseProtocol>(_ sender: Sender,
                                                                                                        _ type: Notice.Type = Notice.self,
                                                                                                        _ callback: @escaping @Sendable (Notice) -> ()) -> pxr.TfNotice.SwiftKey where Sender._SelfType == Sender {
        let anyWeakSender = Overlay.TfWeakPtr(sender)._asAnyWeakPtr()
        return Notice._Register(anyWeakSender) { caster in
            callback(caster(Notice.self)!)
        }
    }
    
    // Specific, yes sender, no casting
    @discardableResult
    public static func Register<Notice: SwiftUsd.TfNoticeProtocol, Sender: Overlay._TfWeakBaseProtocol>(_ sender: Sender,
                                                                                                        _ type: Notice.Type = Notice.self,
                                                                                                        _ callback: @escaping @Sendable (Notice, Sender) -> ()) -> pxr.TfNotice.SwiftKey where Sender._SelfType == Sender {
        let anyWeakSender = Overlay.TfWeakPtr(sender)._asAnyWeakPtr()
        return Notice._Register(anyWeakSender) { senderPtr, caster in
            let notice = caster(Notice.self)!
            let typedWeakSender = Overlay._TfWeakPtr(senderPtr, pointingTo: Sender.self)
            let strongSender = Overlay.Dereference(typedWeakSender)
            callback(notice, strongSender)
        }
    }
    
    // Global, yes casting
    @discardableResult
    public static func Register<Notice: SwiftUsd.TfNoticeProtocol>(_ type: Notice.Type = Notice.self,
                                                                   _ callback: @escaping @Sendable (Notice, borrowing pxr.TfNotice.NoticeCaster) -> ()) -> pxr.TfNotice.SwiftKey {
        return Notice._Register { caster in
            let notice = caster(Notice.self)!
            callback(notice, caster)
        }
    }
    
    // Specific, no sender, yes casting
    @discardableResult
    public static func Register<Notice: SwiftUsd.TfNoticeProtocol, Sender: Overlay._TfWeakBaseProtocol>(_ sender: Sender,
                                                                                                        _ type: Notice.Type = Notice.self,
                                                                                                        _ callback: @escaping @Sendable (Notice, borrowing pxr.TfNotice.NoticeCaster) -> ()) -> pxr.TfNotice.SwiftKey where Sender._SelfType == Sender {
        let anyWeakSender = Overlay.TfWeakPtr(sender)._asAnyWeakPtr()
        return Notice._Register(anyWeakSender) { caster in
            let notice = caster(Notice.self)!
            callback(notice, caster)
        }
    }
    
    // Specific, yes sender, yes casting
    @discardableResult
    public static func Register<Notice: SwiftUsd.TfNoticeProtocol, Sender: Overlay._TfWeakBaseProtocol>(_ sender: Sender,
                                                                                                        _ type: Notice.Type = Notice.self,
                                                                                                        _ callback: @escaping @Sendable (Notice, Sender, borrowing pxr.TfNotice.NoticeCaster) -> ()) -> pxr.TfNotice.SwiftKey where Sender._SelfType == Sender {
        let anyWeakSender = Overlay.TfWeakPtr(sender)._asAnyWeakPtr()
        return Notice._Register(anyWeakSender) { senderPtr, caster in
            let notice = caster(Notice.self)!
            let typedWeakSender = Overlay._TfWeakPtr(senderPtr, pointingTo: Sender.self)
            let strongSender = Overlay.Dereference(typedWeakSender)
            callback(notice, strongSender, caster)
        }
    }
}
