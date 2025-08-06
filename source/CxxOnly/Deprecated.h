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
