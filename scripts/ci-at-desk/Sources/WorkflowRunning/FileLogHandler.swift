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
import Logging
import Synchronization

/// Log handler for logging to a file
internal struct FileLogHandler: LogHandler {
    private let label: String
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [:]
    public var metadataProvider: Logger.MetadataProvider?
    private var fileHandle: FileHandle
    
    public init(label: String, outputFile: URL) {
        self.label = label
        
        // FileHandle(forWritingAtPath:) returns nil if the file doesn't already exist
        try? FileManager.default.createDirectory(at: outputFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: outputFile.path(percentEncoded: false), contents: nil)
        self.fileHandle = FileHandle(forWritingAtPath: outputFile.path(percentEncoded: false))!
        try! self.fileHandle.seekToEnd()
    }
    
    internal func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let now = Date()
        let timestamp = now.ISO8601Format(.iso8601WithTimeZone(includingFractionalSeconds: true))
        let levelString = level.rawValue.uppercased()
        
        // Merge handler metadata with message metadata
        let combinedMetadata = Self.prepareMetadata(
            base: self.metadata,
            provider: self.metadataProvider,
            explicit: metadata
        )
        
        // Format metadata
        let metadataString = if let combinedMetadata { "[" + combinedMetadata.map { "\($0.key)=\($0.value)" }.joined(separator: ",") + "]" }
        else { "" }
        
        // Create log line and print to console
        let logLine = "\(label) \(timestamp) \(levelString) [\(metadataString)]: \(message)\n"
        
        fileHandle.write(Data(logLine.utf8))
    }
    
    internal subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[key]
        }
        set {
            self.metadata[key] = newValue
        }
    }


    static func prepareMetadata(
        base: Logger.Metadata,
        provider: Logger.MetadataProvider?,
        explicit: Logger.Metadata?
    ) -> Logger.Metadata? {
        var metadata = base


        let provided = provider?.get() ?? [:]


        guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
            // all per-log-statement values are empty
            return metadata
        }


        if !provided.isEmpty {
            metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
        }


        if let explicit = explicit, !explicit.isEmpty {
            metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
        }


        return metadata
    }
}

internal func fileLogger(label: String, outputFile: URL) -> Logger {
     var result = Logger(label: label.replacingOccurrences(of: " ", with: "-"),
                         factory: {
         let fileLogHandler = FileLogHandler(label: $0, outputFile: outputFile)
         if InProcessLogNotificationHandler.enabled {
             let inProcessHandler = InProcessLogNotificationHandler(label: $0, outputFile: outputFile)
             return MultiplexLogHandler([inProcessHandler, fileLogHandler])
         } else {
             return fileLogHandler
         }
     })
    result.logLevel = .trace
    return result
}

/// Log handler for treating log messages as notifications that other parts of the process can respond to.
/// Makes the UI more performant because it doesn't have to repeatedly parse log files from disk
public struct InProcessLogNotificationHandler: LogHandler {
    static nonisolated(unsafe) public var enabled: Bool = false
    
    private struct Storage {
        var messages: [URL : [Message]] = [:]
        var subscribers: [URL : [([Message]) -> ()]] = [:]
    }
    
    static private let storage: Mutex<Storage> = .init(.init())
    
    private let label: String
    private let outputFile: URL
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [:]
    public var metadataProvider: Logger.MetadataProvider?
    
    public init(label: String, outputFile: URL) {
        self.label = label
        self.outputFile = outputFile
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let now = Date()
        
        // Merge handler metadata with message metadata
        let combinedMetadata = Self.prepareMetadata(
            base: self.metadata,
            provider: self.metadataProvider,
            explicit: metadata
        )
        
        // Format metadata
        let metadataString = if let combinedMetadata { "[" + combinedMetadata.map { "\($0.key)=\($0.value)" }.joined(separator: ",") + "]" }
        else { "" }

        let message = Message(label: label, timestamp: now, level: level, metadata: metadataString, message: message.description)
        Self.post(message, to: outputFile)
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[key]
        }
        set {
            self.metadata[key] = newValue
        }
    }
    
    private static func prepareMetadata(
        base: Logger.Metadata,
        provider: Logger.MetadataProvider?,
        explicit: Logger.Metadata?
    ) -> Logger.Metadata? {
        var metadata = base


        let provided = provider?.get() ?? [:]


        guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
            // all per-log-statement values are empty
            return metadata
        }


        if !provided.isEmpty {
            metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
        }


        if let explicit = explicit, !explicit.isEmpty {
            metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
        }


        return metadata
    }
    
    /// The structured message/notification sent by InProcessLogNotificationHandler
    public struct Message: Sendable, Equatable {
        public let label: String
        public let timestamp: Date
        public let level: Logger.Level
        public let metadata: String
        public let message: String
    }
    
    public static func clearAllStorage() {
        storage.withLock { $0 = .init() }
    }
    
    public static func subscribe(url: URL, _ code: @escaping @Sendable ([Message]) -> ()) {
        storage.withLock { storage in
            if storage.subscribers[url] == nil {
                storage.subscribers[url] = []
            }
            storage.subscribers[url]!.append(code)
            if let messages = storage.messages[url] {
                code(messages)
            }
        }
    }
    
    public static func post(_ message: Message, to url: URL) {
        storage.withLock { storage in
            if storage.messages[url] == nil {
                storage.messages[url] = []
            }
            storage.messages[url]!.append(message)
            for subscriber in storage.subscribers[url] ?? [] {
                subscriber([message])
            }
        }
    }
}
