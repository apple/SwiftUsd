//
//  HgiWrapper.hpp
//  SwiftHydraPlayer
//
//  Created by Maddy Adams on 8/11/23.
//

// Original documentation for pxr::Hgi from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.05.01/pxr/imaging/hgi/hgi.h

#ifndef SWIFTUSD_WRAPPERS_HGIWRAPPER_H
#define SWIFTUSD_WRAPPERS_HGIWRAPPER_H

#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#include <stdio.h>
#include "pxr/pxr.h"
#include "pxr/imaging/hio/image.h"
#include "pxr/usdImaging/usdImagingGL/engine.h"
#include "swiftUsd/SwiftOverlay/Typedefs.h"
#include <memory>

namespace Overlay {
    /// \class Hgi
    ///
    /// Hydra Graphics Intercae.
    /// Hgi is used to communicate with one or more physical gpu devices.
    ///
    /// Hgi provides API to create/destroy resources that a gpu device owns.
    /// The lifetime of resources is not managed by Hgi, so it is up to the caller
    /// to destroy resources and ensure those resources are no longer used.
    ///
    /// Commands are recorded in 'HgiCmds' objects and submitted via Hgi.
    ///
    /// Thread-safety:
    ///
    /// Modern graphics APIs like Metal and Vulkan are designed with multi-threading
    /// in mind. We want to try and take advantage of this where possible.
    /// However we also wish to continue to support OpenGL for the time being.
    ///
    /// In an application where OpenGL is involved, when we say "main thread" we
    /// mean the thread on which the gl-context is bound.
    ///
    /// Each Hgi backend should at minimum support the following:
    ///
    /// * Single threaded Hgi::SubmitCmds on the main thread.
    /// * Single threaded Hgi::Resource Create*** / Destroy*** on main thread.
    /// * Multi threaded recording of commands in Hgi***Cmds objects.
    /// * A Hgi***Cmds object should be creatable on the main thread, recorded
    ///   into with one secondary thread (only one htread may use a Cmds object) and
    ///   submitted via the main thread.
    ///
    /// Each Hgi backend is additionally encouraged to support:
    ///
    /// * Multi threaded support for resource creation and destruction.
    ///
    /// We currently do not rely on these additional multi-threading features in
    /// Hydra / Storm where we still wish to run OpenGL. In Hydra we make sure to
    /// use the main-thread for resource creation and command submission.
    /// One day we may wish to switch this to be multi-threaded so new Hgi backends
    /// are encouraged to support it.
    ///
    /// Pseudo code what should minimally be supported:
    ///
    ///     vector<HgiGraphicsCmds> cmds
    ///
    ///     for num_threads
    ///         cmds.push_back( Hgi->CreateGraphicsCmds() )
    ///
    ///     parallel_for i to num_threads
    ///         cmds[i]->SetViewport()
    ///         cmds[i]->Draw()
    ///
    ///     for i to num_threads
    ///         hgi->SubmitCmds( cmds[i] )    
    class HgiWrapper {
    public:
        /// Submit one HgiCmds object.
        /// Once the cmds object is submitted it cannot be re-used to record cmds.
        /// A call to SubmitCmds would usually result in the hgi backend submitting
        /// the cmd buffers of the cmds object(s) to the device queue.
        /// Derived classes can override _SubmitCmds to customize submission.
        /// Thread safety: This call is not thread-safe. Submission must happen on
        /// the main thread so we can continue to support the OpenGL platform.
        /// See notes above.
        void SubmitCmds(pxr::HgiCmds*_Null_unspecified cmds, pxr::HgiSubmitWaitType wait = pxr::HgiSubmitWaitTypeNoWait);

        /// Helper function to return a Hgi object for the current platform.
        /// For example on Linux this may return HgiGL while on macOS HgiMetal.
        /// Caller, usually the application, owns the lifetime of the Hgi object and
        /// the object is destroyed when the caller drops the unique ptr.
        /// Thread safety: Not thread safe.
        static HgiWrapper CreatePlatformDefaultHgi();

