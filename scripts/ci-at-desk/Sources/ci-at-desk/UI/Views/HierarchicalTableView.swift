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
import SwiftUI
import AppKit

/// A table using OutlineGroups to display the workflows, jobs, matrix instances, and steps of a CI run
struct HierarchicalTableView: View {
    let parsedLogs: ParsedLogs?
    @Binding var selection: Node?
    
    enum Node: Hashable, Identifiable {
        var id: Self { self }
        
        case none
        case root(ParsedLogs)
        case workflow(WorkflowLog)
        case job(JobLog)
        case matrixInstance(MatrixInstanceLog)
        case step(StepLog)
        
        @MainActor var children: [Node]? {
            switch self {
            case .none: nil
            case .root(let x): x.workflows.map { .workflow($0) }
            case let .workflow(x): x.jobs.map { .job($0) }
            case let .job(x): x.matrixInstances.map { .matrixInstance($0) }
            case let .matrixInstance(x): x.steps.map { .step($0) }
            case .step: nil
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .none: hasher.combine(0)
            case let .root(x): hasher.combine(x.url)
            case let .workflow(x): hasher.combine(x.url)
            case let .job(x): hasher.combine(x.url)
            case let .matrixInstance(x): hasher.combine(x.url)
            case let .step(x): hasher.combine(x.url)
            }
        }
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none): true
            case let (.root(x), .root(y)) where x.url == y.url: true
            case let (.workflow(x), .workflow(y)) where x.url == y.url: true
            case let (.job(x), .job(y)) where x.url == y.url: true
            case let (.matrixInstance(x), .matrixInstance(y)) where x.url == y.url: true
            case let (.step(x), .step(y)) where x.url == y.url: true
            default: false
            }
        }
    }
    
    var body: some View {
        List(selection: $selection) {
            if let parsedLogs {
                OutlineGroup(Node.root(parsedLogs), children: \.children) { node in
                    switch node {
                    case let .root(x): RunnerStatusLabel(x).showInFinderContextMenu(logs: x.url, runner: nil)
                    case let .workflow(x): RunnerStatusLabel(x).showInFinderContextMenu(logs: x.url.appending(path: "log.txt"), runner: nil)
                    case let .job(x): RunnerStatusLabel(x).showInFinderContextMenu(logs: x.url.appending(path: "log.txt"), runner: nil)
                    case let .matrixInstance(x): RunnerStatusLabel(x).showInFinderContextMenu(logs: x.url.appending(path: "log.txt"), runner: x.runnerWorkspace)
                    case let .step(x): RunnerStatusLabel(x).showInFinderContextMenu(logs: x.url.appending(path: "log.txt"), runner: x.runnerWorkspace)
                    case .none: Text("No parsed logs")
                    }
                }
            }
        }
    }
}

fileprivate extension View {
    func showInFinderContextMenu(logs: URL, runner: URL?) -> some View {
        self.contextMenu {
            Button("Show logs in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([logs])
            }
            if let runner {
                Button("Show runner workspace in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([runner])
                }
            }
        }
    }
}

// todo: add an inline CPU/memory usage chart under the HierarchicalTableView?
