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

// Original documentation for pxr::HgiGL from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v26.05/pxr/imaging/hgiGL/hgi.h

#ifndef SWIFTUSD_WRAPPERS_HGIGLWRAPPER_H
#define SWIFTUSD_WRAPPERS_HGIGLWRAPPER_H

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include <stdio.h>
#include <memory>
#include "pxr/imaging/hgi/hgi.h"
#include "pxr/imaging/hio/image.h"
#include "pxr/imaging/hgiGL/hgi.h"
#include "pxr/usdImaging/usdImagingGL/engine.h"
#include "swiftUsd/Wrappers/HgiWrapper.h"

namespace Overlay {
    /// \class HgiGL
    ///
    /// OpenGL implementation of the Hydra Graphics Interface.
    ///
    /// \section GL Context Management
    /// HgiGL expects any GL context(s) to be externally managed.
    /// When HgiGL is constructed and during any of its resource create / destroy
    /// calls and during command recording operations, it expects that an OpenGL
    /// context is valid and current.
    ///
    class HgiGLWrapper final: public Overlay::HgiWrapper {
    public:
        // HgiGL interface, omitting inherited methods

        //
        // HgiGL specific
        //

        HgiGLWrapper();

        /// Returns the opengl device.
        pxr::HgiGLDevice*_Nullable GetPrimaryDevice() const;

        /// Creates and return a context arena object handle.
        pxr::HgiGLContextArenaHandle CreateContextArena();

        /// Destroy a context arena.
        /// Note: The context arena must be unset (by calling SetContextArena with
        ///       an empty handle) prior to destruction.
        void DestroyContextArena(pxr::HgiGLContextArenaHandle*_Nonnull arenaHandle);

        /// Set the context arena to manage container resources (currently limited to
        /// framebuffer objects) for graphics commands submitted subsequently.
        void SetContextArena(const pxr::HgiGLContextArenaHandle& arenaHandle);

        /// SwiftUsd wrapping constructor
        HgiGLWrapper(std::shared_ptr<pxr::HgiGL> _ptr);

        /// SwiftUsd static downcasting constructor. Check `operator bool()` to determine
        /// if the downcast succeeded.
        HgiGLWrapper(Overlay::HgiWrapper hgi);

        /// Returns the underlying HgiGL wrapped by this instance
        pxr::HgiGL*_Nullable get() const;

        /// Returns the underlying HgiGL wrapped by this instance
        std::shared_ptr<pxr::HgiGL> get_shared() const;
    };
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#endif /* SWIFTUSD_WRAPPERS_HGIGLWRAPPER_H */
