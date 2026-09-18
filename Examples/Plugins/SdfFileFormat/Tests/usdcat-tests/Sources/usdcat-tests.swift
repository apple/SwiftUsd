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
import ArgumentParser
import Subprocess
import System

@main
struct Args: AsyncParsableCommand {
    @Flag(help: "Show verbose output")
    var verbose: Bool = false
    
    @Option(help: "Temporary directory to use",
            transform: URL.init(fileURLWithPath:))
    var tempDir: URL = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    
    @Option(help: "Only run tests that match these files")
    var include: [String] = []
    
    @Option(help: "Don't run tests that match these files")
    var exclude: [String] = []
    
    @Option(help: "Also test any USD files in these trees",
            transform: URL.init(fileURLWithPath:))
    var additionalTrees: [URL] = []
    
    @Flag(help: "List the tests that would be run, and exit")
    var listTestsOnly: Bool = false
    
    @Flag(help: "Stop testing after the first test failure")
    var stopOnFirstFailure: Bool = false
    
    @Flag(help: "Run tests in a random order")
    var shuffleTests: Bool = false
    
    @Option(help: "Run up to this many jobs in parallel")
    var jobs: Int = ProcessInfo.processInfo.activeProcessorCount * 2
    
    @Argument(help: "Plugin to build and test",
              transform: URL.init(fileURLWithPath:))
    var plugin: URL
    
    func run() async throws {
        try await Driver(args: self).run()
    }
}
