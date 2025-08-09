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
import SymbolKit
import SwiftUsdDoccUtil

// MARK: Collections in place

extension MutableCollection {
    fileprivate mutating func mapInPlace(_ transform: (inout Element) -> ()) {
        for (index, var element) in zip(self.indices, self) {
            transform(&element)
            self[index] = element
        }
    }
}

extension Dictionary {
    fileprivate mutating func mapInPlace(_ transform: (inout Key, inout Value) -> ()) {
        for (var key, var value) in self {
            self[key] = nil
            transform(&key, &value)
            self[key] = value
        }
    }
}

extension Dictionary<String, any Mixin> {
    fileprivate mutating func _mapKeyInPlace<T: Mixin>(_ k: String, _ transform: (inout T) -> ()) {
        if var t = self[k] as? T {
            transform(&t)
            self[k] = t
        }
    }
    
    fileprivate mutating func mapDeclarationFragmentsInPlace(_ transform: (inout SymbolGraph.Symbol.DeclarationFragments) -> ()) {
        _mapKeyInPlace("declarationFragments", transform)
    }
    
    fileprivate mutating func mapFunctionSignatureInPlace(_ transform: (inout SymbolGraph.Symbol.FunctionSignature) -> ()) {
        _mapKeyInPlace("functionSignature", transform)
    }
    
    fileprivate mutating func mapSwiftExtensionInPlace(_ transform: (inout SymbolGraph.Symbol.Swift.Extension) -> ()) {
        _mapKeyInPlace("swiftExtension", transform)
    }
}

extension SymbolGraph.Symbol.FunctionSignature {
    fileprivate mutating func recursivelyMapDeclarationFragments(_ transform: (inout SymbolGraph.Symbol.DeclarationFragments.Fragment) -> ()) {
        func _recurse(_ functionParameter: inout FunctionParameter) {
            functionParameter.declarationFragments.mapInPlace(transform)
            functionParameter.children.mapInPlace(_recurse)
        }
        self.parameters.mapInPlace(_recurse)
        self.returns.mapInPlace(transform)
    }
}

// MARK: Map to Swift

fileprivate func prettyPrint(_ symbolKind: SymbolGraph.Symbol.Kind, _ fragments: SymbolGraph.Symbol.DeclarationFragments) {
    func prettyPrint(_ declarationFragment: SymbolGraph.Symbol.DeclarationFragments.Fragment) {
        if let id = declarationFragment.preciseIdentifier {
            print("\(declarationFragment.kind.rawValue): '\(declarationFragment.spelling)', id: '\(id)'")
        } else {
            print("\(declarationFragment.kind.rawValue): '\(declarationFragment.spelling)'")
        }
    }
    print(symbolKind.identifier)
    for fragment in fragments.declarationFragments {
        prettyPrint(fragment)
    }
    print("")
}


fileprivate typealias Fragment = SymbolGraph.Symbol.DeclarationFragments.Fragment
fileprivate typealias FragmentArray = [Fragment]

/*
 field: type fieldName semi
 param: type paramName? (commaSpace param)?
 function: type functionName lParen param? rParam const? semi
 */

