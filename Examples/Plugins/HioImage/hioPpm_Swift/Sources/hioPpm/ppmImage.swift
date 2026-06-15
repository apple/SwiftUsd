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

import Foundation
import OpenUSD

extension PpmImage {
    /// Error type for errors while parsing a PPM image
    fileprivate struct ParseError: Error {
        var message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var description: String { message }
    }
}

/// Class for reading and writing PPM images
class PpmImage {
    private(set) var width: UInt16
    private(set) var height: UInt16
    private(set) var componentMaximum: UInt16
    private var storage: [UInt16]
        
    init?(forReading filename: std.string) {
        do throws(ParseError) {
            
            let asset = Overlay.ArGetResolver().OpenAsset(pxr.ArResolvedPath(filename))
            guard Bool(asset) else {
                throw ParseError("PpmImage createForReading failed during ArResolver::OpenAsset '\(filename)'")
            }
            
            var width: UInt16?
            var height: UInt16?
            var componentMaximum: UInt16?
            var storage: [UInt16] = []
            
            // Parse the file contents
            try withExtendedLifetime((asset, asset.GetBuffer())) { (asset, bufSharedPtr) throws(ParseError) in
                let buf = bufSharedPtr.__getUnsafe()!
                
                var index = 0
                while index < asset.GetSize() {
                    // Check for the magic number at the start of the file
                    if index == 0 {
                        guard buf[index] == UInt8(ascii: "P") else {
                            throw ParseError("Invalid PPM magic number")
                        }
                        index += 1
                        continue
                    }
                    if index == 1 {
                        guard buf[index] == UInt8(ascii: "3") else {
                            throw ParseError("Invalid PPM magic number")
                        }
                        index += 1
                        continue
                    }
                    
                    
                    // Line comments are ignored
                    if buf[index] == UInt8(ascii: "#") && index > 0 && buf[index - 1] == UInt8(ascii: "\n") {
                        // Advance through the end of the line
                        while index < asset.GetSize() && buf[index] != UInt8(ascii: "\n") {
                            index += 1
                        }
                        continue
                    }
                    
                    // Whitespace delimits values
                    if isspace(Int32(buf[index])) != 0 {
                        // Advance through the last contiguous whitespace
                        while index < asset.GetSize() && isspace(Int32(buf[index])) != 0 {
                            index += 1
                        }
                        continue
                    }
                    
                    // Handle numbers in the file
                    if isdigit(Int32(buf[index])) != 0 {
                        var digitBuffer = ""
                        while index < asset.GetSize() && isdigit(Int32(buf[index])) != 0 {
                            digitBuffer += String(UnicodeScalar(UInt8(buf[index])))
                            index += 1
                        }
                        
                        guard let parsedInt = UInt16(digitBuffer) else {
                            throw ParseError("Invalid PPM number (failed to convert)")
                        }
                        
                        if width == nil {
                            guard parsedInt > 0 else {
                                throw ParseError("Invalid PPM width")
                            }
                            width = parsedInt
                            continue
                        }
                        
                        if height == nil {
                            guard parsedInt > 0 else {
                                throw ParseError("Invalid PPM height")
                            }
                            height = parsedInt
                            continue
                        }
                        
                        if componentMaximum == nil {
                            guard parsedInt > 0 else {
                                throw ParseError("Invalid PPM component maximum")
                            }
                            componentMaximum = parsedInt
                            continue
                        }
                        
                        guard parsedInt <= componentMaximum! else {
                            throw ParseError("Invalid PPM, raster component greater than component maximum")
                        }
                        
                        storage.append(parsedInt)
                        guard storage.count <= 3 * width! * height! else {
                            throw ParseError("Invalid PPM, raster larger than expected")
                        }
                        
                        continue
                    } // `if isdigit(Int32(buf[index])) != 0`
                    
                    // We've handled comments, whitespace, and numbers, so
                    // anything else must be an invalid character in a single-image PPM file
                    throw ParseError("Invalid PPM file contents")
                } // outermost `while index < asset.GetSize()`
                
            } // `withExtendedLifetime`
            
            guard let width, let height, let componentMaximum else {
                throw ParseError("Invalid PPM file header")
            }
            
            guard storage.count == 3 * width * height else {
                throw ParseError("Invalid PPM, raster size is unexpected")
            }
            
            self.width = width
            self.height = height
            self.componentMaximum = componentMaximum
            self.storage = storage
            
        } catch let error as ParseError {
            TF_RUNTIME_ERROR(std.string(error.message))
            return nil
        }
    }
    
    init(forWritingWithWidth width: UInt16, height: UInt16, componentMaximum: UInt16) {
        self.width = width
        self.height = height
        self.componentMaximum = componentMaximum
        self.storage = .init(repeating: 0, count: Int(width) * Int(height) * 3)
    }
    
    var isTwoBytesPerComponent: Bool { componentMaximum >= 256 }
    
    func getPixel(x: UInt16, y: UInt16, channel: Int) -> UInt16 {
        guard let index = _toIndex(x: x, y: y, channel: channel) else { return 0 }
        return storage[index]
    }
    
    func setPixel(x: UInt16, y: UInt16, channel: Int, value: UInt16) {
        guard let index = _toIndex(x: x, y: y, channel: channel) else { return }
        guard value <= componentMaximum else {
            TF_CODING_ERROR("Cannot PpmImage.setPixel to a value greater than the component maximum")
            return
        }
        storage[index] = value
    }
    
    func write(filename: std.string) {
        var asset = Overlay.ArGetResolver().OpenAssetForWrite(pxr.ArResolvedPath(filename), .Replace)
        guard Bool(asset) else {
            TF_RUNTIME_ERROR(std.string("PpmImage write failed during ArResolver::OpenAssetForWrite '\(filename)'"))
            return
        }
        
        var lines = [String]()
        lines.append("P3")
        lines.append("\(width) \(height)")
        lines.append("\(componentMaximum)")
        for i in stride(from: 0, to: storage.count, by: 3) {
            lines.append("\(storage[i]) \(storage[i + 1]) \(storage[i + 2])")
        }
        let s = lines.joined(separator: "\n") + "\n"
        

        asset.Write(s, s.count, 0)
        #TF_VERIFY(asset.Close())
    }
    
    private func _toIndex(x: UInt16, y: UInt16, channel: Int) -> Int? {
        if x >= width || y >= height || channel >= 3 || channel < 0 {
            TF_CODING_ERROR("Invalid coordinates or channel for PpmImage")
            return nil
        }
        
        return Int(y) * 3 * Int(width) + 3 * Int(x) + channel
    }
}
