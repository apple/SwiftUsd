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
import Subprocess
import Synchronization

/// A type for measuring system metrics (e.g. CPU, memory)
enum SystemMetricsSampler {
    static func bytesToHumanString(_ x: Int, withSpace: Bool = false) -> String {
        let spacer = withSpace ? " " : ""
        guard x > 0 else { return "0\(spacer)B"}
        
        func nLevels(_ n: Int) -> Int { (0..<n).map { _ in 1024 }.reduce(1, *) }
        func formatNLevels(_ n: Int) -> String {
            (Double(x) / Double(nLevels(n - 1)))
                .formatted(.number
                    .precision(.fractionLength(0...1))
                    .rounded(rule: .toNearestOrAwayFromZero, increment: 0.1)
                )
        }
        
        let levels = [
            (1, "B"),
            (2, "KiB"),
            (3, "MiB"),
            (4, "GiB"),
            (5, "TiB")
        ]
        for (n, suffix) in levels {
            if x < nLevels(n) { return "\(formatNLevels(n))\(spacer)\(suffix)"}
        }
        return "\(formatNLevels(6))\(spacer)PiB"
    }
    
    static func parseHumanStringToBytes(_ s: String) -> Int? {
        if s.isEmpty { return nil }
        
        var s = s
        var multiplier: Int = 1
        func consumeSuffixIfPossible(_ xs: [String], _ y: Int) -> Bool {
            for x in xs {
                if s.hasSuffix(x) {
                    s = s.dropLast(x.count).trimmingCharacters(in: .whitespaces)
                    multiplier = y
                    return true
                }
            }
            return false
        }
        
        if consumeSuffixIfPossible(["PB", "P"], 1024 * 1024 * 1024 * 1024 * 1024) {}
        else if consumeSuffixIfPossible(["TB", "T"], 1024 * 1024 * 1024 * 1024) {}
        else if consumeSuffixIfPossible(["GB", "G"], 1024 * 1024 * 1024) {}
        else if consumeSuffixIfPossible(["MB", "M"], 1024 * 1024) {}
        else if consumeSuffixIfPossible(["KB", "K"], 1024) {}
        else if consumeSuffixIfPossible(["B"], 1) {}
        else {}
        
        if let x = Int(s) {
            return x * multiplier
        }
        
        return nil
    }
    
    /// A snapshot of system metrics
    struct Sample {
        var numberOfCPUCores: Int
        // In bytes
        var physicalMemorySize: Int
        // In bytes
        var diskTotalSize: Int
        // In bytes
        var diskUsed: Int
        // In bytes
        var diskFree: Int
        // Percent, 0...100
        var memoryPressure: Int
        
        var globalProcessesInfo: GlobalProcessesInfo
        var sampleDate: Date
        var loadAverage: LoadAverageInfo
        var cpuUsage: CPUUsageInfo
        var sharedLibraries: SharedLibrariesInfo
        var memoryRegions: MemoryRegionsInfo
        var physicalMemory: PhysicalMemoryInfo
        var virtualMemory: VirtualMemoryInfo
        var network: NetworksInfo
        var disk: DisksInfo
        
        var perProcessInfo: [PerProcessInfo]
        
        // Number of processes in a particular state
        struct GlobalProcessesInfo {
            var total: Int
            var running: Int
            var stuck: Int
            var sleeping: Int
            var unknown: Int
            var threads: Int
        }
        
        // Average number of jobs in the run queue
        struct LoadAverageInfo {
            var oneMinute: Double
            var fiveMinutes: Double
            var fifteenMinutes: Double
        }
        
        // Percent, i.e. 0...100
        struct CPUUsageInfo {
            var user: Double
            var system: Double
            var idle: Double
        }
        
        // In bytes
        struct SharedLibrariesInfo {
            var resident: Int
            var data: Int
            var linkedit: Int
        }
        
        struct MemoryRegionsInfo {
            var total: Int
            var resident: Int
            var `private`: Int
            var shared: Int
        }
        
        struct PhysicalMemoryInfo {
            var used: Int
            // Used by the OS, can't be cached, must stay in RAM
            var wired: Int
            // Inactive apps may have their memory compressed so active apps can use more memory
            var compressor: Int
            var unused: Int
        }
        
        // In bytes
        struct VirtualMemoryInfo {
            var total: Int
            var framework: Int
            var swapins: Int
            var swapouts: Int
        }
        
