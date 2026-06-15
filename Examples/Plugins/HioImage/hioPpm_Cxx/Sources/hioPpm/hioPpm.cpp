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


#include "hioPpm.h"
#include "PpmImage.h"
#include "Diagnostics.h"

/// We use `TF_REGISTRY_FUNCTION` and `pxr::TfType` to
/// register this plugin with the OpenUSD runtime. 
namespace {
    // Like the TfDiagnostic macros, TF_REGISTRY_FUNCTION expects
    // to be within PXR_NAMESPACE_USING_DIRECTIVE or PXR_NAMESPACE_OPEN_SCOPE.
    PXR_NAMESPACE_USING_DIRECTIVE;
    TF_REGISTRY_FUNCTION(TfType) {
        pxr::TfType t = pxr::TfType::Define<HioPpm_Image, pxr::TfType::Bases<pxr::HioImage>>();
        t.SetFactory<pxr::HioImageFactory<HioPpm_Image>>();
    }
}

uint16_t extract_uint6_t(void* data, size_t index, pxr::HioType hioType);

bool HioPpm_Image::Read(const HioImage::StorageSpec &storage) {
    return ReadCropped(0, 0, 0, 0, storage);
}

bool HioPpm_Image::ReadCropped(const int cropTop, const int cropBottom, const int cropLeft, const int cropRight, const HioImage::StorageSpec &storage) {
    if (cropLeft < 0 || cropRight < 0 || cropTop < 0 || cropBottom < 0 ) {
        MY_CODING_ERROR("Cannot ReadCropped with negative crop amounts");
        return false;
    }
    
    if (cropLeft + cropRight >= GetWidth() || cropTop + cropBottom >= GetHeight()) {
        MY_CODING_ERROR("Cannot ReadCropped with crop amounts exceeding image size");
        return false;
    }
    
    for (int y = 0; y < storage.height; y++) {
        if (y + cropTop >= GetHeight() - cropBottom) { continue; }
        for (int x = 0; x < storage.width; x++) {
            if (x + cropLeft >= GetWidth() - cropRight) { continue; }
            for (int c = 0; c < 3; c++) {
                uint16_t value = _ppmImage->getPixel(x + cropLeft, y + cropTop, c);
                int maybeFlippedY = storage.flipped ? storage.height - y - 1 : y;
                size_t index = maybeFlippedY * 3 * GetWidth() + 3 * x + c;
                if (_ppmImage->isTwoBytesPerComponent()) {
                    reinterpret_cast<uint16_t*>(storage.data)[index] = value;
                } else {
                    reinterpret_cast<uint8_t*>(storage.data)[index] = static_cast<uint8_t>(value);
                }
            }
        }
    }
    
    return true;
}

bool HioPpm_Image::Write(const HioImage::StorageSpec &storage, VtDictionary const& metadata) {
    pxr::HioType hioType = pxr::HioGetHioType(storage.format);
    int componentCount = pxr::HioGetComponentCount(storage.format);
        
    uint16_t maxValue;
    if (hioType == pxr::HioTypeUnsignedByte || hioType == pxr::HioTypeUnsignedByteSRGB) {
        maxValue = std::numeric_limits<uint8_t>::max();
    } else {
        maxValue = std::numeric_limits<uint16_t>::max();
    }
    
    _ppmImage = PpmImage::createForWriting(storage.width, storage.height, maxValue);

    for (int y = 0; y < storage.height; y++) {
        for (int x = 0; x < storage.width; x++) {
            for (int c = 0; c < std::min(3, componentCount); c++) {
                int maybeFlippedY = storage.flipped ? storage.height - y - 1 : y;
                size_t index = maybeFlippedY * storage.width * componentCount + x * componentCount + c;
                
                _ppmImage->setPixel(x, y, c, extract_uint6_t(storage.data, index, hioType));
            }
        }
    }
    
    _ppmImage->write(_filename);
    return true;
}

std::string const& HioPpm_Image::GetFilename() const {
    return _filename;
}

int HioPpm_Image::GetWidth() const {
    if (!_ppmImage) { return 0; }
    return _ppmImage->getWidth();
}

int HioPpm_Image::GetHeight() const {
    if (!_ppmImage) { return 0; }
    return _ppmImage->getHeight();
}

