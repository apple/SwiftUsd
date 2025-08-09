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

#include "swiftUsd/SwiftOverlay/Miscellaneous.h"

const std::function<bool (const pxr::TfToken& propertyName)> Overlay::DefaultPropertyPredicateFunc = {};


// Workaround for rdar://124105392 (UsdMetadataValueMap subscript getter is mutating (5.10 regression))
pxr::VtValue __Overlay::operatorSubscript(const pxr::UsdMetadataValueMap& m, const pxr::TfToken& x, bool* isValid) {
    auto it = m.find(x);
    *isValid = it != m.end();
    return *isValid ? it->second : pxr::VtValue();
}

// SdfPathSet is std::set<SdfPath>, which isn't caught by Equatable codegen
bool __Overlay::operatorEqualsEquals(const pxr::SdfPathSet& l, const pxr::SdfPathSet& r) {
    return l == r;
}
