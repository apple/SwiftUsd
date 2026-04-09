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

struct ConsoleSearchInfo {
    var text: String
    var linesBefore: Int
    var linesAfter: Int
    
    init() {
        text = ""
        linesBefore = 0
        linesAfter = 0
    }
}

/// View showing detail about a selected workflow, job, matrix instance, or step
struct NodeDetailView: View {
    @Environment(AppModel.self) private var model
    let node: HierarchicalTableView.Node
    
    @State private var searchInfo = ConsoleSearchInfo()
    
    // HierarchicalTableView.Node only compares the URLs and ignores the log contents, but we want
    // the detail view to refresh if the log contents change, so reextract the logs from the model
    private func extract(workflow: URL) -> WorkflowLog? {
        model.parsedLogs?.workflows.first(where: { $0.url == workflow })
    }
    private func extract(job: URL) -> JobLog? {
        model.parsedLogs?.workflows.flatMap(\.jobs).first(where: { $0.url == job })
    }
    private func extract(matrixInstance: URL) -> MatrixInstanceLog? {
        model.parsedLogs?.workflows.flatMap(\.jobs).flatMap(\.matrixInstances).first(where: { $0.url == matrixInstance })
    }
    private func extract(step: URL) -> StepLog? {
        model.parsedLogs?.workflows.flatMap(\.jobs).flatMap(\.matrixInstances).flatMap(\.steps).first(where: { $0.url == step })
    }
    
    var body: some View {
        Group {
            switch node {
            case .none, .root:
                SummaryView()
                
            case let .workflow(x):
                if let x = extract(workflow: x.url) {
                    HStack {
                        RunnerStatusLabel(x)
                        Spacer()
                    }
                    .padding(.top, 6)
                    ScrollView {
                        LogContentsView(logContents: x.logContents)
                    }
                }
            case let .job(x):
                if let x = extract(job: x.url) {
                    HStack {
                        RunnerStatusLabel(x)
                        Spacer()
                    }
                    .padding(.top, 6)
                    ScrollView {
                        LogContentsView(logContents: x.logContents)
                    }
                }
            case let .matrixInstance(x):
                if let x = extract(matrixInstance: x.url) {
                    HStack {
                        RunnerStatusLabel(x)
                        Spacer()
                    }
                    .padding(.top, 6)
                    GeometryReader { proxy in
                        ScrollView {
                            MatrixInstanceView(matrixInstance: x)
                                .frame(maxWidth: proxy.size.width)
                        }
                    }
                }
                
            case let .step(x):
                if let x = extract(step: x.url) {
                    HStack {
                        RunnerStatusLabel(x)
                        Spacer()
                    }
                    .padding(.top, 6)
                    GeometryReader { proxy in
                        ScrollView {
                            StepView(step: x)
                                .frame(maxWidth: proxy.size.width)
                        }
                    }
                }
            }
        }
        .environment(\.searchInfo, searchInfo)
        .searchable(text: $searchInfo.text)
        .toolbar {
            ToolbarItemGroup {
                HStack {
                    Text("Lines before: \(searchInfo.linesBefore)")
                    Stepper("Lines before", value: $searchInfo.linesBefore, in: 0...100)
                }
                HStack {
                    Text("Lines after: \(searchInfo.linesAfter)")
                    Stepper("Lines after", value: $searchInfo.linesAfter, in: 0...100)
                }
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var searchInfo = ConsoleSearchInfo()
}

fileprivate struct MatrixInstanceView: View {
    let matrixInstance: MatrixInstanceLog
    @Environment(AppModel.self) private var model
    
    func defaultExpansion(for x: StepLog) -> Bool {
        switch model.autoExpandSteps {
        case .never: false
        case .onErrorOnly: x.containsErrors
        case .onSuccessOnly: !x.containsErrors && !x.isEnded
        case .whileInProgressOnly: !x.isEnded
        case .exceptOnError: !x.containsErrors
        case .exceptOnSuccess: x.containsErrors || !x.isEnded
        case .exceptWhileInProgress: !x.isEnded
        case .always: true
        }
    }
    
    func defaultExpansion(for x: MatrixInstanceLog) -> Bool {
        switch model.autoExpandSteps {
        case .never: false
        case .onErrorOnly: x.containsErrors
        case .onSuccessOnly: !x.containsErrors && !x.isEnded
        case .whileInProgressOnly: !x.isEnded
        case .exceptOnError: !x.containsErrors
        case .exceptOnSuccess: x.containsErrors || !x.isEnded
        case .exceptWhileInProgress: !x.isEnded
        case .always: true
        }
    }
    
    var body: some View {
        ForEach(matrixInstance.steps) { step in
            InitialStateDisclosureGroup(isInitiallyExpanded: defaultExpansion(for: step)) {
                StepView(step: step)
            } label: {
                RunnerStatusLabel(step)
            }
        }
        
        InitialStateDisclosureGroup(isInitiallyExpanded: defaultExpansion(for: matrixInstance)) {
            GroupBox {
                LogContentsView(logContents: matrixInstance.logContents)
            }
        } label: {
            RunnerStatusLabel(name: "Log", isEnded: matrixInstance.isEnded, containsErrors: matrixInstance.containsErrors, startTime: matrixInstance.startTime, endTime: matrixInstance.endTime)
        }
    }
}

fileprivate struct StepView: View {
    let step: StepLog
    
    var body: some View {
        TabView {
            Tab {
                LogContentsView(logContents: step.logContents)
            } label: {
                Text("Log")
            }
            
            if !step.githubOutputContents.isEmpty {
                Tab {
                    TextEditor(text: .constant(step.githubOutputContents))
                } label: {
                    Text("GitHub Output")
                }
            }
            
            if !step.githubSummaryContents.isEmpty {
                Tab {
                    TextEditor(text: .constant(step.githubSummaryContents))
                } label: {
                    Text("GitHub Summary")
                }
            }
        }
    }
}
