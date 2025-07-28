//
//  Math.cpp
//
//  Created by Maddy Adams on 3/28/24.h

#include "swiftUsd/SwiftOverlay/Math.h"


const double* __Overlay::GfMatrix4d_subscript_workaround(const pxr::GfMatrix4d& x, int i) {
    return x[i];
}
