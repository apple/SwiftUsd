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

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include "swiftUsd/Wrappers/HioImageWrapper.h"

pxr::HioImage::ImageOriginLocation convertImageOriginLocation(Overlay::HioImageWrapper::ImageOriginLocation x) {
    switch (x) {
        case Overlay::HioImageWrapper::OriginUpperLeft: return pxr::HioImage::OriginUpperLeft;
        case Overlay::HioImageWrapper::OriginLowerLeft: return pxr::HioImage::OriginLowerLeft;
    }
}

pxr::HioImage::SourceColorSpace convertSourceColorSpace(Overlay::HioImageWrapper::SourceColorSpace x) {
    switch (x) {
        case Overlay::HioImageWrapper::Raw: return pxr::HioImage::Raw;
        case Overlay::HioImageWrapper::SRGB: return pxr::HioImage::SRGB;
        case Overlay::HioImageWrapper::Auto: return pxr::HioImage::Auto;
    }
}

pxr::HioImage::StorageSpec convertStorageSpec(Overlay::HioImageWrapper::StorageSpec x) {
    pxr::HioImage::StorageSpec result;
    result.width = x.width;
    result.height = x.height;
    result.depth = x.depth;
    result.format = x.format;
    result.flipped = x.flipped;
    result.data = x.data;
    return result;
}


/* static */ 
bool Overlay::HioImageWrapper::IsSupportedImageFile(const std::string& filename) {
    return pxr::HioImage::IsSupportedImageFile(filename);
}

/* static */
Overlay::HioImageWrapper Overlay::HioImageWrapper::OpenForReading(const std::string& filename,
                                                                  int subimage,
                                                                  int mip,
                                                                  SourceColorSpace sourceColorSpace,
                                                                  bool suppressErrors) {
    std::shared_ptr<pxr::HioImage> _impl = pxr::HioImage::OpenForReading(filename,
                                                                         subimage,
                                                                         mip,
                                                                         convertSourceColorSpace(sourceColorSpace),
                                                                         suppressErrors);
    return Overlay::HioImageWrapper(_impl);
}

bool Overlay::HioImageWrapper::Read(const StorageSpec& storage) {
    return _impl->Read(convertStorageSpec(storage));
}

bool Overlay::HioImageWrapper::ReadCropped(int const cropTop,
                                           int const cropBottom,
                                           int const cropLeft,
                                           int const cropRight,
                                           const StorageSpec& storage) {
    return _impl->ReadCropped(cropTop,
                              cropBottom,
                              cropLeft,
                              cropRight,
                              convertStorageSpec(storage));
}

/* static */
Overlay::HioImageWrapper Overlay::HioImageWrapper::OpenForWriting(const std::string& filename) {
    return Overlay::HioImageWrapper(pxr::HioImage::OpenForWriting(filename));
}

bool Overlay::HioImageWrapper::Write(const StorageSpec& storage,
                                     const pxr::VtDictionary& metadata) {
    return _impl->Write(convertStorageSpec(storage),
                        metadata);
}


const std::string& Overlay::HioImageWrapper::GetFilename() const {
    return _impl->GetFilename();
}

int Overlay::HioImageWrapper::GetWidth() const {
    return _impl->GetWidth();
}

int Overlay::HioImageWrapper::GetHeight() const {
    return _impl->GetHeight();
}

pxr::HioFormat Overlay::HioImageWrapper::GetFormat() const {
    return _impl->GetFormat();
}

int Overlay::HioImageWrapper::GetBytesPerPixel() const {
    return _impl->GetBytesPerPixel();
}

int Overlay::HioImageWrapper::GetNumMipLevels() const {
    return _impl->GetNumMipLevels();
}

bool Overlay::HioImageWrapper::IsColorSpaceSRGB() const {
    return _impl->IsColorSpaceSRGB();
}

bool Overlay::HioImageWrapper::GetMetadata(const pxr::TfToken& key, pxr::VtValue* value) const {
    return _impl->GetMetadata(key, value);
}

bool Overlay::HioImageWrapper::GetSamplerMetadata(pxr::HioAddressDimension dim,
                                                  pxr::HioAddressMode* params) const {
    return _impl->GetSamplerMetadata(dim, params);
}

// MARK: SwiftUsd implementation access

Overlay::HioImageWrapper::HioImageWrapper(std::shared_ptr<pxr::HioImage> _impl)
    : _impl(_impl) {}

Overlay::HioImageWrapper::operator bool() const {
    return (bool)_impl;
}

pxr::HioImage*_Nullable Overlay::HioImageWrapper::get() const {
    return _impl.get();
}

std::shared_ptr<pxr::HioImage> Overlay::HioImageWrapper::get_shared() const {
    return _impl;
}

const Overlay::HioImageWrapper::ImageOriginLocation Overlay::HioImageWrapper::_OriginUpperLeft = Overlay::HioImageWrapper::OriginUpperLeft;
const Overlay::HioImageWrapper::ImageOriginLocation Overlay::HioImageWrapper::_OriginLowerLeft = Overlay::HioImageWrapper::OriginLowerLeft;
const Overlay::HioImageWrapper::SourceColorSpace Overlay::HioImageWrapper::_Raw = Overlay::HioImageWrapper::Raw;
const Overlay::HioImageWrapper::SourceColorSpace Overlay::HioImageWrapper::_SRGB = Overlay::HioImageWrapper::SRGB;
const Overlay::HioImageWrapper::SourceColorSpace Overlay::HioImageWrapper::_Auto = Overlay::HioImageWrapper::Auto;

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
