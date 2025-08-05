//
//  HgiWrapper.cpp
//  SwiftHydraPlayer
//
//  Created by Maddy Adams on 8/11/23.
//

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include "swiftUsd/Wrappers/HgiWrapper.h"
#include "pxr/imaging/hgi/blitCmds.h"
#include "pxr/imaging/hdx/types.h"
#include "pxr/imaging/hgi/blitCmdsOps.h"
#include "pxr/imaging/hio/image.h"
#include "pxr/imaging/hgi/texture.h"

void Overlay::HgiWrapper::SubmitCmds(pxr::HgiCmds *cmds, pxr::HgiSubmitWaitType wait) {
    get()->SubmitCmds(cmds, wait);
}

Overlay::HgiWrapper Overlay::HgiWrapper::CreatePlatformDefaultHgi() {
    return Overlay::HgiWrapper(pxr::Hgi::CreatePlatformDefaultHgi());
}

Overlay::HgiWrapper Overlay::HgiWrapper::CreateNamedHgi(const pxr::TfToken& hgiToken) {
    return Overlay::HgiWrapper(pxr::Hgi::CreateNamedHgi(hgiToken));
}

bool Overlay::HgiWrapper::IsBackendSupported() const {
    return get()->IsBackendSupported();
}    

bool Overlay::HgiWrapper::IsSupported(const pxr::TfToken& hgiToken) {
    return pxr::Hgi::IsSupported(hgiToken);
}

pxr::HgiGraphicsCmdsUniquePtr Overlay::HgiWrapper::CreateGraphicsCmds(const pxr::HgiGraphicsCmdsDesc &desc) {
    return get()->CreateGraphicsCmds(desc);
}

Overlay::HgiBlitCmds_SharedPtr Overlay::HgiWrapper::CreateBlitCmds() {
    return get()->CreateBlitCmds();
}

pxr::HgiComputeCmdsUniquePtr Overlay::HgiWrapper::CreateComputeCmds(const pxr::HgiComputeCmdsDesc& desc) {
    return get()->CreateComputeCmds(desc);
}

pxr::HgiTextureHandle Overlay::HgiWrapper::CreateTexture(const pxr::HgiTextureDesc& desc) {
    return get()->CreateTexture(desc);
}

void Overlay::HgiWrapper::DestroyTexture(pxr::HgiTextureHandle* texHandle) {
    get()->DestroyTexture(texHandle);
}

pxr::HgiTextureViewHandle Overlay::HgiWrapper::CreateTextureView(const pxr::HgiTextureViewDesc& desc) {
    return get()->CreateTextureView(desc);
}

void Overlay::HgiWrapper::DestroyTextureView(pxr::HgiTextureViewHandle* viewHandle) {
    get()->DestroyTextureView(viewHandle);
}

pxr::HgiSamplerHandle Overlay::HgiWrapper::CreateSampler(const pxr::HgiSamplerDesc& desc) {
    return get()->CreateSampler(desc);
}

void Overlay::HgiWrapper::DestroySampler(pxr::HgiSamplerHandle* smpHandle) {
    get()->DestroySampler(smpHandle);
}

pxr::HgiBufferHandle Overlay::HgiWrapper::CreateBuffer(const pxr::HgiBufferDesc& desc) {
    return get()->CreateBuffer(desc);
}

void Overlay::HgiWrapper::DestroyBuffer(pxr::HgiBufferHandle* bufHandle) {
    get()->DestroyBuffer(bufHandle);
}

pxr::HgiShaderFunctionHandle Overlay::HgiWrapper::CreateShaderFunction(const pxr::HgiShaderFunctionDesc& desc) {
    return get()->CreateShaderFunction(desc);
}

void Overlay::HgiWrapper::DestroyShaderFunction(pxr::HgiShaderFunctionHandle* shaderFunctionHandle) {
    return get()->DestroyShaderFunction(shaderFunctionHandle);
}

pxr::HgiShaderProgramHandle Overlay::HgiWrapper::CreateShaderProgram(const pxr::HgiShaderProgramDesc& desc) {
    return get()->CreateShaderProgram(desc);
}

void Overlay::HgiWrapper::DestroyShaderProgram(pxr:: HgiShaderProgramHandle* shaderProgramHandle) {
    return get()->DestroyShaderProgram(shaderProgramHandle);
}

pxr::HgiResourceBindingsHandle Overlay::HgiWrapper::CreateResourceBindings(const pxr::HgiResourceBindingsDesc& desc) {
    return get()->CreateResourceBindings(desc);
}

void Overlay::HgiWrapper::DestroyResourceBindings(pxr::HgiResourceBindingsHandle* resHandle) {
    get()->DestroyResourceBindings(resHandle);
}

pxr::HgiGraphicsPipelineHandle Overlay::HgiWrapper::CreateGraphicsPipeline(const pxr::HgiGraphicsPipelineDesc& pipeDesc) {
    return get()->CreateGraphicsPipeline(pipeDesc);
}

void Overlay::HgiWrapper::DestroyGraphicsPipeline(pxr::HgiGraphicsPipelineHandle* pipeHandle) {
    get()->DestroyGraphicsPipeline(pipeHandle);
}

pxr::HgiComputePipelineHandle Overlay::HgiWrapper::CreateComputePipeline(const pxr::HgiComputePipelineDesc& pipeDesc) {
    return get()->CreateComputePipeline(pipeDesc);
}

void Overlay::HgiWrapper::DestroyComputePipeline(pxr::HgiComputePipelineHandle* pipeHandle) {
    get()->DestroyComputePipeline(pipeHandle);
}

const pxr::TfToken& Overlay::HgiWrapper::GetAPIName() {
    return get()->GetAPIName();
}

const pxr::HgiCapabilities* Overlay::HgiWrapper::GetCapabilities() const {
    return get()->GetCapabilities();
}

pxr::HgiIndirectCommandEncoder* Overlay::HgiWrapper::GetIndirectCommandEncoder() const {
    return get()->GetIndirectCommandEncoder();
}

void Overlay::HgiWrapper::StartFrame() {
    get()->StartFrame();
}

void Overlay::HgiWrapper::EndFrame() {
    get()->EndFrame();
}

void Overlay::HgiWrapper::GarbageCollect() {
    get()->GarbageCollect();
}

// MARK: SwiftUsd implementation access

Overlay::HgiWrapper::HgiWrapper(std::shared_ptr<pxr::Hgi> _ptr) : _ptr(_ptr) {}

pxr::Hgi* Overlay::HgiWrapper::get() const {
    return _ptr.get();
}

std::shared_ptr<pxr::Hgi> Overlay::HgiWrapper::get_shared() const {
    return _ptr;
}

Overlay::HgiWrapper::operator bool() const {
    return (bool)_ptr;
}

pxr::VtValue Overlay::HgiWrapper::VtValueWrappingHgiRawPtr() const {
    pxr::Hgi* p = get();
    // Important: p must be non-const when passed to pxr::VtValue(),
    // otherwise this obscure warning is emitted followed by a crash
    // during UsdImagingGLEngine construction.
    // Coding Error: in SetDrivers at line 255 of pxr/imaging/hdSt/renderDelegate.cpp -- Failed verification: ' _hgi ' -- HdSt requires Hgi HdDriver

    return pxr::VtValue(p);
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