extension Fragment {
    fileprivate static var space: Fragment { .init(kind: .text, spelling: " ", preciseIdentifier: nil) }
    fileprivate static var const: Fragment { .init(kind: .keyword, spelling: "const", preciseIdentifier: nil) }
    fileprivate static var commaSpace: Fragment { .init(kind: .text, spelling: ", ", preciseIdentifier: nil) }
    fileprivate static var colonColon: Fragment { .init(kind: .text, spelling: "::", preciseIdentifier: nil) }
    fileprivate static var `enum`: Fragment { .init(kind: .keyword, spelling: "enum", preciseIdentifier: nil) }
    fileprivate static var `var`: Fragment { .init(kind: .keyword, spelling: "var", preciseIdentifier: nil) }
    fileprivate static var colonSpace: Fragment { .init(kind: .text, spelling: ": ", preciseIdentifier: nil) }
    fileprivate static var spaceEqualsSpace: Fragment { .init(kind: .text, spelling: " = ", preciseIdentifier: nil) }
    fileprivate static var typedef: Fragment { .init(kind: .keyword, spelling: "typedef", preciseIdentifier: nil) }
    fileprivate static var `typealias`: Fragment { .init(kind: .keyword, spelling: "typealias", preciseIdentifier: nil) }
    fileprivate static var namespace: Fragment { .init(kind: .keyword, spelling: "namespace", preciseIdentifier: nil) }
    fileprivate static var `operator`: Fragment { .init(kind: .keyword, spelling: "operator", preciseIdentifier: nil) }
    fileprivate static var `static`: Fragment { .init(kind: .keyword, spelling: "static", preciseIdentifier: nil) }
    fileprivate static var colon: Fragment { .init(kind: .text, spelling: ":", preciseIdentifier: nil) }
    fileprivate static var underscore: Fragment { .init(kind: .externalParameter, spelling: "_", preciseIdentifier: nil) }
    fileprivate static var initKeyword: Fragment { .init(kind: .keyword, spelling: "init", preciseIdentifier: nil) }
    fileprivate static var mutating: Fragment { .init(kind: .keyword, spelling: "mutating", preciseIdentifier: nil) }
    fileprivate static var `func`: Fragment { .init(kind: .keyword, spelling: "func", preciseIdentifier: nil) }
    fileprivate static var lParenRParen: Fragment { .init(kind: .text, spelling: "()", preciseIdentifier: nil) }
    fileprivate static var lParen: Fragment { .init(kind: .text, spelling: "(", preciseIdentifier: nil) }
    fileprivate static var rParen: Fragment { .init(kind: .text, spelling: ")", preciseIdentifier: nil) }
    fileprivate static var voidUppercase: Fragment { .init(kind: .typeIdentifier, spelling: "Void", preciseIdentifier: "c:v") }
    fileprivate static var returnArrow: Fragment { .init(kind: .text, spelling: "->", preciseIdentifier: nil) }
    fileprivate static var extern: Fragment { .init(kind: .keyword, spelling: "extern", preciseIdentifier: nil) }
    fileprivate static var lBrace: Fragment { .init(kind: .text, spelling: "{", preciseIdentifier: nil) }
    fileprivate static var rBrace: Fragment { .init(kind: .text, spelling: "}", preciseIdentifier: nil) }
    fileprivate static var get: Fragment { .init(kind: .keyword, spelling: "get", preciseIdentifier: nil) }
    fileprivate static var `case`: Fragment { .init(kind: .keyword, spelling: "case", preciseIdentifier: nil) }
    fileprivate static var template: Fragment { .init(kind: .keyword, spelling: "template", preciseIdentifier: nil) }
    fileprivate static var lAngle: Fragment { .init(kind: .text, spelling: "<", preciseIdentifier: nil) }
    fileprivate static var rAngle: Fragment { .init(kind: .text, spelling: ">", preciseIdentifier: nil) }
    fileprivate static var unsafePointer: Fragment { .init(kind: .typeIdentifier, spelling: "UnsafePointer", preciseIdentifier: nil) }
    fileprivate static var unsafeMutablePointer: Fragment { .init(kind: .typeIdentifier, spelling: "UnsafeMutablePointer", preciseIdentifier: nil) }
}

extension FragmentArray {
    mutating func trimLeadingCharacters(_ s: String, kind: SymbolGraph.Symbol.DeclarationFragments.Fragment.Kind?,
                                        file: StaticString = #file, line: UInt = #line) {
        if let kind {
            assert(first!.kind == kind, file: file, line: line)
        }
        assert(first!.spelling.hasPrefix(s), file: file, line: line)
        self[0].spelling.removeFirst(s.count)
        if first!.spelling.isEmpty {
            removeFirst()
        }
    }
    
