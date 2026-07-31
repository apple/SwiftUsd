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
    name: "hioPpm",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "hioPpm",
            targets: ["hioPpm"]
        ),
    ],
    dependencies: [
        .package(path: "SwiftUsd")
        // We use a symlink to the SwiftUsd repo for this example, 
        // but typically you'd do something like this:
        // .package(url: "https://github.com/apple/SwiftUsd", from: "8.1.0"),
    ],
    targets: [        
        .target(
            name: "hioPpm",
            dependencies: [
                .product(name: "OpenUSD", package: "SwiftUsd")
            ],
            resources: [
                .copy("plugInfo.json")
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
            ] + enableExperimentalFeature_SymbolLinkageMarkers_ifNeeded(),
            plugins: [
                .plugin(name: "generate-plug-info-json", package: "SwiftUsd")
            ],
        ),
    ],
    cxxLanguageStandard: .gnucxx17
)

// Swift 6.3 adds the `@used` and `@section` attributes, but Swift 6.1 and Swift 6.2
// can use the `@_used` and `@_section` underscored attributes with `SymbolLinkageMarkers` enabled
func enableExperimentalFeature_SymbolLinkageMarkers_ifNeeded() -> [SwiftSetting] {
    #if compiler(<6.3)
    [.enableExperimentalFeature("SymbolLinkageMarkers")]
    #else
    []
    #endif
}
