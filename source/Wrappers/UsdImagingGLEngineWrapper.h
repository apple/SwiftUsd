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

// Original documentation for pxr::UsdImagingGLEngine from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/usdImaging/usdImagingGL/engine.h

#ifndef SWIFTUSD_WRAPPERS_USDIMAGINGGLENGINEWRAPPER_H
#define SWIFTUSD_WRAPPERS_USDIMAGINGGLENGINEWRAPPER_H

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT


#include <stdio.h>
#include <vector>
#include <memory>
#include "pxr/imaging/hio/image.h"

#include "pxr/usdImaging/usdImagingGL/engine.h"
#include "pxr/pxr.h"

namespace Overlay {
    /// \class UsdImagingGLEngine
    ///
    /// The UsdImagingGLEngine is the main entry point API for rendering USD scenes.
    ///
    class UsdImagingGLEngineWrapper {
    public:
        /// Parameters to construct UsdImagingGLEngine
        struct Parameters
        {
            pxr::SdfPath rootPath = pxr::SdfPath::AbsoluteRootPath();
            pxr::SdfPathVector excludedPaths;
            pxr::SdfPathVector invisedPaths;
            pxr::SdfPath sceneDelegateID = pxr::SdfPath::AbsoluteRootPath();
            /// An HdDriver, containing the Hgi of your choice, can be optionally passed
            /// in during construction. This can be helpful if your application creates
            /// multiple UsdImagingGLEngine's that wish to use the same HdDriver / Hgi.
            pxr::HdDriver driver;
            /// The \p rendererPluginId argument indicates the renderer plugin that
            /// Hydra should use. If the empty token is passed in, a default renderer
            /// plugin will be chosen depending on the vlaue of \p gpuEnabled.
            pxr::TfToken rendererPluginId;
            /// The \p gpuEnabled argument determines if this instance will allow Hydra
            /// to use the GPU to produce images.
            bool gpuEnabled = true;
            /// \p displayUnloadedPrimsWithBounds draws bounding boxes for unloaded
            /// prims if they have extents/extentsHint authored.
            bool displayUnloadedPrimsWithBounds = false;
            /// \p allowAsynchronousSceneProcessing indicates to constructed hydra
            /// scene indices that asynchronous processing is allowed. Applications
            /// should periodically call PollForAsynchronousUpdates on the engine.
            bool allowAsynchronousSceneProcessing = false;
            /// \p enableUsdDrawModes enables the UsdGeomModelAPI draw mode
            /// feature.
            bool enableUsdDrawModes = true;
        };

        // ---------------------------------------------------------------------
        /// \name Construction
        /// @{
        // ---------------------------------------------------------------------
    
        UsdImagingGLEngineWrapper(const Parameters &params);

        /// A HdDriver, containing the Hgi of your choice, can be optionally passed
        // in during construction. This can be helpful if your application creates
        /// multiple UsdImagingGLEngine that wish to use the same HdDriver / Hgi.
        /// The \p rendererPluginId argument indicates the renderer plugin that
        /// Hydra should use. If the empty token is passed in, a default renderer
        /// plugin will be chosen depending on the value of \p gpuEnabled.
        /// The \p gpuEnabled argument determines if this instance will allow Hydra
        /// to use the GPU to produce images.
        UsdImagingGLEngineWrapper(const pxr::HdDriver& driver = pxr::HdDriver(),
                                  const pxr::TfToken& rendererPluginId = pxr::TfToken(),
                                  bool gpuEnabled = true);
        
        UsdImagingGLEngineWrapper(const pxr::SdfPath &rootPath,
                                  const pxr::SdfPathVector &excludedPaths, 
                                  const pxr::SdfPathVector &invisedPaths = pxr::SdfPathVector(),
                                  const pxr::SdfPath &sceneDelegateID = pxr::SdfPath::AbsoluteRootPath(),
                                  const pxr::HdDriver &driver = pxr::HdDriver(),
                                  const pxr::TfToken &rendererPluginId = pxr::TfToken(),
                                  const bool gpuEnabled = true,
                                  const bool displayUnloadedPrimsWithBounds = false,
                                  const bool allowAsynchronousSceneProcessing = false,
                                  const bool enableUsdDrawModes = true);

