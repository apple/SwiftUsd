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

fileprivate struct TableSearchInfo: Hashable {
    var text = ""
    var finishState = FinishState.any
    var successState = SuccessState.any
    var durationState = DurationState.any
    
    enum FinishState: CaseIterable, Identifiable {
        case finished
        case unfinished
        case any
        
        var id: Self { self }
    }
    enum SuccessState: CaseIterable, Identifiable {
        case successful
        case unsuccessful
        case any
        
        var id: Self { self }
    }
    enum DurationState: Hashable {
        case shorterThan(Double)
        case longerThan(Double)
        case any
    }
}

// Search filtering
fileprivate extension HierarchicalTableView.Node {
    @MainActor func children(searchInfo: TableSearchInfo) -> [HierarchicalTableView.Node]? {
        var result: [HierarchicalTableView.Node]? = switch self {
        case .none: nil
        case .root(let x): x.workflows.map { .workflow($0) }
        case let .workflow(x): x.jobs.map { .job($0) }
        case let .job(x): x.matrixInstances.map { .matrixInstance($0) }
        case let .matrixInstance(x): x.steps.map { .step($0) }
        case .step: nil
        }
        
        result = result?.filter { $0.selfOrChildMatches(searchInfo: searchInfo) }
        if result == [] {
            result = nil
        }
                    
        return result
    }
    
    @MainActor func selfOrChildMatches(searchInfo: TableSearchInfo) -> Bool {
        func matchesAll(commonProperties: LogNodeCommonProperties) -> Bool {
            if commonProperties.children.contains(where: { matchesAll(commonProperties: $0) }) { return true }
            
            if !matchesSearchText(commonProperties: commonProperties) { return false }
            if !matchesFinishState(commonProperties: commonProperties) { return false }
            if !matchesSuccessState(commonProperties: commonProperties) { return false }
            if !matchesDurationState(commonProperties: commonProperties) { return false }
            
            return true
        }
        
        func matchesSearchText(commonProperties: LogNodeCommonProperties) -> Bool {
            if searchInfo.text.isEmpty { return true }
            if commonProperties.name.localizedCaseInsensitiveContains(searchInfo.text) { return true }
            if let prettyName = commonProperties.prettyName, prettyName.localizedCaseInsensitiveContains(searchInfo.text) { return true }
            return false
        }
        
        func matchesFinishState(commonProperties: LogNodeCommonProperties) -> Bool {
            switch searchInfo.finishState {
            case .any: true
            case .finished: commonProperties.isEnded
            case .unfinished: !commonProperties.isEnded
            }
        }
        
        func matchesSuccessState(commonProperties: LogNodeCommonProperties) -> Bool {
            switch searchInfo.successState {
            case .any: true
            case .successful: !commonProperties.containsErrors
            case .unsuccessful: commonProperties.containsErrors
            }
        }
        
        func matchesDurationState(commonProperties: LogNodeCommonProperties) -> Bool {
            switch searchInfo.durationState {
            case .any: true
            case let .longerThan(x): commonProperties.duration.map { $0 >= x } ?? false
            case let .shorterThan(x): commonProperties.duration.map { $0 <= x } ?? false
            }
        }
        
        return switch self {
        case .none: matchesAll(commonProperties: .init(name: "", prettyName: nil, children: [], isEnded: false, containsErrors: false, duration: nil))
        case let .root(x): matchesAll(commonProperties: .init(x))
        case let .workflow(x): matchesAll(commonProperties: .init(x))
        case let .job(x): matchesAll(commonProperties: .init(x))
        case let .matrixInstance(x): matchesAll(commonProperties: .init(x))
        case let .step(x): matchesAll(commonProperties: .init(x))
        }
    }
}

/// A table using OutlineGroups to display the workflows, jobs, matrix instances, and steps of a CI run
struct HierarchicalTableView: View {
    let parsedLogs: ParsedLogs?
    @Binding var selection: Node?
    
    @State private var tableSearchInfo = TableSearchInfo()
        
    enum Node: Hashable, Identifiable {
        var id: Self { self }
        
        case none
        case root(ParsedLogs)
        case workflow(WorkflowLog)
        case job(JobLog)
        case matrixInstance(MatrixInstanceLog)
        case step(StepLog)
        
        fileprivate var children: FilterableChildren { .init(node: self) }
        fileprivate struct FilterableChildren {
            var node: Node
            
            @MainActor subscript(searchInfo searchInfo: TableSearchInfo) -> [Node]? {
                node.children(searchInfo: searchInfo)
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
        VStack {
            TableSearchInfoView(info: $tableSearchInfo)
            
            List(selection: $selection) {
                if let parsedLogs {
                    OutlineGroup(Node.root(parsedLogs), children: \.children[searchInfo: tableSearchInfo]) { node in
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
        .searchable(text: $tableSearchInfo.text, placement: .sidebar)
    }
}

fileprivate struct TableSearchInfoView: View {
    @Binding var info: TableSearchInfo
    
    @State private var durationValue = 0.0
    @State private var durationDiscriminant = DurationDiscriminant.any
    
    enum DurationDiscriminant: CaseIterable, Identifiable, CustomStringConvertible {
        case any, longerThan, shorterThan
        
        var id: Self { self }
        
        var description: String {
            switch self {
            case .any: return "any"
            case .longerThan: return ">="
            case .shorterThan: return "<="
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Finished:", selection: $info.finishState) {
                    ForEach(TableSearchInfo.FinishState.allCases) {
                        Text(String(describing: $0))
                    }
                }
                
                Picker("Success:", selection: $info.successState) {
                    ForEach(TableSearchInfo.SuccessState.allCases) {
                        Text(String(describing: $0))
                    }
                }

                Picker("Duration:", selection: $durationDiscriminant) {
                    ForEach(DurationDiscriminant.allCases) {
                        Text(String(describing: $0))
                    }
                }
                .onChange(of: info.durationState, initial: true) { oldValue, newValue in
                    switch newValue {
                    case .any:
                        durationValue = 0
                        durationDiscriminant = .any
                    case .longerThan(let x):
                        durationValue = x
                        durationDiscriminant = .longerThan
                    case .shorterThan(let x):
                        durationValue = x
                        durationDiscriminant = .shorterThan
                    }
                }
                .onChange(of: durationDiscriminant) { oldValue, newValue in
                    switch newValue {
                    case .any: info.durationState = .any
                    case .longerThan: info.durationState = .longerThan(durationValue)
                    case .shorterThan: info.durationState = .shorterThan(durationValue)
                    }
                }
                
                if durationDiscriminant != .any {
                    TextField("Duration", value: $durationValue, format: .number)
                        .onSubmit {
                            switch durationDiscriminant {
                            case .any: break
                            case .longerThan: info.durationState = .longerThan(durationValue)
                            case .shorterThan: info.durationState = .shorterThan(durationValue)
                            }
                        }
                        .disabled(durationDiscriminant == .any)
                }
            }
        }
        .padding([.leading, .trailing])
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
