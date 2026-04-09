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
import WorkflowDescription
import WorkflowRunning
import Logging

/// Entry point for ci-at-desk
@main
struct CLIArgs: MainActorAsyncParsableCommand {
    @Argument(transform: URL.init(fileURLWithPath:)) var configFile: URL?
    @Option var consoleLogLevel: Logger.Level = .error
    
    @Flag var ui: Bool = false
    @Flag var readOnly: Bool = false

    mutating func run() async throws {
        ConsoleLogHandler.consoleLogLevel = consoleLogLevel
        
        #if os(macOS)
        if ui {
            InProcessLogNotificationHandler.enabled = true
            ci_at_desk_UI.initialConfigFile = configFile
            ci_at_desk_UI.readOnly = readOnly
            ci_at_desk_UI.main()
            return
        }
        #else
        if ui { throw ValidationError("--ui is only supported on macOS") }
        #endif
        if readOnly { throw ValidationError("--read-only is only supported with --ui") }
        
        guard let configFile else {
            throw ValidationError("configFile is required if not running in UI mode")
        }
        
        let success = try await WorkflowOrchestrator.run(configFile: configFile, workflows: Self.workflows)
        throw success ? ExitCode.success : ExitCode.failure
    }
}

// MARK: Workflow definitions
extension CLIArgs {
    static let workflows = [buildSwiftUsd, runTests, releaseNewVersion]
    
    static var buildSwiftUsd: Workflow {
        Workflow(
            id: "Build-SwiftUsd",
            jobs: [
                Job(id: "Define-Build-Matrix",
                    name: "Define build matrix",
                    outputs: ["matrix" : "${{ steps.matrix.outputs.matrix }}"],
                    steps: [
                        Step(name: "Sparse checkout repository code",
                             sparseCheckout: [".github/scripts"]),
                        
                        Step(name: "Define matrix",
                             id: "matrix",
                             run: "python3", "-u", "./.github/scripts/define-build-matrix.py",
                                  "--targets", "${{ inputs.build-targets }}"),
                    ]),
                
                Job(id: "Cache-cloning-OpenUSD-for-at-desk-builds",
                    if_: "${{ !skips.build-openusd }}",
                    steps: [
                        Step(name: "Sparse checkout repository code",
                             sparseCheckout: []),
                        
                        Step(name: "Cache cloning OpenUSD for at-desk-builds",
                             cache: .init(key: "openusd-source", path: "${{ github.workspace }}/openusd-source"),
                             run: "git", "clone", "https://github.com/PixarAnimationStudios/OpenUSD.git", "${{ github.workspace }}/openusd-source"),
                    ]),
                
                Job(id: "Build-OpenUSD",
                    if_: "${{ !skips.build-openusd }}",
                    name: "Build OpenUSD (${{ matrix.target }})",
                    needs: ["Define-Build-Matrix", "Cache-cloning-OpenUSD-for-at-desk-builds"],
                    env: [
                        "OPENUSD_REF" : "${{ inputs.openusd-ref }}",
                        "TARGET_PLATFORM" : "${{ matrix.target }}",
                        "OPENUSD_PATH" : "${{ github.workspace }}/openusd-source",
                        "SWIFTUSD_PATH" : "${{ runner.swiftusd-path }}",
                    ],
                    strategy: Job.Strategy(matrix: "${{ fromJson(needs.Define-Build-Matrix.outputs.matrix) }}"),
                    steps: [
                        Step(name: "Sparse checkout repository code",
                             sparseCheckout: [".github/scripts", "openusd-patch.patch"]),
                        
                        Step(name: "Cache cloning OpenUSD for at-desk-builds",
                             cache: .init(key: "openusd-source", path: "${{ github.workspace }}/openusd-source", requiresIndependentCopy: true),
                             run: "git", "clone", "https://github.com/PixarAnimationStudios/OpenUSD.git", "${{ github.workspace }}/openusd-source"),
                        
                        Step(name: "Compute cache key",
                             id: "compute-cache-key",
                             run: "python3", "-u", "./.github/scripts/compute-openusd-build-cache-key.py"),
                        
                        Step(name: "Build OpenUSD on cache miss",
                             cache: .init(key: "${{ steps.compute-cache-key.outputs.cache-key }}",
                                          path: "${{ github.workspace }}/openusd-builds/${{ matrix.target }}"),
                             run: "python3", "-u", "./.github/scripts/build-openusd.py"),
                        
                        Step(name: "Save OpenUSD build artifact",
                             if_: "${{ always() }}",
                             saveArtifact: .init(name: "openusd-builds-${{ github.run_id }}-${{ matrix.target }}",
                                                 path: "openusd-builds/${{ matrix.target }}")),
                    ]),
                
                Job(id: "Make-Swift-Package",
                    if_: "${{ !skips.make-swift-package }}",
                    name: "Make Swift Package",
                    needs: ["Build-OpenUSD"],
                    steps: [
                        Step(name: "Checkout repository code",
                             checkout: .swiftUsd),

                        Step(name: "Restore OpenUSD build artifacts",
                             if_: "${{ !skips.build-openusd }}",
                             restoreArtifact: .init(path: "openusd-builds",
                                                    pattern: "openusd-builds-${{ github.run_id }}-*")),
                        
                        Step(name: "Restore OpenUSD build artifacts when skipping building OpenUSD",
                             if_: "${{ skips.build-openusd }}",
                             sparseCheckout: ["openusd-builds"]),
                        
                        Step(name: "Clean make-swift-package",
                             run: "swift", "package", "--package-path", "./scripts/make-swift-package",
                             "clean"),

                        Step(name: "Run make-swift-package",
                             run: "swift", "run", "--package-path", "./scripts/make-swift-package",
                             "make-swift-package", "${{ github.workspace }}/openusd-builds/*", "--force"),
                        
                        Step(name: "Save package artifact",
                             saveArtifact: .init(name: "SwiftUsd-package-${{ github.run_id }}",
                                                 path: "SwiftUsd"))
                    ])
            ]
        )
    }
    
