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


import SwiftUI
import Logging

/// The root view in ci-at-desk-ui
struct ContentView: View {
    @State private var model = AppModel()
    @State private var selection: HierarchicalTableView.Node?
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                Divider()
                LogDisplayControls()
                Divider()
                HierarchicalTableView(parsedLogs: model.parsedLogs, selection: $selection)
                    
            }
        } detail: {
            VStack(alignment: .leading) {
                NodeDetailView(node: selection ?? .none)
            }
            .padding(.leading, 4)
        }
        .navigationSplitViewStyle(.balanced)
        .environment(model)
        .onAppear {
            if let initialConfigFile = ci_at_desk_UI.initialConfigFile {
                model.run(yamlConfig: initialConfigFile)
            }
        }
        .onDisappear {
            model.cancel()
        }
        .alert("Invalid YAML config file", isPresented: $model.isShowingInvalidYamlAlert) {}
    }
}
