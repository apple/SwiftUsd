//
//  SdfLayer.cpp
//
//  Created by Maddy Adams on 3/28/24.

#include "swiftUsd/SwiftOverlay/SdfLayer.h"

// MARK: SdfLayer
pxr::SdfLayer::TraversalFunction Overlay::SdfLayer::TraversalFunction(void (^f)(const pxr::SdfPath&)) {
    return f;
}
