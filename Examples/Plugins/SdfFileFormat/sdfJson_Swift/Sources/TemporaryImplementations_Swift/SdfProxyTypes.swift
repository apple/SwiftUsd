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

public protocol _StdVectorProtocol<value_type>: Sequence where Element == value_type {
    associatedtype value_type
    init()
    mutating func push_back(_ elem: value_type)
}

// See the note in VtArrayTemplateErgonomics.swift.
// We need to work in a "C++ templates" way over different
// pxr::SdfListOp<T>, pxr::SdfListProxy<T>, and pxr::SdfListEditorProxy<T>.
// We can do that by writing protocols that closely match the interface of
// the C++ template, and then conform the specializations to the protocols.
// Swift protocols can't fully express the entire interface of C++ templates
// in some circumstances, so certain members are commented out or excluded.
// It might make sense to move this into SwiftUsd itself at some point. 

// MARK: SdfListOp

extension Overlay {
    public protocol _SdfListOpProtocol<value_type> {
        typealias T = value_type
        typealias ItemType = value_type
        typealias ItemVector = value_vector_type
        associatedtype value_type // T
        associatedtype value_vector_type: _StdVectorProtocol<T> // std::vector<T>

//        static func CreateExplicit(_ explicitItems: ItemVector) -> Self
//        static func Create(_ prependedItems: ItemVector,
//                           _ appendedItems: ItemVector,
//                           _ deletedItems: ItemVector) -> Self
        
        init()
//        
//        mutating func Swap(_ rhs: Self)
//        
        func HasKeys() -> Bool
        func HasItem(_ item: T) -> Bool
        func IsExplicit() -> Bool
        func __GetExplicitItemsUnsafe() -> UnsafePointer<ItemVector>
        func __GetPrependedItemsUnsafe() -> UnsafePointer<ItemVector>
        func __GetAppendedItemsUnsafe() -> UnsafePointer<ItemVector>
        func __GetDeletedItemsUnsafe() -> UnsafePointer<ItemVector>
        func __GetItemsUnsafe(_ type: pxr.SdfListOpType) -> UnsafePointer<ItemVector>
        func GetAppliedItems() -> ItemVector
        mutating func SetExplicitItems(_ items: ItemVector, _ errMsg: UnsafeMutablePointer<std.string>!) -> Bool
        mutating func SetPrependedItems(_ items: ItemVector, _ errMsg: UnsafeMutablePointer<std.string>!) -> Bool
        mutating func SetAppendedItems(_ items: ItemVector, _ errMsg: UnsafeMutablePointer<std.string>!) -> Bool
        mutating func SetDeletedItems(_ items: ItemVector, _ errMsg: UnsafeMutablePointer<std.string>!) -> Bool
        mutating func SetItems(_ items: ItemVector, _ type: pxr.SdfListOpType, _ errMsg: UnsafeMutablePointer<std.string>!) -> Bool
        mutating func Clear()
        mutating func ClearAndMakeExplicit()
//        
//        associatedtype ApplyCallback
//        func ApplyOperations(_ vec: UnsafeMutablePointer<ItemVector>, _ cb: ApplyCallback)
//        
//        associatedtype StdOptionalStdListOpT
//        func ApplyOperations(_ inner: Self) -> StdOptionalStdListOpT
//        
//        associatedtype ModifyCallback
//        mutating func ModifyOperations(_ callback: ModifyCallback) -> Bool
//        mutating func ModifyOperations(_ callback: ModifyCallback, _ unusedRemoveDuplicates: Bool) -> Bool
//        mutating func ReplaceOperations(_ op: pxr.SdfListOpType, _ index: Int, _ n: Int, _ newItems: ItemVector) -> Bool
//        
//        mutating func ComposeOperations(_ stronger: Self, _ op: pxr.SdfListOpType)
//        
        func __GetAddedItemsUnsafe() -> UnsafePointer<ItemVector>
        func __GetOrderedItemsUnsafe() -> UnsafePointer<ItemVector>
        mutating func SetAddedItems(_ items: ItemVector)
        mutating func SetOrderedItems(_ items: ItemVector)
        
