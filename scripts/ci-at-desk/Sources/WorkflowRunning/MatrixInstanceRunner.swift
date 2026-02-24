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

/// A matrix-instance level runner, responsible for running individual steps in order
internal struct MatrixInstanceRunner: ~Copyable, RunnerProtocol {
    internal static func run(matrix: [String : Expression], matrixIndex: Int, job: Job, workflow: Workflow, context: inout Context, logger: Logger) async throws {
        logger.debug("MatrixInstanceRunner.run \(matrixIndex + 1)", metadata: [
            "matrix" : matrix.loggerRepresentation,
            "matrixIndex" : matrixIndex.loggerRepresentation,
            "job": job.loggerRepresentation,
            "workflow": workflow.loggerRepresentation,
            "context": context.loggerRepresentation
        ])
        
        var instance = MatrixInstanceRunner(matrix: matrix, matrixIndex: matrixIndex, job: job, workflow: workflow, context: context)
        defer {
            context.merge(other: instance.context, logger: logger)
            logger.debug("MatrixInstanceRunner.run \(matrixIndex + 1) returning")
        }
        
        do {
            try await instance.run()
        } catch {
            instance.logger.error(.init(stringLiteral: String(describing: error)))
            logger.error(.init(stringLiteral: String(describing: error)))
            throw error
        }
    }
    
    private let runnerID: UUID
    private let matrixIndex: Int
    private let job: Job
    private let workflow: Workflow
    private var context: Context
    let fileSystemHelper: FileSystemHelper
    
    init(matrix: [String : Expression], matrixIndex: Int, job: Job, workflow: Workflow, context: borrowing Context) {
        self.runnerID = UUID()
        self.matrixIndex = matrixIndex
        self.job = job
        self.workflow = workflow
        self.fileSystemHelper = FileSystemHelper(yamlConfig: context.yamlConfig, workflow: workflow, job: job, matrixIndex: matrixIndex, matrixRunnerId: runnerID, stepIndex: nil, step: nil)
        self.context = context.detachedCopy()
        self.context.augment(matrixInclude: matrix, logger: logger)
    }
    
    mutating func run() async throws {
        logger.info("run() start", metadata: ["runnerID" : .string(runnerID.uuidString)])
        logger.info("Runner workspace: \(fileSystemHelper.githubWorkspaceDirectory.path(percentEncoded: false))")
        defer { logger.info("run() end"); fileSystemHelper.logLoggingDirectory() }
        
        let jobName = if let nameExpr = job.name {
            try expressionEvaluator.evaluateAsString(nameExpr, in: context)
        } else {
            job.id + " (\(matrixIndex))"
        }
        logger.debug("name: \(jobName)")
        
        try fileSystemHelper.ensureEmptyDirectoryExists(url: fileSystemHelper.runnerRootDirectory)
        try fileSystemHelper.ensureEmptyDirectoryExists(url: fileSystemHelper.githubWorkspaceDirectory)
        try fileSystemHelper.ensureEmptyDirectoryExists(url: fileSystemHelper.runnerTempDirectory)
        context["runner.swiftusd-path"] = .string(fileSystemHelper.swiftUsdWorkspaceDirectory.absoluteURL.path(percentEncoded: false))
        context["github.workspace"] = .string(fileSystemHelper.githubWorkspaceDirectory.absoluteURL.path(percentEncoded: false))

        switch job.kind {
        case .workflow(let workflow):
            logger.debug("Will run workflow '\(workflow.id)'", metadata: [
                "workflow" : workflow.loggerRepresentation,
            ])
            let runJobSucceeded = try await WorkflowOrchestrator.run(workflow: workflow, context: &context, logger: logger, runPrecheckouts: false)
            if !runJobSucceeded {
                context.everyMatrixSucceded = false
            }
            logger.debug("Workflow status: \(runJobSucceeded ? "success" : "failure")")
            
        case .steps(let steps):
            logger.debug("Will run steps")
            context.everyStepSucceeded = true
            
            for (stepIndex, step) in steps.enumerated() {
                let ifIsSatisfied = try expressionEvaluator.evaluateAsBool(step.if_, in: context, purpose: .stepIf)
                if !ifIsSatisfied {
                    logger.debug("Skipping step \(step.name) because step.if_ evaluated to false")
                    continue
                }
                
                logger.debug("Will run step '\(step.name)' (\(stepIndex + 1)/\(steps.count))", metadata: [
                    "step": step.loggerRepresentation,
                ])
                let runStepSucceeded: Bool
                do {
                    runStepSucceeded = try await StepRunner.run(stepIndex: stepIndex, step: step, matrixIndex: matrixIndex, matrixRunnerId: runnerID, job: job, workflow: workflow, context: &context, logger: logger)
                } catch {
                    runStepSucceeded = false
                    logger.error("Got uncaught error from StepRunner.run: \(error)")
                }
                if !runStepSucceeded {
                    context.everyMatrixSucceded = false
                    context.everyStepSucceeded = false
                }
                logger.debug("Step '\(step.name)' status: \(runStepSucceeded ? "success" : "failure")")
            }
        }
        
        if !context.everyMatrixSucceded {
            if job.continueOnError {
                logger.debug("Had matrix failures, but continuing because job.continueOnError is set")
            } else {
                logger.debug("Had matrix failures, cancelling matrix run")
                throw CancellationError()
            }
        }
        
        logger.trace("Will augment context with job outputs")
        // Augment context
        var jobOutputs = [String : Expression]()
        for (k, v) in job.outputs {
            jobOutputs[k] = try expressionEvaluator.evaluate(expression: v, in: context, purpose: .default_)
        }
        context.augment(jobId: job.id, jobOutputs: jobOutputs, logger: logger)
    }
}
