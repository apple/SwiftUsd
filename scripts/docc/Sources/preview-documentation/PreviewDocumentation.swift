// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

import Foundation
import SwiftUsdDoccUtil

@main
struct PreviewDocumentation {
    static func main() async throws {
        var hasOpenedAddress = false
        
        for try await line in try ShellUtil.runCommandAndGetOutput(arguments: [
            "xcrun", "docc", "preview",
            "--additional-symbol-graph-dir", Driver.shared.symbolGraphsURL,
            Driver.shared.doccCatalogURL
        ]) {
            print(line)
            
            guard !hasOpenedAddress else { continue }
            guard let match = line.wholeMatch(of: /\s*Address: (http:\/\/localhost:.*)\s*/)?.output.1 else { continue }
            hasOpenedAddress = true
            try await ShellUtil.runCommandAndWait(arguments: ["open", String(match)])
        }
    }
}
