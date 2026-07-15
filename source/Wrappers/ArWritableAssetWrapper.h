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

// Original documentation for pxr::ArWritableAsset from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.05/pxr/usd/ar/writableAsset.h

#ifndef SWIFTUSD_WRAPPERS_ARWRITABLEASSETWRAPPER_H
#define SWIFTUSD_WRAPPERS_ARWRITABLEASSETWRAPPER_H

#include <cstdio>
#include <memory>
#include "pxr/usd/ar/writableAsset.h"

namespace Overlay {
    class ArWritableAssetWrapper {
    public:
        /// Close this asset, performing any necessary finalization or commits
        /// of data that was previously written. Returns true on success, false
        /// otherwise.
        ///
        /// If successful, reads to the written asset in the same process should
        /// reflect the fully written state by the time this function returns.
        /// Also, further calls to any functions on this interface are invalid.
        bool Close();
        
        /// Writes \p count bytes from \p buffer at \p offset from the beginning
        /// of the asset. Returns number of bytes written, or 0 on error.
        size_t Write(const void* buffer, size_t count, size_t offset);
        
        // MARK: SwiftUsd implementation access
        
        /// SwiftUsd wrapping constructor
        ArWritableAssetWrapper(std::shared_ptr<pxr::ArWritableAsset> _ptr);
        
        /// Returns the underlying ArWritableAsset wrapped by this instance
        pxr::ArWritableAsset*_Nullable get() const;
        
        /// Returns the underlying ArWritableAsset wrapped by this instance
        std::shared_ptr<pxr::ArWritableAsset> get_shared() const;
        
        /// Returns `true` iff the underlying instance is valid
        explicit operator bool() const;
        
    private:
        std::shared_ptr<pxr::ArWritableAsset> _ptr;
    };
}

#endif /* SWIFTUSD_WRAPPERS_ARWRITABLEASSETWRAPPER_H */
