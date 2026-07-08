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

#include "swiftUsd/Wrappers/ArAssetWrapper.h"

size_t Overlay::ArAssetWrapper::GetSize() const {
    return get()->GetSize();
}

std::shared_ptr<const char> Overlay::ArAssetWrapper::GetBuffer() const {
    return get()->GetBuffer();
}

size_t Overlay::ArAssetWrapper::Read(void* buffer, size_t count, size_t offset) const {
    return get()->Read(buffer, count, offset);
}

std::pair<FILE*, size_t> Overlay::ArAssetWrapper::GetFileUnsafe() const {
    return get()->GetFileUnsafe();
}

Overlay::ArAssetWrapper Overlay::ArAssetWrapper::GetDetachedAsset() const {
    return Overlay::ArAssetWrapper(get()->GetDetachedAsset());
}

// MARK: SwiftUsd implementation access

Overlay::ArAssetWrapper::ArAssetWrapper(std::shared_ptr<pxr::ArAsset> _ptr) : _ptr(_ptr) {}

pxr::ArAsset* Overlay::ArAssetWrapper::get() const {
    return _ptr.get();
}

std::shared_ptr<pxr::ArAsset> Overlay::ArAssetWrapper::get_shared() const {
    return _ptr;
}

Overlay::ArAssetWrapper::operator bool() const {
    return (bool)_ptr;
}

