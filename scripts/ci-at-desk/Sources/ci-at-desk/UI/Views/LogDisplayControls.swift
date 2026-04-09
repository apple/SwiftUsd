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

/// Controls for customizing how logs are displayed
struct LogDisplayControls: View {
    @Environment(AppModel.self) private var model
    @State private var isOpenPanelPresented = ci_at_desk_UI.initialConfigFile == nil
    
    private var openButton: some View {
        Button {
            isOpenPanelPresented = true
        } label: {
            Label("Open", systemImage: "square.and.arrow.down")
        }
        .fileImporter(isPresented: $isOpenPanelPresented,
                      allowedContentTypes: [.yaml], onCompletion: { result in
            if let url = try? result.get() {
                model.run(yamlConfig: url)
            } else {
                model.cancel()
            }
        })
    }
    
    private var stopButton: some View {
        Button {
            model.cancel()
        }
        label: {
            Label("Stop", systemImage: "stop.fill")
        }
        .disabled(!model.isRunning)
    }
        
    var body: some View {
        @Bindable var model = model                
        
        HStack {
            Form {
                Group {
                    if !model.isRunning {
                        openButton
                    } else {
                        stopButton
                    }
                }.disabled(ci_at_desk_UI.readOnly)
                
                Toggle("Raw logs", isOn: $model.rawLogs)
                LogLevelPicker(logLevel: $model.logLevel)
                TimestampsPicker(label: "Timestamp mode:", value: $model.timestampsMode)
                AutoExpansionModePicker(label: "Auto-expand logs:", value: $model.autoExpandLogs)
            }
            
            Form {
                let nowString = ISO8601DateFormatter().string(from: model.synchronizedNow)
                Text(nowString)
                    .monospaced()

                
                TextField("Log line display limit:", value: $model.logLineDisplayLimit, format: .number)
                Toggle("Show label", isOn: $model.showLabel)
                Toggle("Show metadata", isOn: $model.showMetadata)
                AutoExpansionModePicker(label: "Auto-expand steps:", value: $model.autoExpandSteps)
            }
        }
        .padding()
    }
}

// MARK: Miscellaneous pickers

fileprivate struct TimestampsPicker: View {
    let label: String
    @Binding var value: AppModel.TimestampsMode
    
    var body: some View {
        Picker(label, selection: $value) {
            ForEach(AppModel.TimestampsMode.allCases) { x in
                Text("\(x.description)")
            }
        }
    }
}

fileprivate struct AutoExpansionModePicker: View {
    let label: String
    @Binding var value: AppModel.AutoExpansionMode
        
    var body: some View {
        Picker(label, selection: $value) {
            ForEach(AppModel.AutoExpansionMode.allCases) { x in
                Text("\(x.description)")
            }
        }
    }
}

fileprivate struct LogLevelPicker: View {
    @Binding var logLevel: Logger.Level
    
    var body: some View {
        Picker("Log level:", selection: $logLevel) {
            ForEach(Logger.Level.allCases, id: \.self) { x in
                Text(x.description)
            }
        }
    }
}
