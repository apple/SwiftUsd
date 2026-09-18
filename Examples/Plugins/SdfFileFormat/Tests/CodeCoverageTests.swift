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

// This file runs through the test resources files included in usdcat-tests,
// but as in-process instead of calling out to usdcat, so we can measure code coverage

import Foundation
import Testing
import OpenUSD

public typealias pxr = pxrInternal_v0_26_8__pxrReserved__

func ensurePluginLoaded() throws {
    let root = #bundle.resourceURL!
        .absoluteURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    let toLoad = root.path(percentEncoded: false) + "*/Contents/Resources/plugInfo_macOS.json"
    print(toLoad)
    let plugins = pxr.PlugRegistry.GetInstance().RegisterPlugins(std.string(toLoad))
    try #require(!plugins.empty())
}

func resourcesUrl() -> URL {
    #bundle.resourceURL!.appending(path: "Resources")
}

func usdResourcesFiles() throws -> [URL] {
    var result = [URL]()
    let enumerator = try #require(FileManager.default.enumerator(at: resourcesUrl(), includingPropertiesForKeys: nil))
    for case let item as URL in enumerator {
        guard item.pathExtension.hasPrefix("usd") else { continue }
        guard !item.lastPathComponent.starts(with: "SKIP") else { continue }
        result.append(item.absoluteURL)
    }
    result.sort(using: KeyPathComparator(\.path))
    try #require(!result.isEmpty)
    return result
}

func jsonResourcesFiles() throws -> [URL] {
    var result = [URL]()
    let enumerator = try #require(FileManager.default.enumerator(at: resourcesUrl(), includingPropertiesForKeys: nil))
    for case let item as URL in enumerator {
        guard item.pathExtension == "json" else { continue }
        guard !item.lastPathComponent.starts(with: "SKIP") else { continue }
        result.append(item.absoluteURL)
    }
    result.sort(using: KeyPathComparator(\.path))
    try #require(!result.isEmpty)
    return result
}

func expectJsonFailure(_ x: URL) throws {
    try Overlay.withTfErrorMark { mark in
        // Note: The #expect/#require macros require all subexpressions to be Copyable,
        // so we can't use `mark` because Overlay.TfErrorMarkWrapper is ~Copyable
        var isClean = mark.IsClean()
        try #require(isClean)
        let layer = Overlay.DereferenceOrNil(pxr.SdfLayer.FindOrOpen(x.forUsd, .init()))
        // Don't want to put `layer` in the `#require`, because if it fails,
        // Swift Testing will try to using reflection/mirrors to introspect the subexpressions
        // and hit a runtime crash
        let layerIsNil = layer == nil
        if let layer {
            let usdaLayer = Overlay.Dereference(pxr.SdfLayer.CreateAnonymous("", .init()))
            usdaLayer.TransferContent(Overlay.TfWeakPtr(layer))
            var s: std.string = ""
            usdaLayer.ExportToString(&s)
            print("\"\"\"\n" + String(s) + "\"\"\"")
        }
        try #require(layerIsNil, "\(x.forUsd)")
        isClean = mark.IsClean()
        try #require(!isClean)
    }
}

func usdcat(a: std.string, b: std.string) throws {
    let layer = try #require(Overlay.DereferenceOrNil(pxr.SdfLayer.FindOrOpen(a, .init())), "\(a), \(b)")
    #expect(layer.Export(b, layer.GetComment(), .init()))
}

func diff(a: URL, b: URL) throws {
    // Skip USDZ extraction since this isn't correctness,
    // just code coverage
    if a.pathExtension == "usdz" { return }

    // Fake usddiff normalization by just usdcatting once more.
    let aCatForDiff = std.string(String(b.forUsd) + ".acatfordiff.usda")
    let bCatForDiff = std.string(String(b.forUsd) + ".bcatfordiff.usda")

    try usdcat(a: a.forUsd, b: aCatForDiff)
    try usdcat(a: b.forUsd, b: bCatForDiff)
    
    let aLines = try String(contentsOf: URL(fileURLWithPath: String(aCatForDiff)),
                            encoding: .utf8).components(separatedBy: .newlines)
    let bLines = try String(contentsOf: URL(fileURLWithPath: String(bCatForDiff)),
                            encoding: .utf8).components(separatedBy: .newlines)

    try #require(aLines.count == bLines.count)
    for i in 0..<aLines.count {
        try #require(aLines[i] == bLines[i])
    }
}

extension URL {
    var forUsd: std.string { 
        std.string(path(percentEncoded: false))
    }
}

@Test func go() throws {
    try ensurePluginLoaded()
    for file in try usdResourcesFiles() {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        print("Will test \(file.forUsd) in \(tempDir.forUsd)")


        let json = tempDir.appending(path: file.lastPathComponent + ".json")
        let secondUsda = tempDir.appending(path: file.lastPathComponent + ".second.usda")
       
        try usdcat(a: file.forUsd, b: json.forUsd)
        try usdcat(a: json.forUsd, b: secondUsda.forUsd)
        try diff(a: file, b: secondUsda)
        print("\(file.forUsd) passed")
    }
    for file in try jsonResourcesFiles() {
        print("Will test \(file.forUsd)")
        try expectJsonFailure(file)
        print("\(file.forUsd) failed as expected")
    }
}