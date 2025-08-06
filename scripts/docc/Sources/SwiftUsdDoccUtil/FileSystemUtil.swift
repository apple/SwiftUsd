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

import Foundation
import Synchronization

final public class Driver: Sendable {
    static private func _getSwiftUsdRepoURL() -> URL {
        // /Users/maddyadams/SwiftUsd/scripts/docc/Sources/SwiftUsdDoccUtil/FileSystemUtil.swift
        let _filePath: String = #filePath
        
        // We want to get to /Users/maddyadams/SwiftUsd/,
        // so just remove the last 5 path components
        let result = URL(filePath: _filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        // Do a smoke test to make sure we have something that looks like the SwiftUsd repo
        let repoContents = try! FileManager.default.contentsOfDirectory(atPath: result.path(percentEncoded: false))
        assert(repoContents.contains("docs"),                 "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("openusd-patch.patch"),  "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("Package.swift"),        "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("README.md"),            "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("scripts"),              "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("source"),               "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("swift-package"),        "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("SwiftUsd.docc"),        "Error! Could not find SwiftUsd repo URL")
        assert(repoContents.contains("SwiftUsd.doccarchive"), "Error! Could not find SwiftUsd repo URL")
        
        return result
    }
    
    private init() {
        swiftUsdRepoURL = Self._getSwiftUsdRepoURL()
        
        dotBuildURL = swiftUsdRepoURL.appending(path: ".build")
        packageResolvedURL = swiftUsdRepoURL.appending(path: "Package.resolved")
        
        symbolGraphsURL = swiftUsdRepoURL.appending(path: ".symbol-graphs")
        moduleAtObjcSymbolsURL = symbolGraphsURL.appending(path: "OpenUSD@__ObjC.symbols.json")
        moduleAtCppSymbolsURL = symbolGraphsURL.appending(path: "OpenUSD@C++.symbols.json")
        
        docsURL = swiftUsdRepoURL.appending(path: "docs")
        doccArchiveURL = swiftUsdRepoURL.appending(path: "SwiftUsd.doccarchive")
        doccCatalogURL = swiftUsdRepoURL.appending(path: "SwiftUsd.docc")
        doccGeneratedArticlesURL = doccCatalogURL.appending(path: "generated")
        
        sourceURL = swiftUsdRepoURL.appending(path: "source")
        umbrellaHeaderURL = sourceURL.appending(path: "swiftUsd.h")
        
        includeURL = swiftUsdRepoURL.appending(path: "swift-package/Sources/_OpenUSD_SwiftBindingHelpers/include")
        pixarHeaderURL = includeURL.appending(path: "pxr/pxr.h")
    }
    public static let shared = Driver()
    
    public let swiftUsdRepoURL: URL
    public let packageResolvedURL: URL
    
    public let dotBuildURL: URL
    
    public let symbolGraphsURL: URL
    public func clangExtractAPISymbolsURL(header: URL, forCpp: Bool) -> URL {
        let languageTag = forCpp ? ".cpp" : ".swift"
        
        var candidate = "OpenUSD@" + header.lastPathComponent + languageTag + ".symbols.json"
        var i = 0
        
        _clangExtractAPISymbolsAlreadyUsedFilenames.withLock { alreadyUsed in
            while alreadyUsed.contains(candidate) {
                i += 1
                candidate = "OpenUSD@" + header.lastPathComponent + ".\(i)" + languageTag + ".symbols.json"
            }
            alreadyUsed.insert(candidate)
        }
        
        return symbolGraphsURL.appending(path: candidate)
    }
    private let _clangExtractAPISymbolsAlreadyUsedFilenames = Mutex<Set<String>>([])
    
    public let moduleAtObjcSymbolsURL: URL
    public let moduleAtCppSymbolsURL: URL
    
    public let docsURL: URL
    public let doccArchiveURL: URL
    public let doccCatalogURL: URL
    public let doccGeneratedArticlesURL: URL
        
    public let sourceURL: URL
    public let umbrellaHeaderURL: URL
    
    public let includeURL: URL
    public let pixarHeaderURL: URL
}

extension FileManager {
    public func allUrls(under: URL) -> [URL] {
        var result = [URL]()
        if let e = enumerator(at: under, includingPropertiesForKeys: nil) {
            for case let x as URL in e {
                result.append(x)
            }
        }
        return result
    }
}
