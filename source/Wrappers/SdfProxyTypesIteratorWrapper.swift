//
//  SdfProxyTypesIteratorWrapper.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 6/2/25.
//

import Foundation


extension __Overlay {
    public protocol SdfProxyTypesSequenceProtocol: Sequence {}
    //    where Iterator: SdfProxyTypesIteratorProtocol, Iterator.RangeType == Self {}

    public protocol SdfProxyTypesIteratorProtocol: IteratorProtocol {
        associatedtype value_type
        associatedtype RangeType: SdfProxyTypesSequenceProtocol where RangeType.Iterator == Self
        mutating func advanceAndGetCurrent(_ resultIsValid: UnsafeMutablePointer<Bool>) -> value_type
        init(_ range: RangeType)
    }
}

extension __Overlay.SdfProxyTypesSequenceProtocol {
    public func makeIterator() -> Iterator where Iterator: __Overlay.SdfProxyTypesIteratorProtocol, Iterator.RangeType == Self {
        .init(self)
    }
}

extension __Overlay.SdfProxyTypesIteratorProtocol {
    public mutating func next() -> value_type? {
        var isValid = false
        let result = advanceAndGetCurrent(&isValid)
        return isValid ? result : nil
    }
}

extension pxr.SdfNameOrderProxy: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfNameOrderProxyIteratorWrapper
}
extension __Overlay.SdfNameOrderProxyIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfSubLayerProxy: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfSubLayerProxyIteratorWrapper
}
extension __Overlay.SdfSubLayerProxyIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfAttributeSpecView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfAttributeSpecViewIteratorWrapper
}
extension __Overlay.SdfAttributeSpecViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfPrimSpecView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfPrimSpecViewIteratorWrapper
}
extension __Overlay.SdfPrimSpecViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfPropertySpecView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfPropertySpecViewIteratorWrapper
}
extension __Overlay.SdfPropertySpecViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfRelationalAttributeSpecView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfRelationalAttributeSpecViewIteratorWrapper
}
extension __Overlay.SdfRelationalAttributeSpecViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfRelationshipSpecView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfRelationshipSpecViewIteratorWrapper
}
extension __Overlay.SdfRelationshipSpecViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfVariantView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfVariantViewIteratorWrapper
}
extension __Overlay.SdfVariantViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}


extension pxr.SdfVariantSetView: __Overlay.SdfProxyTypesSequenceProtocol {
    public typealias Iterator = __Overlay.SdfVariantSetViewIteratorWrapper
}
extension __Overlay.SdfVariantSetViewIteratorWrapper: __Overlay.SdfProxyTypesIteratorProtocol {}