        // ==
        // !=
    }
}

extension Overlay._SdfListOpProtocol {
    public borrowing func GetExplicitItems() -> ItemVector { __GetExplicitItemsUnsafe().pointee }
    public borrowing func GetPrependedItems() -> ItemVector { __GetPrependedItemsUnsafe().pointee }
    public borrowing func GetAppendedItems() -> ItemVector { __GetAppendedItemsUnsafe().pointee }
    public borrowing func GetDeletedItems() -> ItemVector { __GetDeletedItemsUnsafe().pointee }
    public borrowing func GetItems(_ type: pxr.SdfListOpType) -> ItemVector { __GetItemsUnsafe(type).pointee }
    public borrowing func GetAddedItems() -> ItemVector { __GetAddedItemsUnsafe().pointee }
    public borrowing func GetOrderedItems() -> ItemVector { __GetOrderedItemsUnsafe().pointee }
}

extension pxr.SdfIntListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfIntListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfUIntListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfUIntListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfInt64ListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfInt64ListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfUInt64ListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfUInt64ListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfTokenListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfTokenListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfStringListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfStringListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfPathListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfPathListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfReferenceListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfReferenceListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfPayloadListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfPayloadListOp.value_vector_type: _StdVectorProtocol {}
extension pxr.SdfUnregisteredValueListOp: Overlay._SdfListOpProtocol {}
extension pxr.SdfUnregisteredValueListOp.value_vector_type: _StdVectorProtocol {}

// MARK: SdfListProxy

extension Overlay {
    public protocol _SdfListProxyProtocol<TypePolicy>: Sequence {
        associatedtype TypePolicy
        typealias value_type = Element
        associatedtype value_vector_type: _StdVectorProtocol<value_type>
        associatedtype iterator
        associatedtype const_iterator
                
        init(_ op: pxr.SdfListOpType)
        // init(editor, op)
        
        mutating func __beginMutatingUnsafe() -> iterator
        mutating func __endMutatingUnsafe() -> iterator
        
        // rbegin
        // rend
        func __beginUnsafe() -> const_iterator
        func __endUnsafe() -> const_iterator
        
        // rbegin
        // rend
        
        func size() -> Int
        func empty() -> Bool
        
        // []
        // []
        
        // front
        // back
        // front
        // back
        
        mutating func push_back(_ elem: value_type)
        mutating func pop_back()

        mutating func __insertUnsafe(_ pos: iterator, _ x: value_type) -> iterator
        // template<class InputIterator> insert
//        mutating func __eraseUnsafe(_ pos: iterator)
//        mutating func __eraseUnsafe(_ f: iterator, _ l: iterator)
        mutating func clear()
        mutating func resize(_ n: Int, _ t: value_type)
        
        // operator value_vector_type() const
        
        // ==
        // !=
        // <
        // <=
        // >
        // >=
        // ==
        // ==
        // !=
        // !=
        // <
        // <
        // >
        // >
        // <=
        // <=
        // >=
        // >=
        func __convertToBool() -> Bool
        func GetLayer() -> pxr.SdfLayerHandle
        func GetPath() -> pxr.SdfPath
        func IsExpired() -> Bool
        func Count(_ value: value_type) -> Int
        func Find(_ value: value_type) -> Int
        mutating func Insert(_ index: CInt, _ value: value_type)
        mutating func Remove(_ value: value_type)
        mutating func Replace(_ oldValue: value_type, _ newValue: value_type)
        mutating func Erase(_ index: Int)
        mutating func ApplyList(_ list: Self)
//        mutating func ApplyEditsToList(_ vec: UnsafeMutablePointer<value_vector_type>?)
        // ModifyItemEdits
    }
}

extension pxr.SdfNameOrderProxy: Overlay._SdfListProxyProtocol {}
extension pxr.SdfSubLayerProxy: Overlay._SdfListProxyProtocol {}

