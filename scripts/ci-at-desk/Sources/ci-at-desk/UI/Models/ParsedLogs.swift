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
import WorkflowRunning
import Subprocess
import RegexBuilder

// Finds directories under a given directory with a given prefix
fileprivate func dirs(under: URL, withPrefix: String) -> [URL] {
    guard let contents = try? FileManager.default.contentsOfDirectory(at: under, includingPropertiesForKeys: nil) else { return [] }
    let filteredContents = contents.filter { url in
        guard url.lastPathComponent.hasPrefix(withPrefix) else { return false }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDirectory) else { return false }
        guard isDirectory.boolValue else { return false }
        return true
    }
    return filteredContents.sorted(by: { x, y in
        // If the files look like an incrementing prefix,
        // sort by the increment
        let trimmedX = x.lastPathComponent.trimmingPrefix(withPrefix)
        let trimmedY = y.lastPathComponent.trimmingPrefix(withPrefix)
        
        if let intX = Int(trimmedX), let intY = Int(trimmedY) {
            return intX < intY
        }
        
        // Fallback to lexicographic on the file name
        return x.lastPathComponent < y.lastPathComponent
    })
}

fileprivate func contentsOrEmpty(at: URL) -> String {
    (try? String(contentsOf: at, encoding: .utf8)) ?? ""
}

/// Top-level class containing logs for each workflow
@MainActor @Observable class ParsedLogs {
    let url: URL
    var workflows: [WorkflowLog]
    
    init(_ loggingDirectory: URL) {
        url = loggingDirectory
        workflows = dirs(under: url, withPrefix: "workflow-").map(WorkflowLog.init(_:))
    }
    
    var name: String { "ci-at-desk" }
    var id: ObjectIdentifier { .init(self) }
    
    var isEnded: Bool = false
    var containsErrors: Bool = false
    var startTime: Date? = nil
    var endTime: Date? = nil
    
    func refresh() {
        let dirs = dirs(under: url, withPrefix: "workflow-")
        let toAdd = dirs.filter { dir in !workflows.contains(where: { $0.url == dir })}
        workflows.append(contentsOf: toAdd.map(WorkflowLog.init(_:)))
        workflows = workflows.filter { dirs.contains($0.url) }
        
        for w in workflows {
            w.refresh()
        }
        
        if !isEnded && workflows.allSatisfy(\.isEnded) { isEnded = true }
        if !containsErrors && workflows.contains(where: \.containsErrors) { containsErrors = true }
        if startTime == nil {
            startTime = workflows.compactMap(\.startTime).min()
        }
        if endTime == nil {
            let endTimes = workflows.compactMap(\.endTime)
            if endTimes.count == workflows.count { endTime = endTimes.max() }
        }
    }
}

// Contains logs for a workflow and all its jobs
@MainActor @Observable class WorkflowLog: @MainActor Identifiable {
    let url: URL
    let logContents: LogContents
    var jobs: [JobLog]
    
    init(_ workflowDirectory: URL) {
        url = workflowDirectory
        logContents = .init(workflowDirectory)
        jobs = dirs(under: workflowDirectory, withPrefix: "job-").map(JobLog.init(_:))
    }
    
    var name: String { logContents.prettyName ?? url.lastPathComponent }
    var id: ObjectIdentifier { .init(self) }
    
    var isEnded: Bool = false
    var containsErrors: Bool = false
    var startTime: Date? { logContents.startTime }
    var endTime: Date? { logContents.endTime }
    
    func refresh() {
        let dirs = dirs(under: url, withPrefix: "job-")
        let toAdd = dirs.filter { dir in !jobs.contains(where: { $0.url == dir })}
        jobs.append(contentsOf: toAdd.map(JobLog.init(_:)))
        jobs = jobs.filter { dirs.contains($0.url) }
        
        for j in jobs {
            j.refresh()
        }
        
        if !isEnded && logContents.isEnded && jobs.allSatisfy(\.isEnded) { isEnded = true }
        if !containsErrors && (logContents.containsErrors || jobs.contains(where: \.containsErrors)) { containsErrors = true }
    }
}

// Contains logs for a job and all its matrix instances
@MainActor @Observable class JobLog: @MainActor Identifiable {
    let url: URL
    let logContents: LogContents
    var matrixInstances: [MatrixInstanceLog]
    
    init(_ jobDirectory: URL) {
        url = jobDirectory
        logContents = .init(jobDirectory)
        matrixInstances = dirs(under: jobDirectory, withPrefix: "matrix-").map(MatrixInstanceLog.init(_:))
    }
    
    var name: String { logContents.prettyName ?? url.lastPathComponent }
    var id: ObjectIdentifier { .init(self) }
    
    var isEnded: Bool = false
    var containsErrors: Bool = false
    var startTime: Date? { logContents.startTime }
    var endTime: Date? { logContents.endTime }

