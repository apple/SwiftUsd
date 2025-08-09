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

extension String {
    /// Removes the given prefix if present, otherwise returns the string unchanged
    func removingPrefix(_ prefix: some StringProtocol) -> String {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }
    
    /// Removes the given suffix if present, otherwise returns the string unchanged
    func removingSuffix(_ suffix: some StringProtocol) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(path: URL) {
        appendLiteral(path.path(percentEncoded: false))
    }
}

extension URL {
    func deletingLastPathComponents(count: Int) -> URL {
        guard count >= 0 else { fatalError("Illegal count: \(count)") }
        var result = self
        for _ in 0..<count {
            result.deleteLastPathComponent()
        }
        return result
    }
    
    mutating func deleteLastPathComponents(count: Int) {
        self = deletingLastPathComponents(count: count)
    }
    
    /// Makes `self` into a relative URL that, when applied to `base`, becomes `self`
    func urlRelative(to base: URL) -> URL {
        let selfComponents = self.pathComponents
        let baseComponents = base.pathComponents
        
        var result = [String]()
        var i = 0
        while i < min(selfComponents.count, baseComponents.count) {
            if selfComponents[i] == baseComponents[i] {
                i += 1
                continue
            }
            
            result.append(contentsOf: [String](repeating: "..", count: baseComponents.count - i - 1))
            result.append(selfComponents[i])
            i += 1
            break
        }
        result.append(contentsOf: selfComponents[i...])
        return URL(fileURLWithPath: result.joined(separator: "/"))
    }
    
    /// Appends `url` to `self`
    func appending(url: URL) -> URL {
        URL(fileURLWithPath: path(percentEncoded: false) + "/" + url.path(percentEncoded: false))
    }
    
    func expandingTildeInPath() -> URL {
        .init(fileURLWithPath: NSString(string: path(percentEncoded: false)).expandingTildeInPath)
    }
}

extension FileManager {
    func fileExists(at: URL) -> Bool {
        fileExists(atPath: at.path(percentEncoded: false))
    }
    
    func nonDirectoryFileExists(at: URL) -> Bool {
        var isDirectory = ObjCBool(true)
        return fileExists(atPath: at.path(percentEncoded: false), isDirectory: &isDirectory) && !isDirectory.boolValue
    }
    
    func directoryExists(at: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        return fileExists(atPath: at.path(percentEncoded: false), isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    func createSymlink(at: URL, path: String) {
        try! createSymbolicLink(atPath: at.path(percentEncoded: false), withDestinationPath: path)
    }
    
    func allUrls(under: URL) -> [URL] {
        var result = [URL]()
        if let e = enumerator(at: under, includingPropertiesForKeys: nil) {
            for case let x as URL in e {
                result.append(x)
            }
        }
        return result
    }
}


/// Makes it easy to run shell commands as subprocesses
// TODO: Replace with swift-subprocess
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
    #if os(macOS)
    public typealias ShellUtilCommandOutput = AsyncLineSequence<FileHandle.AsyncBytes>
    #else
    public struct ShellUtilCommandOutput: AsyncSequence {
        public struct AsyncIterator: AsyncIteratorProtocol {
            public typealias Element = String
            public typealias Failure = Never

            public mutating func next() async -> String? {
                let result = lines.first
                if result != nil { lines.removeFirst() }
                return result
            }

            fileprivate var lines: [String]
        }

        private var lines: [String]

        public init(_ fileHandle: FileHandle) {
            lines = String(data: fileHandle.availableData, encoding: .utf8)!.components(separatedBy: .newlines)
        }

        public func makeAsyncIterator() -> AsyncIterator {
            .init(lines: lines)
        }
    }
    #endif

    public static func runCommandAndGetOutput(arguments: [any Argument], exitOnSigint: Bool = true) throws -> ShellUtilCommandOutput {
        let output = Pipe()
        
        let process = Process()
        
        if exitOnSigint {
            SigintHandler.add(process: process)
        }
        
        process.standardOutput = output
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", arguments.map { $0.asSpaceEscapedString() }.joined(separator: " ")]
        try process.run()

        #if os(macOS)
        return output.fileHandleForReading.bytes.lines
        #else
        return .init(output.fileHandleForReading)
        #endif
    }
    
    public static func runCommandAndWait(arguments: [any Argument], currentDirectoryURL: URL? = nil, exitOnSigint: Bool = true, quiet: Bool = false) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let process = Process()
                
                if exitOnSigint {
                    SigintHandler.add(process: process)
                }
                
                if quiet {
                    process.standardOutput = FileHandle.nullDevice
                    process.standardError = FileHandle.nullDevice
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

