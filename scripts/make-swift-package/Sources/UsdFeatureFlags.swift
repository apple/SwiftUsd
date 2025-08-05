//
//  UsdFeatureFlags.swift
//  make-swift-package
//
//  Created by Maddy Adams on 2/18/25.
//

import Foundation
import ArgumentParser

extension FileSystemInfo {
    /// Represents the aggregate of interesting Usd feature flags from one or more Usd installs,
    /// e.g. which optional plugins were used, was imaging built, was Python enabled
    struct UsdFeatureFlags: Decodable, CustomStringConvertible {
        /// Feature flags that should become detectable at compile time using SwiftUsd.
        /// Maps feature flags from vanilla OpenUSD into a standardized format for SwiftUsd
        static var compileTimeDirectiveFlags: [(String, String)] {
            [
                ("PXR_BUILD_ALEMBIC_PLUGIN", "ALEMBIC"),
                ("PXR_BUILD_DRACO_PLUGIN", "DRACO"),
                ("PXR_BUILD_EMBREE_PLUGIN", "EMBREE"),
                ("PXR_BUILD_OPENCOLORIO_PLUGIN", "OPENCOLORIO"),
                ("PXR_BUILD_OPENIMAGEIO_PLUGIN", "OPENIMAGEIO"),
                ("PXR_BUILD_PRMAN_PLUGIN", "PRMAN"),
                ("PXR_BUILD_IMAGING", "IMAGING"),
                ("PXR_BUILD_USD_IMAGING", "USD_IMAGING"),
                ("PXR_BUILD_IMAGEIO_PLUGIN", "IMAGEIO"),
                ("PXR_ENABLE_MATERIALX_SUPPORT", "MATERIALX"),
                ("PXR_ENABLE_OPENVDB_SUPPORT", "OPENVDB"),
                ("PXR_ENABLE_PTEX_SUPPORT", "PTEX"),
                ("PXR_ENABLE_PYTHON_SUPPORT", "PYTHON"),
            ].map {
                ($0.0, "SwiftUsd_PXR_ENABLE_\($0.1)_SUPPORT")
            }
        }
        
        /// Returns a short name suitable for use in comments if the module name is unavailable on embedded platforms,
        /// or nil if the module name is available on embedded platforms
        static func shortNameForFeatureUnavailableOnEmbeddedPlatforms(moduleName: String) -> String? {
            switch moduleName {
            case "SwiftUsd_PXR_ENABLE_EMBREE_SUPPORT": "Embree"
            case "SwiftUsd_PXR_ENABLE_OPENIMAGEIO_SUPPORT": "OpenImageIO"
            case "SwiftUsd_PXR_ENABLE_OPENVDB_SUPPORT": "OpenVDB"
            default: nil
            }
        }

        /// Most feature flags get merged using boolean AND when using multiple Usd installs.
        /// These flags use OR instead, because they're only available on certain platforms
        static func prefersOrForMergingFeatureFlag(_ flag: String) -> Bool {
            switch flag {
            case "PXR_BUILD_EMBREE_PLUGIN": true
            case "PXR_BUILD_OPENIMAGEIO_PLUGIN": true
            case "PXR_ENABLE_OPENVDB_SUPPORT": true
            default: false
            }
        }
        
        /// Feature flags that must have the same value when coerced to bool
        /// in order to support multiple Usd installs on Apple platforms
        static var coercedBoolMustMatch: [String] {
            [
                "BUILD_SHARED_LIBS",
                "PXR_BUILD_IMAGING",
                "PXR_BUILD_USD_IMAGING",
                "PXR_ENABLE_MATERIALX_SUPPORT",
            ]
        }
        
        /// The raw flags
        var rawFlags: [String : String]
        
        func coerceFlagToBool(_ flag: String) -> Bool {
            rawFlags[flag].map { CMakeValue($0).coercedToBool } ?? false
        }
        