        /// @}

        // ---------------------------------------------------------------------
        /// \name Rendering
        /// @{
        // ---------------------------------------------------------------------

        /// Support for batched drawing
        void PrepareBatch(const pxr::UsdPrim& root,
                          const pxr::UsdImagingGLRenderParams& params);
    
        void RenderBatch(const pxr::SdfPathVector& paths,
                         const pxr::UsdImagingGLRenderParams& params);

        /// Entry point for kicking off a render
        void Render(const pxr::UsdPrim& root,
                    const pxr::UsdImagingGLRenderParams& params);

        /// Returns true if the resulting image is fully converged.
        // (otherwise, caller may need to call Render() again to refine the result)
        bool IsConverged() const;
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Root Transform and Visibility
        /// @{
        // ---------------------------------------------------------------------

        /// Sets the root transform.
        void SetRootTransform(const pxr::GfMatrix4d& xf);

        /// Sets the root visibility.
        void SetRootVisibility(bool isVisible);
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Camera State
        /// @{
        // ---------------------------------------------------------------------

        /// Scene camera API
        /// Set the scene camera path to use for rendering.
        void SetCameraPath(const pxr::SdfPath& id);

        /// Determines how the filmback of the camera is mapped into
        /// the pixels of the render buffer and what pixels of the render
        /// buffer will be rendered into.
        void SetFraming(const pxr::CameraUtilFraming& framing);

        /// Specifies whether to force a window policy when conforming
        /// the frustum of the camera to match the display window of
        /// the camera framing.
        ///
        /// If set to std::nullopt, the window policy of the specified camera
        /// will be used.
        void SetOverrideWindowPolicy(const std::optional<pxr::CameraUtilConformWindowPolicy>& policy);

        /// Set the size of the render buffers backing the AOVs.
        /// GUI applications should set this to be the size of the window.
        ///
        void SetRenderBufferSize(const pxr::GfVec2i& size);

        /// Set the viewport to use for rendering as (x,y,w,h) where (x,y)
        /// represents the lower left corner of the viewport rectangle, and (w,h)
        /// is the width and height of the viewport in pixels.
        ///
        /// \deprecated Use SetFraming and SetRenderBufferSize instead.
        void SetRenderViewport(const pxr::GfVec4d& viewport);

        /// Set the window policy to use.
        /// XXX: This is currently used for scene cameras set via SetCameraPath.
        /// See comment in SetCameraState for the free cam.
        void SetWindowPolicy(pxr::CameraUtilConformWindowPolicy policy);

        /// Free camera API
        /// Set camera framing state directly (without pointing to a camera on the
        /// USD stage). The projection matrix is expected to be pre-adjusted for the
        /// window policy.
        void SetCameraState(const pxr::GfMatrix4d& viewMatrix,
                            const pxr::GfMatrix4d& projectionMatrix);
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Light State
        /// @{
        // ---------------------------------------------------------------------

        /// Copy lighting state from another lighting context.
        void SetLightingState(const pxr::GlfSimpleLightingContextPtr& src);

        /// Set lighting state
        /// Derived classes should ensure that passing an empty lights
        /// vector disables lighting.
        /// \param lights is the set of lights to use, or empty to disable lighting.
        void SetLightingState(const pxr::GlfSimpleLightVector& lights,
                              const pxr::GlfSimpleMaterial& material,
                              const pxr::GfVec4f& sceneAmbient);
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Selection Highlight
        /// @{
        // ---------------------------------------------------------------------

        /// Sets (replaces) the list of prim paths that should be included in
        /// selection highlighting. These paths may include root paths which will
        /// be expanded internally.
        void SetSelected(const pxr::SdfPathVector& paths);

        /// Clear the list of prim paths that should be included in selection
        /// highlighting.
        void ClearSelected();

        /// Add a path with instanceIndex to the list of prim paths that should be
        /// included in selection hightlight. UsdImagingDelegate::ALL_Instances
        /// can be used for highlighting all instances if path is an instancer.
        void AddSelected(const pxr::SdfPath& path, int instanceIndex);

        /// Sets the selection highlighting color.
        void SetSelectionColor(const pxr::GfVec4f& color);

        /// @}

