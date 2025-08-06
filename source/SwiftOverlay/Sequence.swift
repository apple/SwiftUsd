// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

import Foundation
import CxxStdlib


extension __Overlay {
    public struct OpenUSD_Iterator<S: __Overlay.OpenUSD_Sequence>: IteratorProtocol {
        var begin: S.const_iterator
        var end: S.const_iterator
        var s: S // hold the Sequence alive as long as there's an iterator to it

        init(begin: S.const_iterator, end: S.const_iterator, s: S) {
            self.begin = begin
            self.end = end
            self.s = s
        }

        public mutating func next() -> S.value_type? {
            if begin == end {
                return nil
            }
            let result = begin.pointee
            begin = begin.successor()
            return result
        }
    }
}

extension __Overlay {
    public protocol OpenUSD_Sequence_const_iterator: Equatable {
        associatedtype value_type
        var pointee: value_type { get }
        func successor() -> Self
    }
}

extension __Overlay {
    public protocol OpenUSD_Sequence: Sequence {
        associatedtype value_type
        associatedtype const_iterator: OpenUSD_Sequence_const_iterator where const_iterator.value_type == value_type
        func __beginUnsafe() -> const_iterator
        func __endUnsafe() -> const_iterator
    }
}
extension __Overlay.OpenUSD_Sequence where Element == Self.value_type {
    public func makeIterator() -> __Overlay.OpenUSD_Iterator<Self> {
        .init(begin: __beginUnsafe(), end: __endUnsafe(), s: self)
    }
}



extension pxr.UsdPrimSubtreeRange: __Overlay.OpenUSD_Sequence {}
extension pxr.UsdPrimSubtreeRange.const_iterator: __Overlay.OpenUSD_Sequence_const_iterator {}
extension pxr.UsdPrimSiblingRange: __Overlay.OpenUSD_Sequence {}
extension pxr.UsdPrimSiblingRange.const_iterator: __Overlay.OpenUSD_Sequence_const_iterator {}


extension pxr.VtDictionary: CxxDictionary, CxxSequence {
    public typealias RawIterator = pxr.VtDictionary.const_iterator
    public typealias RawMutableIterator = pxr.VtDictionary.iterator

    public typealias Key = std.string
    public typealias Value = pxr.VtValue
    public typealias Size = size_type
    public typealias InsertionResult = Overlay.VtDictionary_Iterator_Bool_Pair
    public typealias Element = pxr.VtDictionary.value_type

    public mutating func __insertUnsafe(_ element: Self.Element) -> Self.InsertionResult {
        __Overlay.insert(&self, element)
    }
    public func __findUnsafe(_ key: Self.Key) -> Self.RawIterator {
        __Overlay.find(self, key)
    }
    public mutating func __findMutatingUnsafe(_ key: Self.Key) -> Self.RawMutableIterator {
        __Overlay.findMutating(&self, key)
    }
    @discardableResult
    public mutating func __eraseUnsafe(_ iter: RawMutableIterator) -> RawMutableIterator {
        erase(iter)
    }
}

extension pxr.VtDictionary.const_iterator: UnsafeCxxInputIterator {}
extension pxr.VtDictionary.iterator: UnsafeCxxMutableInputIterator {}




// MARK: UsdMetadataValueMap
// Workaround for rdar://124105392 (UsdMetadataValueMap subscript getter is mutating (5.10 regression))
extension pxr.UsdMetadataValueMap {
    public subscript(_ k: pxr.TfToken) -> pxr.VtValue? {
        var isValid = false
        let result = __Overlay.operatorSubscript(self, k, &isValid)
        return isValid ? result : nil
    }
}






extension Overlay.TfDiagnosticBase_Shared_Ptr_Vector: CxxSequence {}
extension pxr.UsdMetadataValueMap: CxxSequence {}

extension pxr.UsdNotice.ObjectsChanged.PathRange: CxxSequence {
    public typealias Element = pxr.SdfPath
    public typealias RawIterator = pxr.UsdNotice.ObjectsChanged.PathRange.iterator
}
extension pxr.UsdNotice.ObjectsChanged.PathRange.iterator: UnsafeCxxInputIterator {}

extension pxr.GfMultiInterval: CxxSequence {
    public typealias RawIterator = pxr.GfMultiInterval.const_iterator
    public typealias Element = pxr.GfInterval
}
extension pxr.GfMultiInterval.const_iterator: UnsafeCxxInputIterator {}