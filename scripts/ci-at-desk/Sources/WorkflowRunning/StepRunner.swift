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
import WorkflowDescription
import System
import Logging
import Synchronization

/// A step level runner, responsible for executing a single step
internal struct StepRunner: ~Copyable, RunnerProtocol {
    internal static func run(stepIndex: Int, step: Step, matrixIndex: Int, matrixRunnerId: UUID, job: Job, workflow: Workflow, context: inout Context, logger: Logger) async throws -> Bool {
        logger.trace("StepRunner.run", metadata: [
            "step": step.loggerRepresentation,
            "matrixIndex": matrixIndex.loggerRepresentation,
            "matrixRunnerId": matrixRunnerId.loggerRepresentation,
            "job": job.loggerRepresentation,
            "workflow": workflow.loggerRepresentation,
            "context": context.loggerRepresentation,
        ])
        var instance = StepRunner(stepIndex: stepIndex, step: step, matrixIndex: matrixIndex, matrixRunnerId: matrixRunnerId, job: job, workflow: workflow, context: context)
        defer {
            context.merge(other: instance.context, logger: logger)
            logger.trace("StepRunner.run returning")
        }
        
        do {
            return try await instance.run()
        } catch {
            instance.logger.error(.init(stringLiteral: String(describing: error)))
            logger.error(.init(stringLiteral: String(describing: error)))
            throw error
        }
    }
    
    private let step: Step
    private let matrixIndex: Int
    private let job: Job
    private let workflow: Workflow
    internal let fileSystemHelper: FileSystemHelper
    private var context: Context
    
    init(stepIndex: Int, step: Step, matrixIndex: Int, matrixRunnerId: UUID, job: Job, workflow: Workflow, context: borrowing Context) {
        self.step = step
        self.matrixIndex = matrixIndex
        self.job = job
        self.workflow = workflow
        self.fileSystemHelper = .init(yamlConfig: context.yamlConfig, workflow: workflow, job: job, matrixIndex: matrixIndex, matrixRunnerId: matrixRunnerId, stepIndex: stepIndex, step: step)
        self.context = context.detachedCopy()
    }
    
    internal mutating func run() async throws -> Bool {
        logger.info("run() start")
        logger.info("Runner workspace: \(fileSystemHelper.githubWorkspaceDirectory.path(percentEncoded: false))")
        defer { logger.info("run() end"); fileSystemHelper.logLoggingDirectory() }
        
        logger.debug("name: \(step.name)")
        
        var hadCacheHit = false
        if let cache = step.cache {
            logger.debug("Checking cache", metadata: ["cache": cache.loggerRepresentation])
            if fileSystemHelper.hasCacheEntry(cache: cache, context: context) {
                logger.debug("Cache hit, restoring")
                try fileSystemHelper.restoreCacheEntry(cache: cache, context: context)
                hadCacheHit = true
            } else {
                logger.debug("Cache miss, will save if step succeeds")
            }
        }
        if hadCacheHit { return true }
        
        let stepSucceeded = switch step.kind {
        case let .runShellCommand(runStep): try await run(runStep: runStep)
        case let .saveArtifact(saveArtifact): try await run(saveArtifactStep: saveArtifact)
        case let .restoreArtifact(restoreArtifact): try await run(restoreArtifactStep: restoreArtifact)
        case let .sparseCheckout(sparseCheckout): try await run(sparseCheckoutStep: sparseCheckout)
        case let .checkout(checkout): try await run(checkoutStep: checkout)
        }
        
        if let cache = step.cache, stepSucceeded {
            logger.debug("Saving to cache")
            try fileSystemHelper.saveCacheEntry(cache: cache, context: context)
        }
        return stepSucceeded
    }
    
