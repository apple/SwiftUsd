//
//  TypeConversionInitializers.cpp
//
//  Created by Maddy Adams on 3/28/24

#include "swiftUsd/SwiftOverlay/TypeConversionInitializers.h"

float __Overlay::halfToFloat(pxr::GfHalf h) {
    return (float) h;
}
