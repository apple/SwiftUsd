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

#ifndef SdfSerialization_hpp
#define SdfSerialization_hpp

#include <stdio.h>
#include "pxr/usd/sdf/types.h"
#include "pxr/base/js/value.h"

pxr::SdfAnimationBlock extractSdfAnimationBlock(const pxr::JsValue& js);
pxr::JsValue writeSdfAnimationBlock(const pxr::SdfAnimationBlock& x);

pxr::SdfPath extractSdfPath(const pxr::JsValue&);
pxr::JsValue writeSdfPath(const pxr::SdfPath&);

pxr::SdfUnregisteredValue extractSdfUnregisteredValue(const pxr::JsValue& js);
pxr::JsValue writeSdfUnregisteredValue(const pxr::SdfUnregisteredValue& value);

pxr::SdfReference extractSdfReference(const pxr::JsValue& js);
pxr::JsValue writeSdfReference(const pxr::SdfReference& reference);

pxr::SdfPayload extractSdfPayload(const pxr::JsValue& js);
pxr::JsValue writeSdfPayload(const pxr::SdfPayload& payload);


#endif /* SdfSerialization_hpp */
