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
import Subprocess
import System

let STRING_SUBPROCESS_LIMIT = 100_000_000

enum TestOneError: Error {
    case forwardCatFailed
    case forwardCatProducedInvalidJson
    case reverseCatFailed
    case usddiffFailed
}

func forwardCat(_ args: Args, _ a: URL, _ b: URL, _ env: Environment, _ output: inout [String]) async throws {
    output.append("usdcat \(a.path(percentEncoded: false)) -o \(b.path(percentEncoded: false))")
    let proc = try await Subprocess.run(
        .name("usdcat"),
        arguments: [a.path(percentEncoded: false), "-o", b.path(percentEncoded: false)],
        environment: env,
        output: .string(limit: STRING_SUBPROCESS_LIMIT),
        error: .string(limit: STRING_SUBPROCESS_LIMIT)
    )
    output.append(contentsOf: proc.standardOutput?.components(separatedBy: .newlines) ?? [])
    output.append(contentsOf: proc.standardError?.components(separatedBy: .newlines) ?? [])
    if !proc.terminationStatus.isSuccess {
        output.append("usdcat exited with \(proc.terminationStatus)")
        throw TestOneError.forwardCatFailed
    }
}

func verifyJsonFileIsActuallyJson(_ a: URL, _ output: inout [String]) throws {
    do {
        let data = try Data(contentsOf: a)
        _ = try JSONSerialization.jsonObject(with: data)
    } catch {
        output.append("usdcat produced invalid json: \(error)")
        throw TestOneError.forwardCatProducedInvalidJson
    }
}

func reverseCat(_ args: Args, _ a: URL, _ b: URL, _ env: Environment, _ output: inout [String]) async throws {
    output.append("usdcat \(a.path(percentEncoded: false)) -o \(b.path(percentEncoded: false))")
    let proc = try await Subprocess.run(
        .name("usdcat"),
        arguments: [a.path(percentEncoded: false), "-o", b.path(percentEncoded: false)],
        environment: env,
        output: .string(limit: STRING_SUBPROCESS_LIMIT),
        error: .string(limit: STRING_SUBPROCESS_LIMIT)
    )
    output.append(contentsOf: proc.standardOutput?.components(separatedBy: .newlines) ?? [])
    output.append(contentsOf: proc.standardError?.components(separatedBy: .newlines) ?? [])
    if !proc.terminationStatus.isSuccess {
        output.append("usdcat exited with \(proc.terminationStatus)")
        throw TestOneError.reverseCatFailed
    }
}

func usddiff(_ args: Args, _ a: URL, _ b: URL, _ output: inout [String]) async throws -> Bool {
    var a = a
    
    if a.pathExtension == "usdz" {
        // usddiff will say that a usdz with a single layer is different to a usda with
        // the same contents as the usdz's layer. We want to allow those comparisons to
        // proceed on single-layer zips so that we have more test cases.
        
        output.append("usdzip -l \(a.path(percentEncoded: false))")
        let proc = try await Subprocess.run(
            .name("usdzip"),
            arguments: ["-l", a.path(percentEncoded: false)],
            output: .string(limit: STRING_SUBPROCESS_LIMIT),
            error: .discarded
        )
        try proc.check("usdzip -l \(a.path(percentEncoded: false))")
        guard proc.standardOutput?.components(separatedBy: .newlines).count == 1 else {
            output.append("Warning: Skipping multi-layer usdz \(a.path(percentEncoded: false))")
            return true
        }
        
        let tempUsdzCat = b.deletingLastPathComponent().appending(path: b.lastPathComponent + ".usdzextraction.usda")
        output.append("usdcat \(a.path(percentEncoded: false)) -o \(tempUsdzCat.path(percentEncoded: false))")
        try await Subprocess.run(
            .name("usdcat"),
            arguments: [a.path(percentEncoded: false), "-o", tempUsdzCat.path(percentEncoded: false)],
            output: .discarded,
        ).check(
            "usdcat \(a.path(percentEncoded: false)) -o \(tempUsdzCat.path(percentEncoded: false))"
        )
        
        a = tempUsdzCat
    }
    
    output.append("usddiff \(a.path(percentEncoded: false)) \(b.path(percentEncoded: false))")
    let proc = try await Subprocess.run(
        .name("usddiff"),
        arguments: [a.path(percentEncoded: false), b.path(percentEncoded: false)],
        output: .string(limit: 16_000_000),
        error: .string(limit: 16_000_000),
    )
    output.append(contentsOf: proc.standardOutput?.components(separatedBy: .newlines) ?? [])
    output.append(contentsOf: proc.standardError?.components(separatedBy: .newlines) ?? [])

    return proc.terminationStatus.isSuccess
}

struct TestOneResult {
    var output: [String]
    var success: Bool
    var file: URL
    var duration: Double
}

@concurrent func test_one(args: Args, tempDir: URL, file: URL, builtPluginDir: URL) async -> TestOneResult {
    var output = [String]()
    var success = false
    let start = Date()
    
    let newPluginPathName = if let old = ProcessInfo.processInfo.environment["PXR_PLUGINPATH_NAME"] {
        "\(builtPluginDir.path(percentEncoded: false)):\(old)"
    } else {
        "\(builtPluginDir.path(percentEncoded: false))"
    }
    let env: Environment = .inherit.updating([
        "PXR_PLUGINPATH_NAME" : newPluginPathName,
    ])
    
    do {
        let jsonFile = tempDir.appending(path: file.lastPathComponent + ".json")
        let recattedFile = tempDir.appending(path: file.lastPathComponent + ".recatted.usda")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        try await forwardCat(args, file, jsonFile, env, &output)
        try verifyJsonFileIsActuallyJson(jsonFile, &output)
        try await reverseCat(args, jsonFile, recattedFile, env, &output)
        success = try await usddiff(args, file, recattedFile, &output)
    } catch TestOneError.forwardCatFailed {
        success = false
        output.append("Forward cat failed")
    } catch TestOneError.forwardCatProducedInvalidJson {
        success = false
        output.append("Forward cat produced invalid json")
    } catch TestOneError.reverseCatFailed {
        success = false
        output.append("Reverse cat failed")
    } catch TestOneError.usddiffFailed {
        success = false
        output.append("usddiff failed")
    } catch {
        success = false
        output.append("Unknown error: \(error)")
    }
    
    return TestOneResult(output: output, success: success, file: file, duration: Date().timeIntervalSince(start))
}