    mutating func trimTrailingCharacters(_ s: String, kind: SymbolGraph.Symbol.DeclarationFragments.Fragment.Kind?,
                                         file: StaticString = #file, line: UInt = #line) {
        if let kind {
            assert(last!.kind == kind, file: file, line: line)
        }
        assert(last!.spelling.hasSuffix(s), file: file, line: line)
        self[self.count - 1].spelling.removeLast(s.count)
        if last!.spelling.isEmpty {
            removeLast()
        }
    }
    
    mutating func tryTrimTrailingConst() -> Bool {
        if last == .const {
            removeLast()
            return true
        }
        return false
    }
    
    mutating func tryTrimTrailingStar() -> Bool {
        if last!.spelling.trimmingCharacters(in: .whitespaces).hasSuffix("*") {
            self[self.count - 1].spelling = String(self[self.count - 1].spelling[..<self[self.count - 1].spelling.lastIndex(of: "*")!])
            if self[self.count - 1].spelling.trimmingCharacters(in: .whitespaces).isEmpty {
                removeLast()
            }
            return true
        }
        return false
    }
    
    mutating func tryTrimTrailingAmpersand() -> Bool {
        if last!.spelling.trimmingCharacters(in: .whitespaces).hasSuffix("&") {
            self[self.count - 1].spelling = String(self[self.count - 1].spelling[..<self[self.count - 1].spelling.lastIndex(of: "&")!])
            if self[self.count - 1].spelling.trimmingCharacters(in: .whitespaces).isEmpty {
                removeLast()
            }
            return true
        }
        return false
    }
    
    mutating func tryTrimLeadingExternSpaceConstSpace() {
        guard self.count >= 4 else { return }
        if self[0..<4] == [.extern, .space, .const, .space] {
            removeFirst(4)
        }
    }
    
    mutating func trimTrailingSemicolon(file: StaticString = #file, line: UInt = #line) {
        trimTrailingCharacters(";", kind: .text, file: file, line: line)
    }
    
    mutating func trimLeadingTypedef(file: StaticString = #file, line: UInt = #line) {
        trimLeadingCharacters("typedef", kind: .keyword)
    }
    
    mutating func trimLeadingEnum(file: StaticString = #file, line: UInt = #line) {
        trimLeadingCharacters("enum", kind: .keyword)
    }
    
    mutating func trimLeadingStatic(file: StaticString = #file, line: UInt = #line) {
        trimLeadingCharacters("static", kind: .keyword)
    }
    
    mutating func trimLeadingSpace(file: StaticString = #file, line: UInt = #line) {
        trimLeadingCharacters(" ", kind: nil, file: file, line: line)
    }
    
    mutating func trimTrailingSpace(file: StaticString = #file, line: UInt = #line) {
        trimTrailingCharacters(" ", kind: nil, file: file, line: line)
    }
}

extension FragmentArray {
    fileprivate func parseCppTypeAndFollowingName(file: StaticString = #file, line: UInt = #line) -> (cppType: FragmentArray, name: Fragment?) {
        assert(!isEmpty, file: file, line: line)
        
        var copy = self
        let last = copy.popLast()!
        if last.kind == .typeIdentifier {
            return (cppType: self, name: nil)
        }
        if copy.isEmpty {
            return (cppType: [.init(kind: .typeIdentifier, spelling: last.spelling, preciseIdentifier: last.preciseIdentifier)], name: nil)
        }

        copy.trimTrailingSpace()
        assert(!copy.isEmpty, file: file, line: line)
        return (cppType: copy, name: last)
    }
    
