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

// Original documentation for pxr::HioImage from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/imaging/hio/image.h

#ifndef SWIFTUSD_WRAPPERS_HIOIMAGEWRAPPER_H
#define SWIFTUSD_WRAPPERS_HIOIMAGEWRAPPER_H

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include <swift/bridging>
#include <memory>
#include "pxr/imaging/hio/image.h"

namespace Overlay {
    /// \class HioImage
    ///
    /// A base class for reading and writing texture image data.
    ///
    /// The class allows basic access to texture image file data.
    ///
    /// Texture paths are UTF-8 strings, resolvable by AR. Texture system dispatch
    /// is driven by extension, with [A-Z] (and no other characters) case folded.
    class HioImageWrapper {
    public:
        /// Specifies whether to treat the image origin as the upper-left corner
        /// or the lower left
        enum ImageOriginLocation {
            OriginUpperLeft,
            OriginLowerLeft
        };

        /// Specifies the source color space in which the texture is encoded, with
        /// "Auto" indicating the texture reader should determine color space based
        /// on hints from the image (e.g. file type, number of channels, image
        /// metadata)
        enum SourceColorSpace {
            Raw,
            SRGB,
            Auto
        };

        /// \class StorageSpec
        ///
        /// Describes the memory layout and storage of a texture image
        class StorageSpec {
        public:
            StorageSpec()
                : width(0), height(0), depth(0),
                format(pxr::HioFormatInvalid),
                flipped(false),
            data(0) {}
            
            int width, height, depth;
            pxr::HioFormat format;
            bool flipped;
            void* data;
        };

        /// Returns whether \a filename opened as a texture image.
        static bool IsSupportedImageFile(const std::string& filename);

        /// \name Reading
        /// {@

        /// Opens \a filename for reading from the given \a subimage at mip level
        /// \a mip, using \a sourceColorSpace to help determine the color space
        /// with which to interpret the texture
        static HioImageWrapper OpenForReading(const std::string& filename,
                                              int subimage = 0,
                                              int mip = 0,
                                              SourceColorSpace sourceColorSpace = SourceColorSpace::Auto,
                                              bool suppressErrors = false);

        /// Reads the image file into \a storage.
        bool Read(const StorageSpec& storage);

        /// Reads the cropped sub-image into \a storage.
        bool ReadCropped(int const cropTop,
                         int const cropBottom,
                         int const cropLeft,
                         int const cropRight,
                         const StorageSpec& storage);

        /// @}

        /// \name Writing
        /// {@

        /// Opens \a filename for writing from the given \a storage.
        static HioImageWrapper OpenForWriting(const std::string& filename);

        /// Writes the image with \a metadata.
        bool Write(const StorageSpec& storage,
                   const pxr::VtDictionary& metadata = pxr::VtDictionary());

        /// @}

        /// Returns the image filename.
        const std::string& GetFilename() const;

        /// Returns the image width.
        int GetWidth() const;

        /// Returns the image height.
        int GetHeight() const;

        /// Returns the destination HioFormat.
        pxr::HioFormat GetFormat() const;

        /// Returns the number of bytes per pixel.
        int GetBytesPerPixel() const;

        /// Returns the number of mips available.
        int GetNumMipLevels() const;

        /// Returns whether the image is in the sRGB color space.
        bool IsColorSpaceSRGB() const;

        /// \name Metadata
        /// {@
        template <typename T>
        bool GetMetadata(const pxr::TfToken& key, T* value) const;
        
        bool GetMetadata(const pxr::TfToken& key, pxr::VtValue* value) const;
        
        bool GetSamplerMetadata(pxr::HioAddressDimension dim,
                                pxr::HioAddressMode* param) const;

        /// @}

        static const ImageOriginLocation _OriginUpperLeft SWIFT_NAME(OriginUpperLeft);
        static const ImageOriginLocation _OriginLowerLeft SWIFT_NAME(OriginLowerLeft);
        static const SourceColorSpace _Raw SWIFT_NAME(Raw);
        static const SourceColorSpace _SRGB SWIFT_NAME(SRGB);
        static const SourceColorSpace _Auto SWIFT_NAME(Auto);

        // MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor
        HioImageWrapper(std::shared_ptr<pxr::HioImage> impl);

        /// Returns the underlying HioImage instance
        pxr::HioImage* _Nullable get() const;

        /// Returns the underlying HioImage instance
        std::shared_ptr<pxr::HioImage> get_shared() const;

        /// Returns `true` iff the underlying instance is valid
        explicit operator bool() const;

    private:
        std::shared_ptr<pxr::HioImage> _impl;
    };
}

template <typename T>
bool Overlay::HioImageWrapper::GetMetadata(const pxr::TfToken& key, T* value) const {
    return _impl->GetMetadata(key, value);
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#endif /* SWIFTUSD_WRAPPERS_HIOIMAGEWRAPPER_H */
