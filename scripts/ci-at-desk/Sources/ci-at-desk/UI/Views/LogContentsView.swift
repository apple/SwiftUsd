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
import Logging

/// A view displaying the auto-updating contents of a log file
struct LogContentsView: View {
    let logContents: LogContents
    @Environment(AppModel.self) private var model
    @Environment(\.searchInfo) private var searchInfo: ConsoleSearchInfo
            
    var body: some View {
        if model.rawLogs {
            TextEditor(text: .constant(rawLogContents))
        } else {
            NSTextViewRepresentable(searchInfo: searchInfo, logContents: logContents, model: model)
                .frame(minWidth: minWidth)
                .onChange(of: model.logLevel, updateTextViewSize)
                .onChange(of: model.showMetadata, updateTextViewSize)
                .onChange(of: model.showLabel, updateTextViewSize)
                .onChange(of: model.timestampsMode, updateTextViewSize)
                .onChange(of: model.logLineDisplayLimit, updateTextViewSize)
                .onChange(of: logContents.messages, updateTextViewSize)
        }
    }
    
    @State private var minWidth = 1.0
    
    // NSViewRepresentable.sizeThatFits lets SwiftUI ask AppKit views for their preferred size,
    // but it doesn't let AppKit views proactively tell SwiftUI to call sizeThatFits again and
    // layout the view again. So, we use `.frame(minWidth:)` on the NSViewRepresentable,
    // changing the value within a small range to make SwiftUI redo layout when we know it needs
    // to occur
    func updateTextViewSize() {
        minWidth += 1
        if minWidth > 10 {
            minWidth = 1
        }
    }
    
    var rawLogContents: String {
        String(Self.buildLines(searchInfo: searchInfo, lines: logContents, model: model).characters)
    }
    
    static private func groupAndFilter(searchInfo: ConsoleSearchInfo, lines: LogContents, model: AppModel) -> [[LogContents.Line]] {
        if searchInfo.text.isEmpty {
            var result = lines.messages.filter { $0.level >= model.logLevel }
            if model.logLineDisplayLimit > 0 && result.count > model.logLineDisplayLimit {
                result = Array(result[(result.count - model.logLineDisplayLimit)...])
            }
            return [result]
        }
        
        let directlyMatchingIndices: [Int] = lines.messages.enumerated().compactMap { (i, line) in
            guard line.level >= model.logLevel else { return nil }
            if line.message.localizedCaseInsensitiveContains(searchInfo.text) { return i }
            else { return nil }
        }
        
        var result = [[LogContents.Line]()]
        var addedIndices = Set<Int>()
        
        for directly in directlyMatchingIndices {
            for i in (directly - searchInfo.linesBefore)...(directly + searchInfo.linesAfter) {
                if i < 0 || i >= lines.messages.count { continue }
                if addedIndices.contains(i) { continue }
                
                if addedIndices.contains(i - 1) {
                    result[result.count - 1].append(lines.messages[i])
                } else {
                    result.append([lines.messages[i]])
                }
                addedIndices.insert(i)
            }
        }
        
        var lineCount = 0
        outerLoop: for i in result.indices.reversed() {
            for j in result[i].indices.reversed() {
                lineCount += 1
                if model.logLineDisplayLimit > 0 && lineCount >= model.logLineDisplayLimit {
                    result[i] = Array(result[i][j...])
                    result = Array(result[i...])
                    break outerLoop
                }
            }
        }
        
        result = result.filter { !$0.isEmpty }
        
        return result
    }
    
    static fileprivate func buildLines(searchInfo: ConsoleSearchInfo, lines: LogContents, model: AppModel) -> AttributedString {
        var toJoin = [AttributedString]()
        
        let groups = groupAndFilter(searchInfo: searchInfo, lines: lines, model: model)
        
        for (i, group) in groups.enumerated() {
            for line in group {
                var toAdd = AttributedString()
                if model.showLabel {
                    var label = AttributedString(line.label + " ")
                    label.foregroundColor = NSColor.tertiaryLabelColor
                    toAdd.append(label)
                }
                
                switch model.timestampsMode {
                case .none: break
                case .absolute:
                    let originalTimestamp = line.timestamp.ISO8601Format(.iso8601WithTimeZone(includingFractionalSeconds: true))
                    var timestamp = AttributedString(originalTimestamp + " ")
                    timestamp.foregroundColor = NSColor.secondaryLabelColor
                    timestamp.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                    toAdd.append(timestamp)
                case .relative:
                    let durationInSeconds = model.synchronizedNow.timeIntervalSince(line.timestamp)
                    let formattedTime = Duration.seconds(durationInSeconds).formatted(
                        .time(pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 1))
                    )
                    var timestamp = AttributedString("-" + formattedTime + " ")
                    timestamp.foregroundColor = NSColor.secondaryLabelColor
                    timestamp.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                    toAdd.append(timestamp)
                }
                
                if model.showMetadata {
                    var metadata = AttributedString(line.metadata + " ")
                    metadata.foregroundColor = NSColor(.cyan)
                    toAdd.append(metadata)
                }
                
                // message
                var message = AttributedString(line.message)
                switch line.level {
                case .trace:
                    message.foregroundColor = NSColor(.blue)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                case .debug:
                    message.foregroundColor = NSColor(.secondary)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                case .info:
                    message.foregroundColor = NSColor(.primary)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                case .notice:
                    message.foregroundColor = NSColor(.primary)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .bold)
                case .warning:
                    message.foregroundColor = NSColor(.yellow)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                case .error:
                    message.foregroundColor = NSColor(.red)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                case .critical:
                    message.foregroundColor = NSColor(.red)
                    message.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .bold)
                }
                