    fileprivate func splitCppParams() -> [FragmentArray] {
        if isEmpty { return [] }
        
        var result = [FragmentArray]()
        var bufferInProgress = FragmentArray()
        
        for x in self {
            if x == .commaSpace {
                assert(!bufferInProgress.isEmpty)
                result.append(bufferInProgress)
                bufferInProgress = []
            } else {
                bufferInProgress.append(x)
            }
        }
        assert(!bufferInProgress.isEmpty)
        result.append(bufferInProgress)
        
        return result
    }
    
    fileprivate mutating func mapCppTypeToSwiftType(file: StaticString = #file, line: UInt = #line) {
        assert(!isEmpty, file: file, line: line)
        
        // Namespace :: -> .
        mapInPlace {
            if $0 == .colonColon {
                $0.spelling = "."
            }
        }
        
        // Remove const-ref
        if count >= 3 {
            let lastIsRef = self.last!.kind == .text && self.last!.spelling.trimmingCharacters(in: .whitespaces) == "&"
            
            if self[0] == .const && self[1] == .space && lastIsRef {
                removeFirst(2)
                removeLast()
            }
        }
        
        var isUnsafePointer = false
        var hadLeadingConstNotInConstRef = false
        
        // Remove leading const
        if count >= 3 {
            if self[0] == .const && self[1] == .space {
                removeFirst(2)
                hadLeadingConstNotInConstRef = true
            }
        }
        
        // Remove trailing star, trailing ampersand
        if count >= 2 {
            if self.tryTrimTrailingStar() {
                isUnsafePointer = true
            } else if self.tryTrimTrailingAmpersand() {
                isUnsafePointer = true
            }
        }
        
        
        // Swift-ify types
        if self.count == 1 && self[0].kind == .typeIdentifier {
            let remapping = [
                "bool" : "Bool",
                "int" : "CInt",
                "double" : "Double",
                "void" : "Void",
            ]
                        
            self[0].spelling = remapping[self[0].spelling] ?? self[0].spelling
        }
        
        if isUnsafePointer {
            self = [hadLeadingConstNotInConstRef ? .unsafePointer : .unsafeMutablePointer,
                    .lAngle] + self + [.rAngle]
        }
    }
}

extension FragmentArray {
    func isTypeConversionOperator() -> Bool {
        for i in 0..<count - 2 {
            if self[i] == .operator && self[i + 2].kind == .typeIdentifier {
                return true
            }
        }
        return false
    }
    
    func isTemplatedFunction() -> Bool {
        self[0] == .template
    }
    
    func parenthesesIndices(file: StaticString = #file, line: UInt = #line) -> (lParen: Index, rParen: Index) {
        let lParen = firstIndex {
            $0.kind == .text && $0.spelling.starts(with: "(")
        }
        let rParen = lastIndex {
            $0.kind == .text && $0.spelling.trimmingCharacters(in: .whitespaces).hasSuffix(")")
        }
        guard let lParen, let rParen, lParen <= rParen else {
            print("lParen: \(String(describing: lParen))")
            print("rParen: \(String(describing: rParen))")
            fatalError(file: file, line: line)
        }
        
        return (lParen, rParen)
    }
}

extension SymbolGraph.Symbol.Names {
    fileprivate mutating func reset(from: some Sequence<Fragment>) {
        self.subHeading = Array(from)
        self.title = self.subHeading!.map(\.spelling).joined()
    }
        
