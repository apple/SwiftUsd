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
import SwiftUsdDoccUtil

@main
struct UpdateDocumentation {
    static func main() async throws {
        try await ShellUtil.runCommandAndWait(arguments: [
            "xcrun", "docc", "convert",
            "--emit-lmdb-index",
            "--output-path", Driver.shared.doccArchiveURL,
            Driver.shared.doccCatalogURL,
            "--additional-symbol-graph-dir", Driver.shared.symbolGraphsURL
        ])
        
        try await ShellUtil.runCommandAndWait(arguments: [
            "xcrun", "docc", "convert",
            "--emit-lmdb-index",
            "--output-path", Driver.shared.docsURL,
            Driver.shared.doccCatalogURL,
            "--additional-symbol-graph-dir", Driver.shared.symbolGraphsURL,
            "--transform-for-static-hosting",
            "--hosting-base-path", "SwiftUsd"
        ])
    }
}
