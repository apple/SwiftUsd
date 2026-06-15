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

#ifndef HIOPPM_HIOPPM_H
#define HIOPPM_HIOPPM_H

#include "pxr/imaging/hio/image.h"

class PpmImage;

/// The plugin entry point for this plugin. We subclass from 
/// `pxr::HioImage` to implement an HioImage plugin, and in 
/// `hioPpm.cpp`, we register this plugin with the OpenUSD runtime. 
/// This class handles HioImage concerns and delegates actually
/// working with the PPM image file format to the ``PpmImage`` class. 
class HioPpm_Image final: public pxr::HioImage {
public:
    using Base = HioImage;
    
    HioPpm_Image() = default;
    ~HioPpm_Image() = default;
    
    bool Read(pxr::HioImage::StorageSpec const& storage) override;
    
    bool ReadCropped(int const cropTop,
                     int const cropBottom,
                     int const cropLeft,
                     int const cropRight,
                     pxr::HioImage::StorageSpec const& storage) override;
    
    bool Write(pxr::HioImage::StorageSpec const& storage,
               pxr::VtDictionary const& metadata = pxr::VtDictionary()) override;
    
    std::string const& GetFilename() const override;
    
    int GetWidth() const override;
    
    int GetHeight() const override;
    
    pxr::HioFormat GetFormat() const override;
    
    int GetBytesPerPixel() const override;
    
    int GetNumMipLevels() const override;
    
    bool IsColorSpaceSRGB() const override;
    
    bool GetMetadata(pxr::TfToken const & key, pxr::VtValue * value) const override;
    
    bool GetSamplerMetadata(pxr::HioAddressDimension dim,
                            pxr::HioAddressMode * param) const override;
    
protected:
    bool _OpenForReading(std::string const & filename,
                         int subimage,
                         int mip,
                         pxr::HioImage::SourceColorSpace sourceColorSpace,
                         bool suppressErrors) override;
    
    bool _OpenForWriting(std::string const & filename) override;
    
private:
    std::string _filename;
    std::unique_ptr<PpmImage> _ppmImage;
};

#endif // HIOPPM_HIOPPM_H
