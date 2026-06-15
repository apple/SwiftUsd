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

// Dedicated argument parsing for build-vanilla-openusd-plugin,
// because we can't use swift-argument-parser and PackagePlugin.ArgumentExtractor
// leaves something to be desired
struct ArgParse {
    // Fully resolved/parsed args
    var force: Bool = false
    var outputDirectory: URL!
    var productName: String = ""
    var configuration: String = ""
    
    // Derived information that isn't really from the CLI
    var context: PluginContext
    var packageName: String = ""
    var selectiveRecursiveTargetNames: [String] = []
    var hadExplicitProductName = false
    var shouldLinkAgainstSwift = false
    
    var scratchPath: URL { context.pluginWorkDirectoryURL.appending(path: ".tmp") }
    var buildDirectory: URL { packagePath.appending(components: ".build", configuration) }
    var packagePath: URL { context.package.directoryURL }
    
    init(context: PluginContext, arguments: [String]) throws {
        self.context = context
        try parseRawArgs(arguments: arguments)
        try validateArgs()
        try deriveRemainingProperties()
    }
    
    func printHelpAndThrow(_ driverError: DriverError) throws {
        let ansiPrefix = "\u{001B}[1m"
        let ansiSuffix = "\u{001B}[0m"
                
        print("""
        usage: build-vanilla-openusd-plugin [OPTIONS]
        
        Build this Swift Package as an OpenUSD plugin that can be used with vanilla 
        OpenUSD builds. 
        
        \(ansiPrefix)Important:\(ansiSuffix) You must run `swift build` first. 
                
        Options: 
          -h, --help                      Print this help message and exit.
        
          -o, --output <dir>              Write the plugin to a custom directory. You 
                                          may also need to pass it to 
                                          `swift package --allow-writing-to-directory <dir>`.
        
          --force                         If the custom output directory exists, remove 
                                          it before proceeding.
        
          --product                       Select a specific product from the package to 
                                          build. Optional if the product has a single 
                                          library product. 
        
          -c, --configuration <config>    Build with configuration (values: debug, 
                                          release).
        
        """)
        
        throw driverError
    }
}

extension ArgParse {
    private mutating func parseRawArgs(arguments: [String]) throws {
        var i = 0
        while i < arguments.count {
            switch arguments[i] {
            case "-h", "-help", "--help":
                try printHelpAndThrow(.userSpecifiedHelp)
                
            case "--force": force = true; i += 1
                
            case "-o", "--output":
                if outputDirectory != nil { try printHelpAndThrow(.tooManyOptions(.output)) }
                if i + 1 >= arguments.count { try printHelpAndThrow(.optionRequiresArgument(.output)) }
                outputDirectory = URL(fileURLWithPath: arguments[i + 1]); i += 2
                
            case "--product":
                if !productName.isEmpty { try printHelpAndThrow(.tooManyOptions(.product)) }
                if i + 1 >= arguments.count { try printHelpAndThrow(.optionRequiresArgument(.product)) }
                productName = arguments[i + 1]; i += 2
                hadExplicitProductName = true
                
            case "-c", "--configuration":
                if !configuration.isEmpty { try printHelpAndThrow(.tooManyOptions(.configuration)) }
                if i + 1 >= arguments.count { try printHelpAndThrow(.optionRequiresArgument(.configuration)) }
                if arguments[i + 1] != "debug" && arguments[i + 1] != "release" { try printHelpAndThrow(.invalidArgumentForOption(.configuration)) }
                configuration = arguments[i + 1]; i += 2
                
            default:
                try printHelpAndThrow(.unknownArgument(arguments[i]))
            }
        }
    }
    
