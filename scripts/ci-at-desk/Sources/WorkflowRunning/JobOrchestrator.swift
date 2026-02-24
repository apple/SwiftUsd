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
import Synchronization


/// A job-level orchestrator, responsible for kicking off matrix instances in parallel
// Class because it needs to be copied into the TaskGroup closures,
// and Mutex means it would have to be a noncopyable struct
internal final class JobOrchestrator: Sendable, OrchestratorProtocol {
    internal static func run(job: Job, workflow: Workflow, context: inout Context, logger: Logger) async throws -> Bool {
        logger.debug("JobOrchestrator.run", metadata: [
            "job": job.loggerRepresentation,
            "workflow": workflow.loggerRepresentation,
            "context": context.loggerRepresentation,
        ])
        let instance = JobOrchestrator(workflow: workflow, job: job, context: context)
        defer {
            instance.sharedContext.withLock { context.merge(other: $0, logger: logger) }
            logger.debug("JobOrchestrator.run returning", metadata: ["job" : job.loggerRepresentation])
        }
        
        do {
            try await instance.run()
            return instance.sharedContext.withLock { $0.everyMatrixSucceded }
        } catch {
            instance.logger.error(.init(stringLiteral: String(describing: error)))
            logger.error(.init(stringLiteral: String(describing: error)))
            throw error
        }
    }
    
    private let workflow: Workflow
    private let job: Job
    private let sharedContext: Mutex<Context>
    private let maxMatrixParallelism: Int
    let fileSystemHelper: FileSystemHelper

    private init(workflow: Workflow, job: Job, context: borrowing Context) {
        self.workflow = workflow
        self.job = job
        self.maxMatrixParallelism = context.yamlConfig.maxMatrixParallelism
        self.sharedContext = Mutex(context.detachedCopy())
        self.fileSystemHelper = FileSystemHelper(yamlConfig: context.yamlConfig, workflow: workflow, job: job, matrixIndex: nil, matrixRunnerId: nil, stepIndex: nil, step: nil)
    }
    
    private func run() async throws {
        logger.info("run() start")
        defer { logger.info("run() end"); fileSystemHelper.logLoggingDirectory() }
        
        let jobName = if let nameExpr = job.name {
            sharedContext.withLock { try? expressionEvaluator.evaluateAsString(nameExpr, in: $0) } ?? job.id
        } else {
            job.id
        }
        logger.info("name: \(jobName)")
                
        let (matrixList, strategyMaxParallel) = try sharedContext.withLock { try expressionEvaluator.evaluateAsMatrixList(from: job, in: $0) }
        
        // withThrowingTaskGroup requires a Copyable value
        final class ContextRef: Sendable {
            let value: Context
            
            init(value: consuming Context) {
                self.value = value
            }
        }
        
        try await withThrowingTaskGroup(of: ContextRef.self) { taskGroup in
            var matrixIndex = 0
            
            let activeExclusivityKeys = Mutex(Set<String>())
            
            func queueNextMatrix() {
                if matrixIndex >= matrixList.count { return }
                let matrix = matrixList[matrixIndex]
                logger.debug("Starting new matrix index \(matrixIndex + 1) of \(matrixList.count)")
                _ = taskGroup.addTaskUnlessCancelled { @Sendable [job, workflow, matrixIndex, detachedContext = sharedContext.withLock { $0.detachedCopy() }] in
                    do {
                        var detachedContext = detachedContext.detachedCopy()
                        
                        guard let instanceExclusivityKeys = matrix["exclusivity_keys", default: []].asArray?.compactMap(\.asString),
                              instanceExclusivityKeys.count == matrix["exclusivity_keys", default: []].asArray?.count else {
                             throw JobOrchestratorError.invalidExclusivityKeys(matrix)
                        }
                        self.logger.debug("Instance \(matrixIndex + 1) has exclusivity keys \(instanceExclusivityKeys)")
                        
                        var hasLoggedAboutBeingBlocked = false
                        while true {
                            // Spin-lock, waiting 5 seconds. (Easier than setting up a proper semaphore system)
                            let canRun = activeExclusivityKeys.withLock { activeExclusivityKeys in
                                if activeExclusivityKeys.intersection(instanceExclusivityKeys).isEmpty {
                                    self.logger.debug("Instance \(matrixIndex + 1) is inserting exclusivity keys \(instanceExclusivityKeys)")
                                    activeExclusivityKeys.formUnion(instanceExclusivityKeys)
                                    return true
                                } else {
                                    return false
                                }
                            }
                            if canRun {
                                if hasLoggedAboutBeingBlocked {
                                    self.logger.debug("Instance \(matrixIndex + 1) with exclusivity keys \(instanceExclusivityKeys) is newly unblocked")
                                }
                                break
                            }
                            if !hasLoggedAboutBeingBlocked {
                                hasLoggedAboutBeingBlocked = true
                                self.logger.debug("Instance \(matrixIndex + 1) with exclusivity keys \(instanceExclusivityKeys) is blocked")
                            }
                            try await Task.sleep(for: .seconds(5))
                        }
                        // Make sure that even if an error is thrown later,
                        // we clear the activeExclusivityKeys
                        defer {
                            activeExclusivityKeys.withLock {
                                self.logger.debug("Instance \(matrixIndex + 1) is removing exclusivity keys \(instanceExclusivityKeys)")
                                $0.subtract(instanceExclusivityKeys)
                            }
                        }
                        
                        try await MatrixInstanceRunner.run(matrix: matrix, matrixIndex: matrixIndex, job: job, workflow: workflow, context: &detachedContext, logger: self.logger)
                        return ContextRef(value: detachedContext)
                    } catch {
                        self.logger.error(.init(stringLiteral: String(describing: error)))
                        throw error
                    }
                }
                matrixIndex += 1
            }
            
            // Start by trying to queue everything
            var numberToQueueInitially = matrixList.count
            if strategyMaxParallel != 0 {
                // If the strategy has a limit, make sure we respect that
                numberToQueueInitially = min(strategyMaxParallel, numberToQueueInitially)
            }
            if maxMatrixParallelism != 0 {
                // If the yaml has a limit, make sure we respect that
                numberToQueueInitially = min(maxMatrixParallelism, numberToQueueInitially)
            }
            
            while matrixIndex < numberToQueueInitially {
                queueNextMatrix()
            }
            
            for try await returnedContext in taskGroup {
                sharedContext.withLock { $0.merge(other: returnedContext.value, logger: logger) }
                queueNextMatrix()
            }
        }
    }
    
    enum JobOrchestratorError: Error {
        case invalidExclusivityKeys([String : Expression])
    }
}
