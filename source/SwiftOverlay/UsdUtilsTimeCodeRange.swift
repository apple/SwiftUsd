//
//  UsdUtilsTimeCodeRange.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 6/2/25.
//

import Foundation
import CxxStdlib

extension pxr.UsdUtilsTimeCodeRange: CxxSequence {
    public typealias Element = const_iterator.value_type
    public typealias RawIterator = const_iterator
}
extension pxr.UsdUtilsTimeCodeRange.const_iterator: UnsafeCxxInputIterator {
    public var pointee: value_type {
        __Overlay.UsdUtilsTimeCodeRange_const_iterator__operatorStar(self)
    }
    
    public typealias Pointee = value_type
}
extension pxr.UsdUtilsTimeCodeRange: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(GetStartTimeCode(), forKey: .startTimeCode)
        try container.encode(GetEndTimeCode(), forKey: .endTimeCode)
        try container.encode(GetStride(), forKey: .stride)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startTimeCode = try container.decode(pxr.UsdTimeCode.self, forKey: .startTimeCode)
        let endTimeCode = try container.decode(pxr.UsdTimeCode.self, forKey: .endTimeCode)
        let stride = try container.decode(Double.self, forKey: .stride)
        self.init(startTimeCode, endTimeCode, stride)
    }
    
    public enum CodingKeys: String, CodingKey {
        case startTimeCode
        case endTimeCode
        case stride
    }
}
