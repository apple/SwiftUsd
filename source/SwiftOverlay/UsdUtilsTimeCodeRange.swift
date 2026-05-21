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
import CxxStdlib

extension pxr.UsdUtilsTimeCodeRange: CxxSequence {
    public typealias Element = const_iterator.value_type
    public typealias RawIterator = const_iterator
}
extension pxr.UsdUtilsTimeCodeRange.const_iterator: UnsafeCxxInputIterator {
    public var pointee: value_type {
        borrowing get {
            __Overlay.UsdUtilsTimeCodeRange_const_iterator__operatorStar(self).pointee
        }
    }
    
    public typealias Pointee = value_type
}
#if compiler(>=6.4)
// Starting in Swift 6.4, UnsafeCxxInputIterator's requirements change slightly,
// in a way where we need to help the compiler
extension pxr.UsdUtilsTimeCodeRange.const_iterator {
    public borrowing func __operatorStar() -> reference {
        __Overlay.UsdUtilsTimeCodeRange_const_iterator__operatorStar(self)
    }
}
#endif // #if compiler(>=6.4)

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