    private mutating func run(runStep: [Expression]) async throws -> Bool {
        logger.debug("run(runStep:) start")
        defer { logger.debug("run(runStep:) end") }
        try fileSystemHelper.ensureEmptyFileExists(url: fileSystemHelper.githubOutputFile)
        try fileSystemHelper.ensureEmptyFileExists(url: fileSystemHelper.githubStepSummaryFile)
        
        var env = Subprocess.Environment.inherit
        var envString = [String]()
        
        func updateEnv(_ k: Environment.Key, _ v: String) {
            env = env.updating([k : v])
            if k == "PATH" {
                envString.append("export \(k)='\(v)':$\(k)")
            } else {
                envString.append("export \(k)='\(v)'")
            }
        }
        func updateEnv(_ k: Environment.Key, _ v: URL) {
            updateEnv(k, v.absoluteURL.path(percentEncoded: false))
        }
        
        for (k, v) in job.env {
            updateEnv(.init(stringLiteral: k), try expressionEvaluator.evaluateAsString(v, in: context))
        }
        updateEnv("GITHUB_OUTPUT", fileSystemHelper.githubOutputFile)
        updateEnv("GITHUB_STEP_SUMMARY", fileSystemHelper.githubStepSummaryFile)
        updateEnv("GITHUB_WORKSPACE", fileSystemHelper.githubWorkspaceDirectory)
        updateEnv("RUNNER_TEMP", fileSystemHelper.runnerTempDirectory)
        
        for (k, v) in context.yamlConfig.env {
            updateEnv(Environment.Key(stringLiteral: k), v)
        }

        logger.debug(.init(stringLiteral: runStep.map(\.coerceToString).joined(separator: " ")))
        func globExpand(_ s: String) -> [String] {
            guard s.hasSuffix("/*") else { return [s] }
            let dirContents = (try? FileManager.default.contentsOfDirectory(atPath: String(s.dropLast(2)))) ?? []
            return dirContents.map { String(s.dropLast(1)) + $0 }
        }
        let evaluatedRunCommand = try runStep.map { try expressionEvaluator.evaluateAsString($0, in: context) }
            .flatMap { globExpand($0) }
        
        logger.info(.init(stringLiteral: "cd \(FilePath(fileSystemHelper.swiftUsdWorkspaceDirectory)!)"))
        for s in envString {
            logger.info(.init(stringLiteral: s))
        }
        logger.info(.init(stringLiteral: evaluatedRunCommand.joined(separator: " ")))
        
        
        let shellLogFile = fileSystemHelper.shellLogFile
        let writeFileDescriptor = try FileDescriptor.open(FilePath(shellLogFile)!, .writeOnly, options: .create, permissions: .ownerReadWrite)
        await FireAndForgetTasks.shared.add { [logger] in
            _ = try await Subprocess.run(
                .name("tail"),
                arguments: ["-f", shellLogFile.absoluteURL.path(percentEncoded: false)],
                error: .discarded,
                preferredBufferSize: 1,
            ) { execution, output in
                for try await line in output.lines() {
                    var line = line
                    if line.hasSuffix("\n") { line.removeLast() }
                    logger.debug(.init(stringLiteral: line))
                }
            }
        }
        let runResult = try await withTimeout(step.timeout * context.yamlConfig.timeoutScaleFactor) { [env, workingDirectory = FilePath(fileSystemHelper.swiftUsdWorkspaceDirectory)] in
            try await Subprocess.run(
                .name(evaluatedRunCommand.first!),
                arguments: Arguments(Array(evaluatedRunCommand.dropFirst())),
                environment: env,
                workingDirectory: workingDirectory,
                output: .fileDescriptor(writeFileDescriptor, closeAfterSpawningProcess: true),
                error: .combinedWithOutput,
            )
        } onTimeout: { [logger, timeout = step.timeout * context.yamlConfig.timeoutScaleFactor] in
            logger.error("Step timed out after \(timeout)")
        }
        
        logger.debug("Subprocess run terminated with \(runResult.terminationStatus)")
        if !runResult.terminationStatus.isSuccess {
            throw StepRunnerError.runStepError(runResult.terminationStatus)
        }
        
        logger.trace("Will augment context with step outputs")
        // Augment context
        var outputs = [String : String]()
        let outputFileContents = try String(contentsOf: fileSystemHelper.githubOutputFile, encoding: .utf8)
        for line in outputFileContents.components(separatedBy: .newlines) {
            let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            let parts = line.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else {
                throw StepRunnerError.errorParsingOutputFile(line)
            }
            outputs[String(parts[0])] = String(parts[1])
        }
        if let id = step.id {
            context.augment(stepId: id, stepOutputs: outputs, logger: logger)
        } else if !outputs.isEmpty {
            logger.info("Warning! No step ID specified for step, but outputs were found.")
        }
                
        return runResult.terminationStatus.isSuccess
    }
    
    private func run(saveArtifactStep: Step.SaveArtifact) async throws -> Bool {
        logger.debug("run(saveArtifactStep:)", metadata: ["input" : saveArtifactStep.loggerRepresentation])
        let (src, dest) = try _evaluateSaveArtifactStep(saveArtifactStep)
        logger.debug("Saving \(src.path(percentEncoded: false)) to \(dest.path(percentEncoded: false))")
        do {
            // Move and symlink is faster than a copy
            do {
                try FileManager.default.moveItem(at: src, to: dest)
            } catch {
                if saveArtifactStep.allowNoFilesFound { /* pass */ }
                else { throw error }
            }
            try FileManager.default.createSymbolicLink(at: src, withDestinationURL: dest)
            // try FileManager.default.copyItem(at: src, to: dest)
            return true
        } catch {
            throw StepRunnerError.saveArtifactError(error, saveArtifactStep)
        }
    }
    
