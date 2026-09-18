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

#ifndef FundementalTypes_hpp
#define FundementalTypes_hpp

#include <stdio.h>
#include <string>
#include "pxr/base/js/value.h"

#include "LIVERPSSerialization.hpp"
#include "SdfSerialization.hpp"
#include "TsSerialization.hpp"
#include "VtSerialization.hpp"

// Invokes the callback if the object has a value at the given key. 
bool ifValueExists(const pxr::JsObject& js, const std::string& key, std::function<void(const pxr::JsValue&)> callback);

std::string extractString(const pxr::JsValue&);
pxr::JsValue writeString(const std::string&);

long long extractLongLong(const pxr::JsValue&);
pxr::JsValue writeLongLong(long long);

#endif /* FundementalTypes_hpp */
