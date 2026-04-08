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

/// Interprets the expression sublanguage, i.e. the text between `${{` and `}}` in expressions
internal enum ExpressionSublanguageInterpreter {
    static func substitute(sublanguageString s: String, in context: borrowing Context, purpose: ExpressionEvaluator.EvaluationPurpose, logger: Logger) throws -> Expression {
        let tokens = try Token.tokenize(s)
        let rawNode = try Parser.parse(tokens)
        let augmentedNode = rawNode.augmented(for: purpose)
        let result = try Interpreter.interpret(augmentedNode, in: context, for: purpose, logger: logger)
        return result
    }
}

fileprivate enum Token {
    case lparen
    case rparen
    case exclamationMark
    case doublePipe
    case doubleAmpersand
    case period
    case comma
    case identifier(String)
    
    enum TokenError: Error {
        case illegalCharacter(Character, String)
    }
    
    static func tokenize(_ s: String) throws -> [Token] {
        var i = s.startIndex
        var buffer = [Character]()
        var result = [Token]()
        
        func pushBufferIfNonEmpty() {
            if !buffer.isEmpty {
                result.append(.identifier(String(buffer)))
            }
            buffer = []
        }
        func advanceIfPossible(withPrefix: String) -> Bool {
            if s[i...].hasPrefix(withPrefix) {
                i = s.index(i, offsetBy: withPrefix.count)
                return true
            }
            return false
        }
        
        while i < s.endIndex {
            switch s[i] {
            case "(": pushBufferIfNonEmpty(); result.append(.lparen)
            case ")": pushBufferIfNonEmpty(); result.append(.rparen)
            case "!": pushBufferIfNonEmpty(); result.append(.exclamationMark)
            case ".": pushBufferIfNonEmpty(); result.append(.period)
            case ",": pushBufferIfNonEmpty(); result.append(.comma)
            case let c where c.isWhitespace: pushBufferIfNonEmpty()
            case let c where "abcdefghijklmnopqrstuvwxyz_-".contains(c.lowercased()): buffer.append(c)
            case _ where advanceIfPossible(withPrefix: "&&"): pushBufferIfNonEmpty(); result.append(.doubleAmpersand); continue
            case _ where advanceIfPossible(withPrefix: "||"): pushBufferIfNonEmpty(); result.append(.doublePipe); continue
            default:
                throw TokenError.illegalCharacter(s[i], s)
            }
            s.formIndex(after: &i)
        }
        pushBufferIfNonEmpty()
        return result
    }
}

