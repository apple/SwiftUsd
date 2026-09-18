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

#ifndef TsSerialization_hpp
#define TsSerialization_hpp

#include <stdio.h>
#include "pxr/base/js/value.h"
#include "pxr/base/ts/spline.h"
#include "pxr/usd/sdf/valueTypeName.h"

pxr::TsSpline extractTsSpline(const pxr::JsValue& js, const pxr::SdfValueTypeName& type);
pxr::JsValue writeTsSpline(const pxr::TsSpline& x);

pxr::TsExtrapolation extractTsExtrapolation(const pxr::JsValue& js);
pxr::JsValue writeTsExtrapolation(const pxr::TsExtrapolation& x);

pxr::TsLoopParams extractTsLoopParams(const pxr::JsValue& js);
pxr::JsValue writeTsLoopParams(const pxr::TsLoopParams& x);

pxr::TsKnotMap extractTsKnotMap(const pxr::JsValue& js, const pxr::SdfValueTypeName& type);
pxr::JsValue writeTsKnotMap(const pxr::TsKnotMap& x);

pxr::TsKnot extractTsKnot(const pxr::JsValue& js, const pxr::SdfValueTypeName& type);
pxr::JsValue writeTsKnot(const pxr::TsKnot& x);

#endif /* TsSerialization_hpp */
