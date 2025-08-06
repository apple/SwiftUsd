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

#ifndef SWIFTUSD_SWIFTOVERLAY_HYDRAHELPERS_H
#define SWIFTUSD_SWIFTOVERLAY_HYDRAHELPERS_H

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include <string>
#include <memory>
#include "pxr/pxr.h"
#include "pxr/imaging/hgi/texture.h"
#include "pxr/imaging/hgi/blitCmds.h"

#if __has_include(<Metal/Metal.h>)
#include <Metal/Metal.h>
#endif // #if __has_include(<Metal/Metal.h>)

namespace Overlay {
    pxr::HgiTextureDesc GetDescriptor(const pxr::HgiTextureHandle& handle);
    
    void CopyTextureGpuToCpu(std::shared_ptr<pxr::HgiBlitCmds> blitCmds, pxr::HgiTextureGpuToCpuOp copyOp);

    #if __has_include(<Metal/Metal.h>)
    id<MTLTexture> HgiTextureHandleGetTextureId(pxr::HgiTextureHandle handle);
    #endif // #if __has_include(<Metal/Metal.h>)
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#endif /* SWIFTUSD_SWIFTOVERLAY_HYDRAHELPERS_H */
