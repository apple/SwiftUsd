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

struct SwiftPackage {
    private var cliArgs: CLIArgs
    private var fsInfo: FileSystemInfo
    private var xcframeworks: [XCFramework] = []
    private var checksummedArtifacts: [(XCFramework, String)] = []
    
    private var fm: FileManager { .default }
    
    static func run(cliArgs: CLIArgs) async throws {
        print("Making Swift Package...")
        
        var swiftPackage = try await SwiftPackage(cliArgs: cliArgs, fsInfo: .init(cliArgs: cliArgs))
        
        try await swiftPackage.setupDirectoryStructure()
        
        switch cliArgs.usdInstallStrategy {
        case .symlink:
            try await swiftPackage.addRawUsdInstallIntoSwiftPackage(copy: false)
            
        case .copyWithoutBundling:
            try await swiftPackage.addRawUsdInstallIntoSwiftPackage(copy: true)
            
        case .copyAndBundle:
            try await swiftPackage.makeXCFrameworks()
            if cliArgs.checksummedArtifactsDir == nil {
                try await swiftPackage.copyXCFrameworksIntoSwiftPackage()
            } else {
                try await swiftPackage.makeChecksummedArtifacts()
            }
        }
        
        try await swiftPackage.writeSwiftPackageManifest()
        try await swiftPackage.pullInVanillaOpenUSDHeaders()
        try await swiftPackage.addFilesToSwiftPackage()
        try await swiftPackage.writeModulemap()
        try await swiftPackage.writeCppDefinesFile()
        try await swiftPackage.writeExtraArgsFile()
        
        print("")
        print("Success! To use \(path: swiftPackage.fsInfo.swiftUsdPackage.generatedSwiftPackageDir) from the command line: ")
        print("    Add `$(cat extaArgs.txt)` to your swift invocations")
    }
    
