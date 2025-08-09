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

#include "swiftUsd/SwiftOverlay/HydraHelpers.h"
#include <dlfcn.h>
#include <iostream>
#include "pxr/base/plug/registry.h"
#if __has_include(<Metal/Metal.h>)
#include "pxr/imaging/hgiMetal/texture.h"
#endif // #if __has_include(<Metal/Metal.h>)
#include "pxr/imaging/hgi/blitCmdsOps.h"

pxr::HgiTextureDesc Overlay::GetDescriptor(const pxr::HgiTextureHandle &handle) {
    return handle.Get()->GetDescriptor();
}

void Overlay::CopyTextureGpuToCpu(std::shared_ptr<pxr::HgiBlitCmds> blitCmds, pxr::HgiTextureGpuToCpuOp copyOp) {
    blitCmds->CopyTextureGpuToCpu(copyOp);
}

#if __has_include(<Metal/Metal.h>)
id<MTLTexture> Overlay::HgiTextureHandleGetTextureId(pxr::HgiTextureHandle handle) {
    return dynamic_cast<pxr::HgiMetalTexture*>(handle.Get())->GetTextureId();
}
#endif // #if __has_include(<Metal/Metal.h>)

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
