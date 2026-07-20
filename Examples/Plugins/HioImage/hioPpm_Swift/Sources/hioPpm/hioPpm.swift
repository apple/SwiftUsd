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

import OpenUSD

public typealias pxr = pxrInternal_v0_26_8__pxrReserved__

/// The plugin entry point for this plugin. It uses `@SWIFTUSD_PLUGIN` to register
/// this plugin with the OpenUSD runtime, and subclass from `Overlay.HioImageSubclass`
/// to implement an HioImage plugin.
/// It handles HioImage concerns and delegates actually working with the PPM image file format
/// to the ``PpmImage`` class
@SWIFTUSD_PLUGIN
final class HioPpm_Image: Overlay.HioImageSubclass {
    private var filename: std.string = ""
    private var ppmImage: PpmImage?
    
    func Read(_ storage: pxr.HioImage.StorageSpec) -> CBool {
        ReadCropped(0, 0, 0, 0, storage)
    }
    
    func ReadCropped(_ cropTop: CInt, _ cropBottom: CInt, _ cropLeft: CInt, _ cropRight: CInt, _ storage: pxr.HioImage.StorageSpec) -> CBool {
        guard let ppmImage else {
            TF_CODING_ERROR("Cannot ReadCropped on an unopened image")
            return false
        }
        
        if cropLeft < 0 || cropRight < 0 || cropTop < 0 || cropBottom < 0 {
            TF_CODING_ERROR("Cannot ReadCropped with negative crop amounts")
            return false
        }
        
        if (cropLeft + cropRight >= GetWidth()) || (cropTop + cropBottom >= GetHeight()) {
            TF_CODING_ERROR("Cannot ReadCropped with crop amounts exceeding image size")
            return false
        }
        
        for y in 0..<storage.height {
            if y + cropTop >= GetHeight() - cropBottom { continue }
            for x in 0..<storage.width {
                if x + cropLeft >= GetWidth() - cropRight { continue }
                for c in 0..<3 {
                    let value = ppmImage.getPixel(x: UInt16(x + cropLeft), y: UInt16(y + cropTop), channel: c)
                    let maybeFlippedY = storage.flipped ? storage.height - y - 1 : y
                    let index = Int(maybeFlippedY * 3 * GetWidth()) + Int(3 * x) + c
                    if ppmImage.isTwoBytesPerComponent {
                        storage.data.assumingMemoryBound(to: UInt16.self)[index] = value
                    } else {
                        storage.data.assumingMemoryBound(to: UInt8.self)[index] = UInt8(value)
                    }
                }
            }
        }
        
        return true
    }
    
    func Write(_ storage: pxr.HioImage.StorageSpec, _ metadata: pxr.VtDictionary) -> CBool {
        let hioType = pxr.HioGetHioType(storage.format)
        let componentCount = pxr.HioGetComponentCount(storage.format)
        
        var maxValue: UInt16 = 0
        if hioType == .HioTypeUnsignedByte || hioType == .HioTypeUnsignedByteSRGB {
            maxValue = UInt16(UInt8.max)
        } else {
            maxValue = UInt16.max
        }
        
        ppmImage = .init(forWritingWithWidth: UInt16(storage.width), height: UInt16(storage.height), componentMaximum: maxValue)
        
        for y in 0..<storage.height {
            for x in 0..<storage.width {
                for c in 0..<min(3, componentCount) {
                    let maybeFlippedY = storage.flipped ? storage.height - y - 1 : y
                    let index = maybeFlippedY * storage.width * componentCount + x * componentCount + c
                    ppmImage!.setPixel(x: UInt16(x), y: UInt16(y), channel: Int(c), value: extractUInt16(bytes: storage.data, index: Int(index), hioType: hioType))
                }
            }
        }
        
        ppmImage!.write(filename: filename)
        return true
    }
    
    func GetFilename() -> std.string {
        return filename
    }
    
    func GetWidth() -> CInt {
        guard let ppmImage else { return 0 }
        return Int32(ppmImage.width)
    }
    
    func GetHeight() -> CInt {
        guard let ppmImage else { return 0 }
        return Int32(ppmImage.height)
    }
    