        // ---------------------------------------------------------------------
        /// \name Picking
        /// @{
        // ---------------------------------------------------------------------
    
        /// Finds closest point of intersection with a frustum by rendering.
        ///
        /// This method uses a PickRender and a customized depth buffer to find an
        /// approximate point of intersection by rendering. This is less accurate
        /// than implicit methods or rendering with GL_SELECT, but leverages any
        /// data already cached in the renderer.
        ///
        /// Returns whether a hit occurred and if so, \p outHitPoint will contain
        /// the intersection point in world space (i.e. \p projectionMatrix and
        /// \p viewMatrix factored back out of the result), and \p outHitNormal
        /// will contain the world space normal at that point.
        ///
        /// \p outHitPrimPath will point to the gprim selected by the pick.
        /// \p outHitInstancerPath will point to the point instancer (if applicable)
        /// of that gprim. For nested instancing, outHitInstancerPath points to
        /// the closest instancer.
        ///
        /// \deprecated Please use the override of TestIntersection that takes
        /// PickParams and returns an IntersectionResultVector instead!
        bool TestIntersection(const pxr::GfMatrix4d& viewMatrix,
                              const pxr::GfMatrix4d& projectionMatrix,
                              const pxr::UsdPrim& root,
                              const pxr::UsdImagingGLRenderParams& params,
                              pxr::GfVec3d* outHitPoint,
                              pxr::GfVec3d* outHitNormal,
                              pxr::SdfPath* outHitPrimPath = NULL,
                              pxr::SdfPath* outHitInstancerPath = NULL,
                              int* outHitInstanceIndex = NULL,
                              pxr::HdInstancerContext* outInstancerContext = NULL);

        // Pick result
        struct IntersectionResult {
            pxr::GfVec3d hitPoint;
            pxr::GfVec3d hitNormal;
            pxr::SdfPath hitPrimPath;
            pxr::SdfPath hitInstancerPath;
            int hitInstanceIndex;
            pxr::HdInstancerContext instancerContext;
        };

        typedef std::vector<struct IntersectionResult> IntersectionResultVector;

        // Pick params
        struct PickParams {
            pxr::TfToken resolveMode;
        };

        /// Perform picking by finding the intersection of objexcts in the scene with a rendered frustum.
        /// Depending on the resolve mode it may find all objects intersection the frustum or the closest
        /// point of intersection within the frustum.
        ///
        /// If resolve mode is set to resolveDeep it uses Deep Selection to gather all paths within
        /// the frustum even if obscured by other visible objects.
        /// If resolve mode is set to resolveNearestToCenter it uses a PickRender and
        /// a customized depth buffer to find all approximate points of intersection by rendering.
        /// This is less accurate than implicit methods or rendering with GL_SELECT, but leverages any
        /// data already cached in the renderer.
        ///
        /// Returns whether a hit occurred and if so, \p outResults will point to all the
        /// gprims selected by the pick as determined by the resolve mode.
        /// \p outHitPoint will contain the intersection point in wolrd space
        /// (i.e. \p projectionMatrix and \p viewMatrix factored back out of the result)
        /// \p outHitNormal will contain the world space normal at that point.
        /// \p hitPrimPath will point to the gprim selected by the pick.
        /// \p hitInstancerPath will point to the point instancer (if applicable) of each gprim.
        ///
        bool TestIntersection(const PickParams& pickParams,
                              const pxr::GfMatrix4d& viewMatrix,
                              const pxr::GfMatrix4d& projectionMatrix,
                              const pxr::UsdPrim& root,
                              const pxr::UsdImagingGLRenderParams& params,
                              IntersectionResultVector* outResults);

        /// Decodes a pick result given hydra prim ID/instance ID (like you'd get
        /// from an ID render), where ID is represented as a vec4 color.
        bool DecodeIntersection(unsigned char const primIdColor[4],
                                unsigned char const instanceIdColor[4],
                                pxr::SdfPath* outHitPrimPath = NULL,
                                pxr::SdfPath* outHitInstancerPath = NULL,
                                int* outHitInstanceIndex = NULL,
                                pxr::HdInstancerContext* outInstancerContext = NULL);

