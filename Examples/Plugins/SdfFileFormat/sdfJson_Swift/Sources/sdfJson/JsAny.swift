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

// pxr::JsValue uses const&'s for performance where possible
// in C++, which don't get imported super cleanly into Swift.
// Instead, we implement our own "JsAny" type, with good
// Swift ergnomics
indirect enum JsAny: Equatable, Codable {
    case object([String : JsAny])
    case array([JsAny])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null
    
    static func encodeToData(_ x: JsAny) throws -> Data {
        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return try encoder.encode(x)
    }
    
    static func decodeFromData(_ d: Data) throws -> JsAny {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return try decoder.decode(JsAny.self, from: d)
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .object(let x): try x.encode(to: encoder)
        case .array(let x): try x.encode(to: encoder)
        case .string(let x): try x.encode(to: encoder)
        case .number(let x): try x.encode(to: encoder)
        case .bool(let x): try x.encode(to: encoder)
        case .null:
            var c = encoder.singleValueContainer()
            try c.encodeNil()
        }
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let x = try? c.decode([String : JsAny].self) {
            self = .object(x); return
        } else if let x = try? c.decode(String.self) {
            self = .string(x); return
        } else if let x = try? c.decode(Double.self) {
            self = .number(x); return
        } else if let x = try? c.decode(Bool.self) {
            self = .bool(x); return
        } else if c.decodeNil() {
            self = .null; return
        } else if let x = try? c.decode([JsAny].self) {
            self = .array(x); return
        }
        
        throw DecodingError.typeMismatch(JsAny.self, .init(codingPath: decoder.codingPath, debugDescription: "Couldn't determine JsAny concrete type"))
    }
    
    enum Discriminant {
        case object
        case array
        case string
        case number
        case bool
        case null
    }
    
    var discriminant: Discriminant {
        switch self {
        case .object: .object
        case .array: .array
        case .string: .string
        case .number: .number
        case .bool: .bool
        case .null: .null
        }
    }
    
    struct CastError: Error {
        var source: Discriminant
        var target: Discriminant
        var file: String
        var line: Int
        
        init(from source: Discriminant, to target: Discriminant,
             file: String, line: Int) {
            self.source = source
            self.target = target
            self.file = file
            self.line = line
        }
    }
    
    struct MissingKeyError: Error {
        var key: String
        var errorMessage: String
        var file: String
        var line: Int
    }
    
    var isObject: Bool { discriminant == .object }
    var isArray: Bool { discriminant == .array }
    var isString: Bool { discriminant == .string }
    var isNumber: Bool { discriminant == .number }
    var isBool: Bool { discriminant == .bool }
    var isNull: Bool { discriminant == .null }
    
    var isNonEmptyContainer: Bool {
        switch self {
        case .object(let x) where !x.isEmpty: true
        case .array(let x) where !x.isEmpty: true
        default: false
        }
    }
    
    static func int(_ x: Int) -> JsAny {
        .number(Double(x))
    }
    
    var asObject: [String : JsAny]? {
        if case let .object(x) = self { x } else { nil }
    }
    var asArray: [JsAny]? {
        if case let .array(x) = self { x } else { nil }
    }
    var asString: String? {
        if case let .string(x) = self { x } else { nil }
    }
    var asNumber: Double? {
        if case let .number(x) = self { x } else { nil }
    }
    var asInt: Int? {
        asNumber.map { Int($0) }
    }
    var asBool: Bool? {
        if case let .bool(x) = self { x } else { nil }
    }
    var asNull: Void? {
        if case .null = self { () } else { nil }
    }
    
    private func unwrapOrThrow<T, E>(_ x: T?, _ e: E) throws(E) -> T {
        if let x { return x }
        else { throw e }
    }
    
    func castAsObject(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> [String : JsAny] {
        try unwrapOrThrow(asObject, CastError(from: discriminant, to: .object, file: file, line: line))
    }
    
    func castAsArray(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> [JsAny] {
        try unwrapOrThrow(asArray, CastError(from: discriminant, to: .array, file: file, line: line))
    }
    
    func castAsString(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> String {
        try unwrapOrThrow(asString, CastError(from: discriminant, to: .string, file: file, line: line))
    }
    
    func castAsNumber(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> Double {
        try unwrapOrThrow(asNumber, CastError(from: discriminant, to: .number, file: file, line: line))
    }
    
    func castAsInt(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> Int {
        try unwrapOrThrow(asInt, CastError(from: discriminant, to: .number, file: file, line: line))
    }
    
    func castAsBool(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> Bool {
        try unwrapOrThrow(asBool, CastError(from: discriminant, to: .bool, file: file, line: line))
    }
    
    func castAsNull(_ file: String = #fileID, _ line: Int = #line) throws(CastError) -> Void {
        try unwrapOrThrow(asNull, CastError(from: discriminant, to: .null, file: file, line: line))
    }
}

extension [String : JsAny] {
    subscript(key: String, errorMessage errorMessage: String, file: String = #fileID, line: Int = #line) -> JsAny {
        get throws(JsAny.MissingKeyError) {
            guard let x = self[key] else {
                throw JsAny.MissingKeyError(key: key, errorMessage: errorMessage, file: file, line: line)
            }
            return x
        }
    }
    
    mutating func insert(at key: String, ifIsNonEmptyContainer x: JsAny) {
        if x.isNonEmptyContainer {
            self[key] = x
        }
    }
}

extension JsAny: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, JsAny)...) {
        self = .object(.init(uniqueKeysWithValues: elements))
    }
}

extension JsAny: ExpressibleByArrayLiteral {
    init(arrayLiteral: JsAny...) {
        self = .array(arrayLiteral)
    }
}

extension JsAny: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        self = .string(stringLiteral)
    }
}

extension JsAny: ExpressibleByIntegerLiteral {
    init(integerLiteral: Int) {
        self = .int(integerLiteral)
    }
}

extension JsAny: ExpressibleByFloatLiteral {
    init(floatLiteral: Double) {
        self = .number(floatLiteral)
    }
}

extension JsAny: ExpressibleByBooleanLiteral {
    init(booleanLiteral: Bool) {
        self = .bool(booleanLiteral)
    }
}
