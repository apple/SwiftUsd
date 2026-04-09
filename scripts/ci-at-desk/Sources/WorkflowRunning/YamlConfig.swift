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
import Yams

/// Holds the parsed contents of a YAML config file for ci-at-desk
public struct YamlConfig: Sendable {
    public struct Precheckout: Sendable {
        public let remote: String
        public let ref: String
        public let path: URL
        
        public init(remote: String, ref: String, path: URL) {
            self.remote = remote
            self.ref = ref
            self.path = path
        }
    }
    
    // workflow:
    public let workflowId: String

    // precheckouts:
    public let precheckouts: [Precheckout]

    // requiredPaths:
    public let runnerRootDirectory: URL
    public let cacheDirectory: URL
    public let artifactDirectory: URL
    public let loggingDirectory: URL
    public let swiftUsdSrcDirectory: URL
    public let swiftUsdTestsSrcDirectory: URL
    
    // ci-inputs:
    public let inputs: [String : String]
    
    // max-parallelism:
    public let maxJobParallelism: Int
    public let maxMatrixParallelism: Int
    public let atDeskSwiftBuildJobs: Int
    public let atDeskXcodebuildJobs: Int
    
    // skips:
    public let skips: [String : Int]
        
    // env:
    public let env: [String : String]
    
    private enum YamlConfigError: Error {
        case missingWorkflow
        case missingCacheDirectory
        case missingRunnerRootDirectory
        case missingArtifactDirectory
        case missingSwiftUsdDirectory
        case missingSwiftUsdTestsDirectory
        case missingLoggingDirectory
        case invalidPrecheckouts
    }
    
    public init(configFile: URL) throws {
        let yamlString = try String(contentsOf: configFile, encoding: .utf8)
        let yamlBlob = try Yams.load(yaml: yamlString)
        
        func extract(_ key: String) -> Any? {
            guard var top = yamlBlob as? [String : Any] else { return nil }
            let parts = key.components(separatedBy: ".")
            
            for (i, part) in parts.enumerated() {
                if i + 1 < parts.count {
                    guard let newTop = top[part] as? [String : Any] else { return nil }
                    top = newTop
                } else {
                    return top[part]
                }
            }
            
            return nil
        }
        
        func extract<T>(_ key: String, as t: T.Type = T.self) -> T? {
            extract(key) as? T
        }
        func extract<T>(_ key: String, as t: T.Type = T.self, orThrow: YamlConfigError) throws -> T {
            guard let result = extract(key, as: t) else { throw orThrow }
            return result
        }
        
        func formUrl(extractedString s: String) -> URL {
            if s.starts(with: "~/") {
                return FileManager.default.homeDirectoryForCurrentUser.appending(path: s.dropFirst(2))
            } else if s.starts(with: "/") {
                return URL(fileURLWithPath: s)
            } else {
                return configFile.deletingLastPathComponent().appending(path: s)
            }
        }
        
        func extractUrl(_ key: String) -> URL? {
            extract(key, as: String.self).map(formUrl(extractedString:))
        }

        func extractUrl(_ key: String, orThrow: YamlConfigError) throws -> URL {
            guard let result = extractUrl(key) else { throw orThrow }
            return result
        }
        
        func extractPrecheckouts() throws -> [Precheckout] {
            guard let raw = extract("precheckouts") else { return [] }
            guard let casted = raw as? [[AnyHashable : Any]] else { throw YamlConfigError.invalidPrecheckouts }

            return try casted.map { blob in
                guard let remote = blob["remote"] as? String else { throw YamlConfigError.invalidPrecheckouts }
                guard let ref = blob["ref"] as? String else { throw YamlConfigError.invalidPrecheckouts }
                guard let path = blob["path"] as? String else { throw YamlConfigError.invalidPrecheckouts }
                return Precheckout(remote: remote, ref: ref, path: formUrl(extractedString: path))
            }
        }
        
        self.workflowId = try extract("workflow", orThrow: .missingWorkflow)
        
        self.precheckouts = try extractPrecheckouts()
        
        self.cacheDirectory = try extractUrl("requiredPaths.cache", orThrow: .missingCacheDirectory)
        self.runnerRootDirectory = try extractUrl("requiredPaths.runnerRoot", orThrow: .missingRunnerRootDirectory)
        self.artifactDirectory = try extractUrl("requiredPaths.artifacts", orThrow: .missingArtifactDirectory)
        self.loggingDirectory = try extractUrl("requiredPaths.logging", orThrow: .missingLoggingDirectory)
        self.swiftUsdSrcDirectory = try extractUrl("requiredPaths.SwiftUsd", orThrow: .missingSwiftUsdDirectory)
        self.swiftUsdTestsSrcDirectory = try extractUrl("requiredPaths.SwiftUsd-Tests", orThrow: .missingSwiftUsdTestsDirectory)
        
        
        self.inputs = extract("ci-inputs") ?? [:]
        
        self.maxJobParallelism = extract("max-parallelism.jobs") ?? 0
        self.maxMatrixParallelism = extract("max-parallelism.matrices") ?? 0
        self.atDeskSwiftBuildJobs = extract("max-parallelism.ATDESK_SWIFTBUILD_JOBS") ?? 0
        self.atDeskXcodebuildJobs = extract("max-parallelism.ATDESK_XCODEBUILD_JOBS") ?? 0
        
        self.skips = extract("skips") ?? [:]
        
        var theEnv = extract("env", as: [String : String].self) ?? [:]
        if theEnv["SWIFTLY_DENYLIST"] == nil { theEnv["SWIFTLY_DENYLIST"] = "-" }
        if theEnv["XCODE_DENYLIST"] == nil { theEnv["XCODE_DENYLIST"] = "-" }
        self.env = theEnv
    }
}

