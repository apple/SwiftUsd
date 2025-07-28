//
//  UsdZipFileIteratorWrapper.h
//  SwiftUsd
//
//  Created by Maddy Adams on 4/23/25.
//

// Original documentation for pxr::UsdZipFile::Iterator from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.05.01/pxr/usd/usd/zipFile.h

#ifndef SWIFTUSD_WRAPPERS_USDZIPFILEITERATORWRAPPER_H
#define SWIFTUSD_WRAPPERS_USDZIPFILEITERATORWRAPPER_H

#include <stdio.h>
#include <memory>
#include <swift/bridging>
#include "pxr/usd/usd/zipFile.h"


namespace Overlay {
    struct UsdZipFileIteratorWrapper;
}

namespace __Overlay {
    Overlay::UsdZipFileIteratorWrapper UsdZipFileIteratorWrapper_friend(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter);
    Overlay::UsdZipFileIteratorWrapper UsdZipFileIteratorWrapper(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter);
    
    pxr::UsdZipFile UsdZipFileIteratorWrapper__zipFile_friend(Overlay::UsdZipFileIteratorWrapper wrapper);
    pxr::UsdZipFile UsdZipFileIteratorWrapper__zipFile(Overlay::UsdZipFileIteratorWrapper wrapper);
}

namespace Overlay {
    /// \class Iterator
    /// Iterator for traversing and inspecting the contents of the zip archive.
    //
    // UsdZipFile::Iterator::GetFile() returns a pointer into the raw data
    // in the zip archive, so we want to be careful with memory safety.
    // Luckily, UsdZipFile's only field is a shared_ptr to UsdZipFile::_Impl.
    // So, it's safe to copy UsdZipFiles around a bunch, since that just increments
    // the shared_ptr. This way, as long as a UsdZipFileIteratorWrapper is around,
    // the UsdZipFile's memory will still be valid.    
    struct UsdZipFileIteratorWrapper {
        // We need to implement a custom copy constructor because Swift clients
        // expect copies of iterators to be independent ("value semantics"),
        // but we hold a shared_ptr to the UsdZipFile::Iterator, so the
        // default copy constructor does a shallow copy of shared_ptr ("reference semantics")
        UsdZipFileIteratorWrapper(const UsdZipFileIteratorWrapper& other);
        UsdZipFileIteratorWrapper& operator=(const UsdZipFileIteratorWrapper& other);
        UsdZipFileIteratorWrapper(UsdZipFileIteratorWrapper&& other);
        UsdZipFileIteratorWrapper& operator=(UsdZipFileIteratorWrapper&& other);
        
        using difference_type = pxr::UsdZipFile::Iterator::difference_type;
        using value_type = pxr::UsdZipFile::Iterator::value_type;
        using pointer = pxr::UsdZipFile::Iterator::pointer;
        using reference = pxr::UsdZipFile::Iterator::reference;
        using iterator_category = pxr::UsdZipFile::Iterator::iterator_category;
        
        UsdZipFileIteratorWrapper& operator++();
        UsdZipFileIteratorWrapper operator++(int);
        
        bool operator==(const UsdZipFileIteratorWrapper& rhs) const;
        bool operator!=(const UsdZipFileIteratorWrapper& rhs) const;
        
        /// Returns filename of the current file in the zip archive.
        reference operator*() const;
        
        /// Returns filename of the current file in the zip archive.
        pxr::UsdZipFile::Iterator::pointer operator->() const;
        
        /// Returns pointer to the beginning of the current file in the
        /// zip archive. The contents of the current file span the range
        /// [GetFile(), GetFile() + GetFileInfo().size).
        ///
        /// Note that this points to the raw data stored in the zip archive;
        /// no decompression or other transformation is applied.
        const char* _Nullable GetFile() const SWIFT_RETURNS_INDEPENDENT_VALUE;
        
        /// Returns FileInfo object containing information about the
        /// current file.
        pxr::UsdZipFile::FileInfo GetFileInfo() const;
        
    private:
        UsdZipFileIteratorWrapper(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter);
        
        friend UsdZipFileIteratorWrapper __Overlay::UsdZipFileIteratorWrapper_friend(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter);
        friend pxr::UsdZipFile __Overlay::UsdZipFileIteratorWrapper__zipFile_friend(Overlay::UsdZipFileIteratorWrapper wrapper);
        
        std::shared_ptr<pxr::UsdZipFile::Iterator> _iter;
        pxr::UsdZipFile _zipFile;
    };
}

#endif /* SWIFTUSD_WRAPPERS_USDZIPFILEITERATORWRAPPER_H */