fileprivate enum Parser {
    indirect enum Pass1Node: Sendable {
        case functionCall(String, [Pass1Node])
        case parenthesizedExpression([Pass1Node])
        case operator_(String)
        case identifierChain(String)
        case comma
        
        enum Pass1Error: Error {
            case unexpectedRParen([Token], [IntermediateNode])
            case unexpectedPeriod([Token], [IntermediateNode])
            case unexpectedIdentifier([Token], [IntermediateNode])
            case unclosedPass1Node(IntermediateNode)
            case identifierChainsCannotEndInPeriod(String)
        }
        
        enum IntermediateNode: Sendable {
            case openedFunctionCall(String)
            case closedFunctionCall(String, [IntermediateNode])
            case openedParenthesizedExpression
            case closedParenthesizedExpression([IntermediateNode])
            case operator_(String)
            case identifierChain(String)
            case comma
            
            var finalized: Pass1Node {
                get throws {
                    switch self {
                    case .openedFunctionCall, .openedParenthesizedExpression: throw Pass1Error.unclosedPass1Node(self)
                    case let .closedFunctionCall(f, args): .functionCall(f, try args.map { try $0.finalized })
                    case let .closedParenthesizedExpression(nodes): .parenthesizedExpression(try nodes.map { try $0.finalized })
                    case let .operator_(x): .operator_(x)
                    case let .identifierChain(x): if x.last == "." { throw Pass1Error.identifierChainsCannotEndInPeriod(x) } else { .identifierChain(x) }
                    case .comma: .comma
                    }
                }
            }
        }
        
        static func parseTokens(_ tokens: [Token]) throws -> [Pass1Node] {
            var result = [IntermediateNode]()
            tokenLoop: for token in tokens {
                switch token {
                case .lparen:
                    if case let .identifierChain(x) = result.last {
                        result.removeLast()
                        result.append(.openedFunctionCall(x))
                    } else {
                        result.append(.openedParenthesizedExpression)
                    }
                case .rparen:
                    for i in (0..<result.count).reversed() {
                        if case .openedFunctionCall(let x) = result[i] {
                            let toAdd = IntermediateNode.closedFunctionCall(x, Array(result[(i + 1)...]))
                            result.removeLast(result.count - i)
                            result.append(toAdd)
                            continue tokenLoop
                        } else if case .openedParenthesizedExpression = result[i] {
                            let toAdd = IntermediateNode.closedParenthesizedExpression(Array(result[(i + 1)...]))
                            result.removeLast(result.count - i)
                            result.append(toAdd)
                            continue tokenLoop
                        }
                    }
                    
                    throw Pass1Error.unexpectedRParen(tokens, result)
                    
                case .exclamationMark: result.append(.operator_("!"))
                case .doublePipe: result.append(.operator_("||"))
                case .doubleAmpersand: result.append(.operator_("&&"))
                case .period:
                    guard case let .identifierChain(x) = result.popLast(), x.last != "." else {
                        throw Pass1Error.unexpectedPeriod(tokens, result)
                    }
                    result.append(.identifierChain(x + "."))
                case .comma: result.append(.comma)
                case let .identifier(y):
                    if case let .identifierChain(x) = result.last {
                        guard x.last == "." else {
                            throw Pass1Error.unexpectedIdentifier(tokens, result)
                        }
                        result.removeLast()
                        result.append(.identifierChain(x + y))
                    } else {
                        result.append(.identifierChain(y))
                    }
                }
            }
            
            return try result.map { try $0.finalized }
        }
    }
    
    enum Pass2Node: Sendable {
        case identifierChain(String)
        case functionCall(String, [Pass2Node])
        case parenthesizedExpression([Pass2Node])
        case operator_(String)
        
        enum Pass2Error: Error {
            case unexpectedComma([Pass1Node])
        }
        
        static func parseNodes(_ input: [Pass1Node]) throws -> [Pass2Node] {
            var result = [Pass2Node]()
            
            for node in input {
                switch node {
                case let .functionCall(name, args):
                    if case .comma = args.first { throw Pass2Error.unexpectedComma(args) }
                    if case .comma = args.last { throw Pass2Error.unexpectedComma(args) }
                    
                    var splitArgs: [[Pass1Node]] = [[]]
                    for arg in args {
                        switch arg {
                        case .comma:
                            if splitArgs.last!.isEmpty { throw Pass2Error.unexpectedComma(args) }
                            splitArgs.append([])
                        default: splitArgs[splitArgs.count - 1].append(arg)
                        }
                    }
                    if splitArgs.last!.isEmpty { splitArgs.removeLast() }
                    let mappedSplitArgs = try splitArgs.map { try parseNodes($0) }
                    result.append(.functionCall(name, mappedSplitArgs.map { .parenthesizedExpression($0) }))
                    
                case let .parenthesizedExpression(nodes):
                    result.append(.parenthesizedExpression(try parseNodes(nodes)))
                    
                case let .operator_(op): result.append(.operator_(op))
                case let .identifierChain(x): result.append(.identifierChain(x))
                case .comma: throw Pass2Error.unexpectedComma(input)
                }
            }
            
            return result
        }
    }
    
    indirect enum Pass3Node: Sendable {
        case identifierChain(String)
        case functionCall(String, [Pass3Node])
        case parenthesizedExpression([Pass3Node])
        case infixOperator(InfixOperator)
        case prefixOperator(PrefixOperator, Pass3Node)
        
        enum PrefixOperator {
            case not
        }
        enum InfixOperator {
            case and
            case or
        }
        
        enum Pass3Error: Error {
            case unexpectedPrefixOperator(Pass2Node, [Pass2Node])
            case unknownOperator(Pass2Node, [Pass2Node])
            case unexpectedRecurseResult([Pass3Node])
        }
        
        static func parseNodes(_ input: [Pass2Node]) throws -> [Pass3Node] {
            var result = [Pass3Node]()
            
            var i = 0
            while i < input.count {
                let node = input[i]
                switch node {
                case let .identifierChain(x): result.append(.identifierChain(x))
                case let .functionCall(name, args): result.append(.functionCall(name, try parseNodes(args)))
                case let .parenthesizedExpression(exprs): result.append(.parenthesizedExpression(try parseNodes(exprs)))
                case let .operator_(x):
                    if x == "!" {
                        if i + 1 >= input.count {
                            throw Pass3Error.unexpectedPrefixOperator(node, input)
                        } else {
                            let recurseResult = try parseNodes([input[i + 1]])
                            guard recurseResult.count == 1 else { throw Pass3Error.unexpectedRecurseResult(recurseResult) }
                            result.append(.prefixOperator(.not, recurseResult.first!))
                            i += 1
                        }
                    } else if x == "&&" {
                        result.append(.infixOperator(.and))
                    } else if x == "||" {
                        result.append(.infixOperator(.or))
                    } else {
                        throw Pass3Error.unknownOperator(node, input)
                    }
                }
                i += 1
            }
            return result
        }
    }
    
    indirect enum FinalPassNode: Sendable {
        case identifierChain(String)
        case functionCall(String, [FinalPassNode])
        case infixOperator(FinalPassNode, Pass3Node.InfixOperator, FinalPassNode)
        case prefixOperator(Pass3Node.PrefixOperator, FinalPassNode)
        
        enum IntermediateNode {
            case finalPassNode(FinalPassNode)
            case openInfixOperator(FinalPassNode, Pass3Node.InfixOperator)
        }
        
        enum FinalPassError: Error {
            case easyMapReturnedNil(Pass3Node)
            case expectedOperator(Pass3Node, [Pass3Node])
            case unexpectedOperator(Pass3Node, [Pass3Node])
            case expectedOneNode([IntermediateNode], [Pass3Node])
            case expectedOperand([IntermediateNode])
        }
        
        static func parseNodes(_ input: [Pass3Node]) throws -> FinalPassNode {
            func easyMap(_ x: Pass3Node) throws -> FinalPassNode? {
                switch x {
                case let .identifierChain(x): return .identifierChain(x)
                case let .functionCall(name, args):
                    let mappedArgs = try args.map { try parseNodes([$0]) }
                    return .functionCall(name, mappedArgs)
                    
                case let .parenthesizedExpression(x): return try parseNodes(x)
                case .infixOperator: return nil
                case let .prefixOperator(op, expr): return .prefixOperator(op, try parseNodes([expr]))
                }
            }
            
            var result = [IntermediateNode]()
            // Not doing full blown C precedence for && vs ||, but reverse so we have left associativity.
            for node in input.reversed() {
                switch node {
                case .identifierChain, .functionCall, .parenthesizedExpression, .prefixOperator:
                    guard let easyMapped = try easyMap(node) else {
                        throw FinalPassError.easyMapReturnedNil(node)
                    }
                    if case .openInfixOperator(let left, let op) = result.last {
                        result.removeLast()
                        result.append(.finalPassNode(.infixOperator(left, op, easyMapped)))
                    } else if result.isEmpty {
                        result.append(.finalPassNode(easyMapped))
                    } else {
                        throw FinalPassError.expectedOperator(node, input)
                    }
                    
                case let .infixOperator(op):
                    guard case let .finalPassNode(x) = result.last else {
                        throw FinalPassError.unexpectedOperator(node, input)
                    }
                    result.removeLast()
                    result.append(.openInfixOperator(x, op))
                }
            }
            
            guard result.count == 1 else { throw FinalPassError.expectedOneNode(result, input) }
            switch result.first! {
            case let .finalPassNode(x): return x
            case .openInfixOperator: throw FinalPassError.expectedOperand(result)
            }
        }
        
        func augmented(for purpose: ExpressionEvaluator.EvaluationPurpose) -> FinalPassNode {
            switch purpose {
            case .default_: return self
            case .jobIf, .stepIf: break
            }
            
            let statusCheckFunctionNames = ["success", "always", "cancelled", "failure"]
            func hasStatusCheckFunction(_ x: FinalPassNode) -> Bool {
                switch x {
                case .identifierChain: false
                case .functionCall(let name, let args): statusCheckFunctionNames.contains(name) || args.contains(where: { hasStatusCheckFunction($0) })
                case .infixOperator(let left, _, let right): hasStatusCheckFunction(left) || hasStatusCheckFunction(right)
                case .prefixOperator(_, let expr): hasStatusCheckFunction(expr)
                }
            }
            
            if hasStatusCheckFunction(self) { return self }
            return .infixOperator(self, .and, .functionCall("success", []))
        }
    }
    
    static func parse(_ tokens: [Token]) throws -> FinalPassNode {
        let pass1 = try Pass1Node.parseTokens(tokens)
        let pass2 = try Pass2Node.parseNodes(pass1)
        let pass3 = try Pass3Node.parseNodes(pass2)
        let finalPass = try FinalPassNode.parseNodes(pass3)
        return finalPass
    }
}

