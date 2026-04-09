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

/// View showing the overall summary as written into `$GITHUB_STEP_SUMMARY` by steps
struct SummaryView: View {
    @Environment(AppModel.self) private var model
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Summary").bold()
                Spacer()
            }
            ScrollView {
                if let parsedLogs = model.parsedLogs {
                    ForEach(parsedLogs.workflows) { workflow in
                        ForEach(workflow.jobs) { job in
                            jobView(job)
                        }
                    }
                }
            }
            .textSelection(.enabled)
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder private func jobView(_ job: JobLog) -> some View {
        let shouldShow = !job.matrixInstances.allSatisfy { $0.steps.allSatisfy(\.githubSummaryContents.isEmpty) }
        if shouldShow {
            GroupBox {
                VStack(alignment: .leading) {
                    ForEach(job.matrixInstances) { matrixInstance in
                        ForEach(matrixInstance.steps) { step in
                            if !step.githubSummaryContents.isEmpty {
                                SummaryRenderer(text: step.githubSummaryContents)
                            }
                        }
                    }
                    Spacer()
                }
            } label: {
                Text(job.name).bold()
            }
        }
    }
}

/// View showing the summary for an individual step
fileprivate struct SummaryRenderer: View {
    let text: String
    
    var body: some View {
        let items = Self.parse(text)
        ForEach(Array(items.enumerated()), id: \.offset) { offset, element in
            ItemView(item: element)
        }
        .textSelection(.enabled)
    }
    
    enum Item {
        case codeblock(AttributedString)
        indirect case collapsibleSection(AttributedString, [Item])
        case attributedString(AttributedString)
    }
    
    struct ItemView: View {
        let item: Item
        
        var body: some View {
            switch item {
            case .codeblock(let x):
                GroupBox {
                    HStack {
                        Text(x)
                        Spacer()
                    }
                }
            case .collapsibleSection(let name, let contents):
                DisclosureGroup {
                    if contents.count == 1, case .codeblock = contents.first {
                        ItemView(item: contents.first!)
                    } else {
                        GroupBox {
                            HStack {
                                VStack(alignment: .leading) {
                                    ForEach(Array(contents.enumerated()), id: \.offset) { (offset, element) in
                                        HStack {
                                            ItemView(item: element)
                                            Spacer()
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                } label: {
                    Text(name)
                }
            case .attributedString(let x): Text(x)
            }
        }
    }
}

// MARK: Summary parsing

extension SummaryRenderer {
    static func parse(_ text: String) -> [Item] {
        enum Pass1: Equatable {
            case line(String)
            case unclosedCollapsibleSectionStart
            case collapsibleSection([Pass1])
        }
        
        func pass1(_ text: String) -> [Pass1] {
            var result = [Pass1]()
            
            let lines = text.components(separatedBy: .newlines)
            var i = 0
            while i < lines.count {
                if lines[i] == "<details>" {
                    result.append(.unclosedCollapsibleSectionStart)
                } else if lines[i] == "</details>" {
                    if let unclosedIndex = result.lastIndex(of: .unclosedCollapsibleSectionStart) {
                        let sectionBody = result[unclosedIndex...].dropFirst()
                        result.removeSubrange(unclosedIndex...)
                        result.append(.collapsibleSection(Array(sectionBody)))
                    } else {
                        result.append(.line(lines[i]))
                    }

                } else {
                    result.append(.line(lines[i]))
                }
                
                i += 1
            }
            
            result = result.map {
                switch $0 {
                case .unclosedCollapsibleSectionStart: .line("<details>")
                default: $0
                }
            }
            
            if case .line("") = result.last { result.removeLast() }
            
            return result
        }
        
        enum Pass2 {
            case collapsibleSection(String, [Pass2])
            case line(String)
            case codeblock([String])
        }
        
        func pass2(_ pass1: [Pass1]) -> [Pass2] {
            var result = [Pass2]()
            
            var i = 0
            while i < pass1.count {
                switch pass1[i] {
                case .unclosedCollapsibleSectionStart: fatalError("Impossible")
                    
                case .line("```"):
                    i += 1
                    var blockContents = [String]()
                    while i < pass1.count && pass1[i] != .line("```") {
                        if case let .line(l) = pass1[i] {
                            blockContents.append(l)
                        }
                        i += 1
                    }
                    result.append(.codeblock(blockContents))
                    i += 1
                    
                case .line(let l):
                    result.append(.line(l))
                    i += 1
                    
                case .collapsibleSection(let lines):
                    let _summary = lines.lazy.enumerated().compactMap { (i, x) -> (Int, String)? in
                        guard case let .line(l) = x else { return nil }
                        guard let match = l.wholeMatch(of: #/<summary>(.*)</summary>/#)?.output.1 else { return nil }
                        return (i, String(match))
                    }.first
                    let summary = _summary?.1 ?? ""
                    let summaryIndex = _summary?.0
                                        
                    var recurseLines = lines.enumerated().filter { $0.offset != summaryIndex }.map(\.element)
                    if recurseLines.first == .line("") { recurseLines.removeFirst() }
                    if recurseLines.last == .line("") { recurseLines.removeLast() }
                    
                    result.append(.collapsibleSection(summary, pass2(recurseLines)))
                    i += 1
                }
            }
            return result
        }
        
        enum Pass3 {
            case collapsibleSection(String, [Pass3])
            case paragraph([String])
            case codeblock([String])
        }
        
        func pass3(_ pass2: [Pass2]) -> [Pass3] {
            var result = [Pass3]()
            
            var i = 0
            while i < pass2.count {
                switch pass2[i] {
                case .codeblock(let l):
                    result.append(.codeblock(l))
                    i += 1
                case .collapsibleSection(let name, let contents):
                    result.append(.collapsibleSection(name, pass3(contents)))
                    i += 1
                case .line:
                    var toJoin = [String]()
                    while i < pass2.count {
                        if case let .line(l) = pass2[i] {
                            toJoin.append(l)
                            if l.hasSuffix("  ") { toJoin.append("") }
                        } else {
                            break
                        }
                        i += 1
                    }
                    result.append(.paragraph(toJoin))
                }
            }
            return result
        }
        
        func pass4(_ pass3: [Pass3]) -> [Item] {
            func formAttr(_ l: String) -> AttributedString {
                (try? AttributedString(markdown: l)) ?? AttributedString(l)
            }
            
            
            return pass3.map {
                switch $0 {
                case .codeblock(let l):
                    var result = AttributedString(l.joined(separator: "\n"))
                    result.font = .body.monospaced()
                    return .codeblock(result)
                    
                case .collapsibleSection(let name, let contents):
                    return .collapsibleSection(formAttr(name), pass4(contents))
                    
                case .paragraph(let lines):
                    return .attributedString(join(lines.map(formAttr(_:))))
                }
            }
        }
        
        return pass4(pass3(pass2(pass1(text))))
    }
    
    static func join(_ arr: [AttributedString]) -> AttributedString {
        var result = AttributedString()
        for (i, x) in arr.enumerated() {
            if i + 1 < arr.count { result.append(x + "\n") }
            else { result.append(x) }
        }
        return result
    }

}
