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

#ifndef VtSerialization_hpp
#define VtSerialization_hpp

#include <stdio.h>
#include "pxr/base/vt/value.h"
#include "pxr/usd/sdf/valueTypeName.h"

/// Represents a VtValue along with some type information,
/// such as a role or non-value type name, or an empty VtValue
/// that is expected to later be filled in to match a given type
struct TypedValue {
    pxr::VtValue value;
    pxr::SdfValueTypeName valueTypeName;
    std::string otherTypeName;
    
    static TypedValue forVtValue(pxr::VtValue);
    static TypedValue forTypeName(pxr::SdfValueTypeName);
    static TypedValue withOtherTypeName(std::string s);
};

pxr::VtDictionary extractVtDictionary(const pxr::JsValue& js);
pxr::JsValue writeVtDictionary(const pxr::VtDictionary& x);

TypedValue extractTypeHint(const pxr::JsValue& js);
pxr::JsValue writeTypeHint(const TypedValue& value);

/// Expects the type hint to be provided. See also extractTypeHintAndValue
void extractValueWithTypeHint(TypedValue* out, const pxr::JsValue& js);
pxr::JsValue writeValueWithoutTypeHint(const TypedValue& value);

/// Will try to decode the type hint first before decoding the value. See also extractValueWithTypeHint
TypedValue extractTypeHintAndValue(const pxr::JsValue& js);
pxr::JsValue writeTypeHintAndValue(const TypedValue& value);


std::map<double, pxr::VtValue> extractTimeCodeValueMapWithTypeHint(const pxr::JsValue& js, const TypedValue& type);
pxr::JsValue writeTimeCodeValueMapWithoutTypeHint(const std::map<double, pxr::VtValue>& samples, const TypedValue& type);


#endif /* VtSerialization_hpp */