        var description: String {
            "[" + rawFlags.sorted(by: { $0.key < $1.key }).map { "\($0.key) = \(CMakeValue($0.value))" }.joined(separator: ",\n") + "]"
        }
        
        var Boost_NO_BOOST_CMAKE: CMakeValue { _getCMakeValue("Boost_NO_BOOST_CMAKE") }
        var Boost_NO_SYSTEM_PATHS: CMakeValue { _getCMakeValue("Boost_NO_SYSTEM_PATHS") }
        var BUILD_SHARED_LIBS: CMakeValue { _getCMakeValue("BUILD_SHARED_LIBS") }
        var CMAKE_BUILD_TYPE: CMakeValue { _getCMakeValue("CMAKE_BUILD_TYPE") }
        var CMAKE_FIND_ROOT_PATH_MODE_INCLUDE: CMakeValue { _getCMakeValue("CMAKE_FIND_ROOT_PATH_MODE_INCLUDE") }
        var CMAKE_FIND_ROOT_PATH_MODE_LIBRARY: CMakeValue { _getCMakeValue("CMAKE_FIND_ROOT_PATH_MODE_LIBRARY") }
        var CMAKE_FIND_ROOT_PATH_MODE_PACKAGE: CMakeValue { _getCMakeValue("CMAKE_FIND_ROOT_PATH_MODE_PACKAGE") }
        var CMAKE_INSTALL_PREFIX: CMakeValue { _getCMakeValue("CMAKE_INSTALL_PREFIX") }
        var CMAKE_MACOSX_RPATH: CMakeValue { _getCMakeValue("CMAKE_MACOSX_RPATH") }
        var CMAKE_OSX_ARCHITECTURES: CMakeValue { _getCMakeValue("CMAKE_OSX_ARCHITECTURES") }
        var CMAKE_OSX_SYSROOT: CMakeValue { _getCMakeValue("CMAKE_OSX_SYSROOT") }
        var CMAKE_PREFIX_PATH: CMakeValue { _getCMakeValue("CMAKE_PREFIX_PATH") }
        var CMAKE_SYSTEM_NAME: CMakeValue { _getCMakeValue("CMAKE_SYSTEM_NAME") }
        var CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH: CMakeValue { _getCMakeValue("CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH") }
        var PXR_BUILD_ALEMBIC_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_ALEMBIC_PLUGIN") }
        var PXR_BUILD_ANIMX_TESTS: CMakeValue { _getCMakeValue("PXR_BUILD_ANIMX_TESTS") }
        var PXR_BUILD_DOCUMENTATION: CMakeValue { _getCMakeValue("PXR_BUILD_DOCUMENTATION") }
        var PXR_BUILD_DRACO_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_DRACO_PLUGIN") }
        var PXR_BUILD_EMBREE_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_EMBREE_PLUGIN") }
        var PXR_BUILD_EXAMPLES: CMakeValue { _getCMakeValue("PXR_BUILD_EXAMPLES") }
        var PXR_BUILD_IMAGEIO_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_IMAGEIO_PLUGIN") }
        var PXR_BUILD_HTML_DOCUMENTATION: CMakeValue { _getCMakeValue("PXR_BUILD_HTML_DOCUMENTATION") }
        var PXR_BUILD_IMAGING: CMakeValue { _getCMakeValue("PXR_BUILD_IMAGING") }
        var PXR_BUILD_MAYAPY_TESTS: CMakeValue { _getCMakeValue("PXR_BUILD_MAYAPY_TESTS") }
        var PXR_BUILD_OPENCOLORIO_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_OPENCOLORIO_PLUGIN") }
        var PXR_BUILD_OPENIMAGEIO_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_OPENIMAGEIO_PLUGIN") }
        var PXR_BUILD_PRMAN_PLUGIN: CMakeValue { _getCMakeValue("PXR_BUILD_PRMAN_PLUGIN") }
        var PXR_BUILD_PYTHON_DOCUMENTATION: CMakeValue { _getCMakeValue("PXR_BUILD_PYTHON_DOCUMENTATION") }
        var PXR_BUILD_TESTS: CMakeValue { _getCMakeValue("PXR_BUILD_TESTS") }
        var PXR_BUILD_TUTORIALS: CMakeValue { _getCMakeValue("PXR_BUILD_TUTORIALS") }
        var PXR_BUILD_USDVIEW: CMakeValue { _getCMakeValue("PXR_BUILD_USDVIEW") }
        var PXR_BUILD_USD_IMAGING: CMakeValue { _getCMakeValue("PXR_BUILD_USD_IMAGING") }
        var PXR_BUILD_USD_TOOLS: CMakeValue { _getCMakeValue("PXR_BUILD_USD_TOOLS") }
        var PXR_BUILD_USD_VALIDATION: CMakeValue { _getCMakeValue("PXR_BUILD_USD_VALIDATION") }
        var PXR_ENABLE_MATERIALX_SUPPORT: CMakeValue { _getCMakeValue("PXR_ENABLE_MATERIALX_SUPPORT") }
        var PXR_ENABLE_OPENVDB_SUPPORT: CMakeValue { _getCMakeValue("PXR_ENABLE_OPENVDB_SUPPORT") }
        var PXR_ENABLE_PTEX_SUPPORT: CMakeValue { _getCMakeValue("PXR_ENABLE_PTEX_SUPPORT") }
        var PXR_ENABLE_PYTHON_SUPPORT: CMakeValue { _getCMakeValue("PXR_ENABLE_PYTHON_SUPPORT") }
        var PXR_PREFER_SAFETY_OVER_SPEED: CMakeValue { _getCMakeValue("PXR_PREFER_SAFETY_OVER_SPEED") }
        var PXR_USE_BOOST_PYTHON: CMakeValue { _getCMakeValue("PXR_USE_BOOST_PYTHON") }
        var PXR_USE_DEBUG_PYTHON: CMakeValue { _getCMakeValue("PXR_USE_DEBUG_PYTHON") }
        var Python3_EXECUTABLE: CMakeValue { _getCMakeValue("Python3_EXECUTABLE") }
        var Python3_INCLUDE_DIR: CMakeValue { _getCMakeValue("Python3_INCLUDE_DIR") }
        var Python3_LIBRARY: CMakeValue { _getCMakeValue("Python3_LIBRARY") }
        var TBB_USE_DEBUG_BUILD: CMakeValue { _getCMakeValue("TBB_USE_DEBUG_BUILD") }

        
        
