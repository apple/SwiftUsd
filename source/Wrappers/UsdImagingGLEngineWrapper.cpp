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
#if SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT

#include "swiftUsd/Wrappers/UsdImagingGLEngineWrapper.h"
#include "pxr/usd/usd/prim.h"

// Nested types that would normally be importable by Swift-Cxx interop
// are blocked from being imported if their parent type is not imported.
// In these cases, we can define a type with the same size, fields, and layout,
// and reinterpret_cast between the two types. 
// 
// std::is_layout_compatible is C++20, so we can't use it in OpenUSD (C++17).
// Instead, we can check that two types have the same size, and enumerate that all
// fields match by offset and type, to get most of the way there

#define ASSERT_SIZES_MATCH(T, U) \
    static_assert(sizeof(T) == sizeof(U));

#define ASSERT_FIELDS_MATCH(T, U, name) \
    static_assert(offsetof(T, name) == offsetof(U, name)); \
    static_assert(std::is_same<decltype(T::name), decltype(U::name)>::value);




// MARK: Construction

Overlay::UsdImagingGLEngineWrapper::UsdImagingGLEngineWrapper(const Overlay::UsdImagingGLEngineWrapper::Parameters& wrapperParams) {
    ASSERT_SIZES_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, rootPath);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, excludedPaths);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, invisedPaths);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, sceneDelegateID);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, driver);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, rendererPluginId);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, gpuEnabled);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, displayUnloadedPrimsWithBounds);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, allowAsynchronousSceneProcessing);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::Parameters, Overlay::UsdImagingGLEngineWrapper::Parameters, enableUsdDrawModes);

    pxr::UsdImagingGLEngine::Parameters params = *reinterpret_cast<const pxr::UsdImagingGLEngine::Parameters*>(&wrapperParams);
    _impl = std::make_shared<pxr::UsdImagingGLEngine>(params);
}

Overlay::UsdImagingGLEngineWrapper::UsdImagingGLEngineWrapper(const pxr::HdDriver& driver,
                                                              const pxr::TfToken& rendererPluginId,
                                                              bool gpuEnabled) :
    _impl(std::make_shared<pxr::UsdImagingGLEngine>(driver,
                                                    rendererPluginId,
                                                    gpuEnabled))
{
}

Overlay::UsdImagingGLEngineWrapper::UsdImagingGLEngineWrapper(const pxr::SdfPath &rootPath,
                                                              const pxr::SdfPathVector &excludedPaths,
                                                              const pxr::SdfPathVector &invisedPaths,
                                                              const pxr::SdfPath &sceneDelegateID,
                                                              const pxr::HdDriver &driver,
                                                              const pxr::TfToken &rendererPluginId,
                                                              const bool gpuEnabled,
                                                              const bool displayUnloadedPrimsWithBounds,
                                                              const bool allowAsynchronousSceneProcessing,
                                                              const bool enableUsdDrawModes) :
_impl(std::make_shared<pxr::UsdImagingGLEngine>(rootPath,
                                                excludedPaths,
                                                invisedPaths,
                                                sceneDelegateID,
                                                driver,
                                                rendererPluginId,
                                                gpuEnabled,
                                                displayUnloadedPrimsWithBounds,
                                                allowAsynchronousSceneProcessing,
                                                enableUsdDrawModes))
{
}

// MARK: Rendering

void Overlay::UsdImagingGLEngineWrapper::PrepareBatch(const pxr::UsdPrim& root,
                                                      const pxr::UsdImagingGLRenderParams& params) {
    _impl->PrepareBatch(root, params);
}

void Overlay::UsdImagingGLEngineWrapper::RenderBatch(const pxr::SdfPathVector& paths,
                                                     const pxr::UsdImagingGLRenderParams& params) {
    _impl->RenderBatch(paths, params);
}

void Overlay::UsdImagingGLEngineWrapper::Render(const pxr::UsdPrim& root,
                                                const pxr::UsdImagingGLRenderParams& params) {
    _impl->Render(root, params);
}

bool Overlay::UsdImagingGLEngineWrapper::IsConverged() const {
    return _impl->IsConverged();
}

// MARK: Root Transform and Visibility

void Overlay::UsdImagingGLEngineWrapper::SetRootTransform(const pxr::GfMatrix4d& xf) {
    _impl->SetRootTransform(xf);
}

