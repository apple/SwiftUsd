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


extension pxr.GfMatrix4d {
    /// Wrapper for `pxr.GfMatrix().SetTranslate(v)`
    public static func MakeTranslate(_ v: pxr.GfVec3d) -> pxr.GfMatrix4d {
        var x = pxr.GfMatrix4d()
        x.SetTranslate(v)
        return x
    }

    /// Wrapper for `pxr.GfMatrix().SetRotate(r)`
    public static func MakeRotate(_ r: pxr.GfRotation) -> pxr.GfMatrix4d {
        var x = pxr.GfMatrix4d()
        x.SetRotate(r)
        return x
    }
}
extension pxr.GfMatrix4d {
    public subscript(_ x: Int) -> UnsafePointer<Double> {
        // Workaround for https://github.com/swiftlang/swift/issues/83112 (Calling Swift subscript across module boundary accesses uninitialized memory in Release (C++ interop))
        return __Overlay.GfMatrix4d_subscript_workaround(self, Int32(x))
    }
}
extension pxr.GfHalf {
    public static func +(lhs: pxr.GfHalf, rhs: pxr.GfHalf) -> pxr.GfHalf {
        return pxr.GfHalf(Float(lhs) + Float(rhs))
    }
}
public func *(lhs: Float, rhs: pxr.GfVec3f) -> pxr.GfVec3f {
    pxr.GfVec3f(lhs * rhs[0], lhs * rhs[1], lhs * rhs[2])
}

public func *(lhs: pxr.GfVec3f, rhs: Float) -> pxr.GfVec3f {
    pxr.GfVec3f(lhs[0] * rhs, lhs[1] * rhs, lhs[2] * rhs)
}

