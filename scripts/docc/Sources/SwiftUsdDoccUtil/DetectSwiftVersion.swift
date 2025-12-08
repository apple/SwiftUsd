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

/// Major, minor, patch, subpatch, etc
public func detectSwiftVersion() async -> [Int] {
    let lines = try! await ShellUtil.runCommandAndGetOutput(arguments: ["swift", "--version"]).reduce([]) { $0 + [$1] }
    
    lineLoop: for l in lines {
        // `swiftlang-` followed by digits separated by periods, 0 or more times
        let regex = #/swiftlang-(((\d+)\.?)*)/#
        guard let match = l.firstMatch(of: regex) else { continue }
        let allDigitsString = match.output.1
        let components = allDigitsString.components(separatedBy: ".").filter { !$0.isEmpty }
        var result = [Int]()
        for c in components {
            guard let i = Int(c) else { continue lineLoop }
            result.append(i)
        }
        return result
    }

    return []
}

public func isSwiftVersion(_ lhs: [Int], lessThan rhs: [Int]) -> Bool {
    for i in 0..<min(lhs.count, rhs.count) {
       if lhs[i] < rhs[i] { return true }
       if lhs[i] > rhs[i] { return false }
    }
    return false
}