// MARK: SdfListEditorProxy

extension Overlay {
    public protocol _SdfListEditorProxyProtocol<TypePolicy> {
        associatedtype TypePolicy
        associatedtype ListProxy: Overlay._SdfListProxyProtocol<TypePolicy>
        typealias value_type = ListProxy.value_type
        associatedtype value_vector_type: _StdVectorProtocol<value_type>
        
        // ApplyCallback
        
        // ModifyCallback
        
        init()
        
        // init(listEditor)
        
        func IsExpired() -> Bool
        func IsExplicit() -> Bool
        func IsOrderedOnly() -> Bool
        func HasKeys() -> Bool
        // func ApplyEditsToList(_ vec: UnsafeMutablePointer<value_vector_type>?)
        // template ApplyEditsToList
        
        mutating func CopyItems(_ other: Self) -> Bool
        mutating func ClearEdits() -> Bool
        mutating func ClearEditsAndMakeExplicit() -> Bool
        
        // template ModifyItemEdits
        
        func ContainsItemEdit(_ item: value_type, _ onlyAddOrExplicit: Bool) -> Bool
        mutating func RemoveItemEdits(_ item: value_type)
        mutating func ReplaceItemEdits(_ oldItem: value_type, _ newItem: value_type)
        func GetExplicitItems() -> ListProxy
        func GetAddedItems() -> ListProxy
        func GetPrependedItems() -> ListProxy
        func GetAppendedItems() -> ListProxy
        func GetDeletedItems() -> ListProxy
        func GetOrderedItems() -> ListProxy
        func GetAddedOrExplicitItems() -> value_vector_type
        func GetAppliedItems() -> value_vector_type
        mutating func Add(_ value: value_type)
        mutating func Prepend(_ value: value_type)
        mutating func Append(_ value: value_type)
        mutating func Remove(_ value: value_type)
        mutating func Erase(_ value: value_type)
        func __convertToBool() -> Bool
    }
}

extension pxr.SdfNameEditorProxy: Overlay._SdfListEditorProxyProtocol {}
extension pxr.SdfNameEditorProxy.ListProxy: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfNameEditorProxyListProxyIteratorWrapper
}
extension pxr.SdfNameEditorProxy.ListProxy.Iterator: __Overlay.SdfProxyTypesIteratorProtocol {}
extension pxr.SdfNameEditorProxy.ListProxy: Overlay._SdfListProxyProtocol {}

extension pxr.SdfPathEditorProxy: Overlay._SdfListEditorProxyProtocol {}
extension pxr.SdfPathEditorProxy.ListProxy: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfPathEditorProxyListProxyIteratorWrapper
}
extension pxr.SdfPathEditorProxy.ListProxy.Iterator: __Overlay.SdfProxyTypesIteratorProtocol {}
extension pxr.SdfPathEditorProxy.ListProxy: Overlay._SdfListProxyProtocol {}

extension pxr.SdfPayloadEditorProxy: Overlay._SdfListEditorProxyProtocol {}
extension pxr.SdfPayloadEditorProxy.ListProxy: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfPayloadEditorProxyListProxyIteratorWrapper
}
extension pxr.SdfPayloadEditorProxy.ListProxy.Iterator: __Overlay.SdfProxyTypesIteratorProtocol {}
extension pxr.SdfPayloadEditorProxy.ListProxy: Overlay._SdfListProxyProtocol {}

extension pxr.SdfReferenceEditorProxy: Overlay._SdfListEditorProxyProtocol {}
extension pxr.SdfReferenceEditorProxy.ListProxy: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfReferenceEditorProxyListProxyIteratorWrapper
}
extension pxr.SdfReferenceEditorProxy.ListProxy.Iterator: __Overlay.SdfProxyTypesIteratorProtocol {}
extension pxr.SdfReferenceEditorProxy.ListProxy: Overlay._SdfListProxyProtocol {}