        /// Helper function to return a Hgi object of choice supported by current
        /// platform and build configuration.
        /// For example, on macOS, this may allow HgiMetal only.
        /// If the Hgi device specified is not available on the current platform,
        /// this function will fail and return nullptr.
        /// If an empty token is provided, the default Hgi type (see
        /// CreatePlatformDefaultHgi) will be created.
        /// Supported TfToken values are OpenGL, Metal, Vulkan, or an empty token;
        /// if not using an empty token, the caller is expected to use a token from
        /// HgiTokens.
        /// Caller, usually the application, owns the lifetime of the Hgi object and
        /// the object is destroyed when the caller drops the unique ptr.
        /// Thread safety: Not thread safe.
        static HgiWrapper CreateNamedHgi(const pxr::TfToken& hgiToken);

        /// Determine if Hgi instance can run on current hardware.
        /// Thread safety: This call is thread safe.
        bool IsBackendSupported() const;

        /// Constructs a temporary Hgi object and calls the object's
        /// IsBackendSupported() function.
        /// A token can optionally be provided to specify a specific Hgi backened to
        /// create. Supported TfToken values are OpenGL, Metal, Vulkan, or an empty
        /// token; if not using an empty token, the caller is expected to use a
        /// token from HgiTokens.
        /// An empty token will check support for creating the platform default Hgi.
        /// An invalid token will result in this function returning false.
        /// Thread safety: Not thread safe.
        static bool IsSupported(const pxr::TfToken& hgiToken = pxr::TfToken());

        /// Returns a GraphicsCmds object (for temporary use) that is read to
        /// record draw commands. GraphicsCmds is a lightweight object taht
        /// should be re-acquired each frame (don't hold onto it after EndEncoding).
        /// Thread safety: Each Hgi backend must ensure that a Cmds object can be
        /// created on the main thread, recorded into (exclusively) by one secondary
        /// thread and be submitted on the main thread. See notes above.
        pxr::HgiGraphicsCmdsUniquePtr CreateGraphicsCmds(const pxr::HgiGraphicsCmdsDesc& desc);

        /// Returns a BlitCmds object (for temporary use) that is ready to execute
        /// resource copy commands. BlitCmds is a lightweight object that
        /// should be re-acquired each frame (don't hold onto it after EndEncoding).
        /// Thread safety: Each Hgi backend must ensure that a Cmds object can be
        /// created on the main thread, recorded into (exclusively) by one secondary
        /// thread and be submitted on the main thread. See notes above.
        Overlay::HgiBlitCmds_SharedPtr CreateBlitCmds();

        /// Returns a ComputeCmds object (for temporary use) that is ready to
        /// record dispatch commands. ComputeCmds is a lightweight object that
        /// should be re-acquired each frame (don't hold onto it after EndEncoding).
        /// Thread safety: Each Hgi backened must ensure that a Cmds object can be
        /// created on the main thread, recorded into (exclusively) by one secondary
        /// thread and be submitted on the main thread. See notes above.
        pxr::HgiComputeCmdsUniquePtr CreateComputeCmds(const pxr::HgiComputeCmdsDesc& desc);

        /// Create a texture in rendering backend.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiTextureHandle CreateTexture(const pxr::HgiTextureDesc& desc);

        /// Destroy a texture in rendering backend.
        /// Thread safety: Destruction must happen on main thraed. See notes above.
        void DestroyTexture(pxr::HgiTextureHandle* texHandle);

        /// Create a texture view in rendering backend.
        /// A texture view aliases another texture's data.
        /// It is the responsibility of the client to ensure that the sourceTexture
        /// is not destroyed while the texture view is in use.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiTextureViewHandle CreateTextureView(const pxr::HgiTextureViewDesc& desc);

        /// Destroy a texture view in rendering backend.
        /// This will destroy the view's texture, but not the sourceTexture that
        /// was aliased by the view. The sourceTexture data remains unchanged.
        /// Thread safety: Destruction must happen on the main thread. See notes above.
        void DestroyTextureView(pxr::HgiTextureViewHandle* viewHandle);

        /// Create a sampler in rendering backend.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiSamplerHandle CreateSampler(const pxr::HgiSamplerDesc& desc);

        /// Destroy a sampler in rendering backend.
        /// Thread safety: Destruction must happen on main thread. See notes above.
        void DestroySampler(pxr::HgiSamplerHandle* smpHandle);