    private func run(restoreArtifactStep: Step.RestoreArtifact) async throws -> Bool {
        logger.debug("run(restoreArtifactStep:)", metadata: ["input" : restoreArtifactStep.loggerRepresentation])
        let (srcs, dest) = try _evaluateRestoreArtifactStep(restoreArtifactStep)
        logger.debug("Restoring \(srcs.map { $0.path(percentEncoded: false) }) to \(dest.path(percentEncoded: false))")
        do {
            if srcs.count == 1 {
                let src = srcs.first!
                if !FileManager.default.fileExists(atPath: dest.deletingLastPathComponent().path(percentEncoded: false)) {
                    try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
                }
                
                if restoreArtifactStep.requiresIndependentCopy {
                    try FileManager.default.copyItem(at: src, to: dest)
                } else {
                    try FileManager.default.createSymbolicLink(at: dest, withDestinationURL: src)
                }
            } else {
                for src in srcs {
                    if !FileManager.default.fileExists(atPath: dest.path(percentEncoded: false)) {
                        try FileManager.default.createDirectory(at: dest, withIntermediateDirectories: true)
                    }
                    if restoreArtifactStep.requiresIndependentCopy {
                        try FileManager.default.copyItem(at: src, to: dest.appending(path: src.lastPathComponent))
                    } else {
                        try FileManager.default.createSymbolicLink(at: dest.appending(path: src.lastPathComponent), withDestinationURL: src)
                    }
                }
            }
            return true
        } catch {
            throw StepRunnerError.restoreArtifactError(error, restoreArtifactStep)
        }
    }

    private func run(sparseCheckoutStep: [String]) async throws -> Bool {
        logger.debug("run(sparseCheckoutStep:)", metadata: ["input" : .array(sparseCheckoutStep.map { $0.loggerRepresentation })])
        do {
            if !FileManager.default.fileExists(atPath: fileSystemHelper.swiftUsdWorkspaceDirectory.path(percentEncoded: false)) {
                try FileManager.default.createDirectory(at: fileSystemHelper.swiftUsdWorkspaceDirectory, withIntermediateDirectories: true)
            }
            for path in sparseCheckoutStep {
                let src = fileSystemHelper.swiftUsdSrcDirectory.appending(path: path)
                let dest = fileSystemHelper.swiftUsdWorkspaceDirectory.appending(path: path)
                if !FileManager.default.fileExists(atPath: dest.deletingLastPathComponent().path(percentEncoded: false)) {
                    try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
                }
                try FileManager.default.copyItem(at: src, to: dest)
            }
            return true
        } catch {
            throw StepRunnerError.sparseCheckoutError(error, sparseCheckoutStep)
        }
    }

    private func run(checkoutStep: Step.Kind.CheckoutKind) async throws -> Bool {
        logger.debug("run(checkoutStep:)", metadata: ["input" : checkoutStep.loggerRepresentation])
        do {
            switch checkoutStep {
            case .swiftUsd:
                // SwiftUsd repo can be pretty big on dev machines, and an exact copy has a lot of extra files that aren't needed and make the copy take longer
                
                let arguments: Subprocess.Arguments = [
                    "-r", // rsync recursively
                    "--filter=:- .gitignore", // don't copy anything in gitignore
                    // Trailing slash to tell rsync to copy the contents of the directory, not the dir itself
                    fileSystemHelper.swiftUsdSrcDirectory.absoluteURL.path(percentEncoded: false) + "/",
                    // copy _into_ the SwiftUsd workspace dir
                    fileSystemHelper.swiftUsdWorkspaceDirectory.absoluteURL.path(percentEncoded: false),
                    "--exclude=.git", // don't care about git history
                    "--exclude=docs", // don't care about compiled docs
                    "--exclude=SwiftUsd.doccarchive", // don't care about compiled docs
                    "--exclude=SwiftUsd.docc/.docc-build", // don't care about compiled docs,
                    "-l" // copy symlinks as symlinks
                ]
                
                let runResult = try await Subprocess.run(
                    .name("rsync"),
                    arguments: arguments,
                    output: .discarded)
                if !runResult.terminationStatus.isSuccess {
                    throw StepRunnerError.rsyncError(runResult.terminationStatus)
                }
                
                // try FileManager.default.copyItem(at: fileSystemHelper.swiftUsdSrcDirectory, to: fileSystemHelper.swiftUsdWorkspaceDirectory)
            case .swiftUsd_tests:
                try FileManager.default.copyItem(at: fileSystemHelper.swiftUsdTestsSrcDirectory, to: fileSystemHelper.swiftUsdTestsWorkspaceDirectory)
                let runResult = try await Subprocess.run(
                    .name("git"),
                    arguments: ["clean", "-fdX"],
                    workingDirectory: FilePath(fileSystemHelper.swiftUsdTestsWorkspaceDirectory),
                    output: .discarded)
                if !runResult.terminationStatus.isSuccess {
                    throw StepRunnerError.gitCleanError(runResult.terminationStatus)
                }
            }
            return true
        } catch {
            throw StepRunnerError.checkoutStep(error, checkoutStep)
        }
    }

