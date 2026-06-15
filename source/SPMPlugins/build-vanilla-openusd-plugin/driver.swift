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
import PackagePlugin

enum DriverError: Error, CustomStringConvertible {
    enum OptionKind {
        case output
        case product
        case configuration
        
        var options: String {
            switch self {
            case .output: "-o or --output"
            case .product: "--product"
            case .configuration: "-c or --configuration"
            }
        }
        
        var validValues: String {
            switch self {
            case .output: ""
            case .product: ""
            case .configuration: "debug, release"
            }
        }
    }
    
    case userSpecifiedHelp
    case tooManyOptions(OptionKind)
    case optionRequiresArgument(OptionKind)
    case invalidArgumentForOption(OptionKind)
    case mustPassOption(OptionKind)
    case unknownArgument(String)
    
    case noConfigurationInBuildDirectory
    case mustSelectConfigurationWhenBuildDirectoryHasMultipleConfigurations
    
    case outputDirExistsButForceNotPassed(URL)
    case couldntCreateOutputDirectory(URL)
    case couldntCreateTempDirectory(URL)
    case mustSelectProductWhenPackageHasMultipleLibraryProducts
    case couldNotFindDylib
    case noSuchProductInPackage(String, [String])
    case selectedProductIsExecutable(String)
    case couldNotResolvePackage(SubprocessResult)
    case couldNotFindToolchainPath(SubprocessResult)
    
    var description: String {
        switch self {
        case .userSpecifiedHelp: ""
        case let .tooManyOptions(kind): "Must pass only one \(kind.options) option."
        case let .optionRequiresArgument(kind): "\(kind.options) option requires an argument."
        case let .invalidArgumentForOption(kind): "Invalid argument for \(kind.options). Valid values are \(kind.validValues)."
        case let .mustPassOption(kind): "Must pass a \(kind.options) option."
        case let .unknownArgument(x): "Unknown argument \(x)"
            
        case .noConfigurationInBuildDirectory: "No configuration directory was found within the build directory.\nYou must run `swift build` before `swift package build-vanilla-openusd-plugin`"
        case .mustSelectConfigurationWhenBuildDirectoryHasMultipleConfigurations: "Multiple configuration directories were found within the build directory.\nUse -c or --configuration to select one."
            
        case .outputDirExistsButForceNotPassed: "Output directory already exists. Remove it or pass --force to overwrite it."
        case let .couldntCreateOutputDirectory(x): "Couldn't create output directory. You might need to pass --allow-writing-to-directory '\(x.path(percentEncoded: false))' to `swift package`."
        case let .couldntCreateTempDirectory(x): "Couldn't create temp directory '\(x.path(percentEncoded: false))'."
        case .mustSelectProductWhenPackageHasMultipleLibraryProducts: "Package contains multiple library products.\nPass --product <package-name> to select the product to build."
        case .couldNotFindDylib: "Could not find dylib after invoking swift build."
            
        case let .noSuchProductInPackage(product, products): "No such product '\(product)'. Available products are: \(products.joined(separator: ", "))."
            
        case let .selectedProductIsExecutable(product): "Product '\(product)' is an executable. Select a library product instead."
            
        case let .couldNotResolvePackage(x): "`swift package resolve` returned with non-zero \(x.exitCode).\nConsider running `swift package resolve --scratch-path .build/plugins/build-vanilla-openusd-plugin/outputs` first, or `swift package --disable-sandbox build-vanilla-openusd-plugin <args>`"
            
        case let .couldNotFindToolchainPath(x): "`xcrun --show-toolchain-path` returned with an invalid result."
        }
    }
}

extension Driver {
    static func run(context: PluginContext, arguments: [String]) async throws {
        do {
            var driver = try Driver(context: context, arguments: arguments)
            
            try driver.createOutputDirectory()
            try await driver.linkIfNeeded()
            try driver.copyIntoOutputDirectory()
            try await driver.fixLoadCommands()
            
            print(#"Success! To use, set `PXR_PLUGINPATH_NAME="\#(driver.args.outputDirectory.resolvingSymlinksInPath().path(percentEncoded: false)):$PXR_PLUGINPATH_NAME"` before running commands that use OpenUSD"#)
        } catch DriverError.userSpecifiedHelp {
            // pass
        } catch {
            throw error
        }
    }
}

struct Driver {
    var args: ArgParse