        private func _getCMakeValue(_ x: String) -> CMakeValue {
            guard let value = rawFlags[x] else { return .falsey("") }
            return .init(value)
        }
        
        init(usdInstall: URL) throws {
            let logLine = try Self.getLogFileLine(usdInstall: usdInstall)
            rawFlags = Dictionary.init(try Self.splitLogLineToRawFlags(logLine), uniquingKeysWith: { $1 })
        }
                
        /// Merges the feature flags for multiple different Usd installs into a single UsdFeatureFlags instance
        /// that represents all of them
        static func merge(_ featureFlags: [UsdFeatureFlags]) throws -> UsdFeatureFlags {
            // Require compatibility...
            for requiredMatchFlag in Self.coercedBoolMustMatch {
                let mappedFeatureFlags = featureFlags.map({ $0._getCMakeValue(requiredMatchFlag) })
                guard Set(mappedFeatureFlags.map(\.coercedToBool)).count == 1 else {
                    throw ValidationError("Incompatible values for \(requiredMatchFlag): \(mappedFeatureFlags.description)")
                }
            }
            
            var result = featureFlags.first!
            for other in featureFlags.dropFirst() {
                for (k, v) in other.rawFlags {
                    if result.rawFlags[k] == nil {
                        // Missing values get added
                        result.rawFlags[k] = v
                    } else {
                        // Existing non-bools keep the first value.
                        // Existing bools get combined, either by ANDing or ORing
                        let oldValue = CMakeValue(result.rawFlags[k]!)
                        let newValue = CMakeValue(v)
                        
                        guard oldValue.isBooleany && newValue.isBooleany else { continue }
                        
                        if oldValue.coercedToBool != newValue.coercedToBool {
                            if Self.prefersOrForMergingFeatureFlag(k) {
                                // OR: If the old value was true, keep it. If it was false, use the new value
                                result.rawFlags[k] = oldValue.coercedToBool ? result.rawFlags[k] : v
                            } else {
                                // AND: If the old value was false, keep it. If it was true, use the new value
                                result.rawFlags[k] = !oldValue.coercedToBool ? result.rawFlags[k] : v
                            }
                        }
                    }
                }
            }
            return result
        }
        