    fileprivate mutating func reset(fromFunctionSignature: FragmentArray) {
        // Subheading
        do {
            var newSubheading = FragmentArray()
            
            // func foo(bar x: Swift.Int, _ fizz: Swift.String, buzz: Swift.String) -> Swift.Array<Swift.Int>
            // func foo(bar: Swift.Int, Swift.String, buzz: Swift.String) -> Swift.Array<Swift.Int>
            
            var isSeekingTilNextColon = false
            var skipsNextColon = false
            for x in fromFunctionSignature {
                if isSeekingTilNextColon {
                    if x == .colon || x == .colonSpace {
                        isSeekingTilNextColon = false
                        if skipsNextColon {
                            skipsNextColon = false
                            continue
                        }
                    } else {
                        continue
                    }
                }
                
                if x.kind == .internalParameter {
                    isSeekingTilNextColon = true
                    skipsNextColon = false
                    continue
                }
                
                if x == .underscore {
                    isSeekingTilNextColon = true
                    skipsNextColon = true
                    continue
                }
                
                newSubheading.append(x)
            }
            
            subHeading = newSubheading
        }
        
        // Title
        do {
            // func foo(bar x: Swift.Int, _ fizz: Swift.String, buzz: Swift.String) -> Swift.Array<Swift.Int>
            // foo(bar:_:buzz:)
                        
            let lParenIndex = (fromFunctionSignature.firstIndex(of: .lParen) ?? fromFunctionSignature.firstIndex(of: .lParenRParen))!
            let beforeLParen = fromFunctionSignature[..<lParenIndex]
            let functionName = beforeLParen.last!
            
            let rparenIndex = (fromFunctionSignature.lastIndex(of: .rParen) ?? fromFunctionSignature.lastIndex(of: .lParenRParen))!
            let betweenParens = lParenIndex == rparenIndex ? [] : Array(fromFunctionSignature[lParenIndex.advanced(by: 1)..<rparenIndex])
            
            self.title = functionName.spelling + "(" + betweenParens.filter { $0.kind == .externalParameter }.map { $0.spelling + ":" }.joined() + ")"
        }
    }
}




