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

#include "swiftUsd/Wrappers/ArWritableAssetWrapper.h"

bool Overlay::ArWritableAssetWrapper::Close() {
    return get()->Close();
}

size_t Overlay::ArWritableAssetWrapper::Write(const void *buffer, size_t count, size_t offset) {
    return get()->Write(buffer, count, offset);
}

Overlay::ArWritableAssetWrapper::ArWritableAssetWrapper(std::shared_ptr<pxr::ArWritableAsset> _ptr) : _ptr(_ptr) {}

pxr::ArWritableAsset*_Nullable Overlay::ArWritableAssetWrapper::get() const {
    return _ptr.get();
}

std::shared_ptr<pxr::ArWritableAsset> Overlay::ArWritableAssetWrapper::get_shared() const {
    return _ptr;
}

Overlay::ArWritableAssetWrapper::operator bool() const {
    return (bool)_ptr;
}


