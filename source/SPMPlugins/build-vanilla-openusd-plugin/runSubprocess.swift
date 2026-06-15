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
import os

struct SubprocessResult {
    var exitCode: Int32
    var stdout: String
    var stderr: String
}

enum SubprocessError: Error, CustomStringConvertible {
    case nonZeroExitCode(String, [String], Int32)
    case couldNotFindExecutable(String)
    
    var description: String {
        switch self {
        case let .nonZeroExitCode(name, args, ret): "\(name) \(args.joined(separator: " ")) exited with return code \(ret)"
        case let .couldNotFindExecutable(name): "Could not find executable '\(name)'"
        }
    }
}

func runSubprocess(
    executableName: String,
    arguments: [String],
    printStdout: Bool,
    printStderr: Bool,
    check: Bool
) async throws -> SubprocessResult {
    func findExecutableURL(named name: String) throws -> URL {
        for pathEntry in (ProcessInfo.processInfo.environment["PATH"] ?? "").components(separatedBy: ":") {
            let contents = try FileManager.default.contentsOfDirectory(atPath: pathEntry)
            if contents.contains(executableName) {
                return URL(fileURLWithPath: pathEntry).appending(path: executableName)
            }
        }
        
        throw SubprocessError.couldNotFindExecutable(name)
    }
    
    let executableURL = try findExecutableURL(named: executableName)
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    let process = Process()
    
    // todo: Replace with Synchronization.Mutex once we bump SwiftUsd's minimum macOS to macOS 15.0
    let outputData = OSAllocatedUnfairLock(initialState: Data())
    let errorData = OSAllocatedUnfairLock(initialState: Data())
    
    outputPipe.fileHandleForReading.readabilityHandler = { handle in
        let d = handle.availableData
        outputData.withLock { $0.append(d) }
        
        if d.count != 0, printStdout, let s = String(data: d, encoding: .utf8) {
            print(s, terminator: "")
            fflush(stdout)
        }
    }
    
    
    errorPipe.fileHandleForReading.readabilityHandler = { handle in
        let d = handle.availableData
        errorData.withLock { $0.append(d) }
        
        if d.count != 0, printStderr, let s = String(data: d, encoding: .utf8) {
            print(s)
        }
    }
    
    try await withCheckedThrowingContinuation { continuation in
        do {
            process.arguments = arguments
            process.executableURL = executableURL
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            process.terminationHandler = {
                if $0.terminationStatus == 0 || !check {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: SubprocessError.nonZeroExitCode(executableName, arguments, $0.terminationStatus))
                }
            }
            try process.run()
        } catch {
            continuation.resume(throwing: error)
        }
    }
    
    if process.terminationStatus == 0 || !check {
        let out = String(data: outputData.withLock { $0 }, encoding: .utf8) ?? ""
        let err = String(data: errorData.withLock { $0 }, encoding: .utf8) ?? ""
        return .init(exitCode: process.terminationStatus, stdout: out, stderr: err)
    }

    throw SubprocessError.nonZeroExitCode(executableName, arguments, process.terminationStatus)
}
