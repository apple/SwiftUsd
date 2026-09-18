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
import Subprocess
import System
import ArgumentParser

class Driver {
    init(args: Args) {
        self.args = args
        self.builtPluginDirectory = args.tempDir.appending(path: "plugin")
    }
    var args: Args
    
    var filesToTest: [URL] = []
    var builtPluginDirectory: URL
    
    func computeFilesToTest() throws {
        let knownInvalidOpenUSDFiles = computeKnownInvalidOpenUSDFiles()
        
        for tree in [resourcesURL()] + args.additionalTrees {
            guard let enumerator = FileManager.default.enumerator(at: tree, includingPropertiesForKeys: nil) else { return }
            var thisBatch = [URL]()
            for case let item as URL in enumerator {
                guard item.pathExtension.hasPrefix("usd") else { continue }
                guard !item.lastPathComponent.starts(with: "SKIP") else { continue }
                
                if !args.include.isEmpty {
                    var wasInInclude = false
                    for x in args.include {
                        if item.absoluteString.contains(x) {
                            wasInInclude = true
                            break
                        }
                    }
                    if !wasInInclude { continue }
                }
                
                if !args.exclude.isEmpty {
                    var wasInExclude = false
                    for x in args.exclude {
                        if item.absoluteString.contains(x) {
                            wasInExclude = true
                            break
                        }
                    }
                    if wasInExclude { continue }
                }
                
                var isKnownInvalidOpenUSDFile = false
                for x in knownInvalidOpenUSDFiles {
                    if item.absoluteString.contains(x) {
                        isKnownInvalidOpenUSDFile = true
                        continue
                    }
                }
                if isKnownInvalidOpenUSDFile { continue }
                
                thisBatch.append(item.absoluteURL)
            }
            thisBatch.sort(using: KeyPathComparator(\.path))
            filesToTest.append(contentsOf: thisBatch)
        }
        
        if args.shuffleTests {
            filesToTest.shuffle()
        }
    }
    
    func buildPlugin() async throws {
        let pluginRepoPath = args.plugin.path(percentEncoded: false)
        let builtPluginPath = builtPluginDirectory.path(percentEncoded: false)
        
        if args.verbose {
            print("cd \(pluginRepoPath) && swift build")
        }
        try await Subprocess.run(
            .name("swift"),
            arguments: ["build"],
            workingDirectory: FilePath(args.plugin),
            output: .currentStandardOutput,
            error: .currentStandardError,
        )
        .check("swift build")
        
        
        if args.verbose {
            print("cd \(pluginRepoPath) && swift package build-vanilla-openusd-plugin -o \(builtPluginPath)")
        }
        try await Subprocess.run(
            .name("swift"),
            arguments: ["package", "build-vanilla-openusd-plugin", "-o", builtPluginPath],
            workingDirectory: FilePath(args.plugin),
            output: .currentStandardOutput,
            error: .currentStandardError,
        ).check("swift package build-vanilla-openusd-plugin -o \(builtPluginPath)")
    }
    
    func run() async throws {
        
        try computeFilesToTest()
        
        if args.listTestsOnly {
            for file in filesToTest {
                print(file.absoluteURL.path(percentEncoded: false))
            }
            print("\n\(filesToTest.count) tests")
            return
        }
        
        if FileManager.default.fileExists(atPath: args.tempDir.path(percentEncoded: false)) {
            try FileManager.default.removeItem(at: args.tempDir)
        }
        try FileManager.default.createDirectory(at: args.tempDir, withIntermediateDirectories: true)
                
        try await buildPlugin()
        
        try await runTestsInParallel()
    }
    
    func runTestsInParallel() async throws {
        let (nTests, failures) = try await withThrowingTaskGroup(of: TestOneResult.self) {
            [args, filesToTest, builtPluginDirectory] taskGroup in
            
            var i = 0
            func launchTask() {
                taskGroup.addTask { [i] in
                    await test_one(args: args, tempDir: args.tempDir.appending(path: String(i)), file: filesToTest[i], builtPluginDir: builtPluginDirectory)
                    
                }
                i += 1
            }
            
            while i < min(filesToTest.count, args.jobs) {
                launchTask()
            }
            
            var failures = [URL]()
            var nTests = 0
            for try await child in taskGroup {
                guard failures.isEmpty || !args.stopOnFirstFailure else { continue }
                
                nTests += 1
                let formattedDuration = String(format: "%.2f", child.duration)
                print("\(args.verbose ? "\n" : "")Tested \(child.file.path(percentEncoded: false)) (\(formattedDuration)s) (\(nTests)/\(filesToTest.count))")
                if args.verbose || !child.success {
                    for l in child.output where !l.isEmpty {
                        print(l)
                    }
                }
                if !child.success {
                    failures.append(child.file)
                }
                
                if failures.count > 0 && args.stopOnFirstFailure {
                    taskGroup.cancelAll()
                    break
                } else if i < filesToTest.count {
                    launchTask()
                }
            }
            
            return (nTests, failures)
        }
        
        if !failures.isEmpty {
            print("\nFailures:")
            for f in failures {
                print(f.path(percentEncoded: false))
            }
        }
        
        print("\nSummary: \(nTests - failures.count) out of \(nTests) tests passed")
        throw ExitCode(failures.count > 0 ? 1 : 0)
    }
}