        /// Splits the log line from `USD_INSTALL/build/OpenUSD/log.txt` into a map of feature flags and their values
        static func splitLogLineToRawFlags(_ logLine: String) throws -> [(String, String)] {
            // log-line := `cmake ` <flags> ` <source-path>
            // flag := `-D` <flag-name> `=` <unquoted-string> | <quoted-string> \s+
            // flag-name := [A-Za-z0-9_]+
            // unquoted-string := ([^ ]|(\ ))+
            // quoted-string := `"`([^"]|(\\"))+`"`
            // source-path := quoted-string
            
            var logLine = logLine
            guard logLine.starts(with: "cmake ") else { throw ValidationError("Bad log line (0): \(logLine)") }
            logLine.trimPrefix("cmake ")
            
            var result = [(String, String)]()
            
            enum ParseState {
                case lookingForMinusD
                case buildingFlagName
                case buildingStringValue(separator: String)
            }
            var buffer = ""
            var flagName: String?
            var parseState = ParseState.lookingForMinusD
                        
            var index = logLine.startIndex
            charLoop: while index < logLine.endIndex {
                let c = String(logLine[index])
                index = logLine.index(after: index)
                
                func throwBadLogLine(key: Int) throws -> Never {
                    var i = 0
                    var x = logLine.startIndex
                    while x != index {
                        i += 1
                        x = logLine.index(after: x)
                    }
                    throw ValidationError("Bad log line: '\(key)'. Char '\(c)', index '\(i)', parseState '\(parseState)', flagName \(String(describing: flagName)), buffer \(buffer), result '\(result)' line \(logLine)")
                }
                
                switch parseState {
                case .lookingForMinusD:
                    if c == " " { continue }
                    if c == "\"" { break charLoop }
                    guard c == "-" else { try throwBadLogLine(key: 1) }
                    guard index < logLine.endIndex, logLine[index] == "D" else { try throwBadLogLine(key: 2) }
                    index = logLine.index(after: index)
                    parseState = .buildingFlagName
                    continue charLoop
                    
                case .buildingFlagName:
                    if c.wholeMatch(of: #/[A-Za-z0-9_]/#) != nil {
                        buffer.append(c)
                        continue charLoop
                        
                    } else if c == " " || c == "=" {
                        guard flagName == nil else { fatalError() }
                        flagName = buffer
                        buffer = ""
                        
                        index = logLine.index(before: index)
                        var equalsCount = 0
                        while index < logLine.endIndex, logLine[index].isWhitespace || logLine[index] == "=" {
                            if logLine[index] == "=" { equalsCount += 1 }
                            index = logLine.index(after: index)
                        }
                        if equalsCount != 1 || index >= logLine.endIndex {
                            try throwBadLogLine(key: 3)
                        }
                        parseState = logLine[index] == "\"" ? .buildingStringValue(separator: "\"") : .buildingStringValue(separator: " ")
                        if logLine[index] == "\"" || logLine[index] == " " {
                            index = logLine.index(after: index)
                        }
                        continue charLoop
                        
                    } else {
                        try throwBadLogLine(key: 4)
                    }
                    
                case .buildingStringValue(separator: let separator):
                    switch c {
                    case separator:
                        result.append((flagName!, buffer))
                        buffer = ""
                        flagName = nil
                        parseState = .lookingForMinusD
                        continue charLoop
                        
                    case "\\":
                        guard index < logLine.endIndex else { try throwBadLogLine(key: 5) }
                        buffer.append(logLine[index])
                        index = logLine.index(after: index)
                        continue charLoop
                        
                    default:
                        buffer.append(c)
                        continue charLoop
                    }
                }
            }
            
            return result
        }
        