    private mutating func validateArgs() throws {
        if productName.isEmpty {
            let libraryProducts = context.package.products(ofType: LibraryProduct.self)
            if libraryProducts.count == 1 {
                productName = context.package.products[0].name
            } else {
                try printHelpAndThrow(.mustSelectProductWhenPackageHasMultipleLibraryProducts)
            }
        } else {
            let matchingProducts = (try? context.package.products(named: [productName])) ?? []
            if matchingProducts.isEmpty {
                throw DriverError.noSuchProductInPackage(productName, context.package.products.map(\.name))
            }
            if matchingProducts[0] is ExecutableProduct {
                throw DriverError.selectedProductIsExecutable(productName)
            }
        }
        
        if configuration.isEmpty {
            var contents = try FileManager.default.contentsOfDirectory(at: buildDirectory, includingPropertiesForKeys: nil)
            contents = contents.filter { $0.lastPathComponent == "debug" || $0.lastPathComponent == "release" }
            if contents.count == 0 {
                try printHelpAndThrow(.noConfigurationInBuildDirectory)
            } else if contents.count == 2 {
                try printHelpAndThrow(.mustSelectConfigurationWhenBuildDirectoryHasMultipleConfigurations)
            } else {
                configuration = contents[0].lastPathComponent
            }
        }
        
        if outputDirectory == nil {
            force = true
            outputDirectory = context.pluginWorkDirectoryURL.appending(path: "\(productName).usdplugin")
        }
    }
    
    private mutating func deriveRemainingProperties() throws {
        packageName = context.package.displayName
        
        selectiveRecursiveTargetNames = []
        for target in try context.package.products(named: [productName])[0].targets {
            handleTargetDependency(superTarget: nil, currentTarget: target)
        }
        
        selectiveRecursiveTargetNames = Array(Set(selectiveRecursiveTargetNames))
    }
    
    // We want to find the list of targets we should link with,
    // recursively, but exclude OpenUSD and its dependencies under
    // some circumstances
    private mutating func handleTargetDependency(superTarget: (any Target)?, currentTarget: any Target) {
        if currentTarget is SwiftSourceModuleTarget { shouldLinkAgainstSwift = true }
        
        switch currentTarget.name {
        case "OpenUSD":
            if let superTarget {
                if superTarget is SwiftSourceModuleTarget {
                    // Only Swift targets get to link against SwiftUsd
                    selectiveRecursiveTargetNames.append("OpenUSD")
                    selectiveRecursiveTargetNames.append("_OpenUSD_SwiftBindingHelpers")
                    return
                } else if let clangTarget = superTarget as? ClangSourceModuleTarget {
                    // Clang targets can link against _OpenUSD_SwiftBindingHelpers if
                    // they have a `swiftUsd/swiftUsd.h` include directive
                    var hadSwiftUsdIncludeDirective = false
                    fileLoop: for file in clangTarget.sourceFiles {
                        guard file.type == .source || file.type == .header else { continue }
                        guard let s = try? String(contentsOf: file.url, encoding: .utf8) else { continue }
                        for l in s.components(separatedBy: .newlines) {
                            if l.firstMatch(of: #/#\s*include\s+["<]swiftUsd/swiftUsd\.h[">]\s*/#) != nil {
                                hadSwiftUsdIncludeDirective = true
                                break fileLoop
                            }
                        }
                    }
                    
                    if hadSwiftUsdIncludeDirective {
                        selectiveRecursiveTargetNames.append("_OpenUSD_SwiftBindingHelpers")
                    }
                    return
                } else {
                    // The target isn't Swift and it doesn't use `swiftUsd/swiftUsd.h`, so
                    // it doesn't need to link against anything added by SwiftUsd that isn't
                    // part of vanilla OpenUSD
                    return
                }
            }
            
        case "_OpenUSD_SwiftBindingHelpers":
            // Users shouldn't be directly dependent on this
            return
            
        case "_OpenUSD_MacroImplementations":
            // Users shouldn't be dependent on this
            return
            
        case "generate-plug-info-json":
            // Users can depend on this but shouldn't link against it
            return
            
        case "build-vanilla-openusd-plugin":
            // Users shouldn't be dependent on this
            return
            
        default:
            selectiveRecursiveTargetNames.append(currentTarget.name)
            
            for dependency in currentTarget.dependencies {
                switch dependency {
                case let .product(product):
                    for subTarget in product.targets {
                        handleTargetDependency(superTarget: currentTarget, currentTarget: subTarget)
                    }
                case let .target(subTarget):
                    handleTargetDependency(superTarget: currentTarget, currentTarget: subTarget)
                    
                @unknown default:
                    print("Warning! Unknown target dependency \(dependency), linking may fail")
                }
            }
        }
    }
}
