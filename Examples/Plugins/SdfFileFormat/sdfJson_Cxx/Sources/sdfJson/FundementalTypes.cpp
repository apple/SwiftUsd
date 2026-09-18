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

#include "FundementalTypes.hpp"

bool ifValueExists(const pxr::JsObject& js, const std::string& key, std::function<void(const pxr::JsValue&)> callback) {
    const auto& it = js.find(key);
    if (it != js.end()) {
        callback(it->second);
        return true;
    } else {
        return false;
    }
}

std::string extractString(const pxr::JsValue& x) {
    return x.GetString();
}
pxr::JsValue writeString(const std::string& x) {
    return pxr::JsValue(x);
}

long long extractLongLong(const pxr::JsValue& x) {
    return x.GetInt64();
}

pxr::JsValue writeLongLong(long long x) {
    return pxr::JsValue(x);
}
