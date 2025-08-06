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

public enum ShellUtil {}

extension ShellUtil {
    public protocol Argument {
        func asSpaceEscapedString() -> String
    }
}

extension String: ShellUtil.Argument {
    public func asSpaceEscapedString() -> String {
        self.replacingOccurrences(of: " ", with: "\\ ")
    }
}

extension URL: ShellUtil.Argument {
    public func asSpaceEscapedString() -> String {
        path(percentEncoded: false).asSpaceEscapedString()
    }
}

fileprivate actor SigintHandler {
    private init() {
        signal(SIGINT) { _ in
            Task {
                await SigintHandler.shared._exit()
            }
        }
    }
    
    private func _exit() {
        for child in self.children {
            child.terminate()
        }
        exit(SIGINT)
    }
    static let shared = SigintHandler()
    
    private var children = [Process]()
    
    static func add(process: Process) {
        Task {
            await Self.shared._add(process: process)
        }
    }
    
    private func _add(process: Process) {
        children.append(process)
    }
}

extension ShellUtil {
    public static func runCommandAndGetOutput(arguments: [any Argument], exitOnSigint: Bool = true) throws -> AsyncLineSequence<FileHandle.AsyncBytes> {
        let output = Pipe()
        
        let process = Process()
        
        if exitOnSigint {
            SigintHandler.add(process: process)
        }
        
        process.standardOutput = output
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", arguments.map { $0.asSpaceEscapedString() }.joined(separator: " ")]
        try process.run()
        
        return output.fileHandleForReading.bytes.lines
    }
    
    public static func runCommandAndWait(arguments: [any Argument], currentDirectoryURL: URL? = nil, exitOnSigint: Bool = true) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let process = Process()
                
                if exitOnSigint {
                    SigintHandler.add(process: process)
                }
                
                process.executableURL = URL(filePath: "/bin/bash")
                process.arguments = ["-c", arguments.map { $0.asSpaceEscapedString() }.joined(separator: " ")]
                process.terminationHandler = {
                    if $0.terminationStatus == 0 {
                        continuation.resume()
                    } else {
                        struct ProcessError: Error {
                            let status: Int32
                        }
                        continuation.resume(throwing: ProcessError(status: $0.terminationStatus))
                    }
                }
                process.currentDirectoryURL = currentDirectoryURL
                
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