    enum StepRunnerError: Error, Sendable {
        case errorParsingOutputFile(String)
        case runStepError(Subprocess.TerminationStatus)
        case saveArtifactError(Error, Step.SaveArtifact)
        case restoreArtifactError(Error, Step.RestoreArtifact)
        case sparseCheckoutError(Error, [String])
        case checkoutStep(Error, Step.Kind.CheckoutKind)
        case rsyncError(Subprocess.TerminationStatus)
        case gitCleanError(Subprocess.TerminationStatus)
    }
}

// MARK: Artifact evaluation
extension StepRunner {
    private func _evaluateSaveArtifactStep(_ saveArtifactStep: Step.SaveArtifact) throws -> (src: URL, dest: URL) {
        logger.trace("_evaluateSaveArtifactStep")
        let src = try expressionEvaluator.evaluateAsString(saveArtifactStep.path, in: context)
        let dest = try expressionEvaluator.evaluateAsString(saveArtifactStep.name, in: context)
        return (fileSystemHelper.githubWorkspaceDirectory.appending(path: src), fileSystemHelper.artifactDirectory.appending(path: dest))
    }
    
    private func _evaluateRestoreArtifactStep(_ restoreArtifactStep: Step.RestoreArtifact) throws -> (srcs: [URL], dest: URL) {
        logger.trace("_evaluateRestoreArtifactStep")
        let srcPattern = try expressionEvaluator.evaluateAsString(restoreArtifactStep.pattern, in: context)
        let dest = try expressionEvaluator.evaluateAsString(restoreArtifactStep.path, in: context)
        
        var srcs = [URL]()
        for potentialFile in try FileManager.default.contentsOfDirectory(at: fileSystemHelper.artifactDirectory, includingPropertiesForKeys: nil) {
            if Self._artifactPattern(pattern: srcPattern, matches: potentialFile.lastPathComponent) {
                srcs.append(potentialFile)
            }
        }
        return (srcs, fileSystemHelper.githubWorkspaceDirectory.appending(path: dest))
    }
    
    /// Glob-matches the `pattern` against a given input string `matches`
    private static func _artifactPattern(pattern p: String, matches m: String) -> Bool {
        // Keep empty subsequences so we know where glob stars were
        let parts = p.split(separator: "*", omittingEmptySubsequences: false)
        
        var range = m.startIndex..<m.endIndex
        
        for (i, part) in parts.enumerated() {
            // Glob stars always can match everything
            if part.isEmpty { continue }
            var compareOptions = String.CompareOptions()
            // If it's the first part or the previous part was non-empty,
            // this part must follow immediately, otherwise it need not
            // be anchored (glob star)
            if i == 0 || !parts[i - 1].isEmpty {
                compareOptions.insert(.anchored)
            }
            // There needs to be some match
            guard let partRange = m.range(of: part, options: compareOptions, range: range) else { return false }
            
            // The last part always has to match the end of the input
            if i + 1 >= parts.count { return partRange.upperBound == m.endIndex }
            
            range = partRange.lowerBound..<m.endIndex
        }
        
        return true
    }

}

fileprivate struct TimeoutError: Error {}

fileprivate func withTimeout<T: Sendable>(_ d: Duration, returning: T.Type = T.self, code: @Sendable @escaping () async throws -> T, onTimeout: @Sendable @escaping () -> () = {}) async throws -> T {
    try await withThrowingTaskGroup { group in
        group.addTask {
            try await code()
        }
        
        group.addTask {
            try await Task.sleep(for: d)
            onTimeout()
            throw TimeoutError()
        }
        

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}


public actor FireAndForgetTasks {
    var tasks = [Task<Void, Error>]()
    
    public func add(_ code: sending @escaping @isolated(any) () async throws -> ()) {
        tasks.append(Task.detached(operation: code))
    }
    public func cancelAll() {
        for t in tasks {
            t.cancel()
        }
        tasks = []
    }
    
    private init() {}
    public static let shared = FireAndForgetTasks()
}
