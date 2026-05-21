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

struct OverallSystemMetricsView: View {
    @Bindable var autoSampler: SystemMetricsSampler.AutoSampler    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                LabeledContent("Enable sampling: ") {
                    Toggle("", isOn: $autoSampler.isSampling)
                }
                
                DisplayStorageStats(autoSampler: autoSampler)
                    .frame(maxWidth: 550)
                
                LabeledContent("Aggregated PID: ") {
                    TextField("Aggregated PID", value: $autoSampler.specialAggregatedPid, format: .number.grouping(.never), prompt: Text(String(getpid())))
                        .frame(maxWidth: 75)
                }
            }
            HStack {
                DisplayCPUStats(autoSampler: autoSampler)
                Divider()
                DisplayMemoryStats(autoSampler: autoSampler)
            }
        }
        .padding()
    }
}