void Overlay::UsdImagingGLEngineWrapper::SetRootVisibility(bool isVisible) {
    _impl->SetRootVisibility(isVisible);
}

// MARK: Camera State

void Overlay::UsdImagingGLEngineWrapper::SetCameraPath(const pxr::SdfPath& id) {
    _impl->SetCameraPath(id);
}

void Overlay::UsdImagingGLEngineWrapper::SetFraming(const pxr::CameraUtilFraming& framing) {
    _impl->SetFraming(framing);
}

void Overlay::UsdImagingGLEngineWrapper::SetOverrideWindowPolicy(const std::optional<pxr::CameraUtilConformWindowPolicy>& policy) {
    _impl->SetOverrideWindowPolicy(policy);
}

void Overlay::UsdImagingGLEngineWrapper::SetRenderBufferSize(const pxr::GfVec2i& size) {
    _impl->SetRenderBufferSize(size);
}

void Overlay::UsdImagingGLEngineWrapper::SetRenderViewport(const pxr::GfVec4d& viewport) {
    _impl->SetRenderViewport(viewport);
}

void Overlay::UsdImagingGLEngineWrapper::SetWindowPolicy(pxr::CameraUtilConformWindowPolicy policy) {
    _impl->SetWindowPolicy(policy);
}

void Overlay::UsdImagingGLEngineWrapper::SetCameraState(const pxr::GfMatrix4d& viewMatrix,
                                                        const pxr::GfMatrix4d& projectionMatrix) {
    _impl->SetCameraState(viewMatrix, projectionMatrix);
}

// MARK: Light State

void Overlay::UsdImagingGLEngineWrapper::SetLightingState(const pxr::GlfSimpleLightingContextPtr& src) {
    _impl->SetLightingState(src);
}

void Overlay::UsdImagingGLEngineWrapper::SetLightingState(const pxr::GlfSimpleLightVector& lights,
                                                          const pxr::GlfSimpleMaterial& material,
                                                          const pxr::GfVec4f& sceneAmbient) {
    _impl->SetLightingState(lights, material, sceneAmbient);    
}

// MARK: Selection Highlighting

void Overlay::UsdImagingGLEngineWrapper::SetSelected(const pxr::SdfPathVector& paths) {
    _impl->SetSelected(paths);
}

void Overlay::UsdImagingGLEngineWrapper::ClearSelected() {
    _impl->ClearSelected();
}

void Overlay::UsdImagingGLEngineWrapper::AddSelected(const pxr::SdfPath& path, int instanceIndex) {
    _impl->AddSelected(path, instanceIndex);
}

void Overlay::UsdImagingGLEngineWrapper::SetSelectionColor(const pxr::GfVec4f& color) {
    _impl->SetSelectionColor(color);
}

// MARK: Picking

bool Overlay::UsdImagingGLEngineWrapper::TestIntersection(const pxr::GfMatrix4d& viewMatrix,
                                                          const pxr::GfMatrix4d& projectionMatrix,
                                                          const pxr::UsdPrim& root,
                                                          const pxr::UsdImagingGLRenderParams& params,
                                                          pxr::GfVec3d* outHitPoint,
                                                          pxr::GfVec3d* outHitNormal,
                                                          pxr::SdfPath* outHitPrimPath,
                                                          pxr::SdfPath* outHitInstancerPath,
                                                          int* outHitInstanceIndex,
                                                          pxr::HdInstancerContext* outInstancerContext) {
    return _impl->TestIntersection(viewMatrix,
                                   projectionMatrix,
                                   root,
                                   params,
                                   outHitPoint,
                                   outHitNormal,
                                   outHitPrimPath,
                                   outHitInstancerPath,
                                   outHitInstanceIndex,
                                   outInstancerContext);
}