        /// Decodes a pick result given hydra prim ID/instance ID (like you'd get
        /// from an ID render), where ID is represented as an int.
        bool DecodeIntersection(int primIdx,
                                int instanceIdx,
                                pxr::SdfPath* outHitPrimPath = NULL,
                                pxr::SdfPath* outHitInstancerPath = NULL,
                                int* outHitInstanceIndex = NULL,
                                pxr::HdInstancerContext* outInstancerContext = NULL);

        /// @}

        // ---------------------------------------------------------------------
        /// \name Renderer Plugin Management
        /// @{
        // ---------------------------------------------------------------------

        /// Return the vector of available render-graph delegate plugins.
        static pxr::TfTokenVector GetRendererPlugins();

        /// Return the user-friendly name of a renderer plugin.
        static std::string GetRendererDisplayName(const pxr::TfToken& id);

        /// Return the user-friendly name of the Hgi implementation.
        /// For example: OpenGL, Metal, Vulkan. This is only available
        /// if a render plugin was set and it uses Hgi.
        std::string GetRendererHgiDisplayName() const;

        /// Return if the GPU is enabled and can be used for any rendering tasks.
        bool GetGPUEnabled() const;

        /// Return the id of the currently used renderer plugin.
        pxr::TfToken GetCurrentRendererId() const;

        /// Set the current render-graph delegate to \p id.
        /// The plugin will be loaded if it's not yet.
        bool SetRendererPlugin(const pxr::TfToken& id);

        /// @}
    
        // ---------------------------------------------------------------------
        /// \name AOVs
        /// @{
        // ---------------------------------------------------------------------

        /// Return the vector of available renderer AOV settings.
        pxr::TfTokenVector GetRendererAovs() const;

        /// Set the current renderer AOV to \p id.
        bool SetRendererAov(const pxr::TfToken& id);

        /// Set the current renderer AOVs to a list of \p ids.
        bool SetRendererAovs(const pxr::TfTokenVector& ids);

        /// Returns an AOV testure handle for the given token.
        pxr::HgiTextureHandle GetAovTexture(const pxr::TfToken& name) const;

        /// Returns the AOV render buffer for the given token.
        pxr::HdRenderBuffer* GetAovRenderBuffer(const pxr::TfToken& name) const;
    
        // ---------------------------------------------------------------------
        /// \name Render Settings (Legacy)
        /// @{
        // ---------------------------------------------------------------------

        /// Returns the list of renderer settings.
        pxr::UsdImagingGLRendererSettingsList GetRendererSettingsList() const;

        /// Gets a renderer setting's current value.
        pxr::VtValue GetRendererSetting(const pxr::TfToken& id) const;

        /// Sets a renderer setting's value.
        void SetRendererSetting(const pxr::TfToken& id,
                                const pxr::VtValue& value);

        /// @}

        // ---------------------------------------------------------------------
        /// \name Scene-defined Render Pass and Render Settings
        /// \note Support is WPI.
        /// @{
        // ---------------------------------------------------------------------

        /// Set active render pass prim to use to drive rendering.
        void SetActiveRenderPassPrimPath(const pxr::SdfPath& path);

        /// Set active render settings prim to use to drive rendering.
        void SetActiveRenderSettingsPrimPath(const pxr::SdfPath& path);

        /// Utility method to query available render settings prims.
        static pxr::SdfPathVector GetAvailableRenderSettingsPrimPaths(const pxr::UsdPrim& root);
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Presentation
        /// @{
        // ---------------------------------------------------------------------

        /// Enable / disable presenting the render to bound framebuffer.
        /// An application may choose to manage the AOVs that are rendered into
        /// itself and skip the engine's presentation.
        void SetEnablePresentation(bool enabled);

        /// The destination API (e.g., OpenGL, see hgiInterop for details) and
        /// framebuffer that the AOVs are presented into. The framebuffer
        /// is a VtValue that encoding a framebuffer in a destination API
        /// specific way.
        /// E.g., a uint32_t (aka GLuint) for framebuffer object for OpenGL.
        void SetPresentationOutput(const pxr::TfToken& api, const pxr::VtValue& framebuffer);
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Renderer Command API
        /// @{
        // ---------------------------------------------------------------------

