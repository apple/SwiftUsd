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
import Observation
import SwiftUI

extension SystemMetricsSampler {
    /// An automatic sampler for SwiftUI
    @MainActor @Observable class AutoSampler {
        private(set) var rawSamples = [SystemMetricsSampler.Sample]()
        var maxHistory: Int = 30
        
        /// Configurable in the UI, useful for --read-only that wants to measure the aggregated metrics of another process.
        var specialAggregatedPid: Int = Int(getpid())
        
        @ObservationIgnored private var sampleTask: Task<Void, Error>?
        
        func startSampling() {
            stopSampling()
            
            sampleTask = Task { [weak self] in
                while true {
                    try Task.checkCancellation()
                    do {
                        for try await newSample in try await SystemMetricsSampler.streamSamples() {
                            guard let self else { return }
                            rawSamples.append(newSample)
                            if rawSamples.count > maxHistory {
                                rawSamples.removeFirst(rawSamples.count - maxHistory)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            isSampling = true
        }
        
        func stopSampling() {
            sampleTask?.cancel()
            sampleTask = nil
            isSampling = false
            rawSamples = []
        }
        
        var isSampling: Bool = false {
            didSet {
                if isSampling && sampleTask == nil { startSampling() }
                else if !isSampling && sampleTask != nil { stopSampling() }

            }
        }

        init() {
            startSampling()
        }
        
        deinit {
            sampleTask?.cancel()
            sampleTask = nil
        }
        
        @ObservationIgnored private var isSelfOrDescendantBacking: [Int : [Int : Bool]] = [:]
        func isSelfOrDescendant(ancestor: Int, descendant: Int) -> Bool {
            // If we already know the answer, return it
            if let x = isSelfOrDescendantBacking[ancestor]?[descendant] { return x }
            
            // We can't compute the answer, so don't write down an answer, just return
            guard let last = rawSamples.last else { return false }
            
            // Process the last sample to compute the answer
            if isSelfOrDescendantBacking[ancestor] == nil { isSelfOrDescendantBacking[ancestor] = [ancestor : true] }
            func handle(_ p: SystemMetricsSampler.Sample.PerProcessInfo) {
                guard isSelfOrDescendantBacking[ancestor]![p.processID] == nil else { return }
                
                if p.parentProcessId == p.processID {
                    isSelfOrDescendantBacking[ancestor]![p.processID] = ancestor == p.processID
                    return
                }
                                
                // Compute the answer for the parent if needed
                if isSelfOrDescendantBacking[ancestor]![p.parentProcessId] == nil {
                    if let parent = last.perProcessInfo.first(where: { $0.processID == p.parentProcessId }) {
                        handle(parent)
                    }
                }
                                
                // Children are the same as their parents
                isSelfOrDescendantBacking[ancestor]![p.processID] = isSelfOrDescendantBacking[ancestor]![p.parentProcessId]
            }
            
            for p in last.perProcessInfo {
                handle(p)
            }

            // If we still weren't able to compute the answer, fall back to false
            return isSelfOrDescendantBacking[ancestor]![descendant] ?? false
        }
    }
}

// MARK: Aggregation datatypes
extension SystemMetricsSampler.AutoSampler {
    /// A request to aggregate per-process information from a sample
    enum TableItemAggregationRequest {
        case allProcesses
        case descendantsOfProcess(Int)
        case descendantsOfSpecialAggregatedPid
        case null
        static var descendantsOfCurrentProcess: TableItemAggregationRequest {
            .descendantsOfProcess(Int(getpid()))
        }
    }
    
    /// The result of aggregating per-process information from a sample,
    /// or the per-process information of a single sample
    @dynamicMemberLookup
    enum TableItemAggregationResult: Identifiable, Equatable {
        case aggregatedAllProcesses(SystemMetricsSampler.Sample.PerProcessInfo)
        case aggregatedDescendantsOfProcess(SystemMetricsSampler.Sample.PerProcessInfo)
        case null(SystemMetricsSampler.Sample.PerProcessInfo)
        case individualProcess(SystemMetricsSampler.Sample.PerProcessInfo)
        
        var id: Int {
            switch self {
            case .aggregatedAllProcesses: -1
            case .aggregatedDescendantsOfProcess: -2
            case .null: -3
            case .individualProcess(let x): x.processID
            }
        }
        
        subscript<T>(dynamicMember dynamicMember: KeyPath<SystemMetricsSampler.Sample.PerProcessInfo, T>) -> T {
            switch self {
            case let .aggregatedAllProcesses(x), let .aggregatedDescendantsOfProcess(x), let .null(x), let .individualProcess(x): x[keyPath: dynamicMember]
            }
        }
    }
    
    /// Returns the results of the most recent sample for display in a table.
    func tableItems(
        aggregationRequests: [TableItemAggregationRequest] = .defaultRequest,
        sortOrder: [KeyPathComparator<TableItemAggregationResult>] = []
    ) -> [TableItemAggregationResult] {
        guard let last = rawSamples.last, !last.perProcessInfo.isEmpty else { return [] }
        
        var result = [TableItemAggregationResult]()
        for request in aggregationRequests {
            switch request {
            case .allProcesses:
                var toAdd = last.perProcessInfo.combineAll()
                toAdd.commandName = "All Processes"
                result.append(.aggregatedAllProcesses(toAdd))
                
            case .descendantsOfProcess(let x):
                result.append(.aggregatedDescendantsOfProcess(
                    last.perProcessInfo.filter { isSelfOrDescendant(ancestor: x, descendant: $0.processID) }
                        .sorted {
                            if $0.processID == x { return true }
                            if $1.processID == x { return false }
                            return $0.processID < $1.processID
                        }
                        .combineAll()
                ))
                
            case .descendantsOfSpecialAggregatedPid:
                let x = specialAggregatedPid
                result.append(.aggregatedDescendantsOfProcess(
                    last.perProcessInfo.filter { isSelfOrDescendant(ancestor: x, descendant: $0.processID) }
                        .sorted {
                            if $0.processID == x { return true }
                            if $1.processID == x { return false }
                            return $0.processID < $1.processID
                        }
                        .combineAll()
                ))
                
            case .null:
                result.append(.null(last.perProcessInfo.first!))
            }
        }
        
        let perProcess = last.perProcessInfo.map {
            .individualProcess($0)
        }.sorted(using: sortOrder)
        return result + perProcess
    }
}

extension View {
    @ViewBuilder
    func styled(for x: SystemMetricsSampler.AutoSampler.TableItemAggregationResult) -> some View {
        switch x {
        case .aggregatedAllProcesses: self.bold()
        case .aggregatedDescendantsOfProcess: self.bold()
        case .null: EmptyView()
        case .individualProcess: self
        }
    }
}

extension [SystemMetricsSampler.AutoSampler.TableItemAggregationRequest] {
    static var defaultRequest: Self { [.allProcesses, .descendantsOfSpecialAggregatedPid] }
    
    @MainActor func graphedAggregationRequestPid(_ autoSampler: SystemMetricsSampler.AutoSampler) -> Int? {
        for x in self {
            switch x {
            case .allProcesses: continue
            case .descendantsOfProcess(let y): return y
            case .descendantsOfSpecialAggregatedPid: return autoSampler.specialAggregatedPid
            case .null: continue
            }
        }
        return nil
    }
}
