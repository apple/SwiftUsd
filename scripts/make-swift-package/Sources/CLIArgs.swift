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

import ArgumentParser
import Foundation

@main
struct CLIArgs: AsyncParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "make-swift-package",
                                                           abstract: "Utility for creating a Swift Package from one or more Usd builds.",
                                                           usage: "make-swift-package [OPTIONS] <usd-install> ...")
    
    enum SourceStrategy: String, ExpressibleByArgument, CaseIterable {
        case copy = "copy"
        case symlink = "symlink"
    }
    
    enum UsdInstallStrategy: String, ExpressibleByArgument, CaseIterable {
        case symlink = "symlink"
        case copyAndBundle = "copy-and-bundle"
        case copyWithoutBundling = "copy-without-bundling"
    }
    
    
    
    
    @Argument(help: ArgumentHelp("Uses the binaries at this Usd installation for the generated package.", valueName: "usd-install"),
              transform: URL.init(fileURLWithPath:))
    var usdInstalls: [URL]
    
    @Option(help: "Controls how the Usd installations are handled")
    var usdInstallStrategy: UsdInstallStrategy = {
        #if os(macOS)
        .copyAndBundle
        #else
        .symlink
        #endif
    }()
    
    @Option(name: .customLong("copy-plugins"),
            help: nil, // todo
            transform: URL.init(fileURLWithPath:))
    var copiedPlugins: [URL] = []
    
    @Option(name: .customLong("symlink-plugins"),
            help: nil, // todo
            transform: URL.init(fileURLWithPath:))
    var symlinkedPlugins: [URL] = []
    
    @Option(help: "Controls whether `SwiftUsd/source` is copied or symlinked into the generated package directory.")
    var sourceStrategy: SourceStrategy = .symlink
    
    @Option(help: """
    The directory to write the generated Swift Package to. 
    (default: ./swift-package with a hoisted package manifest)
    """, transform: URL.init(fileURLWithPath:))
    var generatedPackageDir: URL?

    // #warning("todo: Add --generate-package-in-place flag that's exclusive with --generated-package-dir, require one or the other")

    // #warning("todo: Add flag to preserve symlinks, OpenUSD build folders, xcframeworks in Libraries, most of package, but lets you add custom plugins without having to build openusd (just clone and run command to add your plugin)")
    
    @Option(help: """
    The directory to write zipped artifacts into. The generated package will depend on
    the artifacts by checksum
    """, transform: URL.init(fileURLWithPath:))
    var checksummedArtifactsDir: URL?
    
    @Option(help: """
    The online URL that the artifacts will be hosted from
    """)
    var artifactsHostingURL: String?
    
    
    
    
    
    
    mutating func validate() throws {
#if !os(macOS)
        if usdInstallStrategy == .copyAndBundle {
            throw ValidationError("--usd-install-strategy copy-and-bundle is only supported on Apple platforms.")
        }
#endif
        
        if !copiedPlugins.isEmpty || !symlinkedPlugins.isEmpty {
            throw ValidationError("Custom Usd plugins are not supported yet. Remove --copy-plugins and --symlink-plugins options.")
        }
        
#if !os(macOS)
        if checksummedArtifactsDir != nil || artifactsHostingURL != nil {
            throw ValidationError("Checksummed artifacts are only supported on Apple platforms.")
        }
#endif
        
        if (checksummedArtifactsDir != nil && artifactsHostingURL == nil) ||
            (checksummedArtifactsDir == nil && artifactsHostingURL != nil) {
            throw ValidationError("Must pass --checksummed-artifacts-dir and --artifacts-hosting-url together.")
        }
        
        if checksummedArtifactsDir != nil && usdInstallStrategy != .copyAndBundle {
            throw ValidationError("--checksummed-artifacts-dir requires --usd-install-strategy copy-and-bundle.")
        }
        
        if artifactsHostingURL != nil && !artifactsHostingURL!.hasSuffix("/") {
            artifactsHostingURL! += "/"
        }
        
#if !os(macOS)
        if usdInstalls.count > 1 {
            throw ValidationError("Multiple Usd installation directories are only supported on Apple platforms.")
        }
#endif
        
        if usdInstalls.count == 0 {
            throw ValidationError("Must specify at least one Usd install using --usd-installs.")
        }
        
        if sourceStrategy == .copy && generatedPackageDir == nil {
            throw ValidationError("--source-strategy copy requires --generated-package-dir.")
        }
    }
    
    mutating func run() async throws {
        try await SwiftPackage.run(cliArgs: self)
    }
}
