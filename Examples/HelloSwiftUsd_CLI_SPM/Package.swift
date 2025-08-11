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

let package = Package(
    name: "HelloSwiftUsd_SPM",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/SwiftUsd", from: "5.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "HelloSwiftUsd_SPM",
            dependencies: [.product(name: "OpenUSD", package: "SwiftUsd")],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
    ],
    cxxLanguageStandard: .gnucxx17
)