    init(context: PluginContext, arguments: [String]) throws {
        self.args = try ArgParse(context: context, arguments: arguments)
    }

    mutating func createOutputDirectory() throws {
        if FileManager.default.fileExists(atPath: args.outputDirectory.path(percentEncoded: false)) && !args.force {
            throw DriverError.outputDirExistsButForceNotPassed(args.outputDirectory)
        }
        
        do {
            if FileManager.default.fileExists(atPath: args.outputDirectory.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: args.outputDirectory)
            }
            try FileManager.default.createDirectory(at: args.outputDirectory, withIntermediateDirectories: true)
        } catch {
            throw DriverError.couldntCreateOutputDirectory(args.outputDirectory)
        }

        do {
            if !FileManager.default.fileExists(atPath: args.scratchPath.path(percentEncoded: false)) {
                try FileManager.default.createDirectory(at: args.scratchPath, withIntermediateDirectories: true)
            }
        } catch {
            throw DriverError.couldntCreateTempDirectory(args.scratchPath)
        }
    }
    

    func linkIfNeeded() async throws {
        // clang++ **.o -o PRODUCT.dylib -Xlinker -FBUILD_DIR -Xlinker -weak_framework -Xlinker Usd_* -dynamiclib
        
        let dylib = args.buildDirectory.appending(path: "lib\(args.productName).dylib")
        if FileManager.default.fileExists(atPath: dylib.path(percentEncoded: false)) {
            // `swift build` produced a dylib, so the product must have been a `.dynamic` library,
            // and we don't need to do anything.
            try FileManager.default.copyItem(at: dylib, to: args.scratchPath.appending(path: dylib.lastPathComponent))
            return
        }
        // `swift build` didn't produce a dylib, so we need to link things ourselves
        
        // todo: handle static libraries correctly
        
        var arguments = [String]()
        // **.o
        func addObjectFilesRecursively(_ dir: URL) throws {
            var isDirectory: ObjCBool = false
            
            guard FileManager.default.fileExists(atPath: dir.path(percentEncoded: false), isDirectory: &isDirectory) else { return }
            guard isDirectory.boolValue else { return }
            
            let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            for file in contents {
                if file.lastPathComponent.hasSuffix(".o") {
                    arguments.append(file.path(percentEncoded: false))
                }
                try addObjectFilesRecursively(file)
            }

        }
        for targetName in args.selectiveRecursiveTargetNames {
            try addObjectFilesRecursively(args.buildDirectory.appending(path: "\(targetName).build"))
        }
        arguments += ["-dynamiclib", "-o", args.scratchPath.appending(path: dylib.lastPathComponent).path(percentEncoded: false)]
        arguments += ["-Xlinker", "-F", "-Xlinker", args.buildDirectory.path(percentEncoded: false)]
        // -Xlinker -weak_framework -Xlinker *.framework
        for file in try FileManager.default.contentsOfDirectory(at: args.buildDirectory.resolvingSymlinksInPath(), includingPropertiesForKeys: nil) {
            if file.lastPathComponent.hasSuffix(".framework") {
                arguments += ["-Xlinker", "-weak_framework", "-Xlinker", file.deletingPathExtension().lastPathComponent]
            }
        }
        
        if args.shouldLinkAgainstSwift {
            let proc = try await runSubprocess(executableName: "xcrun", arguments: ["--show-toolchain-path"],
                                                        printStdout: false, printStderr: true, check: true)
            guard let toolchainPath = proc.stdout.components(separatedBy: .newlines).first else {
                throw DriverError.couldNotFindToolchainPath(proc)
            }
            
            arguments += ["-Xlinker", "-L", "-Xlinker", "\(toolchainPath)/usr/lib/swift/macosx"]
            arguments += ["-Xlinker", "-l", "-Xlinker", "swiftCxx",
                          "-Xlinker", "-l", "-Xlinker", "swiftCxxStdlib"]
        }
        
        _ = try await runSubprocess(
            executableName: "clang++",
            arguments: arguments,
            printStdout: true,
            printStderr: true,
            check: true
        )
    }
    