    func GetFormat() -> pxr.HioFormat {
        guard let ppmImage else {
            TF_CODING_ERROR("Invalid image")
            return .HioFormatUInt16Vec3
        }
        
        if ppmImage.isTwoBytesPerComponent {
            return .HioFormatUInt16Vec3
        } else {
            return .HioFormatUNorm8Vec3srgb
        }
    }
    
    func GetBytesPerPixel() -> CInt {
        guard let ppmImage else { return 0 }
        return ppmImage.isTwoBytesPerComponent ? 6 : 3
    }
    
    func GetNumMipLevels() -> CInt {
        1
    }
    
    func IsColorSpaceSRGB() -> CBool {
        true
    }
    
    func GetMetadata(_ key: pxr.TfToken, _ value: UnsafeMutablePointer<pxr.VtValue>?) -> CBool {
        false
    }
    
    func GetSamplerMetadata(_ dim: pxr.HioAddressDimension, _ param: UnsafeMutablePointer<pxr.HioAddressMode>?) -> CBool {
        false
    }
    
    func _OpenForReading(_ filename: std.string, _ subimage: CInt, _ mip: CInt, _ sourceColorSpace: pxr.HioImage.SourceColorSpace, _ suppressErrors: CBool) -> CBool {
        self.filename = filename
        ppmImage = .init(forReading: filename)
        if ppmImage == nil && !suppressErrors {
            return false
        }
        return true
    }
    
    func _OpenForWriting(_ filename: std.string) -> CBool {
        self.filename = filename
        self.ppmImage = nil
        return true
    }
}

/// Utility function from extracting a UInt16 from a buffer of `hioType` values
fileprivate func extractUInt16(bytes: UnsafeMutableRawPointer, index: Int, hioType: pxr.HioType) -> UInt16 {
    switch hioType {
    case .HioTypeUnsignedByte:
        let raw = bytes.assumingMemoryBound(to: UInt8.self)[index]
        return UInt16(raw)
        
    case .HioTypeUnsignedByteSRGB:
        let raw = bytes.assumingMemoryBound(to: UInt8.self)[index]
        return UInt16(raw)
        
    case .HioTypeSignedByte:
        var raw = bytes.assumingMemoryBound(to: Int8.self)[index]
        if raw < 0 { raw = 0}
        return UInt16(raw)
        
    case .HioTypeUnsignedShort:
        let raw = bytes.assumingMemoryBound(to: UInt16.self)[index]
        return raw
        
    case .HioTypeSignedShort:
        var raw = bytes.assumingMemoryBound(to: Int16.self)[index]
        if raw < 0 { raw = 0 }
        raw = min(raw, Int16(UInt16.max))
        return UInt16(raw)
        
    case .HioTypeUnsignedInt:
        var raw = bytes.assumingMemoryBound(to: UInt32.self)[index]
        raw = min(raw, UInt32(UInt16.max))
        return UInt16(raw)
        
    case .HioTypeInt:
        var raw = bytes.assumingMemoryBound(to: Int32.self)[index]
        if raw < 0 { raw = 0}
        raw = min(raw, Int32(UInt16.max))
        return UInt16(raw)
        
    case .HioTypeHalfFloat:
        var raw = Double(bytes.assumingMemoryBound(to: pxr.GfHalf.self)[index])
        raw *= Double(UInt16.max)
        if raw < 0 { raw = 0 }
        raw = min(raw, Double(UInt16.max))
        return UInt16(raw)
        
    case .HioTypeFloat:
        var raw = Double(bytes.assumingMemoryBound(to: Float.self)[index])
        raw *= Double(UInt16.max)
        if raw < 0 { raw = 0 }
        raw = min(raw, Double(UInt16.max))
        return UInt16(raw)
        
    case .HioTypeDouble:
        var raw = bytes.assumingMemoryBound(to: Double.self)[index]
        raw *= Double(UInt16.max)
        if raw < 0 { raw = 0 }
        raw = min(raw, Double(UInt16.max))
        return UInt16(raw)
        
    case .HioTypeCount:
        return 0
        
    default:
        TF_CODING_ERROR(std.string("Unknown hioType \(hioType)"))
        return 0
    }
}
