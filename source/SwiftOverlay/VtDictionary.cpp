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

#include "swiftUsd/SwiftOverlay/VtDictionary.h"

std::pair<pxr::VtDictionary::iterator, bool> __Overlay::insert(pxr::VtDictionary* d, const pxr::VtDictionary::value_type& obj) {
    return d->insert(obj);
}
pxr::VtDictionary::const_iterator __Overlay::find(const pxr::VtDictionary& d, const std::string& key) {
    return d.find(key);
}
pxr::VtDictionary::iterator __Overlay::findMutating(pxr::VtDictionary* d, const std::string& key) {
    return d->find(key);
}
pxr::VtValue __Overlay::operatorSubscript(const pxr::VtDictionary& d, const std::string& key, bool* isValid) {
    auto it = d.find(key);
    *isValid = it != d.end();
    return *isValid ? it->second : pxr::VtValue();
}
