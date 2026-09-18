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
import OpenUSD
import TemporaryImplementations_Cxx
import TemporaryImplementations_Swift

// These proxy types backing LIVERPS arcs should conform to Sequence, and that conformance should live in SwiftUsd,
// but when trying to do so, we run into:
// rdar://187057230 (Trying to use a `for` loop to iterate over a C++ type conformed to Sequence causes "Failure to produce diagnostic for expression" across a module boundary)
// Workaround: Put the conformance in the module that uses it
//
// There's nothing particularly interesting here, this is just what it takes sometimes to conform C++ types to the right Swift protocols.


extension pxr.SdfVariantSetsProxy: Sequence, CxxSequence {
    public typealias RawIterator = const_iterator
    public typealias Element = const_iterator.value_type
}
extension pxr.SdfVariantSetsProxy.const_iterator: UnsafeCxxInputIterator {
    public static func ==(lhs: Self, _ rhs: Self) -> Bool {
        __Overlay.manual_operatorEqualsEquals(lhs, rhs)
    }
}

extension pxr.SdfRelocatesMapProxy: Sequence, CxxSequence, CxxDictionary {
    public typealias RawIterator = const_iterator
    public typealias RawMutableIterator = iterator
    
    public typealias Key = pxr.SdfPath
    public typealias Value = pxr.SdfPath
    public typealias Size = size_type
    public typealias InsertionResult = Overlay.SdfRelocatesMapProxy_Iterator_Bool_Pair
    public typealias Element = value_type
    
    public mutating func __insertUnsafe(_ element: Self.Element) -> Self.InsertionResult {
        __Overlay.insert(&self, element)
    }
    
    public mutating func __eraseUnsafe(_ it: Self.iterator) -> Self.iterator {
        __Overlay.erase(&self, it)
    }
}

extension pxr.SdfRelocatesMapProxy.const_iterator: UnsafeCxxInputIterator {
    public static func ==(lhs: Self, _ rhs: Self) -> Bool {
        __Overlay.manual_operatorEqualsEquals(lhs, rhs)
    }
}
extension pxr.SdfRelocatesMapProxy.iterator: UnsafeCxxMutableInputIterator {
    public var pointee: pxr.SdfRelocatesMapProxy.Element {
        get { __Overlay.operatorStar(self) }
        set { __Overlay.operatorStarSet(&self, newValue) }
    }
    
    public typealias Pointee = pxr.SdfRelocatesMapProxy.Element
    
    public static func ==(lhs: Self, _ rhs: Self) -> Bool {
        __Overlay.manual_operatorEqualsEquals(lhs, rhs)
    }
}

extension pxr.SdfVariantSelectionProxy: Sequence, CxxSequence, CxxDictionary {
    public typealias RawIterator = const_iterator
    public typealias RawMutableIterator = iterator
    
    public typealias Key = std.string
    public typealias Value = std.string
    public typealias Size = size_type
    public typealias InsertionResult = Overlay.SdfVariantSelectionProxy_Iterator_Bool_Pair
    public typealias Element = value_type
    
    public mutating func __insertUnsafe(_ element: Self.Element) -> Self.InsertionResult {
        __Overlay.insert(&self, element)
    }
    
    public mutating func __eraseUnsafe(_ it: Self.iterator) -> Self.iterator {
        __Overlay.erase(&self, it)
    }
}

extension pxr.SdfVariantSelectionProxy.const_iterator: UnsafeCxxInputIterator {
    public static func ==(lhs: Self, _ rhs: Self) -> Bool {
        __Overlay.manual_operatorEqualsEquals(lhs, rhs)
    }
}
extension pxr.SdfVariantSelectionProxy.iterator: UnsafeCxxMutableInputIterator {
    public var pointee: pxr.SdfVariantSelectionProxy.Element {
        get { __Overlay.operatorStar(self) }
        set { __Overlay.operatorStarSet(&self, newValue) }
    }
    
    public typealias Pointee = pxr.SdfVariantSelectionProxy.Element
    
    public static func ==(lhs: Self, _ rhs: Self) -> Bool {
        __Overlay.manual_operatorEqualsEquals(lhs, rhs)
    }
}
