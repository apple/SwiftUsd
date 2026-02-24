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

/// The SwiftUI App for the SwiftUI version of ci-at-desk.
// Launched in ci_at_desk.swift
struct ci_at_desk_UI: App {
    @Environment(\.openWindow) var openWindow
    
    static var initialConfigFile: URL?
    
    var body: some Scene {
         Window("ci-at-desk", id: "MainWindow") {
            ContentView()
        }
        .onChange(of: 0, initial: true) {
            // Make ci-at-desk-ui appear in the Cmd-tab app switcher
            NSApplication.shared.setActivationPolicy(.regular)
            NSApplication.shared.activate()
    
            // Open the main window when UI mode launches,
            // required
            openWindow(id: "MainWindow")
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}