        /// Return command descriptors for commands supported by the active
        /// render delegate.
        ///
        pxr::HdCommandDescriptors GetRendererCommandDescriptors() const;

        /// Invokes command on the active render delegate. If successful, returns
        /// \c true, returns \c false otherwise. Note that the command will not
        /// succeed if it is not among those returned by
        /// GetRendererCommandDescriptors() for the same active render delegate.
        ///
        bool InvokeRendererCommand(const pxr::TfToken& command,
                                   const pxr::HdCommandArgs& args = pxr::HdCommandArgs()) const;
    
        // ---------------------------------------------------------------------
        /// \name Control of background rendering threads.
        /// @{
        // ---------------------------------------------------------------------

        /// Query the renderer as to whether it supports pausing and resuming.
        bool IsPauseRendererSupported() const;

        /// Pause the renderer.
        ///
        /// Returns \c true if successful.
        bool PauseRenderer();

        /// Resume the renderer.
        ///
        /// Returns \c true if successful.
        bool ResumeRenderer();

        /// Query the renderer as to whether it supports stopping and restarting.
        bool IsStopRendererSupported() const;

        /// Stop the renderer.
        ///
        /// Returns \c true if successful.
        bool StopRenderer();

        /// Restart the renderer.
        ///
        /// Returns \c true if successful.
        bool RestartRenderer();
    
        /// @}

        // ---------------------------------------------------------------------
        /// \name Color Correction
        /// @{
        // ---------------------------------------------------------------------

        /// Set \p ccType to one of the HdxColorCorrectionTokens:
        /// {disabled, sRGB, openColorIO}
        ///
        /// If 'openColorIO' is used, \p ocioDisplay, \p ocioView, \p ocioColorSpace
        /// and \p ocioLook are options the client may supply to configure OCIO.
        /// \p ocioColorSpace refers to the input (source) color space.
        /// The default value is substituted if an option isn't specified.
        /// You can find the values for these strings inside the
        /// profile/config .ocio file. For example:
        ///
        ///  displays:
        ///    rec709g22:
        ///      !<View> {name: studio, colorspace: linear, looks: studio_65_lg2}
        ///
        void SetColorCorrectionSettings(const pxr::TfToken& ccType,
                                        const pxr::TfToken& ocioDisplay = {},
                                        const pxr::TfToken& ocioView = {},
                                        const pxr::TfToken& ocioColorSpace = {},
                                        const pxr::TfToken& ocioLook = {});

        /// @}

        /// Returns true if the platform is color correction capable.
        static bool IsColorCorrectionCapable();
    
        // ---------------------------------------------------------------------
        /// \name Render Statistics
        /// @{
        // ---------------------------------------------------------------------

        /// Returns render statistics.
        ///
        /// The contents of the dictionary will depend on the current render
        /// delegate.
        ///
        pxr::VtDictionary GetRenderStats() const;

        /// @}

        // ---------------------------------------------------------------------
        /// \name HGI
        /// @{
        // ---------------------------------------------------------------------

        /// Returns the HGI interface.
        ///
        pxr::Hgi* GetHgi();

        /// @}

        // ---------------------------------------------------------------------
        /// \name Asynchronous
        /// @{
        // ---------------------------------------------------------------------

        /// If \p allowAsynchronousSceneProcessing is true within the Parameters
        /// provided to the UsdImagingGLEngine constructor, an application can
        /// periodically call this from the main thread.
        ///
        /// A return value of true indicates that the scene has changed and the
        /// render should be updated.
        bool PollForAsynchronousUpdates() const;

        /// MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor
        UsdImagingGLEngineWrapper(std::shared_ptr<pxr::UsdImagingGLEngine> impl);

        /// Gets the underlying UsdImagingGLEngine instance
        pxr::UsdImagingGLEngine*_Nullable get() const;

        /// Gets the underlying UsdImagingGLEngine instance
        std::shared_ptr<pxr::UsdImagingGLEngine> get_shared() const;

        /// Returns `true` iff the underlying instance is valid
        explicit operator bool() const;
    
    private:
        std::shared_ptr<pxr::UsdImagingGLEngine> _impl;
    };
}

#endif // #if SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT

#endif /* SWIFTUSD_WRAPPERS_USDIMAGINGGLENGINEWRAPPER_H */