        struct NetworksInfo {
            var packetsIn: Int
            var bytesIn: Int
            var packetsOut: Int
            var bytesOut: Int
        }
        
        // In bytes
        struct DisksInfo {
            var readOperations: Int
            var readSize: Int
            var writeOperations: Int
            var writeSize: Int
        }
        
        /// Information on an individual process, parsed from `top`
        struct PerProcessInfo: Equatable {
            var processID: Int
            var commandName: String
            // Percent
            var cpuUsage: Double
            // In seconds
            var executionTime: Double
            var threadsTotal: Int
            var threadsRunning: Int
            var workQueueTotal: Int
            var workQueueRunning: Int
            var machPorts: Int
            // In bytes
            var physicalMemoryFootprint: Int
            // In bytes
            var purgableMemorySize: Int
            // In bytes
            var cmprs: Int
            var processGroupID: Int
            var parentProcessId: Int
            var state: State
            var boosts: Boosts
            // Percent
            var cpuMe: Double
            // Percent
            var cpuOthers: Double
            var userID: Int
            var pageFaults: Int
            var copyOnWriteFaults: Int
            var machMessagesSent: Int
            var machMessagesReceived: Int
            var bsdSyscalls: Int
            var machSyscalls: Int
            var contextSwitches: Int
            var pageins: Int
            var idlew: String
            var power: String
            var instrs: String
            var cycles: String
            var jetsamPriority: Int
            var user: String
            var mregs: String
            var rprvt: String
            var vprvt: String
            var vsize: String
            var kprvt: String
            var kshrd: String
            
            init(nullInstance: Void) {
                self.processID = -1
                self.commandName = "(null)"
                self.cpuUsage = -1
                self.executionTime = -1
                self.threadsTotal = -1
                self.threadsRunning = -1
                self.workQueueTotal = -1
                self.workQueueRunning = -1
                self.machPorts = -1
                self.physicalMemoryFootprint = -1
                self.purgableMemorySize = -1
                self.cmprs = -1
                self.processGroupID = -1
                self.parentProcessId = -1
                self.state = .unknown
                self.boosts = .init(numberOfBoosts: -1, numberOfTransitionsToBoosted: -1, sentBoostsSincePreviousUpdate: false)
                self.cpuMe = -1
                self.cpuOthers = -1
                self.userID = -1
                self.pageFaults = -1
                self.copyOnWriteFaults = -1
                self.machMessagesSent = -1
                self.machMessagesReceived = -1
                self.bsdSyscalls = -1
                self.machSyscalls = -1
                self.contextSwitches = -1
                self.pageins = -1
                self.idlew = ""
                self.power = ""
                self.instrs = ""
                self.cycles = ""
                self.jetsamPriority = -1
                self.user = ""
                self.mregs = ""
                self.rprvt = ""
                self.vprvt = ""
                self.vsize = ""
                self.kprvt = ""
                self.kshrd = ""
            }
            
            func combined(with other: PerProcessInfo) -> PerProcessInfo {
                var result = self
                result.cpuUsage += other.cpuUsage
                result.executionTime += other.executionTime
                result.threadsTotal += other.threadsTotal
                result.threadsRunning += other.threadsRunning
                result.workQueueTotal += other.workQueueTotal
                result.workQueueRunning += other.workQueueRunning
                result.machPorts += other.machPorts
                result.physicalMemoryFootprint += other.physicalMemoryFootprint
                result.purgableMemorySize += other.purgableMemorySize
                result.cmprs += other.cmprs
                result.cpuMe += other.cpuMe
                result.cpuOthers += other.cpuOthers
                result.pageFaults += other.pageFaults
                result.copyOnWriteFaults += other.copyOnWriteFaults
                result.machMessagesSent += other.machMessagesSent
                result.machMessagesReceived += other.machMessagesReceived
                result.bsdSyscalls += other.bsdSyscalls
                result.machSyscalls += other.machSyscalls
                result.contextSwitches += other.contextSwitches
                result.pageins += other.pageins
                return result
            }
            

