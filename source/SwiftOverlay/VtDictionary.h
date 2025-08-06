// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

#ifndef SWIFTUSD_SWIFTOVERLAY_VTDICTIONARY_H
#define SWIFTUSD_SWIFTOVERLAY_VTDICTIONARY_H

#include <utility>
#include <string>
#include "pxr/pxr.h"
#include "pxr/base/vt/dictionary.h"

namespace __Overlay {
    std::pair<pxr::VtDictionary::iterator, bool> insert(pxr::VtDictionary* d, const pxr::VtDictionary::value_type& obj);
    pxr::VtDictionary::const_iterator find(const pxr::VtDictionary& d, const std::string& key);
    pxr::VtDictionary::iterator findMutating(pxr::VtDictionary* d, const std::string& key);
    pxr::VtValue operatorSubscript(const pxr::VtDictionary& d, const std::string& key, bool* isValid);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_VTDICTIONARY_H */
