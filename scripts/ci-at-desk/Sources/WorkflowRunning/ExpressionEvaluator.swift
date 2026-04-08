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
import Synchronization
import Logging

// MARK: Interface

/// A type for evaluation expressions, used by runners and orchestrators
internal struct ExpressionEvaluator {
    let logger: Logger
    init(logger: Logger) {
        self.logger = logger
    }
    
    internal enum EvaluationPurpose {
        case default_
        case stepIf
        case jobIf
        
        var loggerRepresentation: Logger.MetadataValue {
            switch self {
            case .default_: "default_"
            case .stepIf: "stepIf"
            case .jobIf: "jobIf"
            }
        }
    }
    
    internal func evaluate(expression e: Expression, in context: borrowing Context, purpose: EvaluationPurpose) throws -> Expression {
        logger.trace("ExpressionEvaluator.evaluate", metadata: [
            "expression": e.loggerRepresentation,
            "context": context.loggerRepresentation,
            "purpose": purpose.loggerRepresentation,
        ])
        
        let result: Expression
        switch e {
        case let .int(i): result = .int(i)
        case let .array(x): result = try .array(x.map { try evaluate(expression: $0, in: context, purpose: purpose) })
        case let .dictionary(x): result = try .dictionary(x.mapValues { try evaluate(expression: $0, in: context, purpose: purpose) })
        case let .string(s):
            let parts = try getEvaluationGroups(s)
            let substitutedParts = try parts.map { try substitute(evaluationGroup: $0, in: context, purpose: purpose, logger: logger) }
            result = join(substitutedParts: substitutedParts)
        }
        logger.trace("ExpressionEvaluator.evaluate returning", metadata: ["result" : result.loggerRepresentation])
        return result
    }
    
    internal func evaluateAsString(_ expression: Expression, in context: borrowing Context) throws -> String {
        logger.trace("ExpressionEvaluator.evaluateAsString", metadata: [
            "expression": expression.loggerRepresentation,
        ])
        let evaluated = try evaluate(expression: expression, in: context, purpose: .default_)
        if let result = evaluated.asString {
            return result
        }
        throw ExpressionEvaluatorError.expressionEvaluatedToNonStringValue(evaluated)
    }
    
    internal func evaluateAsBool(_ e: Expression, in context: borrowing Context, purpose: EvaluationPurpose) throws -> Bool {
        logger.trace("ExpressionEvaluator.evaluateAsBool", metadata: [
            "expression": e.loggerRepresentation,
        ])
        let evaluated = try evaluate(expression: e, in: context, purpose: purpose)
        
        if let result = evaluated.asInt {
            return result != 0
        }
        throw ExpressionEvaluatorError.expressionEvaluatedToNonIntValue(evaluated)
    }
    
    internal func evaluateAsInt(_ e: Expression, in context: borrowing Context) throws -> Int {
        logger.trace("ExpressionEvaluator.evaluateAsInt", metadata: [
            "expression": e.loggerRepresentation,
        ])
        let evaluated = try evaluate(expression: e, in: context, purpose: .default_)
        
        if let result = evaluated.asInt {
            return result
        }
        throw ExpressionEvaluatorError.expressionEvaluatedToNonIntValue(evaluated)
    }
    
    private static let _cacheMutex = Mutex(())
    internal func evaluateCacheEntry(cache: Step.Cache, in context: borrowing Context, fileSystemHelper: borrowing FileSystemHelper) throws -> (key: URL, path: URL) {
        logger.trace("ExpressionEvaluator.evaluateCacheEntry", metadata: [
            "cache": cache.loggerRepresentation,
        ])
        let cacheDirectory = fileSystemHelper.cacheDirectory
        
        func map(key: String) throws -> String {
            try Self._cacheMutex.withLock { _ in
                let mappingUrl = cacheDirectory.appending(path: ".mapping.json")
                var decodedJson = [String : String]()
                if let data = try? Data(contentsOf: mappingUrl) {
                    try decodedJson = JSONDecoder().decode([String : String].self, from: data)
                }
                let mappedPath = decodedJson[key] ?? String(decodedJson.count)
                decodedJson[key] = mappedPath
                try JSONEncoder().encode(decodedJson).write(to: mappingUrl)
                return mappedPath
                
            }
        }
        
        let key = try evaluateAsString(cache.key, in: context)
        let mappedKey = try map(key: key)
        
        let path = try evaluateAsString(cache.path, in: context)
        
        let resultKey = cacheDirectory.appending(path: mappedKey)
        let resultPath = URL(fileURLWithPath: path)
        
        logger.trace("ExpressionEvaluator.evaluateCacheEntry returning", metadata: [
            "key" : resultKey.loggerRepresentation,
            "path" : resultPath.loggerRepresentation,
        ])
        
        return (resultKey, resultPath)
    }
    
