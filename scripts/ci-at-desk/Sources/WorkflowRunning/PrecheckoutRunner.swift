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
import Logging
import WorkflowDescription
import Subprocess
import System

/// Small runner for "precheckouts", i.e. cloning and checking out
/// git repositories before the bulk of workflow running begins
internal enum PrecheckoutRunner {
    /*
     example precheckouts section in yaml:
     ```
     precheckouts:
     - remote: git@github.com:apple/SwiftUsd
       ref: 6.1.0
       path: precheckouts/SwiftUsd
     - remote: git@github.com:apple/SwiftUsd-Tests
       ref: 6.1.0
       path: precheckouts/SwiftUsd-Tests
     ```
     */
    
    static func run(yamlConfig: YamlConfig, logger: Logger) async throws {
        // Important: don't use `run() start` and `run() end` in the logs,
        // because that confuses the UI which searches for those strings for measuring
        // run times
        logger.trace("PrecheckoutRunner.run start")
        defer { logger.trace("PrecheckoutRunner.run end") }

        for (i, p) in yamlConfig.precheckouts.enumerated() {
            logger.debug("Processing precheckout \(p.remote) (\(i + 1) of \(yamlConfig.precheckouts.count))")

            if FileManager.default.fileExists(atPath: p.path.absoluteURL.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: p.path)
            }

            logger.info("git clone '\(p.remote)' '\(p.path.absoluteURL.path(percentEncoded: false))' --depth 1 --revision '\(p.ref)'")
            let cloneResult = try await Subprocess.run(
                .name("git"),
                arguments: ["clone", p.remote, p.path.absoluteURL.path(percentEncoded: false),
                            "--depth", "1", "--revision", p.ref],
                output: .string(limit: 65536),
                error: .combinedWithOutput,
            )
            guard cloneResult.terminationStatus.isSuccess else {
                logger.error("Failed to clone: \(cloneResult.standardOutput ?? "")")
                throw PrecheckoutRunnerError.clone(cloneResult.terminationStatus)
            }            
        }
    }
    
    enum PrecheckoutRunnerError: Error {
        case clone(TerminationStatus)
        case checkout(TerminationStatus)
    }
}
