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

// Original documentation for pxr::ArAsset from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.05/pxr/usd/ar/asset.h

#ifndef SWIFTUSD_WRAPPERS_ARASSETWRAPPER_H
#define SWIFTUSD_WRAPPERS_ARASSETWRAPPER_H

#include <cstdio>
#include <memory>
#include "pxr/usd/ar/asset.h"


namespace Overlay {
    class ArAssetWrapper {
    public:
        /// Returns size of the asset.
        size_t GetSize() const;
        
        /// Returns a pointer to a buffer with the contents of the asset,
        /// with size given by GetSize(). Returns an invalid std::shared_ptr
        /// if the contents could not be retrieved.
        ///
        /// The data in the returned buffer must remain valid while there are
        /// outstanding copies of the returned std::shared_ptr. Note that the
        /// deleter stored in the std::shared_ptr may contain additional data
        /// needed to maintain the buffer's validity.
        std::shared_ptr<const char> GetBuffer() const;
        
        /// Read \p count bytes at \p offset from the beginning of the asset
        /// into \p buffer. Returns number of bytes read, or 0 on error.
        ///
        /// Implementers should range-check calls and return zero for out-of-bounds
        /// reads.
        size_t Read(void* buffer, size_t count, size_t offset) const;
        
        /// Returns a read-only FILE* handle for this asset if
        /// available, or (nullptr, 0) otherwise.
        ///
        /// The returned handle must remain valid for the lifetime of this
        /// ArAsset object. The returned offset is the offset from the beginning
        /// of the FILE* where the asset's contents begins.
        ///
        /// This function is marked unsafe because the handle may wind up
        /// being used in multiple threads depending on the underlying
        /// resolver implementation. For instance, a resolver may cache
        /// and return ArAsset objects with the same FILE* to multiple
        /// threads.
        ///
        /// Clients MUST NOT use this handle with functions that cannot be
        /// called concurrently on the same file descriptor, e.g. read,
        /// fread, fseek, etc. See ArchPRead for a function that can be used
        /// to read data from this handle safely
        std::pair<FILE*, size_t> GetFileUnsafe() const;
        
        /// Returns an ArAsset with the contents of this asest detached from
        /// from this asset's serialized data. External changes to the serialized
        /// data must not have any effect on the ArAsset returned by this function.
        ///
        /// The default implementation returns a new instance of an ArInMemoryAsset
        /// that reads the entire contents of this asset into a heap-allocated
        /// buffer.
        Overlay::ArAssetWrapper GetDetachedAsset() const;
        
        // MARK: SwiftUsd implementation access
        
        /// SwiftUsd wrapping constructor
        ArAssetWrapper(std::shared_ptr<pxr::ArAsset> _ptr);
        
        /// Returns the underlying ArAsset wrapped by this instance
        pxr::ArAsset*_Nullable get() const;
        
        /// Returns the underlying ArAsset wrapped by this instance
        std::shared_ptr<pxr::ArAsset> get_shared() const;
        
        /// Returns `true` iff the underlying instance is valid
        explicit operator bool() const;
        
    private:
        std::shared_ptr<pxr::ArAsset> _ptr;
    };
}

#endif /* SWIFTUSD_WRAPPERS_ARASSETWRAPPER_H */