    internal func evaluateAsMatrixList(from job: Job, in context: borrowing Context) throws -> (matrixList: [[String : Expression]], maxParallel: Int) {
        logger.trace("ExpressionEvaluator.evaluateAsMatrixList", metadata: [
            "job": job.loggerRepresentation,
        ])
        
        let maxParallel = try evaluateAsInt(job.strategy.maxParallel, in: context)
        
        let matrix = job.strategy.matrix
        let evaluated = try evaluate(expression: matrix, in: context, purpose: .default_)
        
        guard let d = evaluated.asDictionary else {
            logger.error("Matrix must be dictionary: \(matrix)")
            throw ExpressionEvaluatorError.matrixMustBeDictionary(matrix)
        }
        if d.isEmpty { throw ExpressionEvaluatorError.matrixDictionaryMustNotBeEmpty(matrix) }
        if d["include"] != nil && d.count != 1 {
            throw ExpressionEvaluatorError.matrixIncludeCantBeMixedWithOtherKeys(matrix)
        }
        if d["exclude"] != nil {
            throw ExpressionEvaluatorError.matrixExcludeIsntSupportedYet(matrix)
        }
        
        if let include = d["include"] {
            guard let includeAsArray = include.asArray else { throw ExpressionEvaluatorError.matrixIncludeMustBeArray(matrix) }
            var result = [[String : Expression]]()
            for includeElement in includeAsArray {
                guard let matrixInstance = includeElement.asDictionary else {
                    throw ExpressionEvaluatorError.matrixIncludeElementMustBeDictionary(matrix)
                }
                result.append(matrixInstance)
            }
            logger.trace("ExpressionEvaluator.evaluateAsMatrixList returning", metadata: [
                "result" : .array(result.map { $0.loggerRepresentation })
            ])
            return (result, maxParallel)
        } else {
            // Compute the cartesian product of d, and return it
            
            var result: [[String : Expression]] = [[:]]
            for (k, v) in d {
                guard let values = v.asArray else {
                    throw ExpressionEvaluatorError.matrixValuesMustBeArrays(matrix)
                }
                
                // For each key,
                // add each of its values to all of the existing
                // cartesian products
                result = values.flatMap { value in
                    result.map { existingItem in
                        var existingItem = existingItem
                        existingItem[k] = value
                        return existingItem
                    }
                }
            }
            
            logger.trace("ExpressionEvaluator.evaluateAsMatrixList returning", metadata: [
                "result" : .array(result.map { $0.loggerRepresentation })
            ])
            return (result, maxParallel)
        }
    }
}

// MARK: Implementation
extension ExpressionEvaluator {
    internal enum EvaluationGroup {
        case rawString(String)
        case substitutableString(String)
    }
    
    private func getEvaluationGroups(_ s: String) throws -> [EvaluationGroup] {
        var result = [EvaluationGroup]()
        
        var i = s.startIndex
        var buffer = [Character]()
        var isInSubstitutionMode = false
        
        func pushCharacter() {
            buffer.append(s[i])
            s.formIndex(after: &i)
        }
        func pushBufferIfNonEmpty() {
            if !buffer.isEmpty {
                result.append(isInSubstitutionMode ? .substitutableString(String(buffer).trimmingCharacters(in: .whitespaces)) : .rawString(String(buffer)))
            }
            buffer = []
            isInSubstitutionMode.toggle()
        }
        func advanceIfPossible(withPrefix: String) -> Bool {
            if s[i...].hasPrefix(withPrefix) {
                i = s.index(i, offsetBy: withPrefix.count)
                return true
            }
            return false
        }
        
        while i < s.endIndex {
            if isInSubstitutionMode {
                if advanceIfPossible(withPrefix: "}}") {
                    pushBufferIfNonEmpty()
                } else {
                    pushCharacter()
                }
            } else {
                if advanceIfPossible(withPrefix: "${{") {
                    pushBufferIfNonEmpty()
                } else {
                    pushCharacter()
                }
            }
        }
        pushBufferIfNonEmpty()
        // pushBufferIfNonEmpty toggled the substitution mode,
        // so if we're not in substitution mode _now_, it means that we just were
        if !isInSubstitutionMode {
            throw ExpressionEvaluatorError.unclosedSubstitution(s)
        }
        
        return result
    }
    
    private func substitute(evaluationGroup g: EvaluationGroup, in context: borrowing Context, purpose: EvaluationPurpose, logger: Logger) throws -> Expression {
        switch g {
        case let .rawString(s): return .string(s)
        case let .substitutableString(s):
            return try ExpressionSublanguageInterpreter.substitute(sublanguageString: s, in: context, purpose: purpose, logger: logger)
        }
    }
    
    private enum ExpressionEvaluatorError: Error, Sendable, Codable {
        case unclosedSubstitution(String)
        case expressionEvaluatedToNonStringValue(Expression)
        case expressionEvaluatedToNonIntValue(Expression)
        case matrixMustBeDictionary(Expression)
        case matrixDictionaryMustNotBeEmpty(Expression)
        case matrixIncludeCantBeMixedWithOtherKeys(Expression)
        case matrixExcludeIsntSupportedYet(Expression)
        case matrixIncludeMustBeArray(Expression)
        case matrixIncludeElementMustBeDictionary(Expression)
        case matrixValuesMustBeArrays(Expression)
    }
    
    private func join(substitutedParts: [Expression]) -> Expression {
        if substitutedParts.isEmpty { return .string("") }
        if substitutedParts.count == 1 { return substitutedParts.first! }
        
        return .string(substitutedParts.reduce(into: "") { $0 += $1.coerceToString })
    }
}
