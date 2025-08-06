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

// Original documentation for pxr::HgiMetal from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/imaging/hgiMetal/hgi.h

#ifndef SWIFTUSD_WRAPPERS_HGIMETALWRAPPER_H
#define SWIFTUSD_WRAPPERS_HGIMETALWRAPPER_H

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT && __has_include(<Metal/Metal.h>)

#include <stdio.h>
#include <memory>
#include <MetalKit/MetalKit.h>
#include <Metal/Metal.h>
#include "pxr/imaging/hgi/hgi.h"
#include "pxr/imaging/hio/image.h"
#include "pxr/imaging/hgiMetal/hgi.h"
#include "pxr/imaging/hgiMetal/texture.h"
#include "pxr/usdImaging/usdImagingGL/engine.h"
#include "swiftUsd/Wrappers/HgiWrapper.h"

namespace Overlay {
    /// \class HgiMetal
    ///
    /// Metal implementation of the Hydra Graphics Interface.
    ///
    class HgiMetalWrapper final: public Overlay::HgiWrapper {
    public:
        // HgiMetal interface, omitting inherited methods
        
        enum CommitCommandBufferWaitType {
            CommitCommandBuffer_NoWait = 0,
            CommitCommandBuffer_WaitUntilScheduled,
            CommitCommandBuffer_WaitUntilCompleted
        };

        //
        // HgiMetal specific
        //

        HgiMetalWrapper(id<MTLDevice> device = nil);

        /// Returns the primary Metal device.
        id<MTLDevice> GetPrimaryDevice() const;

        id<MTLCommandQueue> GetQueue() const;

        // Metal Command buffers are heavy weight, while encoders are lightweight.
        // But we cannot have more than one active encoder at a time per cmd buf.
        // (Ideally we would have created an encoder for each HgiCmds)
        // So for the sake of efficiency, we try to create only one cmd buf and
        // only use the secondary command buffer when the client code requires it.
        // For example, the client code may record in a HgiBlitCmds and a
        // HgiComputeCmds at the same time. It is the responsibility of the the
        // command buffer implementation to call SetHasWork() if there is
        // work to be submitted from the primary command buffer.
        id<MTLCommandBuffer> GetPrimaryCommandBuffer(pxr::HgiCmds *requester = nullptr,
                                                     bool flush = true);

        id<MTLCommandBuffer> GetSecondaryCommandBuffer();

        void SetHasWork();

        int GetAPIVersion() const;

        void CommitPrimaryCommandBuffer(CommitCommandBufferWaitType waitType = CommitCommandBuffer_NoWait,
                                        bool forceNewBuffer = false);

        void CommitSecondaryCommandBuffer(id<MTLCommandBuffer> commandBuffer,
                                          CommitCommandBufferWaitType waitType);

        void ReleaseSecondaryCommandBuffer(id<MTLCommandBuffer> commandBuffer);

        id<MTLArgumentEncoder> GetBufferArgumentEncoder() const;

        id<MTLArgumentEncoder> GetSamplerArgumentEncoder() const;

        id<MTLArgumentEncoder> GetTextureArgumentEncoder() const;

        id<MTLBuffer> GetArgBuffer();

        /// SwiftUsd wrapping constructor
        HgiMetalWrapper(std::shared_ptr<pxr::HgiMetal> _ptr);

        /// SwiftUsd static downcasting constructor. Check `operator bool()` to determine
        /// if the downcast succeeded. 
        HgiMetalWrapper(Overlay::HgiWrapper hgi);

        /// Returns the underlying HgiMetal wrapped by this instance
        pxr::HgiMetal*_Nullable get() const;

        /// Returns the underlying HgiMetal wrapped by this instance
        std::shared_ptr<pxr::HgiMetal> get_shared() const;
    };
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT && __has_include(<Metal/Metal.h>)

#endif /* SWIFTUSD_WRAPPERS_HGIMETALWRAPPER_H */
