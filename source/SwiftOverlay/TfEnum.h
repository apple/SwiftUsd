//
//  TfEnum.h
//  SwiftUsd
//
//  Created by Maddy Adams on 4/17/25.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_TFENUM_H
#define SWIFTUSD_SWIFTOVERLAY_TFENUM_H

#include "pxr/base/tf/enum.h"

namespace Overlay {
    // https://github.com/swiftlang/swift/issues/83081 (Templated C++ function incorrectly imported as returning Void in Swift)
    // Without that, we could do `template <typename T> pxr::TfEnum TfEnum(T x) { return pxr::TfEnum(x); }`
    template <typename T>
    void formTfEnum(T x, pxr::TfEnum& y) {
        y = x;
    }
}

#endif /* SWIFTUSD_SWIFTOVERLAY_TFENUM_H */