HioFormat HioPpm_Image::GetFormat() const {
    if (!_ppmImage) {
        MY_CODING_ERROR("Invalid image");
        return HioFormatUInt16Vec3;
    }
    
    if (_ppmImage->isTwoBytesPerComponent()) {
        return HioFormatUInt16Vec3;
    } else {
        return HioFormatUNorm8Vec3srgb;
    }
}

int HioPpm_Image::GetBytesPerPixel() const {
    if (!_ppmImage) { return 0; }
    return _ppmImage->isTwoBytesPerComponent() ? 6 : 3;
}

int HioPpm_Image::GetNumMipLevels() const {
    return 1;
}

bool HioPpm_Image::IsColorSpaceSRGB() const {
    return true;
}

bool HioPpm_Image::GetMetadata(const TfToken &key, VtValue *value) const {
    return false;
}

bool HioPpm_Image::GetSamplerMetadata(HioAddressDimension dim, HioAddressMode *param) const {
    return false;
}

bool HioPpm_Image::_OpenForReading(const std::string &filename, int subimage, int mip, SourceColorSpace sourceColorSpace, bool suppressErrors) {
    _filename = filename;
    _ppmImage = PpmImage::createForReading(filename);
    if (!_ppmImage && !suppressErrors) {
        return false;
    }
    return true;
}

bool HioPpm_Image::_OpenForWriting(const std::string &filename) {
    _filename = filename;
    _ppmImage = nullptr;
    return true;
}


/// Utility function from extracting a uint16_t from a buffer of `hioType` values
uint16_t extract_uint6_t(void* data, size_t index, pxr::HioType hioType) {
    switch (hioType) {
        case HioTypeUnsignedByte:
        {
            uint8_t raw = reinterpret_cast<uint8_t*>(data)[index];
            return static_cast<uint16_t>(raw);
        }
        case HioTypeUnsignedByteSRGB:
        {
            uint8_t raw = reinterpret_cast<uint8_t*>(data)[index];
            return static_cast<uint16_t>(raw);
        }
        case HioTypeSignedByte:
        {
            int8_t raw = reinterpret_cast<int8_t*>(data)[index];
            if (raw < 0) { raw = 0; }
            return static_cast<uint16_t>(raw);
        }
        case HioTypeUnsignedShort:
        {
            uint16_t raw = reinterpret_cast<uint16_t*>(data)[index];
            return raw;
        }
        case HioTypeSignedShort:
        {
            int16_t raw = reinterpret_cast<int16_t*>(data)[index];
            if (raw < 0) { raw = 0; }
            return static_cast<uint16_t>(raw);
        }
        case HioTypeUnsignedInt:
        {
            uint32_t raw = reinterpret_cast<uint32_t*>(data)[index];
            raw = std::min(raw, static_cast<uint32_t>(std::numeric_limits<uint16_t>::max()));
            return static_cast<uint16_t>(raw);
        }
        case HioTypeInt:
        {
            int32_t raw = reinterpret_cast<int32_t*>(data)[index];
            if (raw < 0) { raw = 0; }
            raw = std::min(raw, static_cast<int32_t>(std::numeric_limits<uint16_t>::max()));
            return static_cast<uint16_t>(raw);
        }
        case HioTypeHalfFloat:
        {
            double raw = static_cast<double>(reinterpret_cast<pxr::GfHalf*>(data)[index]);
            raw *= static_cast<double>(std::numeric_limits<uint16_t>::max());
            if (raw < 0) { raw = 0; }
            raw = std::min(raw, static_cast<double>(std::numeric_limits<uint16_t>::max()));
            return static_cast<uint16_t>(raw);
        }
        case HioTypeFloat:
        {
            double raw = static_cast<double>(reinterpret_cast<float*>(data)[index]);
            raw *= static_cast<double>(std::numeric_limits<uint16_t>::max());
            if (raw < 0) { raw = 0; }
            raw = std::min(raw, static_cast<double>(std::numeric_limits<uint16_t>::max()));
            return static_cast<uint16_t>(raw);
        }
        case HioTypeDouble:
        {
            double raw = reinterpret_cast<double*>(data)[index];
            raw *= static_cast<double>(std::numeric_limits<uint16_t>::max());
            if (raw < 0) { raw = 0; }
            raw = std::min(raw, static_cast<double>(std::numeric_limits<uint16_t>::max()));
            return static_cast<uint16_t>(raw);
        }
        case HioTypeCount:
            return static_cast<uint16_t>(0);
    }
}
