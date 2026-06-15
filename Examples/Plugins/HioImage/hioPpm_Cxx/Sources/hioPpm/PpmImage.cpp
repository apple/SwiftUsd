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


#include "PpmImage.h"
#include "Diagnostics.h"
#include "pxr/base/tf/diagnostic.h"
#include "pxr/usd/ar/resolver.h"
#include "pxr/usd/ar/writableAsset.h"
#include "pxr/usd/ar/asset.h"

#include <sstream>

/* static */
std::unique_ptr<PpmImage> PpmImage::createForReading(const std::string &filename) {
    std::shared_ptr<pxr::ArAsset> asset = pxr::ArGetResolver().OpenAsset(pxr::ArResolvedPath(filename));
    if (!asset) {
        MY_RUNTIME_ERROR("PpmImage createForReading failed during ArResolver::OpenAsset '" + filename + "'");
        return {};
    }
    
    std::optional<uint16_t> _width = std::nullopt;
    std::optional<uint16_t> _height = std::nullopt;
    std::optional<uint16_t> _componentMaximum = std::nullopt;
    std::vector<uint16_t> _storage;
    
    // Parse the file contents
    std::shared_ptr<const char> bufSharedPtr = asset->GetBuffer();
    const char* buf = bufSharedPtr.get();
    size_t index = 0;
    while (index < asset->GetSize()) {
        // Check for the magic number at the start of the file
        if (index == 0) {
            if (buf[index] != 'P') {
                MY_RUNTIME_ERROR("Invalid PPM magic number");
                return {};
            } else {
                index += 1;
                continue;
            }
        }
        
        if (index == 1) {
            if (buf[index] != '3') {
                MY_RUNTIME_ERROR("Invalid PPM magic number");
                return {};
            } else {
                index += 1;
                continue;
            }
        }

        // Line comments are ignored
        if (buf[index] == '#' && index > 0 && buf[index - 1] == '\n') {
            while (index < asset->GetSize() && buf[index] != '\n') {
                index += 1;
            }
            continue;
        }
        
        // Whitespace delimits values
        if (isspace(buf[index])) {
            while (index < asset->GetSize() && isspace(buf[index])) {
                index += 1;
            }
            continue;
        }
        
        // Handle numbers in the file
        if (isdigit(buf[index])) {
            std::string digitBuffer;
            while (index < asset->GetSize() && isdigit(buf[index])) {
                digitBuffer += buf[index];
                index += 1;
            }
            
            uint16_t parsedInt;
            try {
                std::int32_t x = std::stoi(digitBuffer);
                if (x < 0 || x > static_cast<int32_t>(std::numeric_limits<uint16_t>::max())) {
                    MY_RUNTIME_ERROR("Invalid PPM number (out of range)");
                    return {};
                }
                parsedInt = static_cast<uint16_t>(x);
            } catch (...) {
                MY_RUNTIME_ERROR("Invalid PPM number (failed to convert)");
                return {};
            }
            
            if (!_width.has_value()) {
                _width = parsedInt;
                if (*_width == 0) {
                    MY_RUNTIME_ERROR("Invalid PPM width");
                    return {};
                }
                continue;
            }
            
            if (!_height.has_value()) {
                _height = parsedInt;
                if (*_height == 0) {
                    MY_RUNTIME_ERROR("Invalid PPM height");
                    return {};
                }
                continue;
            }
            
            if (!_componentMaximum.has_value()) {
                _componentMaximum = parsedInt;
                if (*_componentMaximum == 0) {
                    MY_RUNTIME_ERROR("Invalid PPM component maximum");
                    return {};
                }
                continue;
            }

            if (parsedInt > *_componentMaximum) {
                MY_RUNTIME_ERROR("Invalid PPM, raster component greater than component maximum");
                return {};
            }
            _storage.push_back(parsedInt);
            if (_storage.size() > 3 * (*_width) * (*_height)) {
                MY_RUNTIME_ERROR("Invalid PPM, raster larger than expected");
                return {};
            }
            
            continue;
        }
        
        // We've handled comments, whitespace, and numbers, so
        // anything else must be an invalid character in a single-image PPM file
        MY_RUNTIME_ERROR("Invalid PPM file contents");
        return {};
    }
    
    if (!_width.has_value() || !_height.has_value() || !_componentMaximum.has_value()) {
        MY_RUNTIME_ERROR("Invalid PPM file header");
        return {};
    }
    if (_storage.size() != 3 * (*_width) * (*_height)) {
        MY_RUNTIME_ERROR("Invalid PPM, raster size is unexpected");
        return {};
    }
    
    std::unique_ptr<PpmImage> result = std::unique_ptr<PpmImage>(new PpmImage());
    result->_width = *_width;
    result->_height = *_height;
    result->_componentMaximum = *_componentMaximum;
    result->_storage = std::move(_storage);
    
    return result;
}

/* static */
std::unique_ptr<PpmImage> PpmImage::createForWriting(uint16_t width, uint16_t height, uint16_t componentMaximum) {
    std::unique_ptr<PpmImage> _result = std::unique_ptr<PpmImage>(new PpmImage());
    _result->_width = width;
    _result->_height = height;
    _result->_componentMaximum = componentMaximum;
    _result->_storage.resize(width * height * 3);
    return _result;
}

bool PpmImage::isTwoBytesPerComponent() const {
    return _componentMaximum >= 256;
}

uint16_t PpmImage::getPixel(uint16_t x, uint16_t y, int channel) const {
    size_t index = _toIndex(x, y, channel);
    if (index == -1) { return 0; }
    return _storage[index];
}

void PpmImage::setPixel(uint16_t x, uint16_t y, int channel, uint16_t value) {
    size_t index = _toIndex(x, y, channel);
    if (index == -1) { return; }
    if (value > _componentMaximum) {
        MY_CODING_ERROR("Cannot PpmImage::setPixel to a value greater than the component maximum");
        return;
    }
    _storage[index] = value;
}

void PpmImage::write(const std::string &filename) {
    std::shared_ptr<pxr::ArWritableAsset> asset = pxr::ArGetResolver().OpenAssetForWrite(pxr::ArResolvedPath(filename), pxr::ArResolver::WriteMode::Replace);
    if (!asset) {
        MY_RUNTIME_ERROR("PpmImage write failed during ArResolver::OpenAssetForWrite '" + filename + "'");
        return;
    }
    
    std::stringstream ss;
    ss << "P3\n";
    ss << _width << " " << _height << "\n";
    ss << _componentMaximum << "\n";
    for (size_t i = 0; i < _storage.size(); i += 3) {
        ss << _storage[i] << " " << _storage[i + 1] << " " << _storage[i + 2] << "\n";
    }
    
    std::string s = ss.str();
    
    asset->Write(s.c_str(), s.size(), 0);
    MY_VERIFY(asset->Close());
}

uint16_t PpmImage::getWidth() const { return _width; }

uint16_t PpmImage::getHeight() const { return _height; }

uint16_t PpmImage::getComponentMaximum() const { return _componentMaximum; }

size_t PpmImage::_toIndex(uint16_t x, uint16_t y, int channel) const {
    if (x >= _width || y >= _height || channel >= 3 || channel < 0) {
        MY_CODING_ERROR("Invalid coordinates or channel for PpmImage");
        return -1;
    }
    
    return y * 3 * _width + 3 * x + channel;
}

PpmImage::PpmImage() {}