    func refresh() {
        let dirs = dirs(under: url, withPrefix: "matrix-")
        let toAdd = dirs.filter { dir in !matrixInstances.contains(where: { $0.url == dir })}
        matrixInstances.append(contentsOf: toAdd.map(MatrixInstanceLog.init(_:)))
        matrixInstances = matrixInstances.filter { dirs.contains($0.url) }
        
        for m in matrixInstances {
            m.refresh()
        }
        
        if !isEnded && logContents.isEnded && matrixInstances.allSatisfy(\.isEnded) { isEnded = true }
        if !containsErrors && (logContents.containsErrors || matrixInstances.contains(where: \.containsErrors)) { containsErrors = true }
    }
}

// Contains logs for a matrix instance and all its steps
@MainActor @Observable class MatrixInstanceLog: @MainActor Identifiable {
    let url: URL
    let logContents: LogContents
    var steps: [StepLog]
    
    init(_ matrixInstanceDirectory: URL) {
        url = matrixInstanceDirectory
        logContents = .init(matrixInstanceDirectory)
        steps = dirs(under: matrixInstanceDirectory, withPrefix: "step-").map(StepLog.init(_:))
    }
    
    var name: String { logContents.prettyName ?? url.lastPathComponent }
    var id: ObjectIdentifier { .init(self) }
    
    var isEnded: Bool = false
    var containsErrors: Bool = false
    var startTime: Date? { logContents.startTime }
    var endTime: Date? { logContents.endTime }
    var runnerWorkspace: URL? { logContents.runnerWorkspace }

    func refresh() {
        let dirs = dirs(under: url, withPrefix: "step-")
        let toAdd = dirs.filter { dir in !steps.contains(where: { $0.url == dir })}
        steps.append(contentsOf: toAdd.map(StepLog.init(_:)))
        steps = steps.filter { dirs.contains($0.url) }
        
        for s in steps {
            s.refresh()
        }
        
        if !isEnded && logContents.isEnded && steps.allSatisfy(\.isEnded) { isEnded = true }
        if !containsErrors && (logContents.containsErrors || steps.contains(where: \.containsErrors)) { containsErrors = true }
    }
}

// Contains logs, github outputs, and github summaries for a step
@MainActor @Observable class StepLog: @MainActor Identifiable {
    let url: URL
    let logContents: LogContents
    var githubOutputContents: String
    var githubSummaryContents: String
    
    init(_ stepDirectory: URL) {
        url = stepDirectory
        logContents = .init(stepDirectory)
        githubOutputContents = ""
        githubSummaryContents = ""
    }
    
    var name: String { logContents.prettyName ?? url.lastPathComponent }
    var id: ObjectIdentifier { .init(self) }

    var isEnded: Bool { logContents.isEnded }
    var containsErrors: Bool { logContents.containsErrors }
    var startTime: Date? { logContents.startTime }
    var endTime: Date? { logContents.endTime }
    var runnerWorkspace: URL? { logContents.runnerWorkspace }
    
    func refresh() {
        githubOutputContents = contentsOrEmpty(at: url.appending(path: ".githuboutput.txt"))
        githubSummaryContents = contentsOrEmpty(at: url.appending(path: ".githubstepsummary.txt"))
    }
}

// Contains structured log messages
@MainActor @Observable class LogContents {
    var messages: [InProcessLogNotificationHandler.Message] = []
    var isEnded: Bool = false
    var containsErrors: Bool = false
    var startTime: Date? = nil
    var endTime: Date? = nil
    var prettyName: String? = nil
    var runnerWorkspace: URL?
    
    typealias Line = InProcessLogNotificationHandler.Message
    
    init(_ directory: URL) {
        InProcessLogNotificationHandler.subscribe(url: directory.appending(path: "log.txt")) { [weak self] messages in
            Task { @MainActor in
                self?.addMessages(messages)
            }
        }
        if ci_at_desk_UI.readOnly {
            Task {
                _ = try await Subprocess.run(
                    .name("tail"),
                    arguments: ["-f", "-n+0", directory.appending(path: "log.txt").absoluteURL.path(percentEncoded: false)],
                    preferredBufferSize: 1,
                ) { execution, output in
                    Task { @MainActor in
                        for try await line in output.lines() {
                            let parsedMessage = Self.parseMessage(line)
                            self.addMessages([parsedMessage])
                        }
                    }
                }
            }
        }
    }
    
