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
#if os(macOS)
import System
#endif

/// Packages raw executables (i.e. dylibs) into `.framework` bundles for Apple platforms
struct Framework: Sendable {
    private var fm: FileManager { .default }
    let fsInfo: FileSystemInfo.Framework
    
    var name: String { fsInfo.name }
    var bundleIdentifier: String { "com.pixar.\(name.replacingOccurrences(of: "_", with: "-"))" }
    
    init(fsInfo: FileSystemInfo.Framework) async {
        self.fsInfo = fsInfo
        try! fm.createDirectory(at: fsInfo.usdInstall.frameworksDir, withIntermediateDirectories: true)
        
        print("Making framework \(name).framework...")
        
        if fm.directoryExists(at: fsInfo.url) {
            print("\(name).framework already exists, returning early")
            return
        }
        
        await createFrameworkDirectoryStructure()
        await copyFilesIntoFrameworkBundle()
        await writeInfoPlistFile()
        await fixDylibLoadCommands()
    }
        
    private func createFrameworkDirectoryStructure() async {
        try! fm.createDirectory(at: fsInfo.url, withIntermediateDirectories: true)
        
        // Refer to https://developer.apple.com/documentation/bundleresources/placing_content_in_a_bundle?language=objc
        // for modern bundle layout information.
        // Supplement it with https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/FrameworkAnatomy.html#//apple_ref/doc/uid/20002253-BAJEJJAB
        // for information specifically about frameworks.
        //
        // This is the file structure we want on macOS:
        //
        // FrameworkName.framework
        //   Headers -> Versions/Current/Headers
        //   FrameworkName -> Versions/Current/FrameworkName
        //   Resources -> Versions/Current/Resources
        //   Versions/
        //     A/
        //       FrameworkName
        //       Headers/
        //         <header files>
        //       Resources/
        //         Info.plist
        //         usd/
        //           <usd plugins>
        //         MaterialX_Libraries
        //           libraries
        //             <materialx libraries>
        //         plugInfo.json
        //     Current -> A
        //
        // This is the file structure we want on iOS:
        // Note that iOS frameworks _cannot_ have a top-level directory named `Resources` starting in Xcode 26
        //
        // FrameworkName.framework
        //   Headers
        //   Info.plist
        //   FrameworkName
        //   Resources_iOS/
        //     usd/
        //       <usd plugins>
        //     MaterialX_Libraries
        //       libraries
        //         <materialx libraries>
        //     plugInfo.json
        
        if await fsInfo.usdInstall.isMacOS {
            // Create the subdirectories and symlinks
            try! fm.createDirectory(at: fsInfo.versions, withIntermediateDirectories: true)
            try! fm.createDirectory(at: fsInfo.versionsA, withIntermediateDirectories: true)
            try! await fm.createDirectory(at: fsInfo.versionsAResources, withIntermediateDirectories: true)
            
            fm.createSymlink(at: fsInfo.url.appending(path: name), path: "Versions/Current/\(name)")
            fm.createSymlink(at: fsInfo.url.appending(path: "Resources"), path: "Versions/Current/Resources")
            fm.createSymlink(at: fsInfo.url.appending(components: "Versions", "Current"), path: "A")
            
        } else {
            try! await fm.createDirectory(at: fsInfo.versionsAResources, withIntermediateDirectories: true)
        }
    }
    
