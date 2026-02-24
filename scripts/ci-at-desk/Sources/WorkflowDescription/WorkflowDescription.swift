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
import Logging

/// A workflow containing jobs
public struct Workflow: Sendable, Codable {
    public let id: String
    public let jobs: [Job]
    
    public init(id: String, jobs: [Job]) {
        self.id = id
        self.jobs = jobs
    }
    
    public var loggerRepresentation: Logger.MetadataValue {
        id.loggerRepresentation
    }
}

/// A job containing steps
public struct Job: Sendable, Codable {
    public let id: String
    public let if_: Expression
    public let name: Expression?
    public let needs: [String]
    public let env: [String : Expression]
    public let strategy: Strategy
    public let continueOnError: Bool
    public let outputs: [String : Expression]
    
    public enum Kind: Sendable, Codable {
        case steps([Step])
        case workflow(Workflow)
    }
    public let kind: Kind
    
    public init(id: String, if_: Expression = .success, name: Expression? = nil,
                needs: [String] = [], env: [String : Expression] = [:],
                strategy: Strategy? = nil, continueOnError: Bool = false,
                outputs: [String : Expression] = [:], kind: Kind) {
        self.id = id
        self.if_ = if_
        self.name = name
        self.needs = needs
        self.env = env
        self.strategy = strategy ?? .empty
        self.continueOnError = continueOnError
        self.outputs = outputs
        self.kind = kind
    }
    
    public init(id: String, if_: Expression = .success, name: Expression? = nil,
                needs: [String] = [], env: [String : Expression] = [:],
                strategy: Strategy? = nil, continueOnError: Bool = false,
                outputs: [String : Expression] = [:], steps: [Step]) {
        self.init(id: id, if_: if_, name: name,
                  needs: needs, env: env,
                  strategy: strategy, continueOnError: continueOnError,
                  outputs: outputs, kind: .steps(steps))
    }
    
    public init(id: String, if_: Expression = .success, name: Expression? = nil,
                needs: [String] = [], env: [String : Expression] = [:],
                strategy: Strategy? = nil, continueOnError: Bool = false,
                outputs: [String : Expression] = [:], workflow: Workflow) {
        self.init(id: id, if_: if_, name: name,
                  needs: needs, env: env,
                  strategy: strategy, continueOnError: continueOnError,
                  outputs: outputs, kind: .workflow(workflow))
    }
    
    public struct Strategy: Sendable, Codable, CustomStringConvertible {
        public let failFast: Bool
        public let maxParallel: Expression
        public let matrix: Expression
        
        public init(failFast: Bool = true,
                    maxParallel: Expression = 0,
                    matrix: Expression) {
            self.failFast = failFast
            self.maxParallel = maxParallel
            self.matrix = matrix
        }
        
        public var description: String {
            "Strategy(failFast: \(failFast), maxParallel: \(maxParallel), matrix: \(matrix))"
        }
        
        public static let empty = Strategy(matrix: ["include": [[:]]])
        
        internal enum StrategyError: Error {
            case matrixMustBeDictionary(Expression)
            case matrixDictionaryMustNotBeEmpty(Expression)
            case matrixIncludeCantBeMixedWithOtherKeys(Expression)
            case matrixExcludeIsntSupportedYet(Expression)
            case matrixIncludeMustBeArray(Expression)
            case matrixIncludeElementMustBeDictionary(Expression)
            case matrixValuesMustBeArrays(Expression)
        }
    }
    
    public var loggerRepresentation: Logger.MetadataValue {
        id.loggerRepresentation
    }
}

/// The individual actions performed sequentially in a job
public struct Step: Sendable, Codable {
    public let name: String
    public let if_: Expression
    public let id: String?
    public let cache: Cache?
    public let timeout: Duration
    public let kind: Kind
    
    /// The underlying kind of step
    public enum Kind: Sendable, Codable, CustomStringConvertible {
        case runShellCommand([Expression])
        case saveArtifact(SaveArtifact)
        case restoreArtifact(RestoreArtifact)
        case sparseCheckout([String])
        case checkout(CheckoutKind)
        
        public enum CheckoutKind: Sendable, Codable, CustomStringConvertible {
            case swiftUsd
            case swiftUsd_tests
            
            public var description: String {
                switch self {
                case .swiftUsd: "SwiftUsd"
                case .swiftUsd_tests: "SwiftUsd-Tests"
                }
            }
            
            public var loggerRepresentation: Logger.MetadataValue {
                description.loggerRepresentation
            }
        }
        
