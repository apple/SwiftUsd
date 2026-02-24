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
            
    var body: some View {
        if model.rawLogs {
            TextEditor(text: .constant(rawLogContents))
        } else {
            NSTextViewRepresentable(logContents: logContents, model: model)
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
        var toJoin = logContents.messages.compactMap { Self.buildLine(line: $0, model: model) }
        
        if model.logLineDisplayLimit > 0 && toJoin.count > model.logLineDisplayLimit {
            toJoin = Array(toJoin.dropFirst(toJoin.count - model.logLineDisplayLimit))
        }

        return toJoin
            .map { String($0.characters) }
            .joined(separator: "\n")
    }

    
    fileprivate static func buildLine(line: LogContents.Line, model: AppModel) -> AttributedString? {
        guard line.level >= model.logLevel else { return nil }
        
        var result = AttributedString()
        if model.showLabel {
            var label = AttributedString(line.label + " ")
            label.foregroundColor = NSColor.tertiaryLabelColor
            result.append(label)
        }
        
        switch model.timestampsMode {
        case .none: break
        case .absolute:
            let originalTimestamp = line.timestamp.ISO8601Format(.iso8601WithTimeZone(includingFractionalSeconds: true))
            var timestamp = AttributedString(originalTimestamp + " ")
            timestamp.foregroundColor = NSColor.secondaryLabelColor
            timestamp.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            result.append(timestamp)
        case .relative:
            let durationInSeconds = model.synchronizedNow.timeIntervalSince(line.timestamp)
            let formattedTime = Duration.seconds(durationInSeconds).formatted(
                .time(pattern: .hourMinuteSecond(padHourToLength: 2, fractionalSecondsLength: 1))
            )
            var timestamp = AttributedString("-" + formattedTime + " ")
            timestamp.foregroundColor = NSColor.secondaryLabelColor
            timestamp.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
            result.append(timestamp)
        }
        
        if model.showMetadata {
            var metadata = AttributedString(line.metadata + " ")
            metadata.foregroundColor = NSColor(.cyan)
            result.append(metadata)
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
        
        result.append(message)
        
        return result
    }
}

// NSTextView wrapper for SwiftUI, for better performance than a single long Text instance
// in a scroll view
fileprivate struct NSTextViewRepresentable: NSViewRepresentable {
    let logContents: LogContents
    let model: AppModel
    
    func makeCoordinator() -> Coordinator {
        .init(logContents: logContents, model: model)
    }

    func makeNSView(context: Context) -> NSTextView {
        context.coordinator.makeNSView()
    }

    func updateNSView(_ textView: NSTextView, context: Context) {
        context.coordinator.updateNSView(textView, logContents: logContents, model: model)
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
        
        func updateNSView(_ textView: NSTextView, logContents: LogContents, model: AppModel) {
            self.logContents = logContents
            self.model = model
            
            var toJoin = logContents.messages.compactMap { line in
                LogContentsView.buildLine(line: line, model: model)
            }
            if model.logLineDisplayLimit > 0 && toJoin.count > model.logLineDisplayLimit {
                toJoin = Array(toJoin.dropFirst(toJoin.count - model.logLineDisplayLimit))
            }
            var attrString = AttributedString()
            for (i, x) in toJoin.enumerated() {
                attrString += x
                if i + 1 < toJoin.count {
                    attrString += "\n"
                }
            }
            
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
