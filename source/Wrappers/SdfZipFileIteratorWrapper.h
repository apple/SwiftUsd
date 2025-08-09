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

// Original documentation for pxr::SdfZipFile::Iterator from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/usd/sdf/zipFile.h

#ifndef SWIFTUSD_WRAPPERS_SDFZIPFILEITERATORWRAPPER_H
#define SWIFTUSD_WRAPPERS_SDFZIPFILEITERATORWRAPPER_H

#include <stdio.h>
#include <memory>
#include <swift/bridging>
#include "pxr/usd/usd/zipFile.h"


namespace Overlay {
    struct SdfZipFileIteratorWrapper;
}

namespace __Overlay {
    Overlay::SdfZipFileIteratorWrapper SdfZipFileIteratorWrapper_friend(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter);
    Overlay::SdfZipFileIteratorWrapper SdfZipFileIteratorWrapper(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter);
    
    pxr::SdfZipFile SdfZipFileIteratorWrapper__zipFile_friend(Overlay::SdfZipFileIteratorWrapper wrapper);
    pxr::SdfZipFile SdfZipFileIteratorWrapper__zipFile(Overlay::SdfZipFileIteratorWrapper wrapper);
}

namespace Overlay {
    /// \class Iterator
    /// Iterator for traversing and inspecting the contents of the zip archive.
    //
    // SdfZipFile::Iterator::GetFile() returns a pointer into the raw data
    // in the zip archive, so we want to be careful with memory safety.
    // Luckily, SdfZipFile's only field is a shared_ptr to SdfZipFile::_Impl.
    // So, it's safe to copy SdfZipFiles around a bunch, since that just increments
    // the shared_ptr. This way, as long as a SdfZipFileIteratorWrapper is around,
    // the SdfZipFile's memory will still be valid.    
    struct SdfZipFileIteratorWrapper {
        // We need to implement a custom copy constructor because Swift clients
        // expect copies of iterators to be independent ("value semantics"),
        // but we hold a shared_ptr to the SdfZipFile::Iterator, so the
        // default copy constructor does a shallow copy of shared_ptr ("reference semantics")
        SdfZipFileIteratorWrapper(const SdfZipFileIteratorWrapper& other);
        SdfZipFileIteratorWrapper& operator=(const SdfZipFileIteratorWrapper& other);
        SdfZipFileIteratorWrapper(SdfZipFileIteratorWrapper&& other);
        SdfZipFileIteratorWrapper& operator=(SdfZipFileIteratorWrapper&& other);
        
        using difference_type = pxr::SdfZipFile::Iterator::difference_type;
        using value_type = pxr::SdfZipFile::Iterator::value_type;
        using pointer = pxr::SdfZipFile::Iterator::pointer;
        using reference = pxr::SdfZipFile::Iterator::reference;
        using iterator_category = pxr::SdfZipFile::Iterator::iterator_category;
        
        SdfZipFileIteratorWrapper& operator++();
        SdfZipFileIteratorWrapper operator++(int);
        
        bool operator==(const SdfZipFileIteratorWrapper& rhs) const;
        bool operator!=(const SdfZipFileIteratorWrapper& rhs) const;
        
        /// Returns filename of the current file in the zip archive.
        reference operator*() const;
        
        /// Returns filename of the current file in the zip archive.
        pxr::SdfZipFile::Iterator::pointer operator->() const;
        
        /// Returns pointer to the beginning of the current file in the
        /// zip archive. The contents of the current file span the range
        /// [GetFile(), GetFile() + GetFileInfo().size).
        ///
        /// Note that this points to the raw data stored in the zip archive;
        /// no decompression or other transformation is applied.
        const char* _Nullable GetFile() const SWIFT_RETURNS_INDEPENDENT_VALUE;
        
        /// Returns FileInfo object containing information about the
        /// current file.
        pxr::SdfZipFile::FileInfo GetFileInfo() const;
        
    private:
        SdfZipFileIteratorWrapper(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter);
        
        friend SdfZipFileIteratorWrapper __Overlay::SdfZipFileIteratorWrapper_friend(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter);
        friend pxr::SdfZipFile __Overlay::SdfZipFileIteratorWrapper__zipFile_friend(Overlay::SdfZipFileIteratorWrapper wrapper);
        
        std::shared_ptr<pxr::SdfZipFile::Iterator> _iter;
        pxr::SdfZipFile _zipFile;
    };
}

#endif /* SWIFTUSD_WRAPPERS_SDFZIPFILEITERATORWRAPPER_H */
