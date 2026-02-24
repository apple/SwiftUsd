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
import Synchronization
import WorkflowDescription
import Logging

/// A workflow level orchestrator, responsible for kicking off jobs in parallel
// Class because it needs to be copied into the TaskGroup closures,
// and Mutex means it would have to be a noncopyable struct
public final class WorkflowOrchestrator: Sendable, OrchestratorProtocol {
    /// The public entry point for external targets to start a CI run
    public static func run(configFile: URL, workflows: [Workflow]) async throws -> Bool {
        let yamlConfig = try YamlConfig(configFile: configFile)
        guard let workflow = workflows.first(where: { $0.id == yamlConfig.workflowId }) else {
            throw WorkflowOrchestratorError.noWorkflowFound(yamlConfig.workflowId, workflows.map(\.id))
        }
        
        // Set up file system
        let fileSystemHelper = FileSystemHelper(yamlConfig: yamlConfig, workflow: workflow, job: nil, matrixIndex: nil, matrixRunnerId: nil, stepIndex: nil, step: nil)
        try fileSystemHelper.ensureEmptyDirectoryExists(url: fileSystemHelper.artifactDirectory)
        try fileSystemHelper.ensureDirectoryExists(url: fileSystemHelper.cacheDirectory)
        try fileSystemHelper.ensureEmptyDirectoryExists(url: yamlConfig.runnerRootDirectory)
        try fileSystemHelper.ensureEmptyDirectoryExists(url: yamlConfig.loggingDirectory)
        
        // Set up context
        var context = Context(yamlConfig: yamlConfig)
        context["github.run_id"] = .string(UUID().uuidString)
        context["inputs"] = .dictionary(yamlConfig.inputs.mapValues { .string($0) })
        context["skips"] = .dictionary(yamlConfig.skips.mapValues { .int($0) })
        
        return try await WorkflowOrchestrator.run(workflow: workflow, context: &context, logger: fileSystemHelper.logger, runPrecheckouts: true)
    }

    private init(workflow: Workflow, context: borrowing Context) {
        // Set up stored properties
        self.workflow = workflow
        self.maxJobParallelism = context.yamlConfig.maxJobParallelism
        
        self.jobIdsToStates = Mutex([String : JobState]())
        self.sharedContext = Mutex(context.detachedCopy())
        self.sharedContext.withLock { $0.everyJobSucceeded = true }
        self.fileSystemHelper = .init(yamlConfig: context.yamlConfig, workflow: workflow, job: nil, matrixIndex: nil, matrixRunnerId: nil, stepIndex: nil, step: nil)
        self.logger.trace("WorkflowOrchestrator.init")
    }
    
    internal static func run(workflow: Workflow, context: inout Context, logger: Logger, runPrecheckouts: Bool) async throws -> Bool {
        logger.trace("WorkflowOrchestrator.run() start", metadata: ["workflow" : workflow.loggerRepresentation,
                                                                    "context" : context.loggerRepresentation])
        let instance = WorkflowOrchestrator(workflow: workflow, context: context)
        defer {
            instance.sharedContext.withLock { context.merge(other: $0, logger: logger) }
            logger.trace("WorkflowOrchestrator.run() end")
        }
        
        do {
            return try await instance.run(runPrecheckouts: runPrecheckouts)
        } catch {
            instance.logger.error(.init(stringLiteral: String(describing: error)))
            logger.error(.init(stringLiteral: String(describing: error)))
            throw error
        }
    }
    
    private func run(runPrecheckouts: Bool) async throws -> Bool {
        logger.info("run() start")
        defer { logger.info("run() end"); fileSystemHelper.logLoggingDirectory() }
        
        logger.info("name: \(workflow.id)")
        
        if runPrecheckouts {
            try await PrecheckoutRunner.run(yamlConfig: sharedContext.withLock { $0.yamlConfig }, logger: fileSystemHelper.logger)
        }
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            try queueMoreJobs(taskGroup: &taskGroup)
            
            for try await _ in taskGroup {
                try queueMoreJobs(taskGroup: &taskGroup)
            }
        }
        
        return sharedContext.withLock { $0.everyJobSucceeded }
    }
        
    private enum JobState {
        case running
        case finished
    }
    
    private let workflow: Workflow
    private let maxJobParallelism: Int
    private let jobIdsToStates: Mutex<[String : JobState]>
    private let sharedContext: Mutex<Context>
    let fileSystemHelper: FileSystemHelper
        
    private func getJobsToStart() throws -> [Job] {
        logger.debug("getJobsToStart")
        let result = try jobIdsToStates.withLock { jobIdsToStates in
            let currentRunningCount = jobIdsToStates.count(where: { $0.value == .running })
            let maxAllowedToStart = maxJobParallelism == 0 ? Int.max : maxJobParallelism - currentRunningCount
            
            var toStart = [Job]()
            for job in workflow.jobs {
                if jobIdsToStates[job.id] != nil { continue }
                if !job.needs.allSatisfy({ jobIdsToStates[$0] == .finished }) { continue }
                toStart.append(job)
                jobIdsToStates[job.id] = .running
                if toStart.count == maxAllowedToStart { break }
            }
            
            if currentRunningCount == 0 && toStart.isEmpty && workflow.jobs.count > jobIdsToStates.count {
                throw WorkflowOrchestratorError.noJobsStart(workflow, jobIdsToStates)
            }
            
            return toStart
        }
        logger.trace("getJobsToStart returning", metadata: [
            "jobs" : .array(result.map(\.loggerRepresentation))
        ])
        return result
    }
    
    private func start(job: Job) async throws {
        logger.debug("start(job:)", metadata: ["job" : job.loggerRepresentation])
        var detachedContext = sharedContext.withLock { $0.detachedCopy() }
        defer { sharedContext.withLock { $0.merge(other: detachedContext, logger: logger) } }
        
        let ifIsSatisfied = try expressionEvaluator.evaluateAsBool(job.if_, in: detachedContext, purpose: .jobIf)
        let runJobSucceeded: Bool
        if ifIsSatisfied {
            logger.trace("Will run job")
            runJobSucceeded = try await JobOrchestrator.run(job: job, workflow: workflow, context: &detachedContext, logger: logger)
        } else {
            logger.trace("Skipping job because its if_ condition is false")
            runJobSucceeded = true
        }
        
        logger.trace("Marking job as finished", metadata: ["job" : job.loggerRepresentation])
        jobIdsToStates.withLock { $0[job.id] = .finished }
        if !runJobSucceeded {
            logger.info("Failing workflow \(workflow.id) because \(job.id) failed")
            detachedContext.everyJobSucceeded = false
        }
    }
    
    private func queueMoreJobs(taskGroup: inout ThrowingTaskGroup<Void, Error>) throws {
        logger.debug("queueMoreJobs")
        for job in try getJobsToStart() {
            taskGroup.addTask { @Sendable in
                do {
                    try await self.start(job: job)
                } catch {
                    self.logger.error(.init(stringLiteral: String(describing: error)))
                    throw error
                }
            }
        }
    }
    
    private enum WorkflowOrchestratorError: Error {
        case noJobsStart(Workflow, [String : JobState])
        case noWorkflowFound(String, [String])
    }
}
