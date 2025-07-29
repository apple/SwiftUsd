//
//  HgiMetalWrapper.cpp
//  SwiftHydraPlayer
//
//  Created by Maddy Adams on 8/14/23.
//

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT && __has_include(<Metal/Metal.h>)

#include "swiftUsd/Wrappers/HgiMetalWrapper.h"

Overlay::HgiMetalWrapper::HgiMetalWrapper(id<MTLDevice> device) :
    Overlay::HgiWrapper(std::make_shared<pxr::HgiMetal>(device)) 
{}

id<MTLDevice> Overlay::HgiMetalWrapper::GetPrimaryDevice() const {
    return get()->GetPrimaryDevice();
}

id<MTLCommandQueue> Overlay::HgiMetalWrapper::GetQueue() const {
    return get()->GetQueue();
}

id<MTLCommandBuffer> Overlay::HgiMetalWrapper::GetPrimaryCommandBuffer(pxr::HgiCmds* requester,
                                                                       bool flush) {
    return get()->GetPrimaryCommandBuffer(requester, flush);
}

id<MTLCommandBuffer> Overlay::HgiMetalWrapper::GetSecondaryCommandBuffer() {
    return get()->GetSecondaryCommandBuffer();
}

void Overlay::HgiMetalWrapper::SetHasWork() {
    get()->SetHasWork();
}

int Overlay::HgiMetalWrapper::GetAPIVersion() const {
    return get()->GetAPIVersion();
}

void Overlay::HgiMetalWrapper::CommitPrimaryCommandBuffer(CommitCommandBufferWaitType waitType,
                                                          bool forceNewBuffer) {
    get()->CommitPrimaryCommandBuffer(static_cast<pxr::HgiMetal::CommitCommandBufferWaitType>(waitType),
                                      forceNewBuffer);
}

void Overlay::HgiMetalWrapper::CommitSecondaryCommandBuffer(id<MTLCommandBuffer> commandBuffer,
                                                            CommitCommandBufferWaitType waitType) {
    get()->CommitSecondaryCommandBuffer(commandBuffer,
                                        static_cast<pxr::HgiMetal::CommitCommandBufferWaitType>(waitType));
}

void Overlay::HgiMetalWrapper::ReleaseSecondaryCommandBuffer(id<MTLCommandBuffer> commandBuffer) {
    get()->ReleaseSecondaryCommandBuffer(commandBuffer);
}

id<MTLArgumentEncoder> Overlay::HgiMetalWrapper::GetBufferArgumentEncoder() const {
    return get()->GetBufferArgumentEncoder();
}

id<MTLArgumentEncoder> Overlay::HgiMetalWrapper::GetSamplerArgumentEncoder() const {
    return get()->GetSamplerArgumentEncoder();
}

id<MTLArgumentEncoder> Overlay::HgiMetalWrapper::GetTextureArgumentEncoder() const {
    return get()->GetTextureArgumentEncoder();
}

id<MTLBuffer> Overlay::HgiMetalWrapper::GetArgBuffer() {
    return get()->GetArgBuffer();
}

// MARK: SwiftUsd implementation access

Overlay::HgiMetalWrapper::HgiMetalWrapper(std::shared_ptr<pxr::HgiMetal> _ptr) : Overlay::HgiWrapper(_ptr) {}

Overlay::HgiMetalWrapper::HgiMetalWrapper(Overlay::HgiWrapper hgi) : Overlay::HgiWrapper(hgi) {
    if (!dynamic_cast<const pxr::HgiMetal*>(_ptr.get())) {
        _ptr = nullptr;
    }
}

pxr::HgiMetal* Overlay::HgiMetalWrapper::get() const {
    return std::static_pointer_cast<pxr::HgiMetal>(_ptr).get();
}

std::shared_ptr<pxr::HgiMetal> Overlay::HgiMetalWrapper::get_shared() const {
    return std::static_pointer_cast<pxr::HgiMetal>(_ptr);
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT && __has_include(<Metal/Metal.h>)