            /// Parses the `processLine` from `top` based on the ranges formed from the space-separated components of the header from `top`
            static private func buildComponents(_ headerRanges: [Range<String.Index>], _ processLine: String) -> [String] {
                let clampRange = processLine.startIndex..<processLine.endIndex
                return headerRanges.map {
                    let rangeToSubscriptWith = $0.relative(to: processLine).clamped(to: clampRange)
                    return processLine[rangeToSubscriptWith].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            init?(headerRanges: [Range<String.Index>], processLine: String) {
                let components = Self.buildComponents(headerRanges, processLine)
                
                var i = 0
                struct ParseError: Error {
                    var message: String
                    var index: Int
                }
                func parseString(stripPlusMinus: Bool) throws -> String {
                    if i >= components.count { throw ParseError(message: "parseString", index: i) }
                    i += 1
                    var result = components[i - 1]
                    if stripPlusMinus {
                        result = result.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
                    }
                    return result
                }
                func parseInt() throws -> Int {
                    guard let x = Int(try parseString(stripPlusMinus: true)) else { throw ParseError(message: "parseInt", index: i) }
                    return x
                }
                func parseIntInt() throws -> (Int, Int) {
                    let s = try parseString(stripPlusMinus: true)
                    let components = s.components(separatedBy: "/")
                    if components.count == 0 { throw ParseError(message: "parseIntInt", index: i) }
                    if components.count == 1 {
                        guard let x = Int(components[0]) else { throw ParseError(message: "parseIntInt", index: i) }
                        return (x, x)
                    }
                    if components.count == 2 {
                        guard let x = Int(components[0]), let y = Int(components[1]) else { throw ParseError(message: "parseIntInt", index: i) }
                        return (x, y)
                    }
                    throw ParseError(message: "parseIntInt", index: i)
                }
                func parseTime() throws -> Double {
                    let s = try parseString(stripPlusMinus: true)
                    let components = s.components(separatedBy: ":")
                    
                    var result = 0.0
                    for (i, c) in components.reversed().enumerated() {
                        guard let d = Double(c) else { throw ParseError(message: "parseTime", index: i) }
                        result += d * pow(60.0, Double(i))
                    }
                    
                    return result
                }
                func parseDouble() throws -> Double {
                    guard let x = Double(try parseString(stripPlusMinus: true)) else { throw ParseError(message: "parseDouble", index: i) }
                    return x
                }
                func parseMemory() throws -> Int {
                    guard let x = parseHumanStringToBytes(try parseString(stripPlusMinus: true)) else { throw ParseError(message: "parseMemory", index: i) }
                    return x
                }
                func parseState() throws -> State {
                    guard let x = State(rawValue: try parseString(stripPlusMinus: false)) else { throw ParseError(message: "parseState", index: i) }
                    return x
                }
                func parseBoosts() throws -> Boosts {
                    var s = try parseString(stripPlusMinus: true)
                    var result = Boosts(numberOfBoosts: 0, numberOfTransitionsToBoosted: 0, sentBoostsSincePreviousUpdate: false)
                    if s.starts(with: "*") {
                        result.sentBoostsSincePreviousUpdate = true
                        s = String(s.dropFirst())
                    }
                    guard var lbracketIndex = s.firstIndex(of: "["),
                          let rbracketIndex = s.firstIndex(of: "]"), lbracketIndex < rbracketIndex else { throw ParseError(message: "parseBoosts", index: i) }
                    guard let firstNumber = Int(s[..<lbracketIndex]) else { throw ParseError(message: "parseBoosts", index: i) }
                    lbracketIndex = s.index(after: lbracketIndex)
                    guard lbracketIndex < rbracketIndex else { throw ParseError(message: "parseBoosts", index: i) }
                    guard let secondNumber = Int(s[lbracketIndex..<rbracketIndex]) else { throw ParseError(message: "parseBoosts", index: i) }
                    result.numberOfBoosts = firstNumber
                    result.numberOfTransitionsToBoosted = secondNumber
                    return result
                }
                
                do {
                    self.processID = try parseInt()
                    self.commandName = try parseString(stripPlusMinus: false)
                    self.cpuUsage = try parseDouble()
                    self.executionTime = try parseTime()
                    (self.threadsTotal, self.threadsRunning) = try parseIntInt()
                    (self.workQueueTotal, self.workQueueRunning) = try parseIntInt()
                    self.machPorts = try parseInt()
                    self.physicalMemoryFootprint = try parseMemory()
                    self.purgableMemorySize = try parseMemory()
                    self.cmprs = try parseMemory()
                    self.processGroupID = try parseInt()
                    self.parentProcessId = try parseInt()
                    self.state = try parseState()
                    self.boosts = try parseBoosts()
                    self.cpuMe = try parseDouble()
                    self.cpuOthers = try parseDouble()
                    self.userID = try parseInt()
                    self.pageFaults = try parseInt()
                    self.copyOnWriteFaults = try parseInt()
                    self.machMessagesSent = try parseInt()
                    self.machMessagesReceived = try parseInt()
                    self.bsdSyscalls = try parseInt()
                    self.machSyscalls = try parseInt()
                    self.contextSwitches = try parseInt()
                    self.pageins = try parseInt()
                    self.idlew = try parseString(stripPlusMinus: false)
                    self.power = try parseString(stripPlusMinus: false)
                    self.instrs = try parseString(stripPlusMinus: false)
                    self.cycles = try parseString(stripPlusMinus: false)
                    self.jetsamPriority = try parseInt()
                    self.user = try parseString(stripPlusMinus: false)
                    self.mregs = try parseString(stripPlusMinus: false)
                    self.rprvt = try parseString(stripPlusMinus: false)
                    self.vprvt = try parseString(stripPlusMinus: false)
                    self.vsize = try parseString(stripPlusMinus: false)
                    self.kprvt = try parseString(stripPlusMinus: false)
                    self.kshrd = try parseString(stripPlusMinus: false)
                    
                } catch {
                    return nil
                }
                
                guard i == components.count else {
                    return nil
                }
            }
            
            enum State: String, Equatable {
                case zombie
                case running
                case stuck
                case sleeping
                case idle
                case stopped
                case halted
                case unknown
            }
            
            struct Boosts: Equatable {
                var numberOfBoosts: Int
                var numberOfTransitionsToBoosted: Int
                var sentBoostsSincePreviousUpdate: Bool
            }
        }
    }
    