    func copyFilesIntoFrameworkBundle() async {
        try! await fm.copyItem(at: fsInfo.originalDylib.resolvingSymlinksInPath(), to: fsInfo.dylib)
        
        if fsInfo.isUsdMtlx {
            // Important: MaterialX wants its libraries to live in a directory called `libraries`
            try! await fm.createDirectory(at: fsInfo.resourcesMaterialXLibraries, withIntermediateDirectories: true)
            try! await fm.copyItem(at: fsInfo.usdInstall.libraries, to: fsInfo.resourcesMaterialXLibraries.appending(components: "libraries"))
        }
        
        if fsInfo.isUsdPlug {
            // Usd needs to be able to find plugInfo.json files.
            // First, copy in the usd core plugin definitions.
            try! await fm.copyItem(at: fsInfo.usdInstall.libUsdDir, to: fsInfo.resourcesUsd)
            
            // Next, write out a plugInfo.json file to bootstrap plugin loading
            // `*/Resources/` finds the core plugin definitions, just like in vanilla OpenUSD,
            // except that we use a capital-R for macOS bundle.
            // `../../../../*.framework/Resources/` finds hydra plugin definitions
            // after Xcode has processed XCFrameworks to extract the platform's framework
            // In both bases, `Resources_iOS` is where the resources live in an iOS bundle
            let plugInfoContents = """
            {
                "Includes": [
                    "*/Resources/",
                    "*/Resources_iOS/",
                    "../../../../*.framework/Resources/",
                    "../../*.framework/Resources_iOS/"
                ]
            }
            
            """
            try! await plugInfoContents.write(to: fsInfo.resourcesPlugInfoJson, atomically: true, encoding: .utf8)
            
            // Usd looks for plugInfo files at libusd_usdPlug.dylib/../usd,
            // so make a symlink there that points to where we put our plugInfo.json file
            if await fsInfo.usdInstall.isMacOS {
                fm.createSymlink(at: fsInfo.versionsAUsd, path: "Resources/usd")
            } else {
                fm.createSymlink(at: fsInfo.url.appending(path: "usd"), path: "Resources_iOS/usd")
            }
            
            // We need to make `Resources/usd/*/resources` into `Resources/usd/*/Resources`,
            // for bundle and iOS case sensitivity reasons
            
            for item in await fm.allUrls(under: fsInfo.versionsAResources) {
                guard fm.directoryExists(at: item) else { continue }
                let nestedResourcesDir = item.appending(path: "resources")
                if fm.directoryExists(at: nestedResourcesDir) {
                    try! fm.moveItem(at: nestedResourcesDir, to: nestedResourcesDir.deletingLastPathComponent().appending(path: "Resources"))
                }
            }
        } // end `if frameworkIsUsdPlug`
        
        // Copy the resources and plugInfo for hydra plugins,
        // which are in folders with the same name as the dylib, without the extension.
        // And, fix the plug info files
        let hydraPluginPath = fsInfo.originalDylib.deletingPathExtension()
        if fm.directoryExists(at: hydraPluginPath) {
            let hydraResources = hydraPluginPath.appending(path: "resources")
            if fm.directoryExists(at: hydraResources) {
                for item in try! fm.contentsOfDirectory(at: hydraResources, includingPropertiesForKeys: nil) {
                    try! await fm.copyItem(at: item, to: fsInfo.versionsAResources.appending(path: item.lastPathComponent))
                }
                await fixPlugInfo(isHydraPlugin: true)
            }
        } else if fsInfo.isUsdPlug {
            await fixPlugInfo(isHydraPlugin: false)
        }
    }
    