    static var runTests: Workflow {
        Workflow(
            id: "Run-Tests",
            jobs: [
                Job(id: "Build-SwiftUsd",
                    if_: "${{ !skips.make-swift-package }}",
                    name: "Build SwiftUsd",
                    workflow: buildSwiftUsd),
                
                Job(id: "Define-Test-Matrix",
                    name: "Define Test Matrix",
                    outputs: ["matrix": "${{ steps.matrix.outputs.matrix }}",
                              "max-parallel": "${{ steps.matrix.outputs.max-parallel }}"],
                    steps: [
                        Step(name: "Sparse checkout repository code",
                             sparseCheckout: [".github/scripts"]),
                        
                        Step(name: "Define matrix",
                             id: "matrix",
                             run: "python3", "-u", "./.github/scripts/define-test-matrix.py")
                    ]),
                
                Job(id: "Run-Tests-Once",
                    name: "Run tests (${{ matrix.target_platform }}, ${{ matrix.config }}, ${{ matrix.build_system }}, ${{ matrix.toolchain_provider }})",
                    needs: ["Build-SwiftUsd", "Define-Test-Matrix"],
                    env: [
                        "TARGET_PLATFORM": "${{ matrix.target_platform }}",
                        "XCODEBUILD_DESTINATION": "${{ matrix.xcodebuild_destination }}",
                        "BUILD_SYSTEM": "${{ matrix.build_system }}",
                        "TOOLCHAIN_PROVIDER": "${{ matrix.toolchain_provider }}",
                        "CONFIG": "${{ matrix.config }}",
                        "SWIFTUSD_REF": "${{ inputs.swiftusd-ref }}",
                        "OPENUSD_REF": "${{ inputs.openusd-ref }}",
                        "SWIFTUSD_TESTS_REF": "${{ inputs.swiftusd-tests-ref }}",
                        "GITHUB_RUN_ID": "${{ github.run_id }}",
                        "SWIFTUSD_TESTS_PATH": "${{ github.workspace }}/SwiftUsd-Tests",
                        "SWIFTUSD_PATH": "${{ github.workspace }}/SwiftUsd",
                        "RESULT_BUNDLE_PATH": "${{ github.workspace }}/SwiftUsd-Tests.xcresult",
                        "MATRIX_RESULT_PATH": "${{ github.workspace }}/matrix-result.json",
                    ],
                    strategy: Job.Strategy(failFast: false,
                                           maxParallel: "${{ fromJson(needs.Define-Test-Matrix.outputs.max-parallel) }}",
                                           matrix: ["include" : "${{ fromJson(needs.Define-Test-Matrix.outputs.matrix) }}"]),
                    continueOnError: true,
                    steps: [
                        Step(name: "Restore package artifact",
                             if_: "${{ !skips.make-swift-package }}",
                             restoreArtifact: .init(path: "SwiftUsd",
                                                    pattern: "SwiftUsd-package-${{ github.run_id }}",
                                                    requiresIndependentCopy: true)),
                        
                        Step(name: "Restore package artifact when skipping make-swift-package",
                             if_: "${{ skips.make-swift-package }}",
                             checkout: .swiftUsd),
                        
                        Step(name: "Check out unit tests",
                             checkout: .swiftUsd_tests),

                        Step(name: "Compute artifact name",
                             id: "compute-artifact-name",
                             run: "python3", "-u", "./.github/scripts/compute-test-artifact-name.py"),
                        
                        Step(name: "Build Tests",
                             timeout: .minutes(20),
                             run: "python3", "-u", "./.github/scripts/run-tests-helper.py", "build-tests"),
                        
                        Step(name: "Run Tests",
                             timeout: .minutes(15),
                             run: "python3", "-u", "./.github/scripts/run-tests-helper.py", "run-tests"),
                        
                        Step(name: "Save xcresult artifact",
                             if_: "${{ always() }}",
                             saveArtifact: .init(name: "${{ steps.compute-artifact-name.outputs.artifact_name }}",
                                                 path: "./SwiftUsd-Tests.xcresult",
                                                 allowNoFilesFound: true)),
                        
                        Step(name: "Save matrix result artifact",
                             if_: "${{ always() }}",
                             saveArtifact: .init(name: "matrix-result-${{ github.run_id }}-${{ steps.compute-artifact-name.outputs.artifact_name }}.json",
                                                 path: "./matrix-result.json")),
                    ]),
                
                Job(id: "Summarize-Test-Results",
                    if_: "${{ always() }}",
                    name: "Summarize Test Results",
                    needs: ["Run-Tests-Once"],
                    env: [
                        "MATRIX_RESULTS_PATH" : "${{ github.workspace }}/../matrix-results"
                    ],
                    steps: [
                        Step(name: "Sparse checkout repository code",
                             sparseCheckout: [".github/scripts"]),
                        
                        Step(name: "Restore matrix result artifacts",
                             restoreArtifact: .init(path: "../matrix-results",
                                                    pattern: "matrix-result-${{ github.run_id }}-*")),
                        
                        Step(name:"Summarize matrix results",
                             run: "python3", "-u", "./.github/scripts/summarize-test-matrix-results.py")
                    ])
            ]
        )
    }
    