    static private func getNumberOfCPUCores() async throws -> Int {
        let result = try await Subprocess.run(.name("sysctl"), arguments: ["-n", "hw.ncpu"], output: .string(limit: 1024), error: .discarded)
        guard result.terminationStatus.isSuccess else { throw SampleError.subprocessFailed("sysctl -n hw.ncpu") }
        guard let output = result.standardOutput else { throw SampleError.subprocessStandardOutputIsNil }
        
        guard let x = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw SampleError.subprocessReturnedBadData }
        return x
    }
    
    static private func getPhysicalMemorySize() async throws -> Int {
        let result = try await Subprocess.run(.name("sysctl"), arguments: ["-n", "hw.memsize"], output: .string(limit: 1024), error: .discarded)
        guard result.terminationStatus.isSuccess else { throw SampleError.subprocessFailed("sysctl -n hw.memsize") }
        guard let output = result.standardOutput else { throw SampleError.subprocessStandardOutputIsNil }
        
        guard let x = Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw SampleError.subprocessReturnedBadData }
        return x
    }
    
    static private func getDiskInfo() async throws -> (Int, Int, Int) {
        let result = try await Subprocess.run(
            .name("python3"),
            arguments: ["-c",
                        """
                        import shutil; total, used, free = shutil.disk_usage("/"); print(total); print(used); print(free);
                        """
                       ],
            output: .string(limit: 1024),
            error: .discarded
        )
        
        guard result.terminationStatus.isSuccess else { throw SampleError.subprocessFailed("python3 get disk_usage") }
        guard let output = result.standardOutput else { throw SampleError.subprocessStandardOutputIsNil }
        
        guard let parts = output.components(separatedBy: .whitespacesAndNewlines).filter({ !$0.isEmpty }).map({ Int($0) }) as? [Int] else { throw SampleError.subprocessReturnedBadData }
        guard parts.count == 3 else { throw SampleError.subprocessReturnedBadData }
        return (parts[0], parts[1], parts[2])
    }
    