bool Overlay::UsdImagingGLEngineWrapper::TestIntersection(const PickParams& pickParams,
                                                          const pxr::GfMatrix4d& viewMatrix,
                                                          const pxr::GfMatrix4d& projectionMatrix,
                                                          const pxr::UsdPrim& root,
                                                          const pxr::UsdImagingGLRenderParams& params,
                                                          IntersectionResultVector* outResults) {
    
    ASSERT_SIZES_MATCH(pxr::UsdImagingGLEngine::PickParams, Overlay::UsdImagingGLEngineWrapper::PickParams);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::PickParams, Overlay::UsdImagingGLEngineWrapper::PickParams, resolveMode);

    pxr::UsdImagingGLEngine::PickParams implPickParams = *reinterpret_cast<const pxr::UsdImagingGLEngine::PickParams*>(&pickParams);

    ASSERT_SIZES_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult, hitPoint);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult, hitNormal);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult, hitPrimPath);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult, hitInstancerPath);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult, hitInstanceIndex);
    ASSERT_FIELDS_MATCH(pxr::UsdImagingGLEngine::IntersectionResult, Overlay::UsdImagingGLEngineWrapper::IntersectionResult, instancerContext);

    pxr::UsdImagingGLEngine::IntersectionResultVector* implOutResults = reinterpret_cast<pxr::UsdImagingGLEngine::IntersectionResultVector*>(outResults);

    return _impl->TestIntersection(implPickParams,
                                   viewMatrix,
                                   projectionMatrix,
                                   root,
                                   params,
                                   implOutResults);
}

bool Overlay::UsdImagingGLEngineWrapper::DecodeIntersection(unsigned char const primIdColor[4],
                                                            unsigned char const instanceIdColor[4],
                                                            pxr::SdfPath* outHitPrimPath,
                                                            pxr::SdfPath* outHitInstancerPath,
                                                            int* outHitInstanceIndex,
                                                            pxr::HdInstancerContext* outInstancerContext) {
    return _impl->DecodeIntersection(primIdColor,
                                     instanceIdColor,
                                     outHitPrimPath,
                                     outHitInstancerPath,
                                     outHitInstanceIndex,
                                     outInstancerContext);
}

bool Overlay::UsdImagingGLEngineWrapper::DecodeIntersection(int primIdx,
                                                            int instanceIdx,
                                                            pxr::SdfPath* outHitPrimPath,
                                                            pxr::SdfPath* outHitInstancerPath,
                                                            int* outHitInstanceIndex,
                                                            pxr::HdInstancerContext* outInstancerContext) {
    return _impl->DecodeIntersection(primIdx,
                                     instanceIdx,
                                     outHitPrimPath,
                                     outHitInstancerPath,
                                     outHitInstanceIndex,
                                     outInstancerContext);
}


/* static */
pxr::TfTokenVector Overlay::UsdImagingGLEngineWrapper::GetRendererPlugins() {
    return pxr::UsdImagingGLEngine::GetRendererPlugins();
}

/* static */
std::string Overlay::UsdImagingGLEngineWrapper::GetRendererDisplayName(const pxr::TfToken& id) {
    return pxr::UsdImagingGLEngine::GetRendererDisplayName(id);
}

std::string Overlay::UsdImagingGLEngineWrapper::GetRendererHgiDisplayName() const {
    return _impl->GetRendererHgiDisplayName();
}

bool Overlay::UsdImagingGLEngineWrapper::GetGPUEnabled() const {
    return _impl->GetGPUEnabled();
}

pxr::TfToken Overlay::UsdImagingGLEngineWrapper::GetCurrentRendererId() const {
    return _impl->GetCurrentRendererId();
}

bool Overlay::UsdImagingGLEngineWrapper::SetRendererPlugin(const pxr::TfToken& id) {
    return _impl->SetRendererPlugin(id);
}

// MARK: AOVs

pxr::TfTokenVector Overlay::UsdImagingGLEngineWrapper::GetRendererAovs() const {
    return _impl->GetRendererAovs();
}

bool Overlay::UsdImagingGLEngineWrapper::SetRendererAov(const pxr::TfToken& id) {
    return _impl->SetRendererAov(id);
}

bool Overlay::UsdImagingGLEngineWrapper::SetRendererAovs(const pxr::TfTokenVector& ids) {
    return _impl->SetRendererAovs(ids);
}

pxr::HgiTextureHandle Overlay::UsdImagingGLEngineWrapper::GetAovTexture(const pxr::TfToken& name) const {
    return _impl->GetAovTexture(name);
}

pxr::HdRenderBuffer* Overlay::UsdImagingGLEngineWrapper::GetAovRenderBuffer(const pxr::TfToken& name) const {
    return _impl->GetAovRenderBuffer(name);
}

// MARK: Render Settings (Legacy)

pxr::UsdImagingGLRendererSettingsList Overlay::UsdImagingGLEngineWrapper::GetRendererSettingsList() const {
    return _impl->GetRendererSettingsList();
}

void Overlay::UsdImagingGLEngineWrapper::SetRendererSetting(const pxr::TfToken& id,
                                                            const pxr::VtValue& value) {
    _impl->SetRendererSetting(id, value);
}

