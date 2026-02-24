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
import WorkflowDescription
import Logging

/// A helper for working with the file system, used by orchestrators and runners
internal struct FileSystemHelper: ~Copyable {
    // All
    var cacheDirectory: URL { yamlConfig.cacheDirectory }
    var artifactDirectory: URL { yamlConfig.artifactDirectory }
    private var loggingDirectory: URL {
        var result = yamlConfig.loggingDirectory
        guard let workflow else { return result }
        result = result.appending(path: "workflow-\(workflow.id)")
        guard let job else { return result }
        result = result.appending(path: "job-\(job.id)")
        guard let matrixIndex else { return result }
        result = result.appending(path: "matrix-\(matrixIndex)")
        guard let step else { return result }
        result = result.appending(path: "step-\(stepIndex!)-\(step.name)")
        return result
    }
    var swiftUsdSrcDirectory: URL { yamlConfig.swiftUsdSrcDirectory }
    var swiftUsdTestsSrcDirectory: URL { yamlConfig.swiftUsdTestsSrcDirectory }
    
    static func topLevelLogFile(yamlConfig: YamlConfig) -> URL {
        yamlConfig.loggingDirectory.appending(path: "log.txt")
    }
    
    // MatrixIndex
    var runnerRootDirectory: URL { yamlConfig.runnerRootDirectory.appending(path: "runner-\(matrixRunnerId!.uuidString)") }
    
    var githubWorkspaceDirectory: URL { runnerRootDirectory.appending(path: "workspace") }
    var runnerTempDirectory: URL { githubWorkspaceDirectory.appending(path: ".temp") }
    var swiftUsdWorkspaceDirectory: URL { githubWorkspaceDirectory.appending(path: "SwiftUsd") }
    var swiftUsdTestsWorkspaceDirectory: URL { githubWorkspaceDirectory.appending(path: "SwiftUsd-Tests") }

    
    // Step
    var githubOutputFile: URL {
        guard step != nil else { fatalError() }
        return loggingDirectory.appending(path: ".githuboutput.txt")
    }
    var githubStepSummaryFile: URL {
        guard step != nil else { fatalError() }
        return loggingDirectory.appending(path: ".githubstepsummary.txt")
    }
    var subprocessPathEnvironmentVariable: String {
        guard step != nil else { fatalError() }
        let existing = ProcessInfo.processInfo.environment["PATH"] ?? ""
        return yamlConfig.pathPrepend + ":" + existing
    }
    
    init(yamlConfig: YamlConfig, workflow: Workflow?, job: Job?, matrixIndex: Int?, matrixRunnerId: UUID?, stepIndex: Int?, step: Step?) {
        self.yamlConfig = yamlConfig
        self.workflow = workflow
        self.job = job
        self.matrixIndex = matrixIndex
        self.matrixRunnerId = matrixRunnerId
        self.stepIndex = stepIndex
        self.step = step
        
        let label: String =
        if let step { "step-\(step.name)" }
        else if let matrixIndex { "matrix-\(matrixIndex)" }
        else if let job { "job-\(job.id)" }
        else if let workflow { "workflow-\(workflow.id)" }
        else { "TopLevelLogger" }
        
        self.logger = fileLogger(label: label, outputFile: loggingDirectory.appending(path: "log.txt"))
        self.expressionEvaluator = ExpressionEvaluator(logger: logger)
    }
                
    private let yamlConfig: YamlConfig
    private(set) var logger: Logger!
    private(set) var expressionEvaluator: ExpressionEvaluator!
    private let workflow: Workflow?
    private let job: Job?
    private let matrixIndex: Int?
    private let matrixRunnerId: UUID?
    private let stepIndex: Int?
    private let step: Step?
    
    func logLoggingDirectory() {
        logger.info("Log file: '\(loggingDirectory.appending(path: "log.txt").absoluteURL.path(percentEncoded: false))'")
    }
    
    func ensureEmptyFileExists(url: URL) throws {
        logger.trace("FileSystemHelper.ensureEmptyFileExists", metadata: ["url" : url.loggerRepresentation])
        if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            // try FileManager.default.removeItem(at: url)
        }
        if !FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path(percentEncoded: false)) {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        try "".data(using: .utf8)!.write(to: url)
    }
    
    func ensureEmptyDirectoryExists(url: URL) throws {
        logger.trace("FileSystemHelper.ensureEmptyDirectoryExists", metadata: ["url" : url.loggerRepresentation])
        if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            // try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func ensureDirectoryExists(url: URL) throws {
        logger.trace("FileSystemHelper.ensureDirectoryExists", metadata: ["url" : url.loggerRepresentation])
        var isDirectory = ObjCBool(false)
        if FileManager.default.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDirectory) {
            if !isDirectory.boolValue { try ensureEmptyDirectoryExists(url: url) }
        } else {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    func hasCacheEntry(cache: Step.Cache, context: borrowing Context) -> Bool {
        logger.trace("FileSystemHelper.hasCacheEntry")
        guard step != nil else { fatalError() }
        do {
            let (key, _) = try expressionEvaluator.evaluateCacheEntry(cache: cache, in: context, fileSystemHelper: self)
            return FileManager.default.fileExists(atPath: key.path(percentEncoded: false))
        } catch {
            logger.error("While evaluating cache entry: \(error)")
            return false
        }
    }
    
    func restoreCacheEntry(cache: Step.Cache, context: borrowing Context) throws {
        logger.trace("FileSystemHelper.restoreCacheEntry")
        guard step != nil else { fatalError() }
        let (key, path) = try expressionEvaluator.evaluateCacheEntry(cache: cache, in: context, fileSystemHelper: self)
        do {
            if !FileManager.default.fileExists(atPath: path.deletingLastPathComponent().path(percentEncoded: false)) {
                try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
            }
            
            if cache.requiresIndependentCopy {
                try FileManager.default.copyItem(at: key, to: path)
            } else {
                try FileManager.default.createSymbolicLink(at: path, withDestinationURL: key)
            }
        } catch {
            throw FileSystemHelperError.restoreCache(error, cache)
        }
    }
    
    func saveCacheEntry(cache: Step.Cache, context: borrowing Context) throws {
        logger.trace("FileSystemHelper.saveCacheEntry")
        guard step != nil else { fatalError() }
        let (key, path) = try expressionEvaluator.evaluateCacheEntry(cache: cache, in: context, fileSystemHelper: self)
        do {
            try FileManager.default.moveItem(at: path, to: key)
            try FileManager.default.createSymbolicLink(at: path, withDestinationURL: key)
        } catch {
            throw FileSystemHelperError.saveCache(error, cache)
        }
    }
    
    private enum FileSystemHelperError: Error, Sendable {
        case restoreCache(Error, Step.Cache)
        case saveCache(Error, Step.Cache)
    }
}


