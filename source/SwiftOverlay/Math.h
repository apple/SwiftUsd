//
//  Math.h
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_MATH_H
#define SWIFTUSD_SWIFTOVERLAY_MATH_H

#include "pxr/pxr.h"
#include "pxr/base/gf/rotation.h"
#include "pxr/base/gf/matrix4d.h"

namespace __Overlay {
    // Workaround for https://github.com/swiftlang/swift/issues/83112 (Calling Swift subscript across module boundary accesses uninitialized memory in Release (C++ interop))
    const double* GfMatrix4d_subscript_workaround(const pxr::GfMatrix4d& x, int i);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_MATH_H */