    static var releaseNewVersion: Workflow {
        Workflow(id: "Release-New-Version",
                 jobs: [
                    Job(id: "Build-SwiftUsd",
                        name: "Build SwiftUsd",
                        workflow: buildSwiftUsd),
                    
                    Job(id: "Release-New-Version",
                        name: "Release New Version",
                        needs: ["Build-SwiftUsd"],
                        env: [
                            "SWIFTUSD_PATH" : "${{ runner.swiftusd-path }}",
                        ],
                        steps: [
                            Step(name: "Restore package artifact",
                                 restoreArtifact: .init(path: "SwiftUsd",
                                                        pattern: "SwiftUsd-package-${{ github.run_id }}",
                                                        requiresIndependentCopy: true)),
                            Step(name: "Add back git remote",
                                 sparseCheckout: [".git"]),
                            
                            Step(name: "Build symbol graphs",
                                 run: "swift", "run", "--package-path", "scripts/docc", "build-documentation"),
                            Step(name: "Check for documentation warnings",
                                 run: "swift", "run", "--package-path", "scripts/docc", "check-documentation"),
                            Step(name: "Update documentation",
                                 run: "swift", "run", "--package-path", "scripts/docc", "update-documentation"),
                            
                            Step(name: "Commit updated swift-package and documentation",
                                 run: "python3", "-u", "./.github/scripts/release-new-version.py", "${{ inputs.swiftusd-tag }}"),
                        ])
                 ])
    }
}

extension Logger.Level: @retroactive _SendableMetatype {}
extension Logger.Level: @retroactive ExpressibleByArgument {}

// MARK: MainActorAsyncParsableCommand

// In order for UI mode to launch properly, the call to
// `ci_at_desk_UI.main()` has to occur when there's a single
// thread in the process. Otherwise, open panels won't work
// and the current timestamp won't update in real time
@MainActor
protocol MainActorAsyncParsableCommand: AsyncParsableCommand {
    mutating func run() async throws
    static func main(_ arguments: [String]?) async
    static func main() async throws
}
extension MainActorAsyncParsableCommand {
    static func main(_ arguments: [String]?) async {
        do {
            var command = try parseAsRoot(arguments)
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }
    static func main() async throws {
        await Self.main(nil)
    }
}

