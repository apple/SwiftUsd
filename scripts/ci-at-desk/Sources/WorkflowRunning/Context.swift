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
import WorkflowDescription
import Logging
import Synchronization

typealias Expression = WorkflowDescription.Expression

/// A context object, used by orchestrators and runners for evaluating expressions
struct Context: ~Copyable, Sendable {
    let yamlConfig: YamlConfig
    private var impl: [String : Expression] = [:]
    var everyJobSucceeded = true
    var everyMatrixSucceded = true
    var everyStepSucceeded = true

    init(yamlConfig: YamlConfig, impl: [String : Expression], everyJobSucceeded: Bool = true, everyMatrixSucceded: Bool = true, everyStepSucceeded: Bool = true) {
        self.yamlConfig = yamlConfig
        self.impl = impl
        self.everyJobSucceeded = everyJobSucceeded
        self.everyMatrixSucceded = everyMatrixSucceded
        self.everyStepSucceeded = everyStepSucceeded
    }
    
    init(yamlConfig: YamlConfig) {
        self.yamlConfig = yamlConfig
    }
    
    /// Creates an independent copy of `self`
    func detachedCopy() -> Context {
        .init(yamlConfig: yamlConfig,
              impl: impl,
              everyJobSucceeded: everyJobSucceeded,
              everyMatrixSucceded: everyMatrixSucceded,
              everyStepSucceeded: everyStepSucceeded)
    }
    
    subscript(key: String) -> Expression? {
        get { impl.nested(get: key) }
        set { impl.nested(set: key, to: newValue) }
    }
    
    mutating func augment(stepId: String, stepOutputs: [String : String], logger: Logger) {
        logger.trace("Context.augment(stepId:stepOutputs:)")
        for (k, v) in stepOutputs {
            self["steps.\(stepId).outputs.\(k)"] = .string(v)
        }
    }
    
    mutating func augment(matrixInclude: [String : Expression], logger: Logger) {
        logger.trace("Context.augment(matrixInclude:)")
        for (k, v) in matrixInclude {
            self["matrix.\(k)"] = v
        }
    }
    
    mutating func augment(jobId: String, jobOutputs: [String : Expression], logger: Logger) {
        logger.trace("Context.augment(jobId:jobOutputs:)")
        for (k, v) in jobOutputs {
            self["needs.\(jobId).outputs.\(k)"] = v
        }
    }

    func hasFailures(for purpose: ExpressionEvaluator.EvaluationPurpose, logger: Logger) -> Bool {
        logger.trace("Context.hasFailures(for:)")
        let toConsider = switch purpose {
        case .default_: [everyJobSucceeded, everyMatrixSucceded, everyStepSucceeded]
        case .jobIf: [everyJobSucceeded]
        case .stepIf: [everyStepSucceeded]
        }
        let result = !toConsider.allSatisfy { $0 }
        logger.trace("Context.hasFailures(for:) returning", metadata: ["result" : result.loggerRepresentation])
        return result
    }

    mutating func merge(other: borrowing Context, logger: Logger) {
        logger.trace("Context.merge(other:)")
        
        self.impl.nestedMerge(other: other.impl)
        self.everyJobSucceeded = self.everyJobSucceeded && other.everyJobSucceeded
        self.everyMatrixSucceded = self.everyMatrixSucceded && other.everyMatrixSucceded
        self.everyStepSucceeded = self.everyStepSucceeded && other.everyStepSucceeded
    }
    
    var loggerRepresentation: Logger.MetadataValue {
        ["everyJobSucceeded" : everyJobSucceeded.loggerRepresentation,
         "everyMatrixSucceeded" : everyMatrixSucceded.loggerRepresentation,
         "everyStepSucceeded" : everyStepSucceeded.loggerRepresentation,
         "values" : impl.loggerRepresentation]
    }
}

extension [String : Expression] {
    fileprivate func nested(get key: String) -> Expression? {
        let parts = key.split(separator: ".", maxSplits: 1)
        guard let value = self[String(parts[0])] else {
            return nil
        }
        if parts.count == 1 {
            return value
        } else {
            return value.asDictionary?.nested(get: String(parts[1]))
        }
    }
    
    fileprivate mutating func nested(set key: String, to newValue: Expression?) {
        let parts = key.split(separator: ".", maxSplits: 1)
        if parts.count == 1 {
            self[key] = newValue
        } else {
            switch self[String(parts[0])] {
            case .array, .int, .string: break
            case nil:
                var newDict = [String : Expression]()
                newDict.nested(set: String(parts[1]), to: newValue)
                self[String(parts[0])] = .dictionary(newDict)
            case .dictionary(var d):
                d.nested(set: String(parts[1]), to: newValue)
                self[String(parts[0])] = .dictionary(d)
            }
        }
    }
    
    fileprivate mutating func nestedMerge(other: [String : Expression]) {
        for (k, v) in other {
            if self[k] == nil { self[k] = v }
            else { self[k]!.nestedMerge(other: v) }
        }
    }
}

extension Expression {
    fileprivate mutating func nestedMerge(other: Expression) {
        switch (self, other) {
        case (.int, _), (.string, _), (.array, _): self = other
        case (var .dictionary(l), let .dictionary(r)):
            l.nestedMerge(other: r)
            self = .dictionary(l)
        case (.dictionary, _): self = other
        }
    }
}
