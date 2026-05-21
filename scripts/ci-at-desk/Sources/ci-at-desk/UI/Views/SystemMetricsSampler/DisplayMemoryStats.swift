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

fileprivate extension KeyPathComparator {
    func reversed() -> Self {
        var copy = self
        copy.order = .reverse
        return copy
    }
}

/// A view with a table and a chart showing live memory metrics, driven by an AutoSampler
struct DisplayMemoryStats: View {
    let autoSampler: SystemMetricsSampler.AutoSampler
    var aggregationRequests: [SystemMetricsSampler.AutoSampler.TableItemAggregationRequest] = .defaultRequest

    var body: some View {
        VStack {
            processesTable
                .frame(minHeight: 50)
            Spacer().frame(height: 16)
            memoryChart
                .frame(minHeight: 50)
        }
        .clipped()
    }
    
    private typealias TableItem = SystemMetricsSampler.AutoSampler.TableItemAggregationResult
    
    @State private var selectedRows = Set<TableItem.ID>()
    @State private var sortOrder: [KeyPathComparator<TableItem>] = [KeyPathComparator(\.physicalMemoryFootprint).reversed()]
    @SceneStorage("DisplayMemoryStats.processesTable") private var columnCustomization: TableColumnCustomization<TableItem> = .init()

    
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
            
            TableColumn("Memory", sortUsing: KeyPathComparator(\.physicalMemoryFootprint)) { x in
                Text(SystemMetricsSampler.bytesToHumanString(x.physicalMemoryFootprint, withSpace: true))
                    .styled(for: x)
            }
            .customizationID("memory")
            
            TableColumn("Page ins", sortUsing: KeyPathComparator(\.pageins)) { x in
                Text(String(x.pageins))
                    .styled(for: x)
            }
            .customizationID("pageins")
            
            TableColumn("PID", sortUsing: KeyPathComparator(\.processID)) { x in
                if case .aggregatedAllProcesses = x { EmptyView() }
                else { Text(String(x.processID)).styled(for: x) }
            }
            .customizationID("pid")
        }
    }
    
    @ViewBuilder
    var memoryChart: some View {
        let chartYMax = autoSampler.rawSamples.last?.physicalMemorySize ?? (1024 * 1024 * 1024)
        
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
                        (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), $1.perProcessInfo.filter { autoSampler.isSelfOrDescendant(ancestor: pidDescendants, descendant: $0.processID) }.map(\.physicalMemoryFootprint).reduce(0, +))
                    }
                    ForEach(descendantPoints, id: \.1) { item in
                        LineMark(x: .value("Time", item.0), y: .value("Bytes", item.1))
                    }
                    .foregroundStyle(by: .value("Series", "Process and descendants"))
                }
                
                let usedPoints = autoSampler.rawSamples.enumerated().map {
                    (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), ($1.physicalMemory.used))
                }
                ForEach(usedPoints, id: \.1) { item in
                    LineMark(x: .value("Time", item.0), y: .value("Bytes", item.1))
                }
                .foregroundStyle(by: .value("Series", "Used"))
                
                let compressedPoints = autoSampler.rawSamples.enumerated().map {
                    (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), ($1.physicalMemory.compressor))
                }
                ForEach(compressedPoints, id: \.1) { item in
                    LineMark(x: .value("Time", item.0), y: .value("Bytes", item.1))
                }
                .foregroundStyle(by: .value("Series", "Compressor"))
                
                let memoryPressurePoints = autoSampler.rawSamples.enumerated().map {
                    (Double(autoSampler.maxHistory - autoSampler.rawSamples.count + $0), ($1.memoryPressure * chartYMax / 100))
                }
                ForEach(memoryPressurePoints, id: \.1) { item in
                    LineMark(x: .value("Time", item.0), y: .value("Bytes", item.1))
                }
                .foregroundStyle(by: .value("Series", "Memory pressure"))

            }
            
            .chartXScale(domain: 0 ... (autoSampler.maxHistory - 1))
            
            .chartYAxis {
                AxisMarks(
                    values: yAxisValues
                ) { value in
                    if let x = value.as(Int.self) {
                        AxisValueLabel(SystemMetricsSampler.bytesToHumanString(x, withSpace: true))
                    }
                    AxisGridLine()
                }
            }
            .chartYScale(domain: 0.0 ... Double(chartYMax))
        }
    }
}
