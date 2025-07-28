//
//  ShellUtil.swift
//  SwiftUsd-DocC-Helper
//
//  Created by Maddy Adams on 12/12/24.
//

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
