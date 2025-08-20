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

#include "swiftUsd/Work/Loops.h"

void _Overlay::WorkParallelForNFunctor::WorkSerialForN(size_t n) const {
    pxr::WorkSerialForN(n, *this);
}

void _Overlay::WorkParallelForNFunctor::WorkParallelForN(size_t n, size_t grainSize) const {
    pxr::WorkParallelForN(n, *this, grainSize);
}

void _Overlay::WorkParallelForNFunctor::WorkParallelForN(size_t n) const {
    pxr::WorkParallelForN(n, *this);
}





_Overlay::WorkParallelForEachFunctor::Iterator::Iterator(CopyableSwiftClass obj,
                                                         increment_t increment,
                                                         isEqual_t isEqual)
    : _obj(obj), _increment(increment), _isEqual(isEqual) {}

_Overlay::WorkParallelForEachFunctor::Iterator _Overlay::WorkParallelForEachFunctor::Iterator::operator*() {
    return *this;
}

_Overlay::WorkParallelForEachFunctor::Iterator& _Overlay::WorkParallelForEachFunctor::Iterator::operator->() {
    return *this;
}

_Overlay::WorkParallelForEachFunctor::Iterator _Overlay::WorkParallelForEachFunctor::Iterator::operator++() {
    _increment(_obj);
    return *this;
}

_Overlay::WorkParallelForEachFunctor::Iterator _Overlay::WorkParallelForEachFunctor::Iterator::operator++(int) {
    Iterator copy = *this;
    _increment(_obj);
    return *copy;
}

bool _Overlay::WorkParallelForEachFunctor::Iterator::operator==(const Iterator& other) {
    return _isEqual(_obj, other._obj);
}

bool _Overlay::WorkParallelForEachFunctor::Iterator::operator!=(const Iterator& other) {
    return !(*this == other);
}

_Overlay::WorkParallelForEachFunctor::Iterator::operator CopyableSwiftClass::object_t() const {
    return _obj;
}

void _Overlay::WorkParallelForEachFunctor::WorkParallelForEach(Iterator start, Iterator end) const {
    pxr::WorkParallelForEach(start, end, *this);
}
