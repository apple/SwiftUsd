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

// MARK: SdfSpecHandle.pointee

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

// MARK: SdfSpec upcasting/downcasting

extension pxr.SdfSpec {
    // Up
    public init(_ x: pxr.SdfPropertySpec) {
        let oldHandle = pxr.SdfPropertySpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfPrimSpec) {
        let oldHandle = pxr.SdfPrimSpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfVariantSetSpec) {
        let oldHandle = pxr.SdfVariantSetSpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfVariantSpec) {
        let oldHandle = pxr.SdfVariantSpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfAttributeSpec) {
        let oldHandle = pxr.SdfAttributeSpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfRelationshipSpec) {
        let oldHandle = pxr.SdfRelationshipSpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfPseudoRootSpec) {
        let oldHandle = pxr.SdfPseudoRootSpecHandle(x)
        var newHandle = pxr.SdfSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
}
extension pxr.SdfPropertySpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfPropertySpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
    // Up
    public init(_ x: pxr.SdfAttributeSpec) {
        let oldHandle = pxr.SdfAttributeSpecHandle(x)
        var newHandle = pxr.SdfPropertySpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
    public init(_ x: pxr.SdfRelationshipSpec) {
        let oldHandle = pxr.SdfRelationshipSpecHandle(x)
        var newHandle = pxr.SdfPropertySpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
}
extension pxr.SdfPrimSpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfPrimSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
    // Up
    public init(_ x: pxr.SdfPseudoRootSpec) {
        let oldHandle = pxr.SdfPseudoRootSpecHandle(x)
        var newHandle = pxr.SdfPrimSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        self = newHandle.pointee
    }
}
extension pxr.SdfVariantSetSpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfVariantSetSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
}
extension pxr.SdfVariantSpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfVariantSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
}
extension pxr.SdfAttributeSpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfAttributeSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
    public init?(_ x: pxr.SdfPropertySpec) {
        let oldHandle = pxr.SdfPropertySpecHandle(x)
        var newHandle = pxr.SdfAttributeSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
}
extension pxr.SdfRelationshipSpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfRelationshipSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
    public init?(_ x: pxr.SdfPropertySpec) {
        let oldHandle = pxr.SdfPropertySpecHandle(x)
        var newHandle = pxr.SdfRelationshipSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
}
extension pxr.SdfPseudoRootSpec {
    // Down
    public init?(_ x: pxr.SdfSpec) {
        let oldHandle = pxr.SdfSpecHandle(x)
        var newHandle = pxr.SdfPseudoRootSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
    public init?(_ x: pxr.SdfPrimSpec) {
        let oldHandle = pxr.SdfPrimSpecHandle(x)
        var newHandle = pxr.SdfPseudoRootSpecHandle()
        __Overlay.dynamic_cast_sdf_spec_handles(oldHandle, &newHandle)
        guard Bool(newHandle) else { return nil }
        self = newHandle.pointee
    }
}
