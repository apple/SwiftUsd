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

#include "swiftUsd/Util/Util.h"

_Overlay::CopyableSwiftClass::CopyableSwiftClass(object_t obj,
                                                 makeCopy_t makeCopy,
                                                 release_t release)
    : _obj(obj), _makeCopy(makeCopy), _release(release) {}

_Overlay::CopyableSwiftClass::CopyableSwiftClass(const CopyableSwiftClass& other)
    : _obj(other._makeCopy(other._obj)), _makeCopy(other._makeCopy), _release(other._release) {}

_Overlay::CopyableSwiftClass& _Overlay::CopyableSwiftClass::operator=(const CopyableSwiftClass& other) {
    if (_obj) {
        _release(_obj);
    }

    _obj = other._makeCopy(other._obj);
    _makeCopy = other._makeCopy;
    _release = other._release;

    return *this;
}

_Overlay::CopyableSwiftClass::CopyableSwiftClass(CopyableSwiftClass&& other)
    : _obj(other._obj), _makeCopy(other._makeCopy), _release(other._release) {
    other._obj = nullptr;
    other._makeCopy = nullptr;
    other._release = nullptr;
}

_Overlay::CopyableSwiftClass& _Overlay::CopyableSwiftClass::operator=(CopyableSwiftClass&& other) {
    if (_obj) {
        _release(_obj);
    }

    _obj = other._obj;
    _makeCopy = other._makeCopy;
    _release = other._release;

    other._obj = nullptr;
    other._makeCopy = nullptr;
    other._release = nullptr;

    return *this;
}

_Overlay::CopyableSwiftClass::~CopyableSwiftClass() {
    if (_obj) {
        _release(_obj);
    }
}

_Overlay::CopyableSwiftClass::operator object_t() const {
    return _obj;
}

_Overlay::CopyableSwiftClass::object_t _Overlay::CopyableSwiftClass::get() const {
    return _obj;
}





_Overlay::RetainableSwiftClass::RetainableSwiftClass(object_t obj, retain_t retain, release_t release)
    : _obj(obj), _retain(retain), _release(release) {}

_Overlay::RetainableSwiftClass::RetainableSwiftClass(const RetainableSwiftClass& other)
    : _obj(other._obj), _retain(other._retain), _release(other._release) {
    _retain(_obj);
}

_Overlay::RetainableSwiftClass& _Overlay::RetainableSwiftClass::operator=(const RetainableSwiftClass& other) {
    if (_obj) {
        _release(_obj);
    }
    
    _obj = other._obj;
    _retain = other._retain;
    _release = other._release;
    _retain(_obj);
    
    return *this;
}

_Overlay::RetainableSwiftClass::RetainableSwiftClass(RetainableSwiftClass&& other)
    : _obj(other._obj), _retain(other._retain), _release(other._release) {
    other._obj = nullptr;
    other._retain = nullptr;
    other._release = nullptr;
}

_Overlay::RetainableSwiftClass& _Overlay::RetainableSwiftClass::operator=(RetainableSwiftClass&& other) {
    if (_obj) {
        _release(_obj);
    }
    
    _obj = other._obj;
    _retain = other._retain;
    _release = other._release;
    
    other._obj = nullptr;
    other._retain = nullptr;
    other._release = nullptr;
    
    return *this;
}

_Overlay::RetainableSwiftClass::~RetainableSwiftClass() {
    if (_obj) {
        _release(_obj);
    }
}

_Overlay::RetainableSwiftClass::operator object_t() const {
    return _obj;
}

_Overlay::RetainableSwiftClass::object_t _Overlay::RetainableSwiftClass::get() const {
    return _obj;
}
