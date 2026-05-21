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
import Charts

/// A view with a table and a chart showing live CPU metrics, driven by an AutoSampler
struct DisplayCPUStats: View {
    let autoSampler: SystemMetricsSampler.AutoSampler
    var aggregationRequests: [SystemMetricsSampler.AutoSampler.TableItemAggregationRequest] = .defaultRequest
            
    var body: some View {
        VStack {
            processesTable
                .frame(minHeight: 50)
            Spacer().frame(height: 16)
            cpuChart
                .frame(minHeight: 50)
        }
        .clipped()
    }
    
    private typealias TableItem = SystemMetricsSampler.AutoSampler.TableItemAggregationResult
    
    @State private var selectedRows = Set<TableItem.ID>()
    @State private var sortOrder: [KeyPathComparator<TableItem>] = []
    @SceneStorage("DisplayCPUStats.processesTable") private var columnCustomization: TableColumnCustomization<TableItem> = .init()
    
    @ViewBuilder
    var processesTable: some View {
        Table.init(autoSampler.tableItems(aggregationRequests: aggregationRequests, sortOrder: sortOrder),
                   selection: $selectedRows,
                   sortOrder: $sortOrder,
                   columnCustomization: $columnCustomization) {
            TableColumn("Process name", sortUsing: KeyPathComparator(\.commandName)) { x in
                Text(x.commandName)
                    .styled(for: x)
            }
            .customizationID("processName")
            
            TableColumn("% CPU", sortUsing: KeyPathComparator(\.cpuUsage)) { x in
                Text(String(format: "%.1f", x.cpuUsage))
                    .styled(for: x)
            }
            .customizationID("cpuPercent")
            
            TableColumn("PID", sortUsing: KeyPathComparator(\.processID)) { x in
                if case .aggregatedAllProcesses = x { EmptyView() }
                else { Text(String(x.processID)).styled(for: x) }
            }
            .customizationID("pid")
        }
    }
    
    @ViewBuilder
    var cpuChart: some View {
        let chartYMax = (autoSampler.rawSamples.last?.numberOfCPUCores ?? 1) * 100
        
        GeometryReader { proxy in
            let yAxisValues = if proxy.size.height > 100 {
                [0, chartYMax / 4, chartYMax / 2, 3 * chartYMax / 4, chartYMax]
            } else if proxy.size.height > 55 {
                [0, chartYMax / 2, chartYMax]
            } else {
                [0, chartYMax]
            }

            Chart {
                if let pidDescendants = aggregationRequests.graphedAggregationRequestPid(autoSampler) {
                    let descendantPoints = autoSampler.rawSamples.enumerated().map {
                        (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), min(Double(chartYMax), $1.perProcessInfo.filter { autoSampler.isSelfOrDescendant(ancestor: pidDescendants, descendant: $0.processID) }.map(\.cpuUsage).reduce(0, +)))
                    }
                    ForEach(descendantPoints, id: \.1) { item in
                        LineMark(x: .value("Time", item.0), y: .value("Percent", item.1))
                    }
                    .foregroundStyle(by: .value("Series", "Process and descendants"))
                }
                
                
                let userPoints = autoSampler.rawSamples.enumerated().map {
                    (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), ($1.cpuUsage.user) * Double($1.numberOfCPUCores))
                }
                ForEach(userPoints, id: \.1) { item in
                    LineMark(x: .value("Time", item.0), y: .value("Percent", item.1))
                }
                .foregroundStyle(by: .value("Series", "User"))
                
                
                let systemPoints = autoSampler.rawSamples.enumerated().map {
                    (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), ($1.cpuUsage.system) * Double($1.numberOfCPUCores))
                }
                ForEach(systemPoints, id: \.1) { item in
                    LineMark(x: .value("Time", item.0), y: .value("Percent", item.1))
                }
                .foregroundStyle(by: .value("Series", "System"))
                
                
                let totalUsagePoints = autoSampler.rawSamples.enumerated().map {
                    (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), (100 - $1.cpuUsage.idle) * Double($1.numberOfCPUCores))
                }
                ForEach(totalUsagePoints, id: \.1) { item in
                    LineMark(x: .value("Time", item.0), y: .value("Percent", item.1))
                }
                .foregroundStyle(by: .value("Series", "Total usage"))
            }
            
            .chartXScale(domain: 0 ... (autoSampler.maxHistory - 1))
            
            .chartYAxis {
                AxisMarks(format: .percent.scale(1),
                          values: yAxisValues)
            }
            .chartYScale(domain: 0.0 ... Double(chartYMax))
        }
    }
}