    func copyIntoOutputDirectory() throws {
        let dylib = args.scratchPath.appending(path: "lib\(args.productName).dylib")
                        
        do {
            try FileManager.default.copyItem(at: dylib, to: args.outputDirectory.appending(path: dylib.lastPathComponent))
        } catch {
            throw DriverError.couldNotFindDylib
        }
        
        for file in try FileManager.default.contentsOfDirectory(at: args.buildDirectory.resolvingSymlinksInPath(), includingPropertiesForKeys: nil) {
            guard file.lastPathComponent.hasSuffix(".bundle") else { continue }
            try FileManager.default.copyItem(at: file, to: args.outputDirectory.appending(path: file.lastPathComponent))
        }
                
        let topPlugInfoJsonContents = """
        {
            "Includes": [
                "*.bundle/plugInfo_vanilla.json"
            ]
        }
        """
        try topPlugInfoJsonContents.write(to: args.outputDirectory.appending(path: "plugInfo.json"), atomically: true, encoding: .utf8)
    }
    
    func fixLoadCommands() async throws {
        // This is required for vanilla `usdview` even if the user weak-links everything, otherwise it just segfaults
        
        let proc = try await runSubprocess(
            executableName: "otool",
            arguments: ["-L", args.outputDirectory.appending(path: "lib\(args.productName).dylib").path(percentEncoded: false)],
            printStdout: false,
            printStderr: true,
            check: true
        )
                
        let otoolLines = proc.stdout
            .components(separatedBy: .newlines)
            .dropFirst() // first line is the LC_ID_DYLIB, ie ourselves and not someone we link against
        
        var toInstallNameTool = [String]()
        var shouldWarnAboutNotWeakLinked = [String]()
        
        for line in otoolLines {
            // extract the names of rpath'd frameworks
            guard let match = line.firstMatch(of: #/@rpath/([^/]+)\.framework/[^/]+ \(compati/#) else { continue }
            toInstallNameTool.append(String(match.output.1))
            if !line.hasSuffix(", weak)") {
                shouldWarnAboutNotWeakLinked.append(String(match.output.1))
            }
        }
        
        func computeOldName(_ name: some StringProtocol) -> String {
            return "@rpath/\(name).framework/\(name)"
        }
        
        func computeNewName(_ name: some StringProtocol) -> String {
            var result = String(name)
            if result.starts(with: "Usd_") {
                result = String(result.dropFirst(4))
                result = result.first!.uppercased() + String(result.dropFirst())
                result = "usd_" + result
            }
            if ["usdShaders", "sdrGlslfx", "hdStorm", "hioImageIO", "hioAvif", "hioOpenEXR"].contains(result) {
                result = "@rpath/\(result).dylib"
            } else {
                result = "@rpath/lib\(result).dylib"
            }
            return result
        }
        
        for x in toInstallNameTool {
            let oldName = computeOldName(x)
            let newName = computeNewName(x)
            
            // print("install_name_tool -change \(oldName) \(newName) \(args.outputDirectory.appending(path: "lib\(args.productName).dylib").path(percentEncoded: false))")
            try await runSubprocess(
                executableName: "install_name_tool",
                arguments: ["-change", oldName, newName, args.outputDirectory.appending(path: "lib\(args.productName).dylib").path(percentEncoded: false)],
                printStdout: false,
                printStderr: true,
                check: true
            )
        }
        
        print("")
        for x in shouldWarnAboutNotWeakLinked {
            print("Warning! '\(x)' is not weak-linked, plugin may not be compatible with vanilla Usd installations.")
        }
        if !shouldWarnAboutNotWeakLinked.isEmpty {
            print(#"Use `linkerSettings: [.unsafeFlags(["-Xlinker", "-weak_framework", "-Xlinker", "{FRAMEWORK_NAME}"])]` in your Package.swift to weakly link frameworks"#)
        }
    }
}
