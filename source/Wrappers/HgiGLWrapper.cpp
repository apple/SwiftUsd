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

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include "swiftUsd/Wrappers/HgiGLWrapper.h"

Overlay::HgiGLWrapper::HgiGLWrapper() :
    Overlay::HgiWrapper(std::make_shared<pxr::HgiGL>())
{}

pxr::HgiGLDevice* Overlay::HgiGLWrapper::GetPrimaryDevice() const {
    return get()->GetPrimaryDevice();
}

pxr::HgiGLContextArenaHandle Overlay::HgiGLWrapper::CreateContextArena() {
    return get()->CreateContextArena();
}

void Overlay::HgiGLWrapper::DestroyContextArena(pxr::HgiGLContextArenaHandle*_Nonnull arenaHandle) {
    get()->DestroyContextArena(arenaHandle);
}

void Overlay::HgiGLWrapper::SetContextArena(const pxr::HgiGLContextArenaHandle& arenaHandle) {
    get()->SetContextArena(arenaHandle);
}

// MARK: SwiftUsd implementation access

Overlay::HgiGLWrapper::HgiGLWrapper(std::shared_ptr<pxr::HgiGL> _ptr) : Overlay::HgiWrapper(_ptr) {}

Overlay::HgiGLWrapper::HgiGLWrapper(Overlay::HgiWrapper hgi) : Overlay::HgiWrapper(hgi) {
    if (!dynamic_cast<const pxr::HgiGL*>(_ptr.get())) {
        _ptr = nullptr;
    }
}

pxr::HgiGL* Overlay::HgiGLWrapper::get() const {
    return std::static_pointer_cast<pxr::HgiGL>(_ptr).get();
}

std::shared_ptr<pxr::HgiGL> Overlay::HgiGLWrapper::get_shared() const {
    return std::static_pointer_cast<pxr::HgiGL>(_ptr);
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