        enum CMakeValue: CustomStringConvertible {
            case truthy(String)
            case falsey(String)
            case string(String)
            
            var asRawString: String {
                switch self {
                case let .truthy(s), let .falsey(s), let .string(s): s
                }
            }
            
            var description: String {
                switch self {
                case let .truthy(s): "\(s) (true)"
                case let .falsey(s): "\(s) (false)"
                case let .string(s): s
                }
            }
            
            var coercedToBool: Bool {
                switch self {
                case .truthy: true
                case .falsey: false
                case .string: false
                }
            }
            var isBooleany: Bool {
                switch self {
                case .truthy, .falsey: true
                case .string: false
                }
            }
            
            init(_ s: String) {
                // Truthy: 1, ON, YES, TRUE, Y, non-zero number (case-insenstive)
                // Falsy: 0, OFF, NO, FALSE, N, IGNORE, NOTFOUND, empty string, ends with `-NOTFOUND` (case-insensitive)
                // Other: string

                for truthyKeyword in ["1", "ON", "YES", "TRUE", "Y"] {
                    if s.uppercased() == truthyKeyword {
                        self = .truthy(s)
                        return
                    }
                }
                if let d = Double(s), d != 0 {
                    self = .truthy(s)
                    return
                }
                
                for falseyKeyword in ["0", "OFF", "NO", "FALSE", "N", "IGNORE", "NOTFOUND", ""] {
                    if s.uppercased() == falseyKeyword {
                        self = .falsey(s)
                        return
                    }
                }
                if s.uppercased().hasSuffix("-NOTFOUND") {
                    self = .falsey(s)
                    return
                }
                
                self = .string(s)
            }
        }
        
        
        /// Extracts the correct log line from `USD_INSTALL/build/OpenUSD/log.txt`
        static private func getLogFileLine(usdInstall: URL) throws -> String {
            let fm = FileManager.default
            let buildDir = usdInstall.appending(path: "build")
            guard fm.directoryExists(at: buildDir) else {
                throw ValidationError("No build dir under \(usdInstall)")
            }
            // Look for subdirectories of USD_INSTALL that have a log.txt file
            let potentialLogFiles = try fm.contentsOfDirectory(at: buildDir, includingPropertiesForKeys: nil)
                .compactMap { (buildSubdir: URL) -> URL? in
                    let potentialResult = buildSubdir.appending(path: "log.txt")
                    guard fm.nonDirectoryFileExists(at: potentialResult) else { return nil }
                    return potentialResult
                }
            guard !potentialLogFiles.isEmpty else {
                throw ValidationError("No log.txt files found under \(buildDir)/*/")
            }
            
            // OpenUSD might have multiple dependencies that have log files,
            // so look for `PXR_PREFER_SAFETY_OVER_SPEED` which is (probably) unique
            // to the OpenUSD install itself
            for logFile in potentialLogFiles {
                let contents = try String(contentsOf: logFile, encoding: .utf8)
                if let line = contents.components(separatedBy: .newlines).first(where: { $0.contains("PXR_PREFER_SAFETY_OVER_SPEED") }) {
                    return line
                }
            }
            
            throw ValidationError("No log.txt files containing PXR_PREFER_SAFETY_OVER_SPEED found under \(buildDir)")
        }
    }
}