    static private func getMemoryPressure() async throws -> Int {
        let result = try await Subprocess.run(.name("memory_pressure"), output: .string(limit: 1024 * 1024), error: .discarded)
        
        guard result.terminationStatus.isSuccess else { throw SampleError.subprocessFailed("memory_pressure") }
        guard let output = result.standardOutput else { throw SampleError.subprocessStandardOutputIsNil }
        guard let line = output.components(separatedBy: .newlines).first(where: { $0.contains("System-wide memory free percentage: ") }) else { throw SampleError.subprocessReturnedBadData }
        guard let match = line.trimmingCharacters(in: .whitespacesAndNewlines).wholeMatch(of: #/System-wide memory free percentage: (.*)%/#),
              let freePercentage = Int(match.output.1) else { throw SampleError.subprocessReturnedBadData }
        return 100 - freePercentage
    }
    
    static private func parseGlobalProcessesInfo(_ lines: [String]) throws -> Sample.GlobalProcessesInfo {
        guard lines.count > 1 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[0].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/Processes: (.+) total, (.+) running,( (.+) stuck,)? (.+) sleeping,( (.+) unknown,)? (.+) threads/#) else {
            print(lines[0].trimmingCharacters(in: .whitespaces))
            throw SampleError.badGlobalProcessInfoData
        }
        
        guard let total = Int(match.output.1), let running = Int(match.output.2), let stuck = Int(match.output.4 ?? "0"), let sleeping = Int(match.output.5), let unknown = Int(match.output.7 ?? "0"), let threads = Int(match.output.8) else {
            print(lines[0].trimmingCharacters(in: .whitespaces))
            throw SampleError.badGlobalProcessInfoData
        }
        return .init(total: total, running: running, stuck: stuck, sleeping: sleeping, unknown: unknown, threads: threads)
    }
    
    static private func parseSampleDate(_ lines: [String]) throws -> Date {
        guard lines.count > 2 else { throw SampleError.subprocessReturnedBadData }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        guard let result = dateFormatter.date(from: lines[1]) else { throw SampleError.subprocessReturnedBadData }
        return result
    }
    
