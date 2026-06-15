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


#ifndef HIOPPM_PPMIMAGE_H
#define HIOPPM_PPMIMAGE_H

#include <stdio.h>
#include <stdint.h>
#include <vector>
#include <memory>

/// Class for reading and writing PPM images
class PpmImage {
public:
    static std::unique_ptr<PpmImage> createForReading(std::string const& filename);
    static std::unique_ptr<PpmImage> createForWriting(uint16_t width, uint16_t height, uint16_t componentMaximum);
    
    bool isTwoBytesPerComponent() const;
    uint16_t getPixel(uint16_t x, uint16_t y, int channel) const;
    void setPixel(uint16_t x, uint16_t y, int channel, uint16_t value);
    
    void write(std::string const& filename);
    
    uint16_t getWidth() const;
    uint16_t getHeight() const;
    uint16_t getComponentMaximum() const;
        
    PpmImage(const PpmImage&) = delete;
    PpmImage& operator=(const PpmImage&) = delete;
    
private:
    PpmImage();
    
    size_t _toIndex(uint16_t x, uint16_t y, int channel) const;
    
    uint16_t _width;
    uint16_t _height;
    uint16_t _componentMaximum;
    std::vector<uint16_t> _storage;
};

#endif // HIOPPM_PPMIMAGE_H
