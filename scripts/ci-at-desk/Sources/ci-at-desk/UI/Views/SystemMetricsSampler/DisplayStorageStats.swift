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

/// A simple view that shows how much storage is available, driven by an AutoSampler
struct DisplayStorageStats: View {
    let autoSampler: SystemMetricsSampler.AutoSampler
    
    @State private var isFreePopoverPresented = false
    
    var freeString: String {
        guard let last = autoSampler.rawSamples.last else { return "N/A" }
        return SystemMetricsSampler.bytesToHumanString(last.diskFree, withSpace: true)
    }
    
    var usedString: String {
        guard let last = autoSampler.rawSamples.last else { return "N/A" }
        return SystemMetricsSampler.bytesToHumanString(last.diskUsed, withSpace: true)
    }
    
    var totalString: String {
        guard let last = autoSampler.rawSamples.last else { return "N/A" }
        return SystemMetricsSampler.bytesToHumanString(last.diskTotalSize, withSpace: true)
    }
    
    var lowFreeSpace: Bool {
        guard let last = autoSampler.rawSamples.last else { return false }
        // 100 GB
        return last.diskFree < 1024 * 1024 * 1024 * 100
    }
    
    var body: some View {
        HStack {
            Text("Disk space free: \(freeString)")
            Button {
                isFreePopoverPresented = true
            } label: {
                Image(systemName: lowFreeSpace ? "exclamationmark.triangle.fill" : "info.circle")
                    .foregroundColor(lowFreeSpace ? .yellow : nil)
                    .imageScale(lowFreeSpace ? .large : .medium)
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $isFreePopoverPresented) {
                Text("ci-at-desk can create many Xcode projects on each run.\nTo reclaim disk space, try removing ~/Library/Developer/Xcode/DerivedData")
                    .padding(6)
            }
            
            Spacer()
            
            Text("Used: \(usedString)")
            
            Spacer()
            
            Text("Total storage: \(totalString)")
            
            Spacer()
        }
    }
}
