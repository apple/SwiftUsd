//
//  HydraHelpers.h
//
//  Created by Maddy Adams on 3/28/24.
//

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