fileprivate enum Interpreter {
    enum InterpreterError: Error {
        case expressionEvaluatedToNonIntValue(Parser.FinalPassNode)
        case badContextLookup(String)
        case unexpectedArgumentCount(String, Int, [Expression])
        case unknownFunction(String)
        case fromJsonRequiresString(Expression)
        case fromJsonRequiresStringValue(String, Expression)
    }
    
    static func interpret(_ node: Parser.FinalPassNode, in context: borrowing Context, for purpose: ExpressionEvaluator.EvaluationPurpose, logger: Logger) throws -> Expression {
        switch node {
        case let .identifierChain(x): return try lookup(string: x, in: context)
        case let .functionCall(name, args):
            let interpretedArgs = try args.map { try interpret($0, in: context, for: purpose, logger: logger) }
            return try computeFunction(name, interpretedArgs, in: context, for: purpose, logger: logger)
        case let .infixOperator(left, op, right):
            guard let interpretedLeft = try interpret(left, in: context, for: purpose, logger: logger).asInt else {
                throw InterpreterError.expressionEvaluatedToNonIntValue(left)
            }
            // Short circuit
            switch op {
            case .and: if interpretedLeft == 0 { return .int(0) }
            case .or: if interpretedLeft != 0 { return .int(1) }
            }
            return try interpret(right, in: context, for: purpose, logger: logger)

        case let .prefixOperator(op, expr):
            guard let interpretedExpr = try interpret(expr, in: context, for: purpose, logger: logger).asInt else {
                throw InterpreterError.expressionEvaluatedToNonIntValue(expr)
            }
            switch op {
            case .not: return .int(interpretedExpr == 0 ? 1 : 0)
            }
        }
    }
    
    static func lookup(string s: String, in context: borrowing Context) throws -> Expression {
        guard let result = context[s] else {
            throw InterpreterError.badContextLookup(s)
        }
        return result
    }

    static func computeFunction(_ name: String, _ args: [Expression], in context: borrowing Context, for purpose: ExpressionEvaluator.EvaluationPurpose, logger: Logger) throws -> Expression {
        func guardArgCount(_ expected: Int) throws {
            guard args.count == expected else { throw InterpreterError.unexpectedArgumentCount(name, expected, args) }
        }
        
        switch name {
        case "always":
            try guardArgCount(0)
            return .int(1)
            
        case "success":
            try guardArgCount(0)
            let hadFailure = context.hasFailures(for: purpose, logger: logger)
            return hadFailure ? .int(0) : .int(1)
            
        case "failure":
            try guardArgCount(0)
            let hadFailure = context.hasFailures(for: purpose, logger: logger)
            return hadFailure ? .int(1) : .int(0)
            
        case "cancelled":
            try guardArgCount(0)
            return .int(0)
            
        case "fromJson":
            try guardArgCount(1)
            guard let argAsString = args[0].asString else { throw InterpreterError.fromJsonRequiresString(args[0]) }
            return try Expression.fromJson(argAsString)
        
        default:
            throw InterpreterError.unknownFunction(name)
        }
    }
}