    static private func parseLoadAverage(_ lines: [String]) throws -> Sample.LoadAverageInfo {
        guard lines.count > 3 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[2].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/Load Avg: (.+), (.+), (.+)/#) else {
            throw SampleError.badLoadAverageInfoData
        }
        guard let one = Double(match.output.1), let five = Double(match.output.2), let fifteen = Double(match.output.3) else {
            throw SampleError.badLoadAverageInfoData
        }
        return .init(oneMinute: one, fiveMinutes: five, fifteenMinutes: fifteen)
    }
    
    static private func parseCpuUsage(_ lines: [String]) throws -> Sample.CPUUsageInfo {
        guard lines.count > 4 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[3].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/CPU usage: (.+)% user, (.+)% sys, (.+)% idle/#) else {
            throw SampleError.badCpuUsageInfoData
        }
        guard let user = Double(match.output.1), let sys = Double(match.output.2), let idle = Double(match.output.3) else {
            throw SampleError.badCpuUsageInfoData
        }
        return .init(user: user, system: sys, idle: idle)
    }
    
    static private func parseSharedLibraries(_ lines: [String]) throws -> Sample.SharedLibrariesInfo {
        guard lines.count > 5 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[4].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/SharedLibs: (.+) resident, (.+) data, (.+) linkedit\./#) else {
            throw SampleError.badSharedLibrariesInfoData
        }
        guard let resident = parseHumanStringToBytes(String(match.output.1)),
              let data = parseHumanStringToBytes(String(match.output.2)),
              let linkedit = parseHumanStringToBytes(String(match.output.3)) else {
            throw SampleError.badSharedLibrariesInfoData
        }
        return .init(resident: resident, data: data, linkedit: linkedit)
    }
    
    static private func parseMemoryRegions(_ lines: [String]) throws -> Sample.MemoryRegionsInfo {
        guard lines.count > 6 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[5].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/MemRegions: (.+) total, (.+) resident, (.+) private, (.+) shared\./#) else {
            throw SampleError.badMemoryRegionsInfoData
        }
        guard let total = Int(match.output.1),
              let resident = parseHumanStringToBytes(String(match.output.2)),
              let `private` = parseHumanStringToBytes(String(match.output.3)),
              let shared = parseHumanStringToBytes(String(match.output.4)) else {
            throw SampleError.badMemoryRegionsInfoData
        }
        return .init(total: total, resident: resident, private: `private`, shared: shared)
    }
    
    static private func parsePhysicalMemory(_ lines: [String]) throws -> Sample.PhysicalMemoryInfo {
        guard lines.count > 7 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[6].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/PhysMem: (.+) used \((.+) wired, (.+) compressor\), (.+) unused\./#) else {
            throw SampleError.badPhysicalMemoryInfoData
        }
        guard let used = parseHumanStringToBytes(String(match.output.1)),
              let wired = parseHumanStringToBytes(String(match.output.2)),
              let compressor = parseHumanStringToBytes(String(match.output.3)),
              let unused = parseHumanStringToBytes(String(match.output.4)) else {
            throw SampleError.badPhysicalMemoryInfoData
        }
        return .init(used: used, wired: wired, compressor: compressor, unused: unused)
    }
    
    static private func parseVirtualMemory(_ lines: [String]) throws -> Sample.VirtualMemoryInfo {
        guard lines.count > 8 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[7].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/VM: (.+) vsize, (.+) framework vsize, (.+)\(.+\) swapins, (.+)\(.+\) swapouts\./#) else {
            throw SampleError.badVirtualMemoryInfoData
        }
        guard let vsize = parseHumanStringToBytes(String(match.output.1)),
              let frameworkVsize = parseHumanStringToBytes(String(match.output.2)),
              let swapins = Int(match.output.3),
              let swapouts = Int(match.output.4) else {
            throw SampleError.badVirtualMemoryInfoData
        }
        return .init(total: vsize, framework: frameworkVsize, swapins: swapins, swapouts: swapouts)
    }
    
    static private func parseNetwork(_ lines: [String]) throws -> Sample.NetworksInfo {
        guard lines.count > 9 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[8].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/Networks: packets: (.+)/(.+) in, (.+)/(.+) out\./#) else {
            throw SampleError.badNetworksInfoData
        }
        guard let packetInCount = Int(match.output.1),
              let packetInSize = parseHumanStringToBytes(String(match.output.2)),
              let packetOutCount = Int(match.output.3),
              let packetOutSize = parseHumanStringToBytes(String(match.output.4)) else {
            throw SampleError.badNetworksInfoData
        }
        
        return .init(packetsIn: packetInCount, bytesIn: packetInSize, packetsOut: packetOutCount, bytesOut: packetOutSize)
    }
    
    static private func parseDisk(_ lines: [String]) throws -> Sample.DisksInfo {
        guard lines.count > 10 else { throw SampleError.subprocessReturnedBadData }
        guard let match = lines[9].trimmingCharacters(in: .whitespaces).wholeMatch(of: #/Disks: (.+)/(.+) read, (.+)/(.+) written\./#) else {
            throw SampleError.badDisksInfoData
        }
        guard let readCount = Int(match.output.1),
              let readSize = parseHumanStringToBytes(String(match.output.2)),
              let writeCount = Int(match.output.3),
              let writeSize = parseHumanStringToBytes(String(match.output.4)) else {
            throw SampleError.badNetworksInfoData
        }
        
        return .init(readOperations: readCount, readSize: readSize, writeOperations: writeCount, writeSize: writeSize)
    }
    
    static private func parsePerProcessInfo(_ lines: [String]) throws -> [Sample.PerProcessInfo] {
        guard lines.count >= 12 else { return [] }
        let header = lines[11]
        let excerpted = lines[12...]
        
        let headerRanges = header.ranges(of: #/[^\s]+\s*/#)
        guard let result = excerpted.filter({ !$0.isEmpty }).map({ Sample.PerProcessInfo(headerRanges: headerRanges, processLine: $0) }) as? [Sample.PerProcessInfo] else {
            throw SampleError.badPerProcessInfoData
        }
        return result
    }
    
    enum SampleError: Error {
        case subprocessFailed(String)
        case subprocessStandardOutputIsNil
        case subprocessReturnedBadData
        case badGlobalProcessInfoData
        case badLoadAverageInfoData
        case badCpuUsageInfoData
        case badSharedLibrariesInfoData
        case badMemoryRegionsInfoData
        case badPhysicalMemoryInfoData
        case badVirtualMemoryInfoData
        case badNetworksInfoData
        case badDisksInfoData
        case badPerProcessInfoData
    }
    
    /// Streams samples over time to the caller
    static func streamSamples() async throws -> any AsyncSequence<Sample, Error> {
        let numberOfCPUCores = try await getNumberOfCPUCores()
        let physicalMemorySize = try await getPhysicalMemorySize()
                
        return AsyncThrowingStream(Sample.self, bufferingPolicy: .unbounded) { continuation in
            let taskMutex = Mutex(Task<Void, Error>?.none)
            
            continuation.onTermination = { _ in
                taskMutex.withLock { $0?.cancel() }
            }
            
            taskMutex.withLock {
                $0 = Task.detached {
                    _ = try await Subprocess.run(
                        .name("top"),
                        arguments: ["-l0"],
                        input: .none,
                        error: .discarded) { execution, outputSequence in
                            var lines = [String]()
                            for try await line in outputSequence.lines() {
                                lines.append(line)
                                
                                if line.starts(with: "Processes: ") && lines.count > 1 {
                                    let toParse = lines[..<(lines.count - 1)].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    lines.removeFirst(lines.count - 1)
                                    
                                    let (diskTotalSize, diskUsed, diskFree) = try await getDiskInfo()
                                    let memoryPressure = try await getMemoryPressure()
                                    
                                    do {
                                        let sample = Sample(
                                            numberOfCPUCores: numberOfCPUCores,
                                            physicalMemorySize: physicalMemorySize,
                                            diskTotalSize: diskTotalSize,
                                            diskUsed: diskUsed,
                                            diskFree: diskFree,
                                            memoryPressure: memoryPressure,
                                            globalProcessesInfo: try parseGlobalProcessesInfo(toParse),
                                            sampleDate: try parseSampleDate(toParse),
                                            loadAverage: try parseLoadAverage(toParse),
                                            cpuUsage: try parseCpuUsage(toParse),
                                            sharedLibraries: try parseSharedLibraries(toParse),
                                            memoryRegions: try parseMemoryRegions(toParse),
                                            physicalMemory: try parsePhysicalMemory(toParse),
                                            virtualMemory: try parseVirtualMemory(toParse),
                                            network: try parseNetwork(toParse),
                                            disk: try parseDisk(toParse),
                                            perProcessInfo: try parsePerProcessInfo(toParse),
                                        )
                                        continuation.yield(sample)
                                    } catch {
                                        print("stream error: \(error)")
                                        continuation.finish(throwing: error)
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    /// Returns a single sample. Use `streamSamples()` to get samples over time
    static func sample() async throws -> Sample {
        let numberOfCPUCores = try await getNumberOfCPUCores()
        let physicalMemorySize = try await getPhysicalMemorySize()
        let (diskTotalSize, diskUsed, diskFree) = try await getDiskInfo()
        let memoryPressure = try await getMemoryPressure()
        
        let result = try await Subprocess.run(
            .name("top"),
            arguments: ["-l2"],
            output: .string(limit: 1024 * 1024 * 16),
            error: .discarded
        )
        
        guard result.terminationStatus.isSuccess else { throw SampleError.subprocessFailed("top -l2") }
        guard let topOutput = result.standardOutput else { throw SampleError.subprocessStandardOutputIsNil }
        
        var lines = topOutput.components(separatedBy: .newlines)
        guard let secondProcessesIndex = lines[1...].firstIndex(where: { $0.starts(with: "Processes: ")}) else { throw SampleError.subprocessReturnedBadData }
        lines = Array(lines[secondProcessesIndex...])
        
        do {
            return Sample(
                numberOfCPUCores: numberOfCPUCores,
                physicalMemorySize: physicalMemorySize,
                diskTotalSize: diskTotalSize,
                diskUsed: diskUsed,
                diskFree: diskFree,
                memoryPressure: memoryPressure,
                globalProcessesInfo: try parseGlobalProcessesInfo(lines),
                sampleDate: try parseSampleDate(lines),
                loadAverage: try parseLoadAverage(lines),
                cpuUsage: try parseCpuUsage(lines),
                sharedLibraries: try parseSharedLibraries(lines),
                memoryRegions: try parseMemoryRegions(lines),
                physicalMemory: try parsePhysicalMemory(lines),
                virtualMemory: try parseVirtualMemory(lines),
                network: try parseNetwork(lines),
                disk: try parseDisk(lines),
                perProcessInfo: try parsePerProcessInfo(lines),
            )
        } catch {
            throw error
        }
    }
}

extension [SystemMetricsSampler.Sample.PerProcessInfo] {
    func combineAll() -> SystemMetricsSampler.Sample.PerProcessInfo {
        guard let first else { return .init(nullInstance: ()) }
        return dropFirst().reduce(first) { $0.combined(with: $1) }
    }
}