        public var description: String {
            switch self {
            case .runShellCommand(let array): "runShellCommand: \(array)"
            case .saveArtifact(let saveArtifact): "\(saveArtifact)"
            case .restoreArtifact(let restoreArtifact): "\(restoreArtifact)"
            case .sparseCheckout(let array): "SparseCheckout: \(array)"
            case .checkout(let checkoutKind): "Checkout: \(checkoutKind)"
            }
        }
        
        public var loggerRepresentation: Logger.MetadataValue {
            switch self {
            case .runShellCommand(let e): ["kind" : "runShellCommand", "expressions" : .array(e.map(\.loggerRepresentation))]
            case .saveArtifact(let s): ["kind" : "saveArtifact", "data" : s.loggerRepresentation]
            case .restoreArtifact(let r): ["kind" : "restoreArtifact", "data" : r.loggerRepresentation]
            case .sparseCheckout(let s): ["kind" : "sparseCheckout", "paths" : .array(s.map(\.loggerRepresentation))]
            case .checkout(let c): ["kind" : "checkout", "repo" : c.loggerRepresentation]
            }
        }
    }
    
    public struct SaveArtifact: Sendable, Codable, CustomStringConvertible {
        public let name: Expression
        public let path: Expression
        public let allowNoFilesFound: Bool
        
        public var description: String {
            "SaveArtifact(name: \(name), path: \(path), allowNoFilesFound: \(allowNoFilesFound))"
        }
        
        public init(name: Expression, path: Expression, allowNoFilesFound: Bool = false) {
            self.name = name
            self.path = path
            self.allowNoFilesFound = allowNoFilesFound
        }
        
        public var loggerRepresentation: Logger.MetadataValue {
            ["name" : name.loggerRepresentation,
             "path" : path.loggerRepresentation,
             "allowNoFilesFound" : allowNoFilesFound.loggerRepresentation]
        }
    }
    
    public struct RestoreArtifact: Sendable, Codable, CustomStringConvertible {
        public let path: Expression
        public let pattern: Expression
        public let requiresIndependentCopy: Bool
        
        public var description: String {
            "RestoreArtifact(path: \(path), pattern: \(pattern), requiresIndependentCopy: \(requiresIndependentCopy))"
        }
        
        public init(path: Expression, pattern: Expression, requiresIndependentCopy: Bool = false) {
            self.path = path
            self.pattern = pattern
            self.requiresIndependentCopy = requiresIndependentCopy
        }
        
        public var loggerRepresentation: Logger.MetadataValue {
            ["path" : path.loggerRepresentation,
             "pattern" : pattern.loggerRepresentation,
             "requiresIndependentCopy" : requiresIndependentCopy.loggerRepresentation]
        }
    }
    
    public init(name: String, if_: Expression = .success, id: String?, cache: Cache?, timeout: Duration, kind: Kind) {
        self.name = name
        self.if_ = if_
        self.id = id
        self.cache = cache
        self.timeout = timeout
        self.kind = kind
    }
    
    public init(name: String, if_: Expression = .success, id: String? = nil, cache: Cache? = nil, timeout: Duration = .hours(1), run: Expression...) {
        self.init(name: name, if_: if_, id: id, cache: cache, timeout: timeout, kind: .runShellCommand(run))
    }
    
    public init(name: String, if_: Expression = .success, timeout: Duration = .hours(1), saveArtifact: SaveArtifact) {
        self.init(name: name, if_: if_, id: nil, cache: nil, timeout: timeout, kind: .saveArtifact(saveArtifact))
    }
    
    public init(name: String, if_: Expression = .success, timeout: Duration = .hours(1), restoreArtifact: RestoreArtifact) {
        self.init(name: name, if_: if_, id: nil, cache: nil, timeout: timeout, kind: .restoreArtifact(restoreArtifact))
    }
    
    public init(name: String, if_: Expression = .success, timeout: Duration = .hours(1), sparseCheckout: [String]) {
        self.init(name: name, if_: if_, id: nil, cache: nil, timeout: timeout, kind: .sparseCheckout(sparseCheckout))
    }
    
    public init(name: String, if_: Expression = .success, timeout: Duration = .hours(1), checkout: Kind.CheckoutKind) {
        self.init(name: name, if_: if_, id: nil, cache: nil, timeout: timeout, kind: .checkout(checkout))
    }

    
    public struct Cache: Sendable, Codable, CustomStringConvertible {
        public let key: Expression
        public let path: Expression
        public let requiresIndependentCopy: Bool
        
        public var description: String {
            "Cache(key: \(key), path: \(path), requiresIndependentCopy: \(requiresIndependentCopy))"
        }
        
        public init(key: Expression, path: Expression, requiresIndependentCopy: Bool = false) {
            self.key = key
            self.path = path
            self.requiresIndependentCopy = requiresIndependentCopy
        }
        