extension SymbolGraph.Symbol {
    mutating func mapToSwift(relationshipsCopy: [SymbolGraph.Relationship], symbolsCopy: [String : SymbolGraph.Symbol]) {
        // Map the declaration fragments to look Swiftier for Swift mode
        mixins.mapDeclarationFragmentsInPlace { declarationFragments in
            switch kind.identifier {
            case .class, .struct:
                declarationFragments.declarationFragments.trimTrailingSemicolon()
                self.names.reset(from: declarationFragments.declarationFragments)
                
            case .init(rawValue: "objective-c++.namespace"):
                assert(declarationFragments.declarationFragments.first == .namespace)
                declarationFragments.declarationFragments[0] = .enum
                
                declarationFragments.declarationFragments.trimTrailingSemicolon()
                kind = .init(parsedIdentifier: .enum, displayName: "enum")
                
            case .func, .method, .typeMethod:
                var isStatic = false
                var isConstructor = false
                var isConst = false
                
                // Bail out if this is a type conversion operator or templated function;
                // we should show those as C++ because there isn't a good
                // Swift analog
                                
                if declarationFragments.declarationFragments.isTypeConversionOperator() ||
                    declarationFragments.declarationFragments.isTemplatedFunction() {
                    break
                }
                
                // Process static, const, semicolon
                
                if kind.identifier == .typeMethod {
                    isStatic = true
                    isConst = true
                    
                    declarationFragments.declarationFragments.trimLeadingStatic()
                    declarationFragments.declarationFragments.trimLeadingSpace()
                }
                
                if kind.identifier == .func {
                    isConst = true
                    if relationshipsCopy.first(where: { $0.source == self.identifier.precise && $0.kind == .memberOf }) != nil {
                        isStatic = true
                    }
                }
                
                declarationFragments.declarationFragments.trimTrailingSemicolon()
                
                if !isConst {
                    isConst = declarationFragments.declarationFragments.tryTrimTrailingConst()
                }
                
                // Look for parentheses and parameters
                let (lParenIndex, rParenIndex) = declarationFragments.declarationFragments.parenthesesIndices()
                var paramTypesAndInternalLabels = [(FragmentArray, Fragment?)]()
                if lParenIndex != rParenIndex {
                    let betweenParens = Array(declarationFragments.declarationFragments[lParenIndex.advanced(by: 1) ..< rParenIndex])
                    let split = betweenParens.splitCppParams()
                    paramTypesAndInternalLabels = split.map { $0.parseCppTypeAndFollowingName() }
                }
                                
                // Look for return type and function name
                let beforeLParen = Array(declarationFragments.declarationFragments[..<lParenIndex])
                var (returnType, functionName) = beforeLParen.parseCppTypeAndFollowingName()
                
                // Handle operators
                if functionName?.spelling.starts(with: "operator") ?? false {
                    isStatic = true
                    isConst = true
                    kind = .init(parsedIdentifier: .operator, displayName: "Operator")
                    functionName!.spelling.trimPrefix("operator")
                    
                    if let relationship = relationshipsCopy.first(where: { $0.source == self.identifier.precise }) {
                        if let containingSymbol = symbolsCopy.first(where: { $0.key == relationship.target })?.value {
                            let containingSymbolType = [Fragment(kind: .typeIdentifier,
                                                                 spelling: containingSymbol.names.title,
                                                                 preciseIdentifier: containingSymbol.identifier.precise)]
                            
                            paramTypesAndInternalLabels.insert((containingSymbolType, nil), at: 0)
                        }
                    }
                }
                
                // Handle constructors
                if functionName == nil {
                    isConst = true
                    isConstructor = true
                    functionName = .initKeyword
                    kind = .init(parsedIdentifier: .`init`, displayName: "Initializer")
                }
                
                // Map C++ types to Swift
                paramTypesAndInternalLabels.mapInPlace { $0.0.mapCppTypeToSwiftType() }
                returnType.mapCppTypeToSwiftType()
                
                
                
                
                // Build the new declaration fragments
                do {
                    declarationFragments.declarationFragments.removeAll()
                    if isStatic {
                        declarationFragments.declarationFragments += [.static, .space]
                    }
                    
                    if !isConst {
                        declarationFragments.declarationFragments += [.mutating, .space]
                    }
                    if !isConstructor {
                        declarationFragments.declarationFragments += [.func, .space]
                        declarationFragments.declarationFragments += [functionName!]
                    } else {
                        declarationFragments.declarationFragments += [.initKeyword]
                    }
                    
                    if paramTypesAndInternalLabels.isEmpty {
                        declarationFragments.declarationFragments += [.lParenRParen]
                    } else {
                        declarationFragments.declarationFragments += [.lParen]
                        
                        for (i, (paramType, internalLabel)) in paramTypesAndInternalLabels.enumerated() {
                            declarationFragments.declarationFragments += [.underscore, .space]
                            if let internalLabel {
                                declarationFragments.declarationFragments += [internalLabel]
                            }
                            declarationFragments.declarationFragments += [.colonSpace]
                            declarationFragments.declarationFragments += paramType
                            
                            if i + 1 < paramTypesAndInternalLabels.count {
                                declarationFragments.declarationFragments += [.commaSpace]
                            }
                        }
                        
                        declarationFragments.declarationFragments += [.rParen]
                    }
                                        
                    if !returnType.isEmpty && returnType != [.voidUppercase] {
                        declarationFragments.declarationFragments += [.space, .returnArrow, .space] + returnType
                    }
                }
                                
                // Redo self.names
                self.names.reset(fromFunctionSignature: declarationFragments.declarationFragments)
                
                
            case .property:
                declarationFragments.declarationFragments.trimTrailingSemicolon()
                var (cppType, name) = declarationFragments.declarationFragments.parseCppTypeAndFollowingName()
                guard let name else { fatalError() }
                
                cppType.mapCppTypeToSwiftType()
                declarationFragments.declarationFragments = [
                    .var,
                    .space,
                    name,
                    .colonSpace,
                ] + cppType
                
                self.names.subHeading = declarationFragments.declarationFragments
                self.names.title = name.spelling
                
            case .typealias:
                declarationFragments.declarationFragments.trimTrailingSemicolon()
                declarationFragments.declarationFragments.trimLeadingTypedef()
                declarationFragments.declarationFragments.trimLeadingSpace()
                
                let newName = declarationFragments.declarationFragments.popLast()!
                declarationFragments.declarationFragments.trimTrailingSpace()
                
                var type = declarationFragments.declarationFragments
                type.mapCppTypeToSwiftType()
                
                declarationFragments.declarationFragments = [
                    .typealias,
                    .space,
                    newName,
                    .spaceEqualsSpace,
                ] + type
                
                self.names.subHeading = [.typealias, .space, newName]
                self.names.title = newName.spelling
                
            case .var:
                declarationFragments.declarationFragments.trimTrailingSemicolon()
                declarationFragments.declarationFragments.tryTrimLeadingExternSpaceConstSpace()
                
                var (cppType, name) = declarationFragments.declarationFragments.parseCppTypeAndFollowingName()
                guard let name else { fatalError() }
                
                cppType.mapCppTypeToSwiftType()
                declarationFragments.declarationFragments = [
                    .var,
                    .space,
                    name,
                    .colonSpace
                ] + cppType + [
                    .space, .lBrace, .space, .get, .space, .rBrace
                ]
                self.names.subHeading = [.var, .space, name, .colonSpace] + cppType
                self.names.title = name.spelling
                
            case .init(rawValue: "enum.case"):
                declarationFragments.declarationFragments = [.case, .space] + declarationFragments.declarationFragments
                self.names.subHeading = declarationFragments.declarationFragments
                
            case .enum:
                declarationFragments.declarationFragments.trimLeadingEnum()
                declarationFragments.declarationFragments.trimLeadingSpace()
                declarationFragments.declarationFragments = [.enum, .space, declarationFragments.declarationFragments.first!]
                self.names.subHeading = declarationFragments.declarationFragments
                self.names.title = declarationFragments.declarationFragments.last!.spelling
                
            default:
                prettyPrint(kind, declarationFragments)
                print("Warning: Documentation is not converting this declaration to Swift")
                break
            }
        }
    }
}

