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
import OpenUSD
import TemporaryImplementations_Cxx
import TemporaryImplementations_Swift

// C++ templated code is fully specialized, so it can directly use all the functionality
// of its instantiations without any extra ceremony. Swift generics/protocols are
// not fully specialized, so we need a Swift protocol that C++ types conform to
// to let us write the equivalent of template code over them.
//
// In this case, we need to access VtArray<T>. The first three
// protocol requirements here are taken directly from VtArray<T>,
// so conforming doesn't require anything extra, but the last the
// protocol requirements have to be added because we need to
// express (e.g.) `pxr.VtValue(someVtArray)`, but protocols
// can only express requirements that are members of the conforming type,
// and `pxr::VtValue::VtValue(_:)` is not a member of `VtArray<T>`.
// (Similarly for `vtValue.Get() as value_type` and `pxr.VtValue(arrayElement)`.)

internal protocol _VtArrayExtractionWritingProtocol: Sequence {
    associatedtype value_type
    init()
    mutating func push_back(_ x: value_type)
    
    var asVtValue: pxr.VtValue { get }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue
}
extension pxr.VtBoolArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtUCharArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtIntArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtUIntArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtInt64Array: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtUInt64Array: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtHalfArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtFloatArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtDoubleArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtTimeCodeArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtStringArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtTokenArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension Overlay.SdfAssetPath_VtArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec2iArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec3iArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec4iArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec2hArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec3hArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec4hArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec2fArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec3fArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec4fArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec2dArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec3dArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtVec4dArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtQuathArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtQuatfArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtQuatdArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtMatrix2dArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtMatrix3dArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension pxr.VtMatrix4dArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
extension Overlay.SdfPathExpression_VtArray: _VtArrayExtractionWritingProtocol {
    var asVtValue: pxr.VtValue { pxr.VtValue(self) }
    static func scalarFromVtValue(_ x: pxr.VtValue) -> value_type {
        var copy = x; return copy.Get()
    }
    static func scalarAsVtValue(_ x: Element) -> pxr.VtValue { pxr.VtValue(x) }
}
