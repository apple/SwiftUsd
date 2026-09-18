// swift-tools-version: 6.2
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

// This package tests whether an SdfFileFormat plugin can losslessly roundtrip USD files. 

let package = Package(
    name: "usdcat-tests",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "usdcat-tests", targets: ["usdcat-tests"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.4.0"),
    ],
    targets: [
        .executableTarget(name: "usdcat-tests",
                          dependencies: [
                            .product(name: "Subprocess", package: "swift-subprocess"),
                            .product(name: "ArgumentParser", package: "swift-argument-parser"),
                          ]
        ),
    ],
)