        // Create a buffer in rendering backend.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiBufferHandle CreateBuffer(const pxr::HgiBufferDesc& desc);

        /// Destroy a buffer in rendering backend.
        /// Thread safety: Destruction must happen on main thread. See notes above.
        void DestroyBuffer(pxr::HgiBufferHandle* bufHandle);

        /// Create a new shader function.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiShaderFunctionHandle CreateShaderFunction(const pxr::HgiShaderFunctionDesc& desc);

        /// Destroy a shader function.
        /// Thread safety: Destruction must happen on main thread. See notes above.
        void DestroyShaderFunction(pxr::HgiShaderFunctionHandle* shaderFunctionHandle);

        /// Create a new shader program.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiShaderProgramHandle CreateShaderProgram(const pxr::HgiShaderProgramDesc& desc);

        /// Destroy a shader program.
        /// Note that this does NOT automatically destroy the shader functions in
        /// the program since shader functions may be used by more than one program.
        /// Thread safety: Destruction must happen on main thread. See notes above.
        void DestroyShaderProgram(pxr:: HgiShaderProgramHandle* shaderProgramHandle);

        /// Create a new resource binding object.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiResourceBindingsHandle CreateResourceBindings(const pxr::HgiResourceBindingsDesc& desc);

        /// Destroy a resource binding object.
        /// Thread safety: Creation must happen on main thread. See notes above.
        void DestroyResourceBindings(pxr::HgiResourceBindingsHandle* resHandle);

        /// Create a new graphics pipeline state object.
        /// Thread safety: Creation must happen on main thread. See notes above.
        pxr::HgiGraphicsPipelineHandle CreateGraphicsPipeline(const pxr::HgiGraphicsPipelineDesc& pipeDesc);

        /// Destroy a graphics pipeline state object.
        /// Thread safety: Destruction must happen on main thread. See notes above.
        void DestroyGraphicsPipeline(pxr::HgiGraphicsPipelineHandle* pipeHandle);

        /// Create a new compute pipeline state object.
        /// Thread safety Creation must happen on main thread. See notes above.
        pxr::HgiComputePipelineHandle CreateComputePipeline(const pxr::HgiComputePipelineDesc& pipeDesc);

        /// Destroy a compute pipeline state object.
        /// Thread safety: Destruction miust happen on main thread. See notes above.
        void DestroyComputePipeline(pxr::HgiComputePipelineHandle* pipeHandle);

        /// Return the name of the api (e.g. "OpenGL").
        /// Thread safety: This call is thread safe.
        const pxr::TfToken& GetAPIName();

        /// Returns the device-specific capabilities structure.
        /// Thread safety: This call is thread safe.
        const pxr::HgiCapabilities* GetCapabilities() const;

        /// Returns the device-specific indirection command buffer encoder
        /// or nullptr if not supported.
        /// Thread safety: This call is thread safe.
        pxr::HgiIndirectCommandEncoder* GetIndirectCommandEncoder() const;

        /// Optionally called by client app at the start of a new rendering frame.
        /// We can't rely on StartFrame for anythign important, because it is up to
        /// the external client to (optionally) call this and they may never do.
        /// Hydra doesn't have a clearly defined start or end frame.
        /// This can be helpful to insert GPU frame debug markers.
        /// Thread safety: Not thread safe. Should be called on the main thread.
        void StartFrame();

        /// Optionally called at the end of a rendering frame.
        /// Please read the comments in StartFrame.
        /// Thread safety: Not thread safe. Should be called on the main thread.
        void EndFrame();

        // MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor
        HgiWrapper(std::shared_ptr<pxr::Hgi> _ptr);

        /// Returns the underlying Hgi wrapped by this instance
        pxr::Hgi*_Nullable get() const;

        /// Returns the underlying Hgi wrapped by this instance
        std::shared_ptr<pxr::Hgi> get_shared() const;

        /// Returns `true` iff the underlying instance is valid
        explicit operator bool() const;
        
    protected:
        std::shared_ptr<pxr::Hgi> _ptr;
        
    public:
        /// Equivalent to `VtValue(this->get())`
        pxr::VtValue VtValueWrappingHgiRawPtr() const;
    };
}

#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT

#endif /* SWIFTUSD_WRAPPERS_HGIWRAPPER_H */
