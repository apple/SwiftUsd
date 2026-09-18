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

public typealias pxr = pxrInternal_v0_26_8__pxrReserved__

@SWIFTUSD_PLUGIN
final class SdfJsonFileFormat: Overlay.SdfFileFormatSubclass {
    func CanRead(_ file: std.string) -> CBool {
        let ext = pxr.TfGetExtension(file)
        if ext != GetFormatId() {
            return false
        }
        return true
    }
    
    func _read(_ layer: pxr.SdfLayer?, _ d: Data) -> Bool {        
        let myLayer = Overlay.Dereference(pxr.SdfLayer.CreateAnonymous("", .init()))
        
        do {
            try readLayer(myLayer, d)
        } catch {
            TF_RUNTIME_ERROR(std.string("Error while reading layer: \(error)"))
            return false
        }
        
        layer?.TransferContent(Overlay.TfWeakPtr(myLayer))
        return true
    }
    
    func Read(_ layer: pxr.SdfLayer?, _ resolvedPath: std.string, _ metadataOnly: CBool) -> CBool {
        let asset = Overlay.ArGetResolver().OpenAsset(pxr.ArResolvedPath(resolvedPath))
        guard Bool(asset) else { return false }
        let buflen = asset.GetSize()
        let buf = asset.GetBuffer()
        let data = withExtendedLifetime((asset, buf)) {
            if let bufPointer = buf.__getUnsafe() {
                Data(bytes: bufPointer, count: buflen)
            } else {
                Data()
            }
        }
        
        return _read(layer, data)
    }
    
    override func WriteToFile(_ layer: pxr.SdfLayer, _ filePath: std.string, _ comment: std.string, _ args: pxr.SdfFileFormat.FileFormatArguments) -> CBool {
        var asset = Overlay.ArGetResolver().OpenAssetForWrite(pxr.ArResolvedPath(filePath), .Replace)
        guard Bool(asset) else {
            TF_RUNTIME_ERROR("Couldn't OpenAssetForWrite(\(filePath))")
            return false
        }
        
        do {
            let data = try writeLayer(layer, comment)
            let writeSucceeded = data.withUnsafeBytes {
                asset.Write($0.baseAddress, $0.count, 0)
            }
            guard writeSucceeded != 0 else {
                TF_RUNTIME_ERROR("ArWritableAsset->Write failed")
                return false
            }
            return asset.Close()
        } catch {
            TF_RUNTIME_ERROR(std.string("Error while encoding layer: \(error)"))
            return false
        }
    }
    
    override func SaveToFile(_ layer: pxr.SdfLayer, _ filePath: std.string, _ comment: std.string, _ args: pxr.SdfFileFormat.FileFormatArguments) -> CBool {
        WriteToFile(layer, filePath, comment, args)
    }
    
    override func ReadFromString(_ layer: pxr.SdfLayer?, _ str: std.string) -> CBool {
        _read(layer, Data(String(str).utf8))
    }
        
    override func WriteToString(_ layer: pxr.SdfLayer, _ str: UnsafeMutablePointer<std.string>?, _ comment: std.string) -> CBool {
        do {
            let data = try writeLayer(layer, comment)
            str?.pointee = std.string(String(data: data, encoding: .utf8))
            return true
        } catch {
            TF_RUNTIME_ERROR(std.string("Error while encoding layer: \(error)"))
            return false
        }
    }
    
    init() {
        super.init("json", "1.0", "usd", "json")
    }
}
