//
//  SdfSpecHandle.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 6/2/25.
//

import Foundation

extension pxr.SdfSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfPropertySpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfPrimSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfVariantSetSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfVariantSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfAttributeSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfRelationshipSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
extension pxr.SdfPseudoRootSpecHandle {
    public var pointee: Self.SpecType {
        __Overlay.operatorArrow(self)
    }
}
