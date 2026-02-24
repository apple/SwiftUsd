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

/// View showing the name, time, and status of a workflow, job, matrix instance, or step
struct RunnerStatusLabel: View {
    @Environment(AppModel.self) private var model
    
    var name: String
    var isEnded: Bool
    var containsErrors: Bool
    var startTime: Date?
    var endTime: Date?
    
    init(name: String, isEnded: Bool, containsErrors: Bool, startTime: Date?, endTime: Date?) {
        self.name = name
        self.isEnded = isEnded
        self.containsErrors = containsErrors
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init(_ x: ParsedLogs) {
        self.init(name: x.name, isEnded: x.isEnded, containsErrors: x.containsErrors, startTime: x.startTime, endTime: x.endTime)
    }
    
    init(_ x: WorkflowLog) {
        self.init(name: x.name, isEnded: x.isEnded, containsErrors: x.containsErrors, startTime: x.startTime, endTime: x.endTime)
    }
    
    init(_ x: JobLog) {
        self.init(name: x.name, isEnded: x.isEnded, containsErrors: x.containsErrors, startTime: x.startTime, endTime: x.endTime)
    }
    
    init(_ x: MatrixInstanceLog) {
        self.init(name: x.name, isEnded: x.isEnded, containsErrors: x.containsErrors, startTime: x.startTime, endTime: x.endTime)
    }
    
    init(_ x: StepLog) {
        self.init(name: x.name, isEnded: x.isEnded, containsErrors: x.containsErrors, startTime: x.startTime, endTime: x.endTime)
    }
    
    var body: some View {
        let elapsedTimeInterval = (endTime ?? model.cancelTime ?? model.synchronizedNow).timeIntervalSince(startTime ?? model.synchronizedNow)
        
        
        let elapsedDuration = Duration.seconds(elapsedTimeInterval)
        let fractionStrategy: Duration.UnitsFormatStyle.FractionalPartDisplayStrategy = if elapsedDuration < .seconds(10) { .show(length: 1) } else { .hide }
        
        let formattedElapsedTime = elapsedDuration.formatted(.units(width: .narrow, fractionalPart: fractionStrategy))
                
        emoji + Text(" " + name) + Text(" (\(formattedElapsedTime))")
    }
    
    private var emoji: Text {
        if isEnded {
            if containsErrors {
                Text("❌")
            } else {
                Text("✅")
            }
        } else if model.cancelTime != nil {
            if containsErrors {
                Text("⏹️❌")
            } else {
                Text("⏹️")
            }
        } else {
            if containsErrors {
                Text("⚙️❌")
            } else {
                Text("⚙️")
            }
        }
    }
}
