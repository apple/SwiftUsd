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
import WorkflowRunning

// UI class for asynchronously starting a WorkflowOrchestrator
// in a cancellable task
@MainActor
class Runner {
    private var task: Task<Void, Error>?
    func cancel() {
        task?.cancel()
        task = nil
    }
    var isRunning: Bool { task != nil }
    
    deinit {
        task?.cancel()
        task = nil
    }
    
    let loggingDirectory: URL
    
    init(yamlConfig: URL) throws {
        self.loggingDirectory = try YamlConfig(configFile: yamlConfig).loggingDirectory
        
        if !ci_at_desk_UI.readOnly {
            task = Task.detached {
                _ = try? await WorkflowOrchestrator.run(configFile: yamlConfig, workflows: CLIArgs.workflows)
                Task { @MainActor in
                    self.task = nil
                }
            }
        }
    }
}
