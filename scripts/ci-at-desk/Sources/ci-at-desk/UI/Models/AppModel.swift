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
import Observation
import Subprocess
import System
import Synchronization
import Logging
import WorkflowRunning

/// The main app model for the SwiftUI version of ci-at-desk
@MainActor
@Observable class AppModel {
    private var runner: Runner?
    private(set) var parsedLogs: ParsedLogs?
    
    private(set) var synchronizedNow = Date()
    private(set) var cancelTime: Date?
    
    // UI properties
    var logLevel = Logger.Level.debug
    var showMetadata: Bool = false
    var showLabel: Bool = false
    var timestampsMode: TimestampsMode = .none
    var logLineDisplayLimit: Int = 60
    var rawLogs: Bool = false
    var isShowingInvalidYamlAlert = false
    var autoExpandLogs: AutoExpansionMode = .exceptOnSuccess
    var autoExpandSteps: AutoExpansionMode = .exceptOnSuccess
    
    var isRunning: Bool { if let runner { runner.isRunning } else { false } }
    
    // Setting for how log timestamps are displayed in the UIp
    enum TimestampsMode: String, CustomStringConvertible, CaseIterable, Identifiable, Hashable {
        case none
        case absolute
        case relative
        
        var id: Self { self }
        var description: String { rawValue }
    }
    
    // Setting for when logs in disclosure groups are automatically expanded
    enum AutoExpansionMode: CaseIterable, CustomStringConvertible, Identifiable, Hashable {
        var id: Self { self }
        
        case never
        case onErrorOnly
        case onSuccessOnly
        case whileInProgressOnly
        case exceptOnError
        case exceptOnSuccess
        case exceptWhileInProgress
        case always
        
        var description: String {
            switch self {
            case .never: "never"
            case .onErrorOnly: "on error only"
            case .onSuccessOnly: "on success only"
            case .whileInProgressOnly: "while in progress only"
            case .exceptOnError: "except on error"
            case .exceptOnSuccess: "except on success"
            case .exceptWhileInProgress: "except while in progress"
            case .always: "always"
            }
        }
    }

    init() {
        Task {
            while true {
                parsedLogs?.refresh()
                synchronizedNow = Date()
                try? await Task.sleep(for: .seconds(0.5))
            }
        }
    }
            
    // MARK: UI actions
    func run(yamlConfig: URL) {
        InProcessLogNotificationHandler.clearAllStorage()
        do {
            runner = try Runner(yamlConfig: yamlConfig)
            if let loggingDirectory = runner?.loggingDirectory {
                parsedLogs = ParsedLogs(loggingDirectory)
            }
            cancelTime = nil
        } catch {
            isShowingInvalidYamlAlert = true
        }
    }
    func cancel() {
        runner?.cancel()
        runner = nil
        cancelTime = Date()
        InProcessLogNotificationHandler.clearAllStorage()
    }
}
