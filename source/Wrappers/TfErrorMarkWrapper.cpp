//
//  TfErrorMarkWrapper.cpp
//  SwiftUsd
//
//  Created by Maddy Adams on 3/13/25.
//

#include "swiftUsd/Wrappers/TfErrorMarkWrapper.h"

Overlay::TfErrorMarkWrapper __Overlay::makeTfErrorMarkWrapper_friend() {
    return {};
}

Overlay::TfErrorMarkWrapper::TfErrorMarkWrapper() : _impl(std::make_unique<pxr::TfErrorMark>()) {}