        public var loggerRepresentation: Logger.MetadataValue {
            ["key" : key.loggerRepresentation,
             "path" : path.loggerRepresentation,
             "requiresIndependentCopy" : requiresIndependentCopy.loggerRepresentation]
        }
    }
        
    public var loggerRepresentation: Logger.MetadataValue {
        ["name" : name.loggerRepresentation,
         "kind" : kind.loggerRepresentation]
    }
}

/// A dynamically typed expression (int, string, array, or dictionary)
public enum Expression: Sendable, Codable,
                 ExpressibleByIntegerLiteral, ExpressibleByStringLiteral,
                 ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, CustomStringConvertible {
    case int(Int)
    case string(String)
    case array([Expression])
    case dictionary([String : Expression])
    
    public static let success: Expression = "${{ success() }}"
    
    public var description: String {
        switch self {
        case .int(let int): "\(int)"
        case .string(let string): "'\(string)'"
        case .array(let array): "\(array)"
        case .dictionary(let dictionary): "\(dictionary)"
        }
    }
    
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    
    public init(arrayLiteral elements: Expression...) {
        self = .array(elements)
    }
    
    public init(dictionaryLiteral elements: (String, Expression)...) {
        self = .dictionary(.init(uniqueKeysWithValues: elements))
    }
    
    public var asInt: Int? {
        switch self {
        case let .int(x): x
        default: nil
        }
    }
    
    public var asString: String? {
        switch self {
        case let .string(x): x
        default: nil
        }
    }
    
    public var asArray: [Expression]? {
        switch self {
        case let .array(x): x
        default: nil
        }
    }
    
    public var asDictionary: [String : Expression]? {
        switch self {
        case let .dictionary(x): x
        default: nil
        }
    }
    
    public var coerceToString: String {
        switch self {
        case let .string(s): s
        case let .int(i): String(i)
        case let .array(a): "[\(a.map(\.coerceToString).joined(separator: ", "))]"
        case let .dictionary(d): "[\(d.map { "\($0) : \($1.coerceToString)" }.joined(separator: ", "))]"
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case let .string(s): try container.encode(s)
        case let .int(i): try container.encode(i)
        case let .array(a): try container.encode(a)
        case let .dictionary(d): try container.encode(d)
        }
    }
        
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let i = try? container.decode(Int.self) {
            self = .int(i)
        } else if let a = try? container.decode([Expression].self) {
            self = .array(a)
        } else if let d = try? container.decode([String : Expression].self) {
            self = .dictionary(d)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Not a valid Expression"))
        }
    }
    
    public static func fromJson(_ s: String) throws -> Expression {
        try JSONDecoder().decode(Expression.self, from: s.data(using: .utf8)!)
    }
    
    public var loggerRepresentation: Logger.MetadataValue {
        switch self {
        case .array(let x): .array(x.map(\.loggerRepresentation))
        case .dictionary(let d): d.loggerRepresentation
        case .int(let i): i.loggerRepresentation
        case .string(let s): s.loggerRepresentation
        }
    }
}

extension [String : Expression] {
    public var loggerRepresentation: Logger.MetadataValue {
        var result = [String : Logger.MetadataValue]()
        
        var stack = [String]()
        func handle(_ k: String, _ v: Expression) {
            stack.append(k)
            defer { stack.removeLast() }
            
            switch v {
            case let .array(a): result[stack.joined(separator: ".")] = .array(a.map(\.loggerRepresentation))
            case let .int(i): result[stack.joined(separator: ".")] = i.loggerRepresentation
            case let .string(s): result[stack.joined(separator: ".")] = s.loggerRepresentation
            case let .dictionary(d):
                for (k, v) in d {
                    handle(k, v)
                }
            }
        }
        
        for (k, v) in self {
            handle(k, v)
        }

        return .dictionary(result)
    }
}

extension Int {
    public var loggerRepresentation: Logger.MetadataValue { .string("\(self)") }
}

extension String {
    public var loggerRepresentation: Logger.MetadataValue { .string(self) }
}

extension Bool {
    public var loggerRepresentation: Logger.MetadataValue { .string(self ? "1" : "0") }
}

extension URL {
    public var loggerRepresentation: Logger.MetadataValue { .string(absoluteURL.path(percentEncoded: false)) }
}

extension UUID {
    public var loggerRepresentation: Logger.MetadataValue { .string(uuidString) }
}

extension Duration {
    public static func minutes(_ x: some BinaryInteger) -> Duration { .seconds(x * 60) }
    public static func hours(_ x: some BinaryInteger) -> Duration { .minutes(x * 60) }
}