    private func setupDirectoryStructure() async throws {
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.generatedSwiftPackageDir, withIntermediateDirectories: true)
        try! fsInfo.packageConfigInfo.write(to: fsInfo.packageConfigInfoUrl, atomically: true, encoding: .utf8)
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.tmpDir, withIntermediateDirectories: true)
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.libraries, withIntermediateDirectories: true)
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.sources, withIntermediateDirectories: true)
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.sourcesOpenUSD, withIntermediateDirectories: true)
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.sources_OpenUSD_SwiftBindingHelpers, withIntermediateDirectories: true)
        try! fm.createDirectory(at: fsInfo.swiftUsdPackage.sourcesInclude, withIntermediateDirectories: true)
    }
    
    private mutating func makeXCFrameworks() async throws {
        // Group framework variants for different platforms by their name
        var groupedFrameworks = [String : [Framework]]()
        for usdInstall in fsInfo.usdInstalls {
            for framework in await Framework.wrapDylibsIntoFrameworks(usdInstall: usdInstall) {
                groupedFrameworks[framework.name, default: []].append(framework)
            }
        }
        
        // Copy fsInfo for the task group
        let fsInfo = fsInfo
        // Make XCFrameworks from the grouped frameworks in parallel
        xcframeworks = await withTaskGroup(of: XCFramework.self) { group in
            for frameworkSet in groupedFrameworks.values {
                group.addTask { @Sendable in await XCFramework(fsInfo: fsInfo, frameworks: frameworkSet) }
            }
            return await group.reduce([]) { $0 + [$1] }
        }.sorted { $0.xcframeworkPath.lastPathComponent < $1.xcframeworkPath.lastPathComponent }
    }
    
    private func copyXCFrameworksIntoSwiftPackage() async throws {
        for (i, xcframework) in xcframeworks.enumerated() {
            let name = xcframework.name
            print("Copying \(name) (\(i + 1) of \(xcframeworks.count))")
            let destPath = fsInfo.swiftUsdPackage.xcframeworkDestPath(name: name)
            if !fm.directoryExists(at: destPath) {
                try! fm.createDirectory(at: destPath.deletingLastPathComponent(), withIntermediateDirectories: true)
                try! fm.copyItem(at: xcframework.xcframeworkPath, to: destPath)
            }
        }
    }
    
    /// Copies or symlinks the entire Usd install into the Swift Package
    private func addRawUsdInstallIntoSwiftPackage(copy: Bool) async throws {
        let url = fsInfo.usdInstalls[0].url
        
        let dest = fsInfo.swiftUsdPackage.libraries.appending(path: "OpenUSD")
        if copy {
            print("Copying \(path: url)")
            try fm.copyItem(at: url, to: dest)
        } else {
            print("Symlinking \(path: url)")
            fm.createSymlink(at: dest, path: url.urlRelative(to: dest).relativePath)
        }
    }
    
    private mutating func makeChecksummedArtifacts() async throws {
        print("Generating artifacts and checksums")
        for (i, xcframework) in xcframeworks.enumerated() {
            print("Zipping \(xcframework.name) (\(i + 1) of \(xcframeworks.count))")
            
            // do we need to codesign before zipping?
            
            let src = xcframework.xcframeworkPath!
            let dest = cliArgs.checksummedArtifactsDir!.appending(path: "\(src.lastPathComponent).zip")
            try await ShellUtil.runCommandAndWait(arguments: ["ditto", "-c", "-k", "--sequesterRsrc", src, dest])
            
            let opensslOutput = try await ShellUtil.runCommandAndGetOutput(arguments: ["openssl", "dgst", "-sha256", dest]).reduce([]) { $0 + [$1] }
            guard let checksum = opensslOutput[0].wholeMatch(of: #/SHA256\(.*\.xcframework\.zip\)= ([0-9a-f]*)/#)?.output.1 else {
                throw ValidationError("openssl checksumming error! Got \(opensslOutput)")
            }
            
            checksummedArtifacts.append((xcframework, String(checksum)))
        }
    }

    
    private func writeModulemap() async throws {
        print("Writing modulemap...")
        func computeUnsortedHeaderLines() -> [String] {
            var result = [String]()
            for dirToEnumerate in fsInfo.swiftUsdPackage.directoriesToEnumerateForModulemap() {
                let resolvedDirToEnumerate = dirToEnumerate.resolvingSymlinksInPath()
                
                for fileURL in fm.allUrls(under: resolvedDirToEnumerate) {
                    guard fm.nonDirectoryFileExists(at: fileURL) else { continue }
                    
                    var relativePath = fileURL.urlRelative(to: resolvedDirToEnumerate).relativePath
                    relativePath = "\(resolvedDirToEnumerate.lastPathComponent)/\(relativePath)"
                    
                    if relativePath.starts(with: "swiftUsd/swiftUsd.h") {
                        continue
                    }
                    if relativePath.starts(with: "swiftUsd/CxxOnly/") {
                        continue
                    }
                    if relativePath.starts(with: "pxr/base/pegtl/pegtl/") {
                        // pegtl is a header-only library with the entry point
                        // pxr/base/pegtl/pegtl.hpp. including other headers out of order
                        // can cause obscure compiler errors
                        continue
                    }
                    // 24.05 has a few headers that are private when they probably should be public
                    if relativePath == "pxr/imaging/hdSt/extCompGpuComputation.h" ||
                        relativePath == "pxr/imaging/hdSt/extCompGpuComputationResource.h" {
                        result.append(#"// header "\#(relativePath)" // 24.05 HdSt_ResourceBinder #include fix"#)
                        continue
                    }
                    if relativePath == "pxr/imaging/hdSt/glslfxShader.h" {
                        result.append(#"// header "\#(relativePath)" // 24.05 HdSt_MaterialNetworkShader #include fix"#)
                        continue
                    }
                    if relativePath.starts(with: "pxr/usdImaging/usdBakeMtlx/") || relativePath.starts(with: "pxr/usdValidation") {
                        continue
                    }
                    if relativePath.starts(with: "pxr/usdImaging/usdviewq") {
                        continue
                    }
                    if relativePath.starts(with: "pxr/external/boost") {
                        continue
                    }
                    #if os(Linux)
                    let isLinux = true
                    #else
                    let isLinux = false
                    #endif
                    if relativePath == "pxr/imaging/garch/glPlatformContextGLX.h" ||
                       (relativePath == "pxr/imaging/garch/glPlatformContext.h" && isLinux) ||
                       (relativePath == "pxr/imaging/glf/glRawContext.h" && isLinux) {
                        // These pull in X11 headers, or OpenUSD headers that pull in X11 headers.
                        // The X11 headers #define a bunch of normal identifiers like `Bool` and `Always`, which causes a bunch of incomprehensible errors.
                        continue
                    }

                    if relativePath.starts(with: "pxr/imaging/hdEmbree") {
                        // Headers are built to `pxr/imaging/hdEmbree/foo.h`, but
                        // they use `#include "pxr/imaging/plugin/hdEmbree/bar.h"`,
                        // which causes errors due to bad include paths. They live at
                        // `pxr/imaging/plugin/hdEmbree` in the OpenUSD repo, so this
                        // may be an issue that OpenUSD should fix. 
                        continue
                    }
                    
                    result.append(#"header "\#(relativePath)""#)
                }
                
                
            }
            return result
        }
        
        func headerSortKey(_ headerLine: String) -> (Int, String) {
            let filePath = String(headerLine.firstMatch(of: #/header "([^"]*)"/#)!.output.1)
            let components = filePath.split(separator: "/", maxSplits: 3)
            
            let minorLibraries = FileSystemInfo.usdMinorLibraries(vanillaOnly: false)
            
            if filePath == "pxr/pxr.h" {
                return (-1, "pxr.h")
            }
            // pxr, base, tf, refPtr.h
            if components[0] == "pxr" {
                guard let index = minorLibraries.firstIndex(of: String(components[2])) else {
                    print("Warning: Unknown header line '\(headerLine)'")
                    return (minorLibraries.count, headerLine)
                }
                return (index, String(components[3]))
            }
            // swiftUsd, generated, ReferenceTypeConformances.h
            if components[0] == "swiftUsd" {
                guard let index = minorLibraries.firstIndex(of: String(components[1])) else {
                    print("Warning: Unknown header line '\(headerLine)'")
                    return (minorLibraries.count, headerLine)
                }
                return (index, String(components[2]))
            }
            print("Warning: Unknown header line '\(headerLine)'")
            return (minorLibraries.count, headerLine)
        }
        
        var lines = [
            "// This file was generated by make-swift-package. Do not edit!",
            "",
            "module _OpenUSD_SwiftBindingHelpers {" // start of main Clang module
        ]
        
        for header in computeUnsortedHeaderLines().sorted(by: { headerSortKey($0) < headerSortKey($1) }) {
            lines.append("    \(header)")
        }
        
        // Add link lines, unless dylibs are being bundled into XCFrameworks
        if cliArgs.usdInstallStrategy != .copyAndBundle {
            lines.append("    ")
            let libContents = try! fm.contentsOfDirectory(at: fsInfo.usdInstalls[0].libDir, includingPropertiesForKeys: nil)
                .sorted(by: { $0.path(percentEncoded: false) < $1.path(percentEncoded: false) })
            for item in libContents {
                guard fm.nonDirectoryFileExists(at: item) else { continue }
                guard item.pathExtension == FileSystemInfo.executableLibraryExtension else { continue }
                guard item.lastPathComponent.starts(with: "lib") else { continue }
                let toLink = item.deletingPathExtension().lastPathComponent.trimmingPrefix("lib")
                lines.append("    link \"\(toLink)\"")
            }
        }
        
        if fsInfo.featureFlags.PXR_ENABLE_PYTHON_SUPPORT.coercedToBool {
            let python3Library = URL(fileURLWithPath: fsInfo.featureFlags.Python3_LIBRARY.asRawString)
            lines.append("    link \"\(python3Library.deletingPathExtension().lastPathComponent.trimmingPrefix("lib"))\"")
        }
        
        lines.append("}") // end of main Clang module
        
        // Write empty module lines so Swift can detect Usd feature flags at compile time
        lines.append(contentsOf: [
            "",
            "// Swift can detect Usd feature flags at compile time by using `#if canImport(SwiftUsd_PXR_ENABLE_<flag>_SUPPORT)`",
            ""
        ])
        for (flag, moduleName) in FileSystemInfo.UsdFeatureFlags.compileTimeDirectiveFlags {
            let enabled = fsInfo.featureFlags.coerceFlagToBool(flag)
            
            var toAdd: [String]
            
            if let shortName = FileSystemInfo.UsdFeatureFlags.shortNameForFeatureUnavailableOnEmbeddedPlatforms(moduleName: moduleName) {
                toAdd = [
                    "module \(moduleName) {",
                    "    // \(shortName) is not available on embedded platforms",
                    "    requires !ios",
                    "}"
                ]
            } else {
                toAdd = ["module \(moduleName) {}"]
            }
            if !enabled {
                toAdd = toAdd.map { "// \($0)" }
            }

            lines.append(contentsOf: toAdd)
        }
        
        
        try! lines.joined(separator: "\n").write(to: fsInfo.swiftUsdPackage.sourcesIncludeModulemap, atomically: true, encoding: .utf8)
    }
    
    private func writeCppDefinesFile() async throws {
        print("Writing swiftUsd/defines.h...")
        var lines = [
            "// This file was generated by make-swift-package. Do not edit!",
            "",
            "#ifndef SWIFTUSD_DEFINES_H",
            "#define SWIFTUSD_DEFINES_H",
            "",
            "#include \"pxr/base/arch/defines.h\"",
            "",
        ]
        
        for (flag, moduleName) in FileSystemInfo.UsdFeatureFlags.compileTimeDirectiveFlags {
            let enabled = fsInfo.featureFlags.coerceFlagToBool(flag)
            let toAdd: [String]
            
            if let shortName = FileSystemInfo.UsdFeatureFlags.shortNameForFeatureUnavailableOnEmbeddedPlatforms(moduleName: moduleName), enabled {
                toAdd = [
                    "// \(shortName) is not available on embedded platforms",
                    "#ifdef ARCH_OS_IPHONE",
                    "#define \(moduleName) 0",
                    "#else",
                    "#define \(moduleName) 1",
                    "#endif // #ifdef ARCH_OS_IPHONE"
                ]
            } else {
                toAdd = [enabled ? "#define \(moduleName) 1" : "#define \(moduleName) 0"]
            }
            
            lines.append(contentsOf: toAdd)
        }
        
        lines.append(contentsOf: [
            "",
            "#endif // #ifndef SWIFTUSD_DEFINES_H"
        ])
        
        try! lines.joined(separator: "\n")
            .write(to: fsInfo.swiftUsdPackage.sourcesIncludeOpenUSDSwiftUsdDefines, atomically: true, encoding: .utf8)
    }
    
    /// Adds sources, resources, apinotes, and documentation,
    /// either by copying or symlink, depending on `--source-strategy`
    private func addFilesToSwiftPackage() async throws {
        print("Adding files to swift package...")
        for fileURL in fm.allUrls(under: fsInfo.swiftUsdPackage.repoSource) {
            guard fm.nonDirectoryFileExists(at: fileURL) else { continue }
            
            // Find the ancestor directory to make the symlink in, based on the file type
            let destParent: URL
            switch fileURL.lastPathComponent {
            case let x where x.hasSuffix(".h") || x.hasSuffix(".hpp"):
                destParent = fsInfo.swiftUsdPackage.sourcesInclude.appending(components: "swiftUsd")
            case let x where x.hasSuffix(".apinotes"):
                destParent = fsInfo.swiftUsdPackage.sourcesInclude
            case let x where x.hasSuffix(".cpp") || x.hasSuffix(".mm"):
                destParent = fsInfo.swiftUsdPackage.sources_OpenUSD_SwiftBindingHelpers
            case let x where x.hasSuffix(".swift") || x.hasSuffix(".metal") || x.hasSuffix(".usdz"):
                let sourceMacroImplementations = fsInfo.swiftUsdPackage.repoSource.appending(path: fsInfo.swiftUsdPackage.sources_OpenUSD_MacroImplementations.lastPathComponent)
                if fileURL.path(percentEncoded: false).starts(with: sourceMacroImplementations.path(percentEncoded: false)) {
                    destParent = fsInfo.swiftUsdPackage.sources_OpenUSD_MacroImplementations
                } else {
                    destParent = fsInfo.swiftUsdPackage.sourcesOpenUSD
                }
            case let x where x == ".DS_Store" || x == "Package.swift.in" || x.hasSuffix(".md"):
                continue
            default:
                print(fileURL)
                fatalError()
            }
            
            // Concat the ancestor directory and the relative path to the file from within the repo sources
            // to determine where to create the symlink
            let dest: URL
            if fileURL.lastPathComponent.hasSuffix(".apinotes") {
                dest = destParent.appending(path: fileURL.lastPathComponent)
            } else {
                dest = destParent.appending(path: fileURL.urlRelative(to: fsInfo.swiftUsdPackage.repoSource).relativePath)
            }
                        
            try! fm.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            if cliArgs.sourceStrategy == .symlink {
                let src = fileURL.urlRelative(to: dest)
                if !fm.fileExists(at: dest) {
                    fm.createSymlink(at: dest, path: src.relativePath)
                }
            } else {
                try fm.copyItem(at: fileURL, to: dest)
            }
        }
    }
    
    private func pullInVanillaOpenUSDHeaders() async throws {
        print("Pulling in vanilla OpenUSD headers...")
        let fm = FileManager.default
        
        // Pull in headers from every install. If different installs have different headers,
        // it's up to the user to conditionally pull in headers that are only usable
        // for the given platform they're compiling for
        let includesToTraverse: [URL] = if cliArgs.usdInstallStrategy == .copyAndBundle {
            fsInfo.usdInstalls.map(\.include)
        } else {
            [fsInfo.swiftUsdPackage.libraries.appending(path: "OpenUSD/include")]
        }
        
        for installInclude in includesToTraverse {
            for _item in try! fm.contentsOfDirectory(at: installInclude, includingPropertiesForKeys: nil) {
                // contentsOfDirectory expands symlinks, but we want to preserve them
                let item = installInclude.appending(path: _item.lastPathComponent)
                
                let dest = fsInfo.swiftUsdPackage.sourcesInclude.appending(path: item.lastPathComponent)
                if fm.fileExists(at: dest) { continue }
                
                if cliArgs.usdInstallStrategy == .copyAndBundle {
                    try! fm.copyItem(at: item, to: dest)
                } else {
                    fm.createSymlink(at: dest, path: item.urlRelative(to: dest).relativePath)
                }
            }
        }
    }
    
    private func writeSwiftPackageManifest() async throws {
        print("Writing Package.swift...")
        // Copy Package.swift.in to Package.swift,
        // but rewrite the @FOO@ lines based on the Usd install
        
        let packageInFile = fsInfo.swiftUsdPackage.repoSource.appending(path: "Package.swift.in")
        let oldLines = try! String(contentsOf: packageInFile, encoding: .utf8).components(separatedBy: .newlines)
        let newLines = oldLines.map { line in
            switch line {
            case "@THIS_FILE_CAN_BE_EDITED_BY_HAND@": 
                return "// This file was auto-generated by make-swift-package. Do not edit!"
                
            case "@CPPTARGET_DEPENDENCIES@":
                var result = ["    ["]
                for xcframework in xcframeworks {
                    let name = #""_\#(xcframework.name)_xcframework""#
                    let condition = FileSystemInfo.conditionForXCFrameworkTargetDependency(xcframework: xcframework)
                    result.append("        .target(name: \(name), condition: \(condition)),")
                }
                result.append("    ]")
                return result.joined(separator: "\n")
                
            case "@XCFRAMEWORKBINARYTARGETS@":
                var result = [String]()
                
                if checksummedArtifacts.isEmpty {
                    result.append("    [")
                    for xcframework in xcframeworks {
                        let name = #""_\#(xcframework.name)_xcframework""#
                        let path = #""\#(fsInfo.swiftUsdPackage.generatedPackagePrefix)Libraries/\#(xcframework.name).xcframework""#
                        result.append("        .binaryTarget(name: \(name), path: \(path)),")
                    }
                    result.append("    ]")
                } else {
                    result.append(#"    let urlBase = "\#(cliArgs.artifactsHostingURL!)""#)
                    result.append( "    return [")
                    for (xcframework, _checksum) in checksummedArtifacts {
                        let name = #""_\#(xcframework.name)_xcframework""#
                        let url = #""\(urlBase)\#(xcframework.name).xcframework.zip""#
                        let checksum = #""\#(_checksum)""#
                        result.append("        .binaryTarget(name: \(name), ")
                        result.append("                      url: \(url), ")
                        result.append("                      checksum: \(checksum)),")
                    }
                    result.append("    ]")
                }
                return result.joined(separator: "\n")
                
            case _ where line.contains("${generated-package-prefix}"):
                return line.replacingOccurrences(of: "${generated-package-prefix}", with: fsInfo.swiftUsdPackage.generatedPackagePrefix)
                                
            default: return line
            }
            
        }.joined(separator: "\n")
        try! newLines.write(to: fsInfo.swiftUsdPackage.packageManifestURL, atomically: true, encoding: .utf8)
    }
    
    private func writeExtraArgsFile() async throws {
        var extraArgs = [String]()
        
        // The workaround for rdar://136691907 (Linker error in Release because std::__1::__voidify and C++ inline functions are missing)
        // breaks `swift build` on the command line, because `__ZNSt3__122__cxx_atomic_fetch_subB8ne180100IiEET_PNS_22__cxx_atomic_base_implIS1_EES1_NS_12memory_orderE`
        // becomes a duplicate symbol, so let Swift know not to do that workaround. 
        extraArgs += ["-Xcxx", "-DOPENUSD_SWIFT_BUILD_FROM_CLI",
                      "-Xswiftc", "-DOPENUSD_SWIFT_BUILD_FROM_CLI"]
        
        // Avoid `__gnu_objc_personality_v0` linker error by specifying
        // the C++ exception type
        #if os(Linux)
        extraArgs += ["-Xcxx", "-fseh-exceptions"]
        #endif // #if os(Linux)
        
        // Tell the linker/loader where the Usd libraries are when
        // they aren't copied into the app bundle
        if cliArgs.usdInstallStrategy != .copyAndBundle {
            let libDir = fsInfo.swiftUsdPackage.libraries.appending(path: "OpenUSD/lib").absoluteURL.path(percentEncoded: false)
            extraArgs += ["-Xlinker", "-L", "-Xlinker", libDir,
                          "-Xlinker", "-rpath", "-Xlinker", libDir]
        }

        // Tell the compiler/linker which Python to use
        if fsInfo.featureFlags.PXR_ENABLE_PYTHON_SUPPORT.coercedToBool {
            let python3IncludeDir = fsInfo.featureFlags.Python3_INCLUDE_DIR.asRawString
            let python3Library = URL(fileURLWithPath: fsInfo.featureFlags.Python3_LIBRARY.asRawString)
            
            extraArgs += ["-Xcxx", "-I", "-Xcxx", python3IncludeDir,
                          "-Xswiftc", "-I", "-Xswiftc", python3IncludeDir]
            extraArgs += ["-Xlinker", "-L", "-Xlinker", python3Library.deletingLastPathComponent().path(percentEncoded: false)]
        }
        
        let extraArgsContents = extraArgs
            .map { $0.replacingOccurrences(of: " ", with: "\\ ") } // escape spaces in paths by replacing ` ` with `\ `
            .joined(separator: " ") + "\n"
        
        
        try! extraArgsContents.write(to: fsInfo.swiftUsdPackage.extraArgsURL, atomically: true, encoding: .utf8)
    }
}