// MARK: Cleaning

extension BuildDocumentation {
    func _cleanSymbolGraph(symbolGraph: inout SymbolGraph, changeFromCppToSwift: Bool) async {
        if changeFromCppToSwift {
            let symbolsCopy = symbolGraph.symbols
            symbolGraph.symbols.mapInPlace { preciseIdentifier, symbol in
                // Change the interface language, so they appear in Swift mode
                symbol.identifier.interfaceLanguage = "swift"
                
                symbol.mapToSwift(relationshipsCopy: symbolGraph.relationships, symbolsCopy: symbolsCopy)
            }
        }
        
        do {
            // Replace type-parameter-0-0 with the nearest genericParameter
            symbolGraph.symbols.mapInPlace { preciseIdentifier, symbol in
                symbol.mixins.mapDeclarationFragmentsInPlace { declarationFragments in
                    var genericParameter: String?
                    
                    declarationFragments.declarationFragments.mapInPlace { declarationFragment in
                        if declarationFragment.kind == .genericParameter {
                            genericParameter = declarationFragment.spelling
                        }
                        
                        if let genericParameter {
                            declarationFragment.spelling.replace("type-parameter-0-0", with: genericParameter)
                        }
                    }
                }
            }
        }
        
        do {
            // Fix PassToSwiftAsFunctionParameter and PassToSwiftAsReturnValue to take by ref instead of R-value ref
            symbolGraph.symbols.mapInPlace { preciseIdentifier, symbol in
                guard symbol.pathComponents == ["SwiftUsd", "PassToSwiftAsFunctionParameter"] ||
                        symbol.pathComponents == ["SwiftUsd", "PassToSwiftAsReturnValue"] else {
                    return
                }
                
                symbol.mixins.mapDeclarationFragmentsInPlace { declarationFragments in
                    let index = declarationFragments.declarationFragments.firstIndex(of: .init(kind: .typeIdentifier, spelling: "SmartPointer &", preciseIdentifier: "c:t0.0"))!
                    declarationFragments.declarationFragments[index].spelling = "SmartPointer"
                }
            }
        }
        
        do {
            // Remove all occurrences of `DocCCppWorkarounds`
            func _fix(_ x: inout String) {
                // Order dependent: Do mangled string replacements first,
                // because they're a super string of non-mangled string replacements
                x.replace("21pxrDocCCppWorkarounds", with: "3pxr")
                x.replace("pxrDocCCppWorkarounds", with: "pxr")
            }
            func _fix(_ x: inout String?) {
                if var y = x {
                    _fix(&y)
                    x = y
                }
            }
            func _fix(_ x: inout SymbolGraph.Symbol.DeclarationFragments.Fragment) {
                _fix(&x.spelling)
                _fix(&x.preciseIdentifier)
            }
            func _fix(_ x: inout Dictionary<String, any Mixin>) {
                x.mapDeclarationFragmentsInPlace { $0.declarationFragments.mapInPlace(_fix) }
                x.mapFunctionSignatureInPlace { $0.recursivelyMapDeclarationFragments(_fix) }
                x.mapSwiftExtensionInPlace { _fix(&$0.extendedModule) }
            }
            
            symbolGraph.symbols.mapInPlace { preciseIdentifier, symbol in
                _fix(&preciseIdentifier)
                _fix(&symbol.mixins)
                symbol.names.navigator?.mapInPlace(_fix)
                _fix(&symbol.names.prose)
                symbol.names.subHeading?.mapInPlace(_fix)
                _fix(&symbol.names.title)
                _fix(&symbol.identifier.precise)
                symbol.pathComponents.mapInPlace(_fix)
            }
            
            symbolGraph.relationships.mapInPlace { relationship in
                _fix(&relationship.mixins)
                _fix(&relationship.source)
                _fix(&relationship.target)
                _fix(&relationship.targetFallback)
            }
        }
        
        do {
            // Replace the Pixar namespace with pxr,
            // and replace __ObjC with C++
            let pixarHeader = Driver.shared.pixarHeaderURL
            let pixarNamespace = String(try! await pixarHeader.lines.compactMap {
                $0.wholeMatch(of: /#define PXR_INTERNAL_NS\s+([^ ]*)\s*/)?.output.1
            }.first { _ in true }!)
            
            func _fix(_ x: inout String) {
                x.replace(pixarNamespace, with: "pxr")
                x.replace("__ObjC", with: "C++")
            }
            func _fix(_ x: inout String?) {
                if var y = x {
                    _fix(&y)
                    x = y
                }
            }
            func _fix(_ x: inout SymbolGraph.Symbol.DeclarationFragments.Fragment) {
                _fix(&x.spelling)
                _fix(&x.preciseIdentifier)
            }
            func _fix(_ x: inout Dictionary<String, any Mixin>) {
                x.mapDeclarationFragmentsInPlace { $0.declarationFragments.mapInPlace(_fix) }
                x.mapFunctionSignatureInPlace { $0.recursivelyMapDeclarationFragments(_fix) }
                x.mapSwiftExtensionInPlace { _fix(&$0.extendedModule) }
            }
            
            symbolGraph.symbols.mapInPlace { preciseIdentifier, symbol in
                _fix(&preciseIdentifier)
                _fix(&symbol.mixins)
                symbol.names.navigator?.mapInPlace(_fix)
                _fix(&symbol.names.prose)
                symbol.names.subHeading?.mapInPlace(_fix)
                _fix(&symbol.names.title)
                _fix(&symbol.identifier.precise)
                symbol.pathComponents.mapInPlace(_fix)
            }
            
            symbolGraph.relationships.mapInPlace { relationship in
                _fix(&relationship.mixins)
                _fix(&relationship.source)
                _fix(&relationship.target)
                _fix(&relationship.targetFallback)
            }
        }
    }
}