// MARK: Render Settings (Scene description driven)

void Overlay::UsdImagingGLEngineWrapper::SetActiveRenderPassPrimPath(const pxr::SdfPath& path) {
    _impl->SetActiveRenderPassPrimPath(path);
}

void Overlay::UsdImagingGLEngineWrapper::SetActiveRenderSettingsPrimPath(const pxr::SdfPath& path) {
    _impl->SetActiveRenderSettingsPrimPath(path);
}

/* static */
pxr::SdfPathVector GetAvailableRenderSettingsPrimPaths(const pxr::UsdPrim& root) {
    return pxr::UsdImagingGLEngine::GetAvailableRenderSettingsPrimPaths(root);
}

// MARK: Presentation

void Overlay::UsdImagingGLEngineWrapper::SetEnablePresentation(bool enabled) {
    _impl->SetEnablePresentation(enabled);
}

void Overlay::UsdImagingGLEngineWrapper::SetPresentationOutput(const pxr::TfToken& api, const pxr::VtValue& framebuffer) {
    _impl->SetPresentationOutput(api, framebuffer);
}

// MARK: Renderer Command API

pxr::HdCommandDescriptors Overlay::UsdImagingGLEngineWrapper::GetRendererCommandDescriptors() const {
    return _impl->GetRendererCommandDescriptors();
}

bool Overlay::UsdImagingGLEngineWrapper::InvokeRendererCommand(const pxr::TfToken& command,
                                                               const pxr::HdCommandArgs& args) const {
    return _impl->InvokeRendererCommand(command, args);
}

// MARK: Control of background rendering threads

bool Overlay::UsdImagingGLEngineWrapper::IsPauseRendererSupported() const {
    return _impl->IsPauseRendererSupported();
}

bool Overlay::UsdImagingGLEngineWrapper::PauseRenderer() {
    return _impl->PauseRenderer();
}

bool Overlay::UsdImagingGLEngineWrapper::ResumeRenderer() {
    return _impl->ResumeRenderer();
}

bool Overlay::UsdImagingGLEngineWrapper::IsStopRendererSupported() const {
    return _impl->IsStopRendererSupported();
}

bool Overlay::UsdImagingGLEngineWrapper::StopRenderer() {
    return _impl->StopRenderer();
}

bool Overlay::UsdImagingGLEngineWrapper::RestartRenderer() {
    return _impl->RestartRenderer();
}

// MARK: Color Correction

void Overlay::UsdImagingGLEngineWrapper::SetColorCorrectionSettings(const pxr::TfToken& ccType,
                                                                    const pxr::TfToken& ocioDisplay,
                                                                    const pxr::TfToken& ocioView,
                                                                    const pxr::TfToken& ocioColorSpace,
                                                                    const pxr::TfToken& ocioLook) {
    _impl->SetColorCorrectionSettings(ccType,
                                      ocioDisplay,
                                      ocioView,
                                      ocioColorSpace,
                                      ocioLook);
}

/* static */
bool Overlay::UsdImagingGLEngineWrapper::IsColorCorrectionCapable() {
    return pxr::UsdImagingGLEngine::IsColorCorrectionCapable();
}

// MARK: Renderer Statistics

pxr::VtDictionary Overlay::UsdImagingGLEngineWrapper::GetRenderStats() const {
    return _impl->GetRenderStats();
}

pxr::Hgi* Overlay::UsdImagingGLEngineWrapper::GetHgi() {
    return _impl->GetHgi();
}

// MARK: Asynchronous

bool Overlay::UsdImagingGLEngineWrapper::PollForAsynchronousUpdates() const {
    return _impl->PollForAsynchronousUpdates();
}

// MARK: SwiftUsd implementation access

pxr::UsdImagingGLEngine* Overlay::UsdImagingGLEngineWrapper::get() const {
    return _impl.get();
}

std::shared_ptr<pxr::UsdImagingGLEngine> Overlay::UsdImagingGLEngineWrapper::get_shared() const {
    return _impl;
}

Overlay::UsdImagingGLEngineWrapper::operator bool() const {
    return (bool)_impl;
}

Overlay::UsdImagingGLEngineWrapper::UsdImagingGLEngineWrapper(std::shared_ptr<pxr::UsdImagingGLEngine> impl) :
    _impl(impl) {}

#endif // #if SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT
