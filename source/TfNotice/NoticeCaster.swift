//
//  NoticeCaster.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 12/20/24.
//

extension pxr.TfNotice {
    /// Utility struct that lets uses cast `pxr::TfNotice` subclasses in a `pxr::TfNotice::Register` callback
    public struct NoticeCaster: ~Copyable {
        /// The pointer is only valid for the duration of the `pxr::TfNotice::Register` callback
        internal init(_ p: UnsafePointer<pxr.TfNotice>) {
            self.p = p
        }
        
        private var p: UnsafePointer<pxr.TfNotice>
        
        /// Casting operator.
        ///
        /// Returns the casted `pxr::TfNotice` during a `pxr::TfNotice::Register` callback, or null if casting failed
        public func cast<T: SwiftUsd.TfNoticeProtocol>(to: T.Type = T.self) -> T? {
            T._dynamic_cast(p)?.pointee
        }
        
        /// Casting operator.
        ///
        /// Returns the casted `pxr::TfNotice` during a `pxr::TfNotice::Register` callback, or null if casting failed.
        /// Equivalent to ``cast(to:)``
        public func callAsFunction<T: SwiftUsd.TfNoticeProtocol>(_ to: T.Type = T.self) -> T? {
            cast(to: to)
        }
    }
}
