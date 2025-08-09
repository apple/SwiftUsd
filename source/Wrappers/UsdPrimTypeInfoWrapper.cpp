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

#include "swiftUsd/Wrappers/UsdPrimTypeInfoWrapper.h"
#include "pxr/usd/usd/prim.h"

Overlay::UsdPrimTypeInfoWrapper::UsdPrimTypeInfoWrapper(const pxr::UsdPrimTypeInfo& _impl) : _impl(&_impl)
{}

Overlay::UsdPrimTypeInfoWrapper::UsdPrimTypeInfoWrapper(const pxr::UsdPrim& prim) : _impl(&prim.GetPrimTypeInfo()) {}

pxr::TfToken Overlay::UsdPrimTypeInfoWrapper::GetTypeName() const {
    return _impl->GetTypeName();
}

pxr::TfTokenVector Overlay::UsdPrimTypeInfoWrapper::GetAppliedAPISchemas() const {
    return _impl->GetAppliedAPISchemas();
}

pxr::TfType Overlay::UsdPrimTypeInfoWrapper::GetSchemaType() const {
    return _impl->GetSchemaType();
}

pxr::TfToken Overlay::UsdPrimTypeInfoWrapper::GetSchemaTypeName() const {
    return _impl->GetSchemaTypeName();
}

bool Overlay::UsdPrimTypeInfoWrapper::operator==(const Overlay::UsdPrimTypeInfoWrapper &other) const {
    return _impl == other._impl;
}

bool Overlay::UsdPrimTypeInfoWrapper::operator!=(const Overlay::UsdPrimTypeInfoWrapper &other) const {
    return _impl != other._impl;
}

Overlay::UsdPrimTypeInfoWrapper Overlay::UsdPrimTypeInfoWrapper::GetEmptyPrimType() {
    return Overlay::UsdPrimTypeInfoWrapper(pxr::UsdPrimTypeInfo::GetEmptyPrimType());
}

const pxr::UsdPrimTypeInfo* Overlay::UsdPrimTypeInfoWrapper::get() const {
    return _impl;
}

Overlay::UsdPrimTypeInfoWrapper::operator bool() const {
    return (bool)_impl;
}
