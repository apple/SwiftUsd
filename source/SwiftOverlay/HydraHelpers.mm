//
//  HydraHelpers.mm
//
//  Created by Maddy Adams on 3/28/24.h

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
