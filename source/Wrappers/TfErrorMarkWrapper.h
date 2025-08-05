//
//  TfErrorMarkWrapper.h
//  SwiftUsd
//
//  Created by Maddy Adams on 3/13/25.
//

// Original documentation for pxr::TfErrorMark from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/base/tf/errorMark.h

#ifndef SWIFTUSD_WRAPPERS_TFERRORMARKWRAPPER_H
#define SWIFTUSD_WRAPPERS_TFERRORMARKWRAPPER_H

#include <memory>
#include "pxr/base/tf/diagnosticMgr.h"
#include "pxr/base/tf/errorMark.h"

namespace Overlay {
    struct TfErrorMarkWrapper;
}

namespace __Overlay {
    // https://github.com/swiftlang/swift/issues/83085 (Calling friend function of type nested in C++ namespace crashes Swift compiler)
    // Workaround: Have Swift call a non-friend function that calls the friend function.
    // (Note that the crash occurs before `SWIFT_NAME` has a chance to swap out one function
    // for another.)
    Overlay::TfErrorMarkWrapper makeTfErrorMarkWrapper_friend();
    Overlay::TfErrorMarkWrapper makeTfErrorMarkWrapper();
}

namespace Overlay {
    /// \class TfErrorMark
    /// \ingroup group_tf_TfError
    ///
    /// Class used to record the end of the error-list.
    ///
    /// See \ref page_tf_TfError for a detailed description.
    ///
    /// A \c TfErrorMark is used as follows:
    /// \code
    ///    TfErrorMark m;
    ///
    ///    m.SetMark();             // (A)
    ///    ... ;
    ///    ... ;
    ///                              // (B)
    ///    if (!m.IsClean()) {
    ///      // errors occurred between (A) and B()
    ///    }
    /// \endcode
    ///
    /// Another common pattern is
    /// \code
    ///     TfErrorMark m;
    ///     if (TF_HAS_ERRORS(m, expr)) {
    ///         // handle errors;
    ///     }
    /// \endcode
    ///
    /// 
    /// SwiftUsd-specific information:
    /// Don't construct this value directly. Instead, call ``Overlay.withTfErrorMark(_:)``,
    /// which will give you scoped access to the TfErrorMark and ensure that it stays alive
    /// for the duration of the closure (similar to RAII behavior in C++).
    ///
    /// This type is explicitly marked as non-Sendable due to its use of
    /// thread-local storage.
    struct TfErrorMarkWrapper {
    public:
        // Expose the typedef for Swift, because TfErrorMark isn't imported
        typedef pxr::TfErrorMark::Iterator _TfErrorMarkIterator;
        
        /// Record future errors.
        ///
        /// \c SetMark() arranges to record future errors in \c *this.
        //
        //
        // Implementation note: To ensure that TfErrorMarkWrapper can't escape from
        // `Overlay.withTfErrorMark(_:)`, this type is `~Copyable` and `withTfErrorMark`'s
        // closure takes it as `borrowing`. As a consequence, any non-const methods
        // can't be called on it. So, make `SetMark()` const here, even though it's non-const
        // for `pxr::TfErrorMark`
        inline void SetMark() const {
            _impl->SetMark();
        }

        /// Return true if no new errors were posted in this thread since the last
        /// call to \c SetMark(), false otherwise.
        ///
        /// When no threads are issuing errors the cost of this function is an
        /// atomic integer read and comparison. Otherwise thread-specific data is
        /// accessed to make the determination. Thus, this function is fast when
        /// diagnostics are not being issued.
        inline bool IsClean() const {
            return _impl->IsClean();
        }

        /// Remove all errors in this mark from the error system. Return true if
        /// any errors were cleared, false if there were no errors in this mark.
        ///
        /// Clear all errors contained in this mark from the error system.
        /// Subsequently, these errors will be considered handled.
        inline bool Clear() const {
            return _impl->Clear();
        }

        /// Remove all errors in this mark from the error system and return them in
        /// a TfErrorTransport.
        ///
        /// This can be used to transfer errors from one thread to another.  See
        /// TfErrorTransport for more information.  As with Clear(), all the
        /// removed errors are considered handled for this thread.  See also
        /// TransportTo().
        ///
        /// SwiftUsd-specific information:
        /// Important: use of `Transport()` or `TransportTo()` to move errors
        /// between Swift Concurrency tasks intentionally requires using unsafe
        /// opt-outs on the `pxr.TfErrorTransport` because it can expose
        /// unsynchronized access to shared mutable state. Use with caution.
        inline pxr::TfErrorTransport Transport() const {
            return _impl->Transport();
        }

        /// Remove all errors in this mark from the error system and return them in
        /// a TfErrorTransport.
        ///
        /// This is a variant of Transport().  Instead of returning a new
        /// TfErrorTransport object it fills an existing one.
        ///
        /// SwiftUsd-specific information:
        /// Important: use of `Transport()` or `TransportTo()` to move errors
        /// between Swift Concurrency tasks intentionally requires using unsafe
        /// opt-outs on the `pxr.TfErrorTransport` because it can expose
        /// unsynchronized access to shared mutable state. Use with caution.
        inline void TransportTo(pxr::TfErrorTransport& dest) const {
            Transport().swap(dest);
        }

        /// Return an iterator to the first error added to the error list after
        /// \c SetMark().
        ///
        /// If there are no errors on the error list that were not already present
        /// when \c SetMark() was called, the iterator returned is equal to the
        /// iterator returned by \c TfDiagnosticMgr::GetErrorEnd(). Otherwise, the
        /// iterator points to the earliest error added to the list since
        /// \c SetMark() was called.
        ///
        /// This function takes O(n) time where n is the number of errors from the
        /// end of the list to the mark i.e. \c GetMark() walks the list from the
        /// end until it finds the mark and then returns an iterator to that spot.
        ///
        /// If \c nErrors is non-NULL, then \c *nErrors is set to the number of
        /// errors between the returned iterator and the end of the list.
        pxr::TfErrorMark::Iterator GetBegin(size_t* _Nullable nErrors = 0) const {
            return _impl->GetBegin(nErrors);
        }

        /// Return an iterator past the last error in the error system.
        ///
        /// This iterator is always equivalent to the iterator returned by \c
        /// TfDiagnosticMgr::GetErrorEnd().
        pxr::TfErrorMark::Iterator GetEnd() const {
            return _impl->GetEnd();
        }

        /// Equivalent to GetBegin()
        pxr::TfErrorMark::Iterator begin() const {
            return _impl->begin();
        }

        /// Equivalent to GetEnd()
        pxr::TfErrorMark::Iterator end() const {
            return _impl->end();
        }
        
    private:
        TfErrorMarkWrapper();
        friend Overlay::TfErrorMarkWrapper __Overlay::makeTfErrorMarkWrapper_friend();
        std::unique_ptr<pxr::TfErrorMark> _impl;
    };
}

namespace __Overlay {
    inline  Overlay::TfErrorMarkWrapper makeTfErrorMarkWrapper() {
        return makeTfErrorMarkWrapper_friend();
    }
}


#endif /* SWIFTUSD_WRAPPERS_TFERRORMARKWRAPPER_H */