    private static func parseMessage(_ line: String) -> InProcessLogNotificationHandler.Message {
        // step-Build-Tests 2026-04-21T18:55:18.475Z DEBUG [[]]: note: Using global toolchain override 'Swift 6.3 Release 2026-04-13 (a)'. (in target 'SwiftSyntaxMacros' from project 'swift-syntax')
        // LABEL, SPACE, TIMESTAMP, SPACE, LEVEL, SPACE, LBRACE, METADATA, RBRACE, COLON, SPACE, MESSAGE
        
        let labelRef = Reference(Substring.self)
        let timestampRef = Reference(Date.self)
        let levelRef = Reference(Logger.Level.self)
        let metadataRef = Reference(Substring.self)
        let messageRef = Reference(Substring.self)
        
        let regex = Regex {
            Capture(as: labelRef) { /[^ ]+/ }
            " "
            Capture(as: timestampRef) {
                Date.ISO8601FormatStyle.iso8601WithTimeZone(includingFractionalSeconds: true).regex
            }
            " "
            TryCapture(as: levelRef) {
                ChoiceOf {
                    "TRACE"
                    "DEBUG"
                    "INFO"
                    "NOTICE"
                    "WARNING"
                    "ERROR"
                    "CRITICAL"
                }
            } transform: {
                Logger.Level(rawValue: $0.lowercased())!
            }

            " ["
            Capture(as: metadataRef) { /.*/ }
            "]: "
            Capture(as: messageRef) { /.*/ }
            Optionally {
                CharacterClass.newlineSequence
            }
        }
                
        
        guard let match = line.wholeMatch(of: regex) else {
            return .init(label: "", timestamp: .distantPast, level: .info, metadata: "", message: line)
        }
                
        return .init(label: String(match[labelRef]),
                     timestamp: match[timestampRef],
                     level: match[levelRef],
                     metadata: "[" + match[metadataRef] + "]",
                     message: String(match[messageRef]))
    }
    
    func addMessages(_ newMessages: [InProcessLogNotificationHandler.Message]) {
        messages.append(contentsOf: newMessages)

        if !isEnded && newMessages.contains(where: { $0.message.contains("run() end") }) { isEnded = true }
        if !containsErrors && newMessages.contains(where: { $0.level >= .error }) { containsErrors = true }
        if startTime == nil, let m = newMessages.first(where: { $0.message.contains("run() start") }) { startTime = m.timestamp }
        if endTime == nil, let m = newMessages.first(where: { $0.message.contains("run() end") }) { endTime = m.timestamp }
        if prettyName == nil {
            for m in newMessages {
                if let wholeMatch = m.message.wholeMatch(of: #/name: (.*)/#) {
                    prettyName = String(wholeMatch.output.1)
                    break
                }
            }
        }
        if runnerWorkspace == nil {
            for m in newMessages {
                if let wholeMatch = m.message.wholeMatch(of: #/Runner workspace: (.*)/#) {
                    runnerWorkspace = URL(fileURLWithPath: String(wholeMatch.output.1))
                    break
                }
            }
        }
    }
}


@MainActor struct LogNodeCommonProperties {
    var name: String
    var prettyName: String?
    var children: [LogNodeCommonProperties]
    var isEnded: Bool
    var containsErrors: Bool
    var duration: Double?

    init(name: String,
         prettyName: String?,
         children: [LogNodeCommonProperties],
         isEnded: Bool,
         containsErrors: Bool,
         duration: Double?) {
        self.name = name
        self.prettyName = prettyName
        self.children = children
        self.isEnded = isEnded
        self.containsErrors = containsErrors
        self.duration = duration
    }
    
    private static func duration(_ a: Date?, _ b: Date?) -> Double? {
        guard let a else { return nil }
        return (b ?? Date()).timeIntervalSince(a)
    }
    
    init(_ log: ParsedLogs) {
        self.init(name: log.name,
                  prettyName: nil,
                  children: log.workflows.map(LogNodeCommonProperties.init(_:)),
                  isEnded: log.isEnded,
                  containsErrors: log.containsErrors,
                  duration: Self.duration(log.startTime, log.endTime))
    }
    
    init(_ workflow: WorkflowLog) {
        self.init(name: workflow.name,
                  prettyName: workflow.logContents.prettyName,
                  children: workflow.jobs.map(LogNodeCommonProperties.init(_:)),
                  isEnded: workflow.isEnded,
                  containsErrors: workflow.containsErrors,
                  duration: Self.duration(workflow.startTime, workflow.endTime))
    }
    
    init(_ job: JobLog) {
        self.init(name: job.name,
                  prettyName: job.logContents.prettyName,
                  children: job.matrixInstances.map(LogNodeCommonProperties.init(_:)),
                  isEnded: job.isEnded,
                  containsErrors: job.containsErrors,
                  duration: Self.duration(job.startTime, job.endTime))
    }
    
    init(_ matrixInstance: MatrixInstanceLog) {
        self.init(name: matrixInstance.name,
                  prettyName: matrixInstance.logContents.prettyName,
                  children: matrixInstance.steps.map(LogNodeCommonProperties.init(_:)),
                  isEnded: matrixInstance.isEnded,
                  containsErrors: matrixInstance.containsErrors,
                  duration: Self.duration(matrixInstance.startTime, matrixInstance.endTime))

    }
    
    init(_ step: StepLog) {
        self.init(name: step.name,
                  prettyName: step.logContents.prettyName,
                  children: [],
                  isEnded: step.isEnded,
                  containsErrors: step.containsErrors,
                  duration: Self.duration(step.startTime, step.endTime))
    }
}
