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

#include "TfSerialization.hpp"

pxr::TfToken extractTfToken(const pxr::JsValue& x) {
    return pxr::TfToken(x.GetString());
}

pxr::JsValue writeTfToken(const pxr::TfToken& x) {
    return pxr::JsValue(x.GetString());
}

pxr::TfTokenVector extractTfTokenVector(const pxr::JsValue& js) {
    pxr::TfTokenVector result;
    const pxr::JsArray& arr = js.GetJsArray();
    for (const auto& x : arr) {
        result.push_back(extractTfToken(x));
    }
    return result;
}


pxr::TfEnum extractTfEnum(const pxr::JsValue& js) {
    return pxr::TfEnum::GetValueFromFullName(js.GetString());
}
pxr::JsValue writeTfEnum(const pxr::TfEnum& x) {
    return pxr::JsValue(pxr::TfEnum::GetFullName(x));
}