                toAdd.append(message)
                
                toJoin.append(toAdd)
            }
            
            if i + 1 < groups.count {
                var separator = AttributedString("--------")
                separator.foregroundColor = NSColor(.secondary)
                separator.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
                toJoin.append(separator)
            }
        }
        
        return joinAttrStringsWithNewline(toJoin)
    }
    
    static private func joinAttrStringsWithNewline(_ arr: [AttributedString]) -> AttributedString {
        var result = AttributedString()
        for (i, x) in arr.enumerated() {
            result += x
            if i + 1 < arr.count {
                result += "\n"
            }
        }
        return result
    }
}

// NSTextView wrapper for SwiftUI, for better performance than a single long Text instance
// in a scroll view
fileprivate struct NSTextViewRepresentable: NSViewRepresentable {
    let searchInfo: ConsoleSearchInfo
    let logContents: LogContents
    let model: AppModel
    
    func makeCoordinator() -> Coordinator {
        .init(logContents: logContents, model: model)
    }

    func makeNSView(context: Context) -> NSTextView {
        context.coordinator.makeNSView()
    }

    func updateNSView(_ textView: NSTextView, context: Context) {
        context.coordinator.updateNSView(textView, searchInfo: searchInfo, logContents: logContents, model: model)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, nsView textView: NSTextView, context: Context) -> CGSize? {
        context.coordinator.sizeThatFits(proposal, nsView: textView)
    }
    
    static func dismantleNSView(_ nsView: NSTextView, coordinator: Coordinator) {
        coordinator.dismantleNSView(nsView)
    }
}

extension NSTextViewRepresentable {
    @MainActor class Coordinator: NSObject {
        var logContents: LogContents
        var model: AppModel
        var textView: NSTextView!
        
        init(logContents: LogContents, model: AppModel) {
            self.logContents = logContents
            self.model = model
        }
        
        @objc func frameDidChange() {
            textView.textContainer?.size = textView.frame.size
            textView.needsLayout = true
            textView.needsDisplay = true
        }
        
        func makeNSView() -> NSTextView {
            textView = NSTextView()
            textView.isEditable = false
            textView.isSelectable = true
            textView.backgroundColor = .clear
            textView.textContainer?.lineBreakMode = .byWordWrapping
            textView.postsFrameChangedNotifications = true
            
            NotificationCenter.default.addObserver(self, selector: #selector(frameDidChange), name: NSView.frameDidChangeNotification, object: textView)
            
            return textView
        }
        
        func updateNSView(_ textView: NSTextView, searchInfo: ConsoleSearchInfo, logContents: LogContents, model: AppModel) {
            self.logContents = logContents
            self.model = model
            
            let attrString = LogContentsView.buildLines(searchInfo: searchInfo, lines: logContents, model: model)
            
            // Copy and restore the selected ranges because setAttributedString() clears the selection
            let selectedRanges = textView.selectedRanges
            textView.textStorage?.setAttributedString(NSAttributedString(attrString))
            textView.selectedRanges = selectedRanges
        }
        
        func dismantleNSView(_ textView: NSTextView) {
            NotificationCenter.default.removeObserver(self)
        }
        
        func sizeThatFits(_ proposal: ProposedViewSize, nsView textView: NSTextView) -> CGSize? {
            guard let textContainer = textView.textContainer else { return nil }
            
            let oldSize = textContainer.size
            defer { textContainer.size = oldSize }
            if let width = proposal.width {
                if width == 0 {
                    textContainer.size.width = 10
                } else {
                    textContainer.size.width = width
                }
            }
            textContainer.size.height = 10000000
            
            textContainer.lineFragmentPadding = 0
            // Important, calling glyphRange makes the layoutManager do some internal calculations
            // instead of just returning a default value for `usedRect(for:)`
            _ = textView.layoutManager?.glyphRange(for: textContainer)
            guard let usedRect = textView.layoutManager?.usedRect(for: textContainer) else { return nil }
            
            // TextKit uses 10000000 to represent an unrestricted size
             var result = usedRect.size
            if result.width == 10000000 {
                result.width = proposal.width ?? 1000
            }
            
            return result
        }
    }
}

extension NSFont: @unchecked @retroactive Sendable {}
