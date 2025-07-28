//
//  SwiftOverlay_Math.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

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

