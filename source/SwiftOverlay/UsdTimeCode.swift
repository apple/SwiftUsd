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



extension pxr.UsdTimeCode: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(Double(value))
    }
}
extension pxr.UsdTimeCode: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}
extension pxr.UsdTimeCode: Numeric {
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let x = Double(exactly: source) else { return nil }
        self.init(x)
    }
    
    public var magnitude: pxr.UsdTimeCode {
        .init(GetValue().magnitude)
    }
    
    public static func * (lhs: pxr.UsdTimeCode, rhs: pxr.UsdTimeCode) -> pxr.UsdTimeCode {
        .init(lhs.GetValue() * rhs.GetValue())
    }
    
    public static func *= (lhs: inout pxr.UsdTimeCode, rhs: pxr.UsdTimeCode) {
        lhs = lhs * rhs
    }
}
extension pxr.UsdTimeCode: SignedNumeric { }
extension pxr.UsdTimeCode: FloatingPoint {
    public mutating func round(_ rule: FloatingPointRoundingRule) {
        var x = GetValue()
        x.round(rule)
        self = .init(x)
    }
    
    public static func /= (lhs: inout pxr.UsdTimeCode, rhs: pxr.UsdTimeCode) {
        lhs = lhs / rhs
    }
    
    public static func - (lhs: pxr.UsdTimeCode, rhs: pxr.UsdTimeCode) -> pxr.UsdTimeCode {
        .init(lhs.GetValue() - rhs.GetValue())
    }
    
    public static func + (lhs: pxr.UsdTimeCode, rhs: pxr.UsdTimeCode) -> pxr.UsdTimeCode {
        .init(lhs.GetValue() + rhs.GetValue())
    }
    
    public init<Source>(_ value: Source) where Source : BinaryInteger {
        self.init(Double(value))
    }
    
    public init(_ value: Int) {
        self.init(Double(value))
    }
    
    public init(sign: FloatingPointSign, exponent: Double.Exponent, significand: pxr.UsdTimeCode) {
        self.init(Double(sign: sign, exponent: exponent, significand: significand.GetValue()))
    }
    
    public var exponent: Double.Exponent {
        GetValue().exponent
    }
    
    public static var nan: pxr.UsdTimeCode {
        .Default()
    }
    
    public static var signalingNaN: pxr.UsdTimeCode {
        .init(Double.signalingNaN)
    }
    
    public static var infinity: pxr.UsdTimeCode {
        .init(Double.infinity)
    }
    
    public static var greatestFiniteMagnitude: pxr.UsdTimeCode {
        .init(Double.greatestFiniteMagnitude)
    }
    
    public static var pi: pxr.UsdTimeCode {
        .init(Double.pi)
    }
    
    public var ulp: pxr.UsdTimeCode {
        .init(GetValue().ulp)
    }
    
    public static var leastNormalMagnitude: pxr.UsdTimeCode {
        .init(Double.leastNormalMagnitude)
    }
    
    public static var leastNonzeroMagnitude: pxr.UsdTimeCode {
        .init(Double.leastNonzeroMagnitude)
    }
    
    public var sign: FloatingPointSign {
        GetValue().sign
    }
    
    public var significand: pxr.UsdTimeCode {
        .init(GetValue().significand)
    }
    
    public static func / (lhs: pxr.UsdTimeCode, rhs: pxr.UsdTimeCode) -> pxr.UsdTimeCode {
        .init(lhs.GetValue() / rhs.GetValue())
    }
    
    public mutating func formRemainder(dividingBy other: pxr.UsdTimeCode) {
        var x = GetValue()
        x.formRemainder(dividingBy: other.GetValue())
        self = .init(x)
    }
    
    public mutating func formTruncatingRemainder(dividingBy other: pxr.UsdTimeCode) {
        var x = GetValue()
        x.formTruncatingRemainder(dividingBy: other.GetValue())
        self = .init(x)
    }
    
    public mutating func formSquareRoot() {
        var x = GetValue()
        x.formSquareRoot()
        self = .init(x)
    }
    
    public mutating func addProduct(_ lhs: pxr.UsdTimeCode, _ rhs: pxr.UsdTimeCode) {
        var x = GetValue()
        x.addProduct(lhs.GetValue(), rhs.GetValue())
        self = .init(x)
    }
    
    public var nextUp: pxr.UsdTimeCode {
        .init(GetValue().nextUp)
    }
    
    public func isEqual(to other: pxr.UsdTimeCode) -> Bool {
        self == other
    }
    
    public func isLess(than other: pxr.UsdTimeCode) -> Bool {
        __Overlay.operatorLess(self, other)
    }
    
    public func isLessThanOrEqualTo(_ other: pxr.UsdTimeCode) -> Bool {
        // Don't use <=, because that causes an infinite loop
        __Overlay.operatorLess(self, other) || __Overlay.operatorEqualsEquals(self, other)
    }
    
    public var isNormal: Bool {
        GetValue().isNormal
    }
    
    public var isFinite: Bool {
        GetValue().isFinite
    }
    
    public var isZero: Bool {
        GetValue().isZero
    }
    
    public var isSubnormal: Bool {
        GetValue().isSubnormal
    }
    
    public var isInfinite: Bool {
        GetValue().isInfinite
    }
    
    public var isNaN: Bool {
        GetValue().isNaN
    }
    
    public var isSignalingNaN: Bool {
        GetValue().isSignalingNaN
    }
    
    public var isCanonical: Bool {
        GetValue().isCanonical
    }
    
    public typealias Exponent = Double.Exponent
}
extension pxr.UsdTimeCode: BinaryFloatingPoint {
    public init(sign: FloatingPointSign, exponentBitPattern: Double.RawExponent, significandBitPattern: Double.RawSignificand) {
        self.init(Double(sign: sign, exponentBitPattern: exponentBitPattern, significandBitPattern: significandBitPattern))
    }
    
    public static var exponentBitCount: Int {
        Double.exponentBitCount
    }
    
    public static var significandBitCount: Int {
        Double.significandBitCount
    }
    
    public var exponentBitPattern: Double.RawExponent {
        GetValue().exponentBitPattern
    }
    
    public var significandBitPattern: Double.RawSignificand {
        GetValue().significandBitPattern
    }
    
    public var binade: pxr.UsdTimeCode {
        .init(GetValue().binade)
    }
    
    public var significandWidth: Int {
        GetValue().significandWidth
    }
    
    public typealias RawSignificand = Double.RawSignificand
    
    public typealias RawExponent = Double.RawExponent
    
    
}
extension pxr.UsdTimeCode: Strideable {
    public func distance(to other: pxr.UsdTimeCode) -> pxr.UsdTimeCode {
        .init(GetValue().distance(to: other.GetValue()))
    }
    
    public func advanced(by n: pxr.UsdTimeCode) -> pxr.UsdTimeCode {
        .init(GetValue().advanced(by: n.GetValue()))
    }
    
    public typealias Stride = Self
    
    
}
extension pxr.UsdTimeCode: AdditiveArithmetic {
    
}