    func writeInfoPlistFile() async {
        let infoPlistContents = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>CFBundleDevelopmentRegion</key>
            <string>en</string>
            <key>CFBundleExecutable</key>
            <string>\(name)</string>
            <key>CFBundleIdentifier</key>
            <string>\(bundleIdentifier)</string>
            <key>CFBundleInfoDictionaryVersion</key>
            <string>6.0</string>
            <key>CFBundleName</key>
            <string>\(name)</string>
            <key>CFBundlePackageType</key>
            <string>FMWK</string>
            <key>CFBundleShortVersionString</key>
            <string>1.0.0</string>
            <key>CFBundleVersion</key>
            <string>1.0.0</string>
            <key>CSResourcesFileMapped</key>
            <true/>
        </dict>
        </plist>
        
        """
        try! await infoPlistContents.write(to: fsInfo.resourcesInfoPlist, atomically: true, encoding: .utf8)
    }
    
    func fixDylibLoadCommands() async {
        // old LC_ID_DYLIB is `"@rpath/\(name)`
        try! await ShellUtil.runCommandAndWait(arguments: ["install_name_tool", "-id", Self.rpathForFramework(named: name), fsInfo.dylib],
                                               quiet: true)
        
        // old LC_RPATH contains @loader_path/., which we don't have to change
        
        // old LC_LOAD_DYLIB contains wrong `@rpath`s
        for loadDylib in await grepOtool("LC_LOAD_DYLIB") {
            // Fix rpath-relative load commands only, since those are from Usd
            if let match = loadDylib.firstMatch(of: #/@rpath/(.*)/#) {
                var newLoadDylib = String(match.output.1)
                newLoadDylib = FileSystemInfo.Framework.getFrameworkName(of: newLoadDylib)
                newLoadDylib = Self.rpathForFramework(named: newLoadDylib)
                try! await ShellUtil.runCommandAndWait(arguments: ["install_name_tool", "-change", loadDylib, newLoadDylib, fsInfo.dylib],
                                                       quiet: true)
            }
        }
        
        // Use code signing to change the identifier in the signature.
        // Xcode will re-sign the frameworks at the end of the build phase,
        // but it specifically preserves the identifier when doing so.
        // If we don't change the identifier here, dylib loading on iOS can fail because the
        // code signing identifier doesn't match the bundle identifier.
        let codeSignId = ProcessInfo.processInfo.environment["CODE_SIGN_ID"] ?? "-"
        try! await ShellUtil.runCommandAndWait(arguments: ["codesign", "-f", "-s", codeSignId, "-i", bundleIdentifier, fsInfo.url],
                                               quiet: true)
    }
    
    /// Greps for `cmd` in the load commands of the dylib,
    /// returning the path associated with the command
    private func grepOtool(_ cmd: String) async -> [String] {
        let otoolOutput = try! await ShellUtil.runCommandAndGetOutput(arguments: ["otool", "-l", fsInfo.dylib]).reduce([]) { $0 + [$1] }
        
        var result = [String]()
        
        for i in 0..<otoolOutput.count {
            if otoolOutput[i].contains("cmd \(cmd)") && i + 2 < otoolOutput.count {
                let pattern = #/\s*(?:name|path) (.*) \(offset \d+\)/#
                result.append(String(otoolOutput[i + 2].wholeMatch(of: pattern)!.output.1))
            }
        }
        
        return result
    }
    
    private static func rpathForFramework(named name: String) -> String {
        "@rpath/\(name).framework/\(name)"
    }
    
    /// All plugInfo.json files are either in libusd\_usdPlug, or hydra.
    /// In both cases, we need to fix the LibraryPath and ResourcePath keys,
    /// because the way we're packaging up dylibs and resources isn't
    /// how Usd expects things to be by default
    private func fixPlugInfo(isHydraPlugin: Bool) async {
        let fm = FileManager.default
        
        let isMacOS = await fsInfo.usdInstall.isMacOS
        
        for fileURL in await fm.allUrls(under: fsInfo.versionsAResources) {
            guard fileURL.lastPathComponent == "plugInfo.json" else { continue }
            
            let mappedLines = try! String(contentsOf: fileURL, encoding: .utf8)
                .components(separatedBy: .newlines)
                .map { line in
                    
                    // First, LibraryPath
                    do {
                        let captureName = #"([^"]+)"#
                        let oldLibraryPathPattern = if isHydraPlugin {
                            #"\.\./\#(captureName)"#
                        } else {
                            #"\.\./\.\./\#(captureName)"#
                        }
                        // Capture the value for the LibraryPath key, preserving whitespace
                        let pattern = #"^(\s*"LibraryPath"\s*:\s*)"\#(oldLibraryPathPattern)"(\s*,\s*)$"#
                        
                        if let match = line.firstMatch(of: try! Regex(pattern)) {
                            var newLibraryPath = FileSystemInfo.Framework
                                .getFrameworkName(of: String(match[2].substring!))
                            if !isHydraPlugin {
                                // Hydra plugins have their plugInfo.json in themselves,
                                // but core plugins have their plugInfo.json in the Usd_Plug.framework,
                                // so walk way up to find the framework containing its dylib
                                if isMacOS {
                                    newLibraryPath = "../../../../../\(newLibraryPath).framework/\(newLibraryPath)"
                                } else {
                                    newLibraryPath = "../../../\(newLibraryPath).framework/\(newLibraryPath)"
                                }
                            }
                            
                            return #"\#(match.output[1].substring!)"\#(newLibraryPath)"\#(match.output[3].substring!)"#
                        }
                    }
                    
                    // Second, ResourcePath
                    // 1. macOS is a case-insensitive file system, but iOS is a case-sensitive file system.
                    // 2. Bundles are required to have a capital-R `Resources` directory.
                    // 3. The framework bundles we're making here are first created on a Mac, then moved over
                    // to iOS.
                    // 1, 2, and 3 together imply iOS bundles can't have a `resources` and a `Resources` directory
                    //
                    // Most Usd plugins use the value `resources` for the `ResourcesPath` key, which
                    // lets them find their resources. The most logical thing to do when packaging Usd as a
                    // set of frameworks is to make their `resources` directory into the bundle's `Resources`.
                    // But, on iOS and not on macOS, when the plugin loading mechanism looks for `resources`,
                    // it won't find anything, so you'll get obscure problems like not being able to render
                    // using UsdPreviewSurface.
                    //
                    // The solution is simple: Tell Usd, regardless of platform, to look for capital-R `Resources`.
                    // macOS doesn't need this, but iOS (and probably other Apple embedded platforms) do,
                    // and splitting the code based on platform is more trouble than its worth
                    do {
                        let pattern = #/^(\s*"ResourcePath"\s*:\s*)"resources"(\s*,\s*)$/#
                        if let match = line.wholeMatch(of: pattern) {
                            if isHydraPlugin && !isMacOS {
                                return #"\#(match.output.1)"Resources_iOS"\#(match.output.2)"#
                            } else {
                                return #"\#(match.output.1)"Resources"\#(match.output.2)"#
                            }
                        }
                    }
                    
                    // If it isn't LibraryPath or ResourcePath, just return it as is
                    return line
                } // end `.map { line in`
            
            let newLines = mappedLines.map { $0 + "\n" }.reduce("", +).dropLast(1)
            try! newLines.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    static func wrapDylibsIntoFrameworks(usdInstall: FileSystemInfo.UsdInstall) async -> [Framework] {
        let allRequiredDylibs = await getAllRequiredDylibs(usdInstall: usdInstall)
        
        return await withTaskGroup(of: Framework.self) { group in
            for dylib in allRequiredDylibs {
                 group.addTask { @Sendable in await Framework(fsInfo: usdInstall.framework(originalDylib: dylib)) }
            }
            return await group.reduce([]) { $0 + [$1] }
        }
    }

    /// Returns a list of all dylibs required by ``usdInstall``
    private static func getAllRequiredDylibs(usdInstall: FileSystemInfo.UsdInstall) async -> [URL] {
        let fm = FileManager.default
        print("Getting all required dylibs at \(path: usdInstall.url)...")
        
        // Start with the dylibs from OpenUSD
        var result = [URL]()
        for item in try! fm.contentsOfDirectory(at: usdInstall.libDir, includingPropertiesForKeys: nil) {
            guard item.lastPathComponent.wholeMatch(of: #/libusd_.+\.dylib/#) != nil else { continue }
            result.append(item.absoluteURL)
        }
        
        // Next, pull in any dylibs in the pluginUsdDir, e.g. Hydra Render Delegates
        for item in try! fm.contentsOfDirectory(at: usdInstall.pluginUsd, includingPropertiesForKeys: nil) {
            if item.lastPathComponent.hasSuffix(".dylib") {
                result.append(item.absoluteURL)
            }
        }
        
        // Finally, pull in the (e.g. third-party) dependencies of any of the above dylibs.
        // (In the case of Embree, hdEmbree pulls in embree3.3.dylib, so this step has to go after finding HRDs
        var i = 0
        while i < result.count {
            for dependency in await findDirectDependenciesOfDylib(dylib: result[i], usdInstall: usdInstall) {
                if !result.contains(dependency.absoluteURL) { result.append(dependency.absoluteURL) }
            }
            i += 1
        }
        
        return result
    }
    
    /// Returns a list of dylibs loaded by `@rpath` by `dylib`
    private static func findDirectDependenciesOfDylib(dylib: URL, usdInstall: FileSystemInfo.UsdInstall) async -> [URL] {
        
        var result = [URL]()
        do {
            // Just use `otool` and extract the `@rpath` dylibs, relative to the `lib_dir`
            for try await line in try! ShellUtil.runCommandAndGetOutput(arguments: ["otool", "-L", dylib]) {
                let pattern = #/\s*@rpath/(.*\.dylib) \(compatibility version .*, current version .*\)/#
                if let match = line.wholeMatch(of: pattern)?.output.1 {
                    let toAppend = usdInstall.libDir.appending(path: match)
                    if !FileManager.default.fileExists(at: toAppend) {
                        // otool -L told us about an rpath dependency we can't find.
                        // if this happens because the dependency is itself, that's okay.
                        // (otool -L outputs the shared library ID when ran on a shared library)
                        let sharedLibraryId = (try! await ShellUtil.runCommandAndGetOutput(arguments: ["otool", "-D", dylib]).reduce([]) { $0 + [$1] })[1]
                        if sharedLibraryId.wholeMatch(of: #/@rpath/(.*\.dylib)/#)?.output.1 == match {
                            continue
                        } else {
                            print("Warning: otool -L '\(dylib.relativePath)' contained '\(line)', but '\(toAppend.relativePath)' doesn't exist")
                        }
                    }
                    result.append(toAppend)
                }
                
                // Sometimes, you can end up with dylib dependencies that aren't located on other machines.
                // E.g., if you installed OpenImageIO via homebrew, building OpenUSD with OpenImageIO on
                // that machine will try to pull in dependencies found in /opt/homebrew. This can make
                // the resulting package non-relocatable, which can be unexpected and hard to debug.
                let allowedDependencyStarts: [any RegexComponent] = [
                    #/\s*@rpath/#,
                    #/\s*/usr/lib/#,
                    #/\s*/System/Library/Frameworks/#,
                ]
                
                if allowedDependencyStarts.allSatisfy({ !line.starts(with: $0) }) && line != "\(dylib.relativePath):" {
                    print("WARNING: \(dylib.relativePath) has non-relocatable dependency: '\(line.trimmingCharacters(in: .whitespaces))'")
                    print("Did you mean to use `--ignore-paths` or `--ignore-homebrew` when building OpenUSD?")
                }
            }
        } catch {
            fatalError(String(describing: error))
        }
        
        return result
    }

}
