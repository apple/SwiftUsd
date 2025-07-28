//
//  Deprecated.h
//  swiftUsd
//
//  Created by Maddy Adams on 11/20/24.
//

#ifndef SWIFTUSD_CXXONLY_DEPRECATED_H
#define SWIFTUSD_CXXONLY_DEPRECATED_H

#include "swiftUsd/CxxOnly/RefcountingAcrossLanguages.h"
#include <swift/bridging>

// MARK: Deprecated in Swift 6, obseleted in Swift 6.2

namespace Overlay {
    /// Deprecated: Use SwiftUsd::PassToSwiftAsReturnValue<T>() instead
    template <typename T> [[deprecated("Use SwiftUsd::PassToSwiftAsReturnValue<T>() instead"), nodiscard]]
    T* _Nullable Dereference(pxr::TfRefPtr<T>& x)
        SWIFT_RETURNS_RETAINED
        SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Dereference<T>(_:)") {
        return SwiftUsd::PassToSwiftAsReturnValue<T>(x);
    }

    /// Deprecated: Use SwiftUsd::PassToSwiftAsReturnValue<T>() instead
    template <typename T> [[deprecated("Use SwiftUsd::PassToSwiftAsReturnValue<T>() instead"), nodiscard]]
    T* _Nullable Dereference(const pxr::TfWeakPtr<T>& x)
        SWIFT_RETURNS_RETAINED
        SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Dereference<T>(_:)") {
        return SwiftUsd::PassToSwiftAsReturnValue<T>(x);
    }
}

// MARK: Deprecated in Swift 6.1, obseleted in Swift 6.3

#endif /* SWIFTUSD_CXXONLY_DEPRECATED_H */
