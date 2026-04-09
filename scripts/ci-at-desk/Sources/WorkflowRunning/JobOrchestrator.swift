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
            
            let sharedActiveKeys = Mutex([String : Int]())
            
            func queueNextMatrix() {
                if matrixIndex >= matrixList.count { return }
                let matrix = matrixList[matrixIndex]
                logger.debug("Starting new matrix index \(matrixIndex + 1) of \(matrixList.count)")
                _ = taskGroup.addTaskUnlessCancelled { @Sendable [job, workflow, matrixIndex, detachedContext = sharedContext.withLock { $0.detachedCopy() }] in
                    do {
                        var detachedContext = detachedContext.detachedCopy()
                        
                        func getActiveOrIncompatibleKeys(_ key: String) throws -> [String] {
                            guard let underlyingExpression = matrix[key] else { return [] }
                            guard let exprAsArray = underlyingExpression.asArray else { throw JobOrchestratorError.invalidActiveOrIncompatibleKeys(key, matrix) }
                            let result = exprAsArray.compactMap(\.asString)
                            guard result.count == exprAsArray.count else { throw JobOrchestratorError.invalidActiveOrIncompatibleKeys(key, matrix) }
                            return result
                        }
                        let instanceActiveKeys = try getActiveOrIncompatibleKeys("active_keys")
                        let instanceIncompatibleKeys = try getActiveOrIncompatibleKeys("incompatible_keys")
                        self.logger.debug("Instance \(matrixIndex + 1) has active keys \(instanceActiveKeys) and incompatible keys \(instanceIncompatibleKeys)")
                        
                        
                        var hasLoggedAboutBeingBlocked = false
                        while true {
                            // Spin-lock, waiting 5 seconds. (Easier than setting up a proper semaphore system)
                            let canRun = sharedActiveKeys.withLock { sharedActiveKeys in
                                // If any incompatible key is active, we're blocked
                                for k in instanceIncompatibleKeys {
                                    if sharedActiveKeys[k, default: 0] > 0 {
                                        return false
                                    }
                                }
                                // Every exclusivity key is inactive, so add our active keys to the shared list
                                for k in instanceActiveKeys {
                                    if sharedActiveKeys[k] == nil { sharedActiveKeys[k] = 0 }
                                    sharedActiveKeys[k]! += 1
                                }
                                
                                self.logger.debug("Instance \(matrixIndex + 1) is inserting active keys \(instanceActiveKeys)")
                                
                                return true
                            }
                            if canRun {
                                if hasLoggedAboutBeingBlocked {
                                    self.logger.debug("Instance \(matrixIndex + 1) with active keys \(instanceActiveKeys) and incompatible keys \(instanceIncompatibleKeys) is newly unblocked")
                                }
                                break
                            }
                            if !hasLoggedAboutBeingBlocked {
                                hasLoggedAboutBeingBlocked = true
                                self.logger.debug("Instance \(matrixIndex + 1) with active keys \(instanceActiveKeys) and incompatible keys \(instanceIncompatibleKeys) is blocked")
                            }
                            try await Task.sleep(for: .seconds(5))
                        }
                        // Make sure that even if an error is thrown later,
                        // we clear the activeSharedKeys
                        defer {
                            sharedActiveKeys.withLock { sharedActiveKeys in
                                for k in instanceActiveKeys {
                                    sharedActiveKeys[k]! -= 1
                                    if sharedActiveKeys[k] == 0 { sharedActiveKeys[k] = nil }
                                }
                                
                                self.logger.debug("Instance \(matrixIndex + 1) is removing active keys \(instanceActiveKeys)")
                            }
                        }
                        
                        try Task.checkCancellation()
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
        case invalidActiveOrIncompatibleKeys(String, [String : Expression])
    }
}
