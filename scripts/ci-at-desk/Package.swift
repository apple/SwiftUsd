// swift-tools-version: 6.1
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


import PackageDescription

#if os(macOS)
let excludeDir = [String]()
#else
let excludeDir = ["UI"]
#endif

let package = Package(
    name: "ci-at-desk",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "WorkflowDescription", targets: ["WorkflowDescription"]),
        .library(name: "WorkflowRunning", targets: ["WorkflowRunning"]),
        .executable(name: "ci-at-desk", targets: ["ci-at-desk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.1"),
    ],
    targets: [
        .target(name: "WorkflowDescription",
                dependencies: [
                    .product(name: "Logging", package: "swift-log"),
                ]),
        .target(name: "WorkflowRunning",
                dependencies: [
                    "WorkflowDescription",
                    .product(name: "Subprocess", package: "swift-subprocess"),
                    .product(name: "Yams", package: "Yams"),
                ]),
        
            .executableTarget(
                name: "ci-at-desk",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    "WorkflowRunning"
                ],
                exclude: excludeDir,
            ),
    ]
)
