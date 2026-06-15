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

import PackagePlugin
import Foundation

/// Makes the source for a shell script that transforms the `plugInfo.json` file into multiple platform-specific `plugInfo_foo.json` files
func makeShellSource(templateUrl: URL, outputDirectory: URL, packageName: String, targetName: String) -> (String, [String : String]) {
    func escapeSlashes(_ x: String) -> String { x.replacingOccurrences(of: "/", with: "\\/") }
    
    // We want to treat the templateUrl, outputDirectory, packageName, and targetName as raw strings, but they might
    // not be sanitized. So rather than try to escape any shell characters, we put them into the environment and then
    // expand them within the script.
    var environment = [String : String]()
    environment["SWIFTUSD_GPIJ_ORIGINAL_FILE"] = templateUrl.path(percentEncoded: false)
    
    environment["SWIFTUSD_GPIJ_MACOS_FILE"] = outputDirectory.appending(path: "plugInfo_macOS.json").path(percentEncoded: false)
    environment["SWIFTUSD_GPIJ_MACOS_LIBRARY"] = ""
    environment["SWIFTUSD_GPIJ_MACOS_RESOURCE"] = escapeSlashes("\(packageName)_\(targetName).bundle/Contents/Resources")
    environment["SWIFTUSD_GPIJ_MACOS_ROOT"] = escapeSlashes("../../..")
    
    environment["SWIFTUSD_GPIJ_IOS_FILE"] = outputDirectory.appending(path: "plugInfo_iOS.json").path(percentEncoded: false)
    environment["SWIFTUSD_GPIJ_IOS_LIBRARY"] = ""
    environment["SWIFTUSD_GPIJ_IOS_RESOURCE"] = escapeSlashes("\(packageName)_\(targetName).bundle")
    environment["SWIFTUSD_GPIJ_IOS_ROOT"] = escapeSlashes("..")
    
    environment["SWIFTUSD_GPIJ_VANILLA_FILE"] = outputDirectory.appending(path: "plugInfo_vanilla.json").path(percentEncoded: false)
    environment["SWIFTUSD_GPIJ_VANILLA_LIBRARY"] = escapeSlashes("lib\(targetName).dylib")
    environment["SWIFTUSD_GPIJ_VANILLA_RESOURCE"] = escapeSlashes("\(packageName)_\(targetName).bundle")
    environment["SWIFTUSD_GPIJ_VANILLA_ROOT"] = escapeSlashes("..")
        
    // Make sure to always quote the environment variable expansions, including in the sed commands.
    // Use a double quoted command string for sed so we can expand environment variables within it
    let script = """
    cat "$SWIFTUSD_GPIJ_ORIGINAL_FILE" |\
    sed -E "s/@PLUG_INFO_LIBRARY_PATH@/$SWIFTUSD_GPIJ_MACOS_LIBRARY/" |\
    sed -E "s/@PLUG_INFO_RESOURCE_PATH@/$SWIFTUSD_GPIJ_MACOS_RESOURCE/" |\
    sed -E "s/@PLUG_INFO_ROOT@/$SWIFTUSD_GPIJ_MACOS_ROOT/" >\
    "$SWIFTUSD_GPIJ_MACOS_FILE"

    cat "$SWIFTUSD_GPIJ_ORIGINAL_FILE" |\
    sed -E "s/@PLUG_INFO_LIBRARY_PATH@/$SWIFTUSD_GPIJ_IOS_LIBRARY/" |\
    sed -E "s/@PLUG_INFO_RESOURCE_PATH@/$SWIFTUSD_GPIJ_IOS_RESOURCE/" |\
    sed -E "s/@PLUG_INFO_ROOT@/$SWIFTUSD_GPIJ_IOS_ROOT/" >\
    "$SWIFTUSD_GPIJ_IOS_FILE"

    cat "$SWIFTUSD_GPIJ_ORIGINAL_FILE" |\
    sed -E "s/@PLUG_INFO_LIBRARY_PATH@/$SWIFTUSD_GPIJ_VANILLA_LIBRARY/" |\
    sed -E "s/@PLUG_INFO_RESOURCE_PATH@/$SWIFTUSD_GPIJ_VANILLA_RESOURCE/" |\
    sed -E "s/@PLUG_INFO_ROOT@/$SWIFTUSD_GPIJ_VANILLA_ROOT/" >\
    "$SWIFTUSD_GPIJ_VANILLA_FILE"
    """
    
    return (script, environment)
}

@main
struct GeneratePlugInfoJson: BuildToolPlugin {
    func createBuildCommands(context: PluginContext,
                             target: any Target) throws -> [Command] {
        
        guard let sourceModule = target.sourceModule else {
            Diagnostics.error("generate-plug-info-json can only be used as a plugin on source module targets, but target '\(target.name)' is '\(type(of: target))'", file: nil, line: nil)
            return []
        }
        let plugInfoJsonList = sourceModule.sourceFiles(withSuffix: "plugInfo.json")
        guard plugInfoJsonList.count == 1, plugInfoJsonList.first!.type == .resource else {
            Diagnostics.error("generate-plug-info-json expects exactly one resource ending in plugInfo.json for the target that invokes it")
            return []
        }
        
        let executable = URL(fileURLWithPath: "/bin/sh")
        
        let templateUrl = plugInfoJsonList.first!.url
        
        let outputFileNames = [
            "plugInfo_vanilla.json",
            "plugInfo_iOS.json",
            "plugInfo_macOS.json"
        ]

        let outputUrls = outputFileNames.map { context.pluginWorkDirectoryURL.appending(path: $0) }
        
        let (shellSource, environment) = makeShellSource(
            templateUrl: templateUrl,
            outputDirectory: context.pluginWorkDirectoryURL,
            packageName: context.package.displayName,
            targetName: target.name,
        )
        
        return [
            .buildCommand(displayName: "generate-plug-info-json",
                          executable: executable,
                          arguments: ["-c", shellSource],
                          environment: environment,
                          inputFiles: [templateUrl],
                          outputFiles: outputUrls)
        ]
    }
}
