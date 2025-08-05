//
//  UsdAppUtilsFrameRecorderWrapper.cpp
//  SwiftUsd
//
//  Created by Maddy Adams on 4/17/25.
//

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT

#include "swiftUsd/Wrappers/UsdAppUtilsFrameRecorderWrapper.h"

Overlay::UsdAppUtilsFrameRecorderWrapper::UsdAppUtilsFrameRecorderWrapper(const pxr::TfToken& rendererPluginId,
                                                                          bool gpuEnabled,
                                                                          bool enableUsdDrawModes) :
_impl(std::make_shared<pxr::UsdAppUtilsFrameRecorder>(rendererPluginId, gpuEnabled, enableUsdDrawModes)) {}

pxr::TfToken Overlay::UsdAppUtilsFrameRecorderWrapper::GetCurrentRendererId() const {
    return _impl->GetCurrentRendererId();
}

bool Overlay::UsdAppUtilsFrameRecorderWrapper::SetRendererPlugin(const pxr::TfToken &id) {
    return _impl->SetRendererPlugin(id);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetActiveRenderPassPrimPath(const pxr::SdfPath &path) {
    _impl->SetActiveRenderPassPrimPath(path);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetActiveRenderSettingsPrimPath(const pxr::SdfPath &path) {
    _impl->SetActiveRenderSettingsPrimPath(path);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetImageWidth(const size_t imageWidth) {
    _impl->SetImageWidth(imageWidth);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetComplexity(const float complexity) {
    _impl->SetComplexity(complexity);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetColorCorrectionMode(const pxr::TfToken &colorCorrectionMode) {
    _impl->SetColorCorrectionMode(colorCorrectionMode);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetCameraLightEnabled(bool cameraLightEnabled) {
    _impl->SetCameraLightEnabled(cameraLightEnabled);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetDomeLightVisibility(bool domeLightsVisible) {
    _impl->SetDomeLightVisibility(domeLightsVisible);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetIncludedPurposes(const pxr::TfTokenVector &purposes) {
    _impl->SetIncludedPurposes(purposes);
}

void Overlay::UsdAppUtilsFrameRecorderWrapper::SetPrimaryCameraPrimPath(const pxr::SdfPath& cameraPath) {
    _impl->SetPrimaryCameraPrimPath(cameraPath);
}

bool Overlay::UsdAppUtilsFrameRecorderWrapper::Record(const pxr::UsdStagePtr &stage,
                                                      const pxr::UsdGeomCamera &usdCamera,
                                                      const pxr::UsdTimeCode timeCode,
                                                      const std::string &outputImagePath) {
    return _impl->Record(stage, usdCamera, timeCode, outputImagePath);
}

// MARK: SwiftUsd implementation access

Overlay::UsdAppUtilsFrameRecorderWrapper::UsdAppUtilsFrameRecorderWrapper(std::shared_ptr<pxr::UsdAppUtilsFrameRecorder> impl) : _impl(impl) {}

pxr::UsdAppUtilsFrameRecorder*_Nullable Overlay::UsdAppUtilsFrameRecorderWrapper::get() const {
    return _impl.get();
}

std::shared_ptr<pxr::UsdAppUtilsFrameRecorder> Overlay::UsdAppUtilsFrameRecorderWrapper::get_shared() const {
    return _impl;
}

Overlay::UsdAppUtilsFrameRecorderWrapper::operator bool() const {
    return (bool)_impl;
}

#endif // #if SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT
