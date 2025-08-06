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
import ArgumentParser

// MARK: FileSystemInfo

/// Container for various common file system paths
struct FileSystemInfo {
    private(set) var cliArgs: CLIArgs
    private(set) var usdInstalls: [UsdInstall] = []
    private(set) var swiftUsdPackage: SwiftUsdPackage
    private(set) var featureFlags: UsdFeatureFlags!
    
    init(cliArgs: CLIArgs) async throws {
        self.cliArgs = cliArgs
        
        // Filter and validate the usdInstall CLI arguments
        let fm = FileManager.default
        let _usdInstalls = cliArgs.usdInstalls.map { $0.expandingTildeInPath() }
            .filter { $0.lastPathComponent != ".DS_Store" || fm.directoryExists(at: $0) }
        
        guard !_usdInstalls.isEmpty else {
            throw ValidationError("At least one USD install directory must be specified")
        }
        for install in _usdInstalls {
            guard fm.directoryExists(at: install) else {
                throw ValidationError("Missing USD install directory: \(path: install)")
            }
            
            let usdDylib = getUsdDylib(installURL: install)
            guard fm.nonDirectoryFileExists(at: usdDylib) else {
                throw ValidationError("Missing \(usdDylib.lastPathComponent): \(path: usdDylib)")
            }
            #if canImport(Darwin)
            if cliArgs.usdInstallStrategy != .copyAndBundle  {
                let platform = try await getPlatformNameForDylib(usdDylib)
                guard platform == "macOS" else {
                    throw ValidationError("Platform \(platform) requires --usd-install-strategy copy-and-bundle")
                }
            }
            #endif // #if canImport(Darwin)
        }
        
        // Okay, validation succeeded
        self.swiftUsdPackage = SwiftUsdPackage(cliArgs: cliArgs)
        self.usdInstalls = _usdInstalls.enumerated().map {
            UsdInstall(url: $0.1, index: $0.0, rootTmpDir: swiftUsdPackage.tmpDir)
        }
        self.featureFlags = try grabUsdFeatureFlags(usdInstalls: usdInstalls)
    }
    
    var packageConfigInfo: String {
        var result = ["Usd installs:"]
        for usdInstall in usdInstalls {
            result.append("- \(usdInstall.url.path(percentEncoded: false))")
        }
        result.append("Usd install strategy: \(cliArgs.usdInstallStrategy)")
        result.append("Copied plugins:")
        for x in cliArgs.copiedPlugins {
            result.append("- \(x.relativePath)")
        }
        result.append("Symlinked plugins:")
        for x in cliArgs.symlinkedPlugins {
            result.append("- \(x.relativePath)")
        }
        result.append("Source strategy: \(cliArgs.sourceStrategy)")
        result.append("Checksummed artifacts dir: \(cliArgs.checksummedArtifactsDir?.relativePath ?? "nil")")
        result.append("Artifacts hosting URL: \(cliArgs.artifactsHostingURL ?? "nil")")
        
        result.append("")
        result.append("Feature flags:")
        for (flag, value) in featureFlags.rawFlags.sorted(by: { $0.key < $1.key }) {
            result.append("  \(flag): \(value)")
        }
        
        return result.joined(separator: "\n")
    }
    
    var packageConfigInfoUrl: URL {
        swiftUsdPackage.generatedSwiftPackageDir.appending(path: ".make-swift-package.info.txt")
    }
    
    /// An ordered list of minor libraries in Usd, e.g. `tf`, `gf`, `sdf`, `usd`, `usdGeom`, `garch`
    static func usdMinorLibraries(vanillaOnly: Bool) -> [String] {
        let vanilla = [
            // base
            "arch", "tf", "gf", "pegtl", "js", "trace", "work", "plug", "vt", "ts",
            // usd
            "ar", "kind", "sdf", "ndr", "sdr", "pcp", "usd", "usdGeom", "usdVol", "usdMedia",
            "usdShade", "usdLux", "usdProc", "usdRender", "usdHydra", "usdRi", "usdSemantics",
            "usdSkel", "usdUI", "usdUtils", "usdPhysics", "usdMtlx",
            // exec
            "vdf", "ef", "esf", "esfUsd", "exec", "execUsd", "execGeom",
            // imaging
            "garch", "hf", "hio", "cameraUtil", "pxOsd", "geomUtil", "glf", "hgi",
            "hgiGL", "hgiMetal", "hgiInterop", "hd", "hdar", "hdGp", "hdsi", "hdMtlx", "hioOpenVDB",
            "hdSt", "hdx", "hdStorm", "hdEmbree",
            // usdImaging
            "usdImaging", "usdImagingGL", "usdProcImaging", "usdRiPxrImaging",
            "usdSkelImaging", "usdVolImaging", "usdAppUtils",
        ]
        let extra = ["CxxOnly", "generated", "SwiftOverlay", "swiftUsd.h", "TfNotice", "Wrappers"]
        
        return vanillaOnly ? vanilla : vanilla + extra
    }
    
    /// Returns either `dylib` or `so`
    static var executableLibraryExtension: String {
        #if os(macOS)
        "dylib"
        #else
        "so"
        #endif
    }
    
    static func conditionForXCFrameworkTargetDependency(xcframework: XCFramework) -> String {
        let subdirs = try! FileManager.default.contentsOfDirectory(at: xcframework.xcframeworkPath, includingPropertiesForKeys: nil)
        let subdirNames = subdirs.compactMap {
            switch $0.lastPathComponent {
            case "ios-arm64": return ".iOS"
            case "macos-arm64": return ".macOS"
            case "Info.plist": return nil
            default:
                print("Warning: Unknown xcframework platform subdirectory: \($0.lastPathComponent)")
                return $0.lastPathComponent
            }
        }
        
        return ".when(platforms: [\(subdirNames.joined(separator: ", "))])"
    }

}

// MARK: FileSystemInfo.SwiftUsdPackage

extension FileSystemInfo {
    /// Common URLs useful when generating the Swift Package
    struct SwiftUsdPackage {
        private var cliArgs: CLIArgs
        
        private var _userArgumentGeneratedPackageDir: URL? {
            cliArgs.generatedPackageDir
        }
        
        /// The SwiftUsd repo
        private(set) var repoURL: URL = _getSwiftUsdRepoURL()
        
        /// The non-deletable `source` directory that's the source of truth for the generated swift package
        var repoSource: URL { repoURL.appending(path: "source") }
        
        var generatedPackagePrefix: String { _userArgumentGeneratedPackageDir == nil ? generatedSwiftPackageDir.lastPathComponent + "/" : "" }
        
        /// The deletable swift-package directory created by make-swift-package
        var generatedSwiftPackageDir: URL {
            if let _userArgumentGeneratedPackageDir { return _userArgumentGeneratedPackageDir }
            return repoURL.appending(path: "swift-package")
        }
        /// The deletable Package manifest file created by make-swift-package
        var packageManifestURL: URL {
            (_userArgumentGeneratedPackageDir ?? repoURL)
                .appending(path: "Package.swift")
        }
        /// The deletable `extraArgs.txt` file
        var extraArgsURL: URL {
            (_userArgumentGeneratedPackageDir ?? repoURL)
                .appending(path: "extraArgs.txt")
        }
        
        /// A deletable scratch directory
        var tmpDir: URL { generatedSwiftPackageDir.appending(path: ".tmp") }
        
        /// package/Sources
        var sources: URL { generatedSwiftPackageDir.appending(path: "Sources") }
        /// package/Sources/OpenUSD
        var sourcesOpenUSD: URL { sources.appending(path: "OpenUSD") }
        /// `package/Sources/_OpenUSD_SwiftBindingHelpers`
        var sources_OpenUSD_SwiftBindingHelpers: URL { sources.appending(path: "_OpenUSD_SwiftBindingHelpers") }
        /// `package/Sources/_OpenUSD_MacroImplementations`
        var sources_OpenUSD_MacroImplementations: URL { sources.appending(path: "_OpenUSD_MacroImplementations") }
        /// `package/Sources/_OpenUSD_SwiftBindingHelpers/include`
        var sourcesInclude: URL { sources_OpenUSD_SwiftBindingHelpers.appending(path: "include") }
        
        /// `package/Sources/_OpenUSD_SwiftBindingHelpers/include/swiftUsd/defines.h`
        var sourcesIncludeOpenUSDSwiftUsdDefines: URL { sourcesInclude.appending(components: "swiftUsd", "defines.h")}
        
        /// `package/Sources/_OpenUSD_SwiftBindingHelpers/include/module.modulemap`
        var sourcesIncludeModulemap: URL { sourcesInclude.appending(path: "module.modulemap") }
        
        func directoriesToEnumerateForModulemap() -> [URL] {
            [
                sourcesInclude.appending(components: "pxr"),
                sourcesInclude.appending(components: "swiftUsd")
            ].map { $0.resolvingSymlinksInPath() }
        }
        
        /// package/Libraries
        var libraries: URL { generatedSwiftPackageDir.appending(path: "Libraries") }
        /// package/Libraries/name
        func xcframeworkDestPath(name: String) -> URL {
            libraries.appending(path: "\(name).xcframework")
        }
        
        fileprivate init(cliArgs: CLIArgs) {
            self.cliArgs = cliArgs
        }
    }
}

// MARK: FileSystemInfo.UsdInstall

extension FileSystemInfo {
    /// Common URLs useful for introspecting a Usd install
    struct UsdInstall {
        /// The URL for this USD installation
        let url: URL
        /// A unique index for this URL
        let index: Int
        /// A deletable scratch directory
        let tmpDir: URL
        
        /// The `Frameworks` dir for this install
        var frameworksDir: URL { tmpDir.appending(path: "Frameworks") }
        
        /// `USD_INSTALL/lib`
        var libDir: URL { url.appending(path: "lib") }
        /// `USD_INSTALL/lib/usd`
        var libUsdDir: URL { libDir.appending(path: "usd") }
        /// `USD_INSTALL/plugin/usd`
        var pluginUsd: URL { url.appending(components: "plugin", "usd") }
        /// `USD_INSTALL/include`
        var include: URL { url.appending(path: "include") }
        
        /// `USD_INSTALL/libraries`
        var libraries: URL { url.appending(path: "libraries") }
                
        var isMacOS: Bool {
            get async {
                (try? await getPlatformNameForDylib(getUsdDylib(installURL: url))) == "macOS"
            }
        }
        
        fileprivate init(url: URL, index: Int, rootTmpDir: URL) {
            self.url = url
            self.index = index
            
            tmpDir = rootTmpDir.appending(path: "\(url.lastPathComponent).\(index)")
        }
        
        func framework(originalDylib: URL) -> FileSystemInfo.Framework {
            .init(usdInstall: self, originalDylib: originalDylib)
        }
    }
}

// MARK: FileSysteInfo.Framework

extension FileSystemInfo {
    /// Common URLs useful for bundling dylibs into frameworks
    struct Framework {
        /// The UsdInstall associated with this framework
        let usdInstall: FileSystemInfo.UsdInstall
        
        /// The name of this framework
        let name: String
        
        /// The original dylib from the UsdInstall
        let originalDylib: URL
        
        /// The url for this framework
        var url: URL { usdInstall.frameworksDir.appending(path: "\(name).framework") }
        /// name.framework/Versions
        var versions: URL { url.appending(path: "Versions") }
        /// name.framework/Versions/A
        var versionsA: URL { versions.appending(path: "A") }
        /// name.framework/Versions/A/usd
        var versionsAUsd: URL { versionsA.appending(path: "usd") }
        /// name.framework/Versions/A/Resources
        var versionsAResources: URL { versionsA.appending(path: "Resources") }
        /// name.framework/Versions/A/Resources/usd
        var resourcesUsd: URL { versionsAResources.appending(path: "usd") }
        /// name.framework/Versions/A/Resources/plugInfo.json
        var resourcesPlugInfoJson: URL { resourcesUsd.appending(path: "plugInfo.json") }
        /// name.framework/Versions/A/Resources/Info.plist
        var resourcesInfoPlist: URL { versionsAResources.appending(path: "Info.plist") }
        /// `name.framework/Versions/A/Resources/MaterialX_Libraries`
        var resourcesMaterialXLibraries: URL { versionsAResources.appending(path: "MaterialX_Libraries") }
        
        /// name.framework/Versions/A/name
        var dylib: URL { versionsA.appending(path: name) }

        
        var isUsdPlug: Bool { name == "Usd_Plug" }
        var isUsdMtlx: Bool { name == "Usd_UsdMtlx" }
        
        fileprivate init(usdInstall: FileSystemInfo.UsdInstall, originalDylib: URL) {
            self.usdInstall = usdInstall
            self.originalDylib = originalDylib
            self.name = Self.getFrameworkName(of: originalDylib)
        }
        
        /// Gets the prettified name of the dylib, e.g. `libusd_usdGeom.dylib` becomes `Usd_UsdGeom`
        static func getFrameworkName(of dylib: URL) -> String {
            getFrameworkName(of: dylib.lastPathComponent)
        }
        
        /// Gets the prettified name of the dylib, e.g. `libusd_usdGeom.dylib` becomes `Usd_UsdGeom`
        static func getFrameworkName(of name: String) -> String {
            var result = name
            result = result.removingSuffix(".dylib")
            result = result.removingPrefix("lib")
            
            // Capitalize `usd_foo` to `Usd_Foo`
            if result.hasPrefix("usd_") {
                let indexFour = result.index(result.startIndex, offsetBy: 4)
                let indexFive = result.index(after: indexFour)
                result = "Usd_" + result[indexFour].uppercased() + result[indexFive...]
            }
            
            if result == "tbb" {
                result = "TBB"
            }
            if result == "tbb_debug" {
                result = "TBB_debug"
            }
            
            if result.hasPrefix("osd") {
                result = "O" + result.dropFirst()
            }
            
            // Osd, MaterialX, and OpenVDB use symlink versioning (e.g. OsdCPU.3.6.0), so strip that out
            if let match = result.wholeMatch(of: #/([^.]*)(\.\d+)+/#) {
                result = String(match.output.1)
            }

            if result == "openvdb" {
                result = "OpenVDB"
            }
            
            return result
        }
    }
}


// MARK: Fileprivate file system utilities

fileprivate func _getSwiftUsdRepoURL() -> URL {
    // /Users/maddyadams/SwiftUsd/scripts/make-swift-package/Sources/make-swift-package.swift
    let _filePath: String = #filePath
    
    // We want to get to /Users/maddyadams/SwiftUsd/,
    // so just remove the last 4 path components
    
    let result = URL(filePath: _filePath).deletingLastPathComponents(count: 4)

    // Do a few checks to make sure we have something that looks like the SwiftUsd repo
    let repoContents = try! FileManager.default.contentsOfDirectory(at: result, includingPropertiesForKeys: nil)
    assert(repoContents.contains { $0.lastPathComponent == "scripts" },              "Error! Could not find SwiftUsd repo URL")
    assert(repoContents.contains { $0.lastPathComponent == "source" },               "Error! Could not find SwiftUsd repo URL")
    
    return result
}

// MARK: Fileprivate executables utilities


fileprivate func getPlatformNameForDylib(_ dylib: URL) async throws -> String {
    #if canImport(Darwin)
    let vtoolOutput = try await ShellUtil.runCommandAndGetOutput(arguments: ["vtool", "-show-build", dylib])
        .reduce([]) { $0 + [$1] }
    guard let platformLine = vtoolOutput.first(where: { $0.trimmingCharacters(in: .whitespaces).starts(with: "platform")} ) else {
        throw ValidationError("vtool -show-build parsing failure")
    }
    let platform = platformLine.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).last!
    
    // Normalize things
    switch platform {
    case "MACOS": return "macOS"
    case "IOS": return "iOS"
    default:
        print("Warning! Unknown vtool platform \(platform)")
        return platform
    }
    
    #else
    return "unknown"
    #endif // #if canImport(Darwin)
}

// MARK: Fileprivate Usd utilities

fileprivate func grabUsdFeatureFlags(usdInstalls: [FileSystemInfo.UsdInstall]) throws -> FileSystemInfo.UsdFeatureFlags {
    let allFlags = try usdInstalls.map { try FileSystemInfo.UsdFeatureFlags(usdInstall: $0.url) }
    return try FileSystemInfo.UsdFeatureFlags.merge(allFlags)
}


fileprivate func getUsdDylib(installURL: URL) -> URL {
    return installURL.appending(components: "lib", "libusd_usd.\(FileSystemInfo.executableLibraryExtension)")
}
