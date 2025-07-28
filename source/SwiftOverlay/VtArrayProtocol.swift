//
//  SwiftOverlay_Comparable.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation
import CxxStdlib

extension __Overlay {
    public protocol VtArray_Equatable: Equatable {
        associatedtype Element: Equatable
        func size() -> Int
        subscript(_ :Int) -> Element { get }
    }
}
extension __Overlay.VtArray_Equatable {
    static public func ==(lhs: Self, rhs: Self) -> Bool {
        guard lhs.size() == rhs.size() else { return false }
        for i in 0..<lhs.size() {
            guard lhs[i] == rhs[i] else { return false }
        }
        return true
    }
}

extension __Overlay {
    public protocol VtArray_ExpressibleByArrayLiteral: ExpressibleByArrayLiteral {
        associatedtype ElementType
        init()
        init(arrayLiteral elements: ArrayLiteralElement...)
        init<S: Sequence>(_ elements: S) where S.Element == ElementType
        mutating func reserve(_ num: Int)
        mutating func push_back(_ x: ArrayLiteralElement)
    }
}
extension __Overlay.VtArray_ExpressibleByArrayLiteral where ArrayLiteralElement == Self.ElementType {
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }

    public init<S: Sequence>(_ elements: S) where S.Element == ElementType {
        self.init()
        for x in elements {
            self.push_back(x)
        }
    }

    public init<C: Collection>(_ elements: C) where C.Element == ElementType {
        self.init()
        self.reserve(elements.count)
        for x in elements {
            self.push_back(x)
        }
    }
}

extension __Overlay {
    public protocol VtArray_CustomStringConvertible: CustomStringConvertible, Sequence where Element: CustomStringConvertible {}
}
extension __Overlay.VtArray_CustomStringConvertible {
    public var description: String {
        "[" + map { $0.description }.joined(separator: ", ") + "]"
    }
}

extension __Overlay {
    public struct VtArray_Sequence_Iterator<V: __Overlay.VtArray_Sequence>: IteratorProtocol {
        var begin: UnsafePointer<V.ElementType>?
        var end: UnsafePointer<V.ElementType>?
        var s: V // hold the VtArray alive as long as there's an iterator to it

        init(begin: UnsafePointer<V.ElementType>?, end: UnsafePointer<V.ElementType>?, s: V) {
            self.begin = begin
            self.end = end
            self.s = s
        }

        public mutating func next() -> V.ElementType? {
            if begin == end {
                return nil
            }
            let result = begin?.pointee
            begin = begin?.advanced(by: 1)
            return result
        }
    }
}

extension __Overlay {
    public protocol VtArray_Sequence: Sequence {
        associatedtype ElementType
        func __beginUnsafe() -> UnsafePointer<ElementType>?
        func __endUnsafe() -> UnsafePointer<ElementType>?
    }
}
extension __Overlay.VtArray_Sequence where Element == Self.ElementType {
    public func makeIterator() -> __Overlay.VtArray_Sequence_Iterator<Self> {
        .init(begin: __beginUnsafe(), end: __endUnsafe(), s: self)
    }
}

extension __Overlay {
    public protocol VtArray_Codable: Codable where ElementType: Codable {
        associatedtype ElementType
    }
    // Codable implementation for VtArray<T> lives in SwiftUsd/source/SwiftOverlay/Codable.swift
}

extension __Overlay {
    public protocol VtArray_WithoutCodableProtocol: VtArray_Equatable,
                                     VtArray_ExpressibleByArrayLiteral,
                                     VtArray_Sequence,
                                     VtArray_CustomStringConvertible {}

    public protocol VtArrayProtocol: VtArray_WithoutCodableProtocol,
                                     VtArray_Codable {
    }
}

extension pxr.VtBoolArray: __Overlay.VtArrayProtocol {}
extension pxr.VtDoubleArray: __Overlay.VtArrayProtocol {}
extension pxr.VtFloatArray: __Overlay.VtArrayProtocol {}
extension pxr.VtHalfArray: __Overlay.VtArrayProtocol {}

extension pxr.VtCharArray: __Overlay.VtArrayProtocol {}
extension pxr.VtUCharArray: __Overlay.VtArrayProtocol {}
extension pxr.VtShortArray: __Overlay.VtArrayProtocol {}
extension pxr.VtUShortArray: __Overlay.VtArrayProtocol {}
extension pxr.VtIntArray: __Overlay.VtArrayProtocol {}
extension pxr.VtUIntArray: __Overlay.VtArrayProtocol {}
extension pxr.VtInt64Array: __Overlay.VtArrayProtocol {}
extension pxr.VtUInt64Array: __Overlay.VtArrayProtocol {}

extension pxr.VtVec4iArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec3iArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec2iArray: __Overlay.VtArrayProtocol {}

extension pxr.VtVec4hArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec3hArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec2hArray: __Overlay.VtArrayProtocol {}

extension pxr.VtVec4fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec3fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec2fArray: __Overlay.VtArrayProtocol {}

extension pxr.VtVec4dArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec3dArray: __Overlay.VtArrayProtocol {}
extension pxr.VtVec2dArray: __Overlay.VtArrayProtocol {}

extension pxr.VtMatrix4fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtMatrix3fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtMatrix2fArray: __Overlay.VtArrayProtocol {}

extension pxr.VtMatrix4dArray: __Overlay.VtArrayProtocol {}
extension pxr.VtMatrix3dArray: __Overlay.VtArrayProtocol {}
extension pxr.VtMatrix2dArray: __Overlay.VtArrayProtocol {}

extension pxr.VtRange3fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtRange3dArray: __Overlay.VtArrayProtocol {}
extension pxr.VtRange2fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtRange2dArray: __Overlay.VtArrayProtocol {}
extension pxr.VtRange1fArray: __Overlay.VtArrayProtocol {}
extension pxr.VtRange1dArray: __Overlay.VtArrayProtocol {}

extension pxr.VtIntervalArray: __Overlay.VtArrayProtocol {}
extension pxr.VtRect2iArray: __Overlay.VtArrayProtocol {}

// VtStringArray gains Codable conformance in Codable.swift,
// but it can't satisfy the requirements that ElementType is Codable
// because std.string isn't Codable
extension pxr.VtStringArray: __Overlay.VtArray_WithoutCodableProtocol {}
extension pxr.VtTokenArray: __Overlay.VtArrayProtocol {}

extension pxr.VtQuathArray: __Overlay.VtArrayProtocol {}
extension pxr.VtQuatfArray: __Overlay.VtArrayProtocol {}
extension pxr.VtQuatdArray: __Overlay.VtArrayProtocol {}
extension pxr.VtQuaternionArray: __Overlay.VtArrayProtocol {}

extension Overlay.SdfAssetPath_VtArray: __Overlay.VtArrayProtocol {}