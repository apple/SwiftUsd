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

// Original documentation for pxr::ArResolver from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/usd/ar/resolver.h

#ifndef SWIFTUSD_WRAPPERS_ARRESOLVERWRAPPER_H
#define SWIFTUSD_WRAPPERS_ARRESOLVERWRAPPER_H

#include "pxr/usd/ar/resolver.h"
#include <memory>
#include <vector>

namespace Overlay {
    class ArResolverWrapper;
}

namespace __Overlay {
    // https://github.com/swiftlang/swift/issues/83085 (Calling friend function of type nested in C++ namespace crashes Swift compiler)
    Overlay::ArResolverWrapper ArGetResolver_friend();
    Overlay::ArResolverWrapper ArGetUnderlyingResolver_friend();
    Overlay::ArResolverWrapper ArCreateResolver_friend(const pxr::TfType& resolverType);
}

namespace Overlay {
    /// \class ArResolver
    ///
    /// Interface for the asset resolution system. An asset resolver is
    /// responsible for resolving asset information (including the asset's
    /// physical path) from a logical path.
    ///
    /// See \ref ar_implementing_resolver for information on how to customize
    /// asset resolution behavior by implementing a subclass of ArResolver.
    /// Cllients may use #ArGetResolver to access the configured asset resolver.
    ///
    class ArResolverWrapper {
    public:
        // --------------------------------------------------------------------- //
        /// \anchor ArResolver_identifier
        /// \name Identifiers
        ///
        /// Identifiers are canonicalized asset paths that may be assigned
        /// to a logical asset to facilitate comparisons and lookups. They
        /// may be used to determine if different asset paths might refer to
        /// the same asset without performing resolution.
        ///
        /// Since identifiers are just a form of asset path, they may be used
        /// with other functions on ArResolver that require an asset path, like
        /// Resolver.
        ///
        /// If two asset paths produce the same identifier, those asset paths
        /// must refer to the same asset. However, in some cases comparing
        /// identifiers may not be sufficient to determine if assets are equal.
        /// For example, there could be two assets with the same identifier
        /// but whose contents were read from different resolved paths because
        /// different resolver contexts where bound when those assets were loaded.
        ///
        /// @{
        // --------------------------------------------------------------------- //

        /// Returns an identifier for the asset specified by \p assetPath.
        // /If \p anchorAssetPath is not empty, it is the resolved asset path
        /// that \p assetPath should be anchored to if it is a relative path.
        std::string CreateIdentifier(
            const std::string& assetPath,
            const pxr::ArResolvedPath& anchorAssetPath = pxr::ArResolvedPath()) const;

        /// Returns an identifier for a new asset specified by \p assetPath.
        /// If \p anchorAssetPath is not empty, it is the resolved asset path
        /// that \p assetPath should be anchored to if it is a relative path.
        std::string CreateIdentifierForNewAsset(
            const std::string& assetPath,
            const pxr::ArResolvedPath& anchorAssetPath = pxr::ArResolvedPath()) const;

        /// @}

        // --------------------------------------------------------------------- //
        /// \anchor ArResolver_resolution
        /// \name Path Resolution Operations
        ///
        /// @{
        // --------------------------------------------------------------------- //

        /// Returns the resolved path for the asset identified by the given \p
        /// assetPath if it exists. If the asset does not exist, returns an empty
        /// ArResolvedPath.
        pxr::ArResolvedPath Resolve(
            const std::string& assetPath) const;

        /// Returns the resolved path for the given \p assetPath that may be used
        /// to create a new asset. If such a path cannot be computed for
        /// \p assetPath, returns an empty ArResolvedPath.
        ///
        /// Note that an asset might or might not already exist at the returned
        /// resolved path.
        pxr::ArResolvedPath ResolveForNewAsset(
            const std::string& assetPath) const;

        /// @}

        // --------------------------------------------------------------------- //
        /// \anchor ArResolver_context
        /// \name Asset Resolver Context Operations
        ///
        /// @{
        // --------------------------------------------------------------------- //

        /// Binds the given context to this resolver.
        ///
        /// Clients should generally use ArResolverContextBinder instead of calling
        /// this function directly.
        ///
        /// \see ArResolverContextBinder
        void BindContext(
            const pxr::ArResolverContext& context,
            pxr::VtValue* bindingData);

        /// Unbind the given context from this resolver.
        ///
        /// Clients should generally use ArResolverContextBinder instead of calling
        /// this function directly.
        ///
        /// \see ArResolverContextBinder
        void UnbindContext(
            const pxr::ArResolverContext& context,
            pxr::VtValue* bindingData);

        /// Return an ArResolverContext that may be bound to this resolver
        /// to resolve assets when no other context is explicitly specified.
        ///
        /// The returned ArResolverContext will contain the default context
        /// returned by the primary resolver and all URI/IRI resolvers.
        pxr::ArResolverContext CreateDefaultContext() const;

        /// Return an ArResolverContext that may be bound to this resolver
        /// to resolve the asset located at \p assetPath or referenced by
        /// that asset when no other context is explicitly specified.
        ///
        /// The returned ArResolverContext will contain the default context
        /// for \p assetPath returned by the primary resolver and all URI/IRI
        /// resolvers.
        pxr::ArResolverContext CreateDefaultContextForAsset(
            const std::string& assetPath) const;

        /// Return an ArResolverContext created from the primary ArResolver
        /// implementation using the given \p contextStr.
        pxr::ArResolverContext CreateContextFromString(
            const std::string& contextStr) const;

        /// Return an ArResolverContext created from the ArResolver registered
        /// for the given \p uriScheme using the given \p contextStr.
        ///
        /// An empty \p uriScheme indicates the primary resolver and is
        /// equivalent to CreateContextFromString(string).
        ///
        /// If no resolver is registered for \p uriScheme, returns an empty
        /// ArResolverContext.
        ///
        /// \note 'uriScheme' can be used to register IRI resolvers
        pxr::ArResolverContext CreateContextFromString(
            const std::string& uriScheme, const std::string& contextStr) const;

        /// Return an ArResolverContext created by combining the ArResolverContext
        /// objects created from the given \p contextStrs.
        ///
        /// \p contextStrs is a list of pairs of strings. The first element in the
        /// pair is the URI/IRI scheme for the ArResolver that will be used to
        /// create the ArResolverContext from the second element in the pair. An
        /// empty resource identifier scheme indicates the primary resolver.
        ///
        /// For example:
        ///
        /// \code
        /// ArResolverContext ctx = ArGetResolver().CreateContextFromStrings(
        ///    { {"", "context str 1"},
        ///      {"my-scheme", "context str 2"} });
        /// \endcode
        ///
        /// This will use the primary resolver to create an ArResolverContext
        /// using the string "context str 1" and use the resolver registered for
        // the "my-scheme" URI/IRI scheme to create an ArResolverContext using
        /// "context str 2". These contents will be combined into a single
        /// ArResolverContext and returned.
        ///
        /// If no resolver is registered for a URI/IRI scheme in an entry in
        /// \p contextStrs, that entry will be ignored.
        pxr::ArResolverContext CreateContextFromStrings(
            const std::vector<
                std::pair<std::string, std::string>>& contextStrs) const;
        
        /// Refresh any caches associated with the given context. If doing so
        /// would invalidate asset paths that had previously been resolved,
        /// an ArNotice::ResolverChanged notice will be sent to inform clients
        /// of this.
        ///
        /// Avoid calling RefreshContext() on the same context from more than one
        /// thread concurrently as ArNotice::ResolverChanged notice listeners may
        /// mutate their state in response to receiving the notice.
        ///
        /// Avoid calling RefreshContext() with a context that is active (bound to
        /// a resolver). Unbind the context before refreshing it.
        ///
        /// \see \ref Usd_Page_MultiThreading "Threading Model and Performance Considerations"
        void RefreshContext(
            const pxr::ArResolverContext& context);

        /// Returns the asset resolver context currently bound in this thread.
        ///
        /// \see ArResolver::BindContext, ArResolver::UnbindContext
        pxr::ArResolverContext GetCurrentContext() const;

        /// Returns true if \p assetPath is a context-dependent path, false
        /// otherwise.
        ///
        /// A context-dependent path may result in different resolved paths
        /// depending on what asset resolver context is bound when Resolve
        /// is called. Assets located at the same context-dependent path may not
        /// be the same since those assets may have been loaded from different
        /// resolved paths. In this case, the assets' resolved paths must be
        /// consulted to determine if they are the same.
        bool IsContextDependentPath(
            const std::string& assetPath) const;

        /// @}

        // --------------------------------------------------------------------- //
        /// \anchor ArResolver_files
        /// \name File/asset-specific Operations
        ///
        /// @{
        // --------------------------------------------------------------------- //

        /// Returns the file extension for the given \p assetPath. The returned
        /// extension does not include a "." at the beginning.
        std::string GetExtension(
            const std::string& assetPath) const;

        /// Returns an ArAssetInfo populated with additional metadata (if any)
        /// about the asset at the given \p assetPath. \p resolvedPath is the
        /// resolved path computed for the given \p assetPath.
        pxr::ArAssetInfo GetAssetInfo(
            const std::string& assetPath,
            const pxr::ArResolvedPath& resolvedPath) const;

        /// Returns an ArTimestamp representing the last time the asset at
        /// \p assetPath was modified. \p resolvedPath is the resolved path
        /// computed for the given \p assetPath. If a timestamp cannot be
        /// retrieved, return an invalid ArTimestamp.
        pxr::ArTimestamp GetModificationTimestamp(
            const std::string& assetPath,
            const pxr::ArResolvedPath& resolvedPath) const;

        /// Returns an ArAsset object for the asset located at \p resolvedPath.
        /// Returns an invalid std::shared_ptr if object could not be created.
        ///
        /// The returned ArAsset object provides functions for accessing the
        /// contents of the specified asset.
        std::shared_ptr<pxr::ArAsset> OpenAsset(
            const pxr::ArResolvedPath& resolvedPath) const;

        /// Enumeration of write modes for OpenAssetForWrite
        enum class WriteMode
        {
            /// Open asset for in-place updates. If the asset exists, its contents
            /// will not be discarded and writes may overwrite existing data.
            /// Otherwise, the asset will be created.
            Update = 0,

            /// Open asset for replacement. If the asset exists, its contents will
            /// be discared by the time ArWritableAsset is destroyed.
            /// Otherwise, the asset will be created.
            Replace
        };

        /// Returns an ArWritableAsset object for the asset located at \p
        /// resolvedPath using the specified \p writeMode. Returns an invalid
        /// std::shared_ptr if object could not be created.
        ///
        /// The returned ArWritableAsset object provides functions for writing data
        /// to the specified asset.
        ///
        /// Note that support for reading an asset through other APIs while it
        // is open for write is implementation-specific. For example, writes to
        /// an asset may or may not be immediately visible to other threads or
        /// processes depending on the implementation.
        std::shared_ptr<pxr::ArWritableAsset> OpenAssetForWrite(
            const pxr::ArResolvedPath& resolvedPath,
            WriteMode writeMode) const;

        /// Returns true if an asset may be written to the given \p resolvedPath,
        /// false otherwise. If this function returns false and \p whyNot is not
        /// \c nullptr, it may be filled with an explanation.
        bool CanWriteAssetToPath(
            const pxr::ArResolvedPath& resolvedPath,
            std::string* whyNot = nullptr) const;

        /// @}

        // --------------------------------------------------------------------- //
        /// \anchor ArResolver_scopedCache
        /// \name Scoped Resolution Cache
        ///
        /// A scoped resolution cache indicates to the resolver that results of
        /// calls to Resolve should be cached for a certain scope. This is
        /// important for performance and also for consistency -- it ensures
        /// that repeated calls to Resolve with the same parameters will
        /// return the same result.
        ///
        /// A resolution cache scope is opened by a call to BeginCacheScope and
        /// must be closed with a matching call to EndCacheScope. The resolver must
        /// cache the results of Resolve until the scope is closed. Note that these
        /// calls may be nested.
        ///
        /// Cache scopes are thread-specific: if multiple threads are running and
        /// a cache scope is opened in one of those threads, caching should be
        /// enabled in that thread only.
        ///
        /// When opening a scope, a resolver may return additional data for
        /// implementation-specific purposes. This data may be shared across
        /// threads, so long as it is safe to access this data concurrently.
        ///
        /// When opening a scope, a resolver may return additional data for
        /// implementaiton-specific purposes. This data may be shared across
        /// threads, so long as it is safe to access this data concurrently.
        ///
        /// ArResolverScopedCache is an RAIII object for managing cache scope
        /// lifetimes and data. Clients should generally use that class rather
        /// than calling the BeginCacheScope and EndCacheScope functions manually.
        ///
        /// \see ArResolverScopedCache
        /// @{
        // --------------------------------------------------------------------- //

        /// Mark the start of a resolution caching scope.
        ///
        /// Clients should generally use ArResolverScopedCache instead of calling
        /// this function directly.
        ///
        /// Resolvers may fill \p cacheScopeData with arbitrary data. Clients may
        /// also pass in a \p cacheScopeData populated by an earlier call to
        /// BeginCacheScope to allow the resolver access to that information.
        ///
        /// \see ArResolverScopedCache
        void BeginCacheScope(
             pxr::VtValue* cacheScopeData);

        /// Mark the end of a resolution caching scope.
        ///
        /// Clients should generally use ArResolverScopedCache instead of calling
        /// this function directly.
        ///
        /// \p cacheScopeData should contain the data that was populated by the
        /// previous corresponding call to BeginScopeCache.
        ///
        /// \see ArResolverScopedCache
        void EndCacheScope(
             pxr::VtValue* cacheScopeData);

        /// @}

        // --------------------------------------------------------------------- //
        /// \anchor ArResolver_deprecated
        /// \name Deprecated APIs
        ///
        /// The functions in this section are deprecated in Ar 2.0 and slated
        /// for removal. Most have default implementaitons to allow subclasses
        /// to ignore them completely.
        ///
        /// @{
        // --------------------------------------------------------------------- //

        /// \deprecated
        /// Returns true if the given path is a repository path.
        bool IsRepositoryPath(const std::string& path) const;

        // MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor. The caller is responsible for ownership
        /// of the parameter
        ArResolverWrapper(pxr::ArResolver*_Nullable unowned);
        
        /// SwiftUsd wrapping constructor
        ArResolverWrapper(std::shared_ptr<pxr::ArResolver> shared);

        /// Returns the underlying ArResolver wrapped by this instance. May have been acquired
        /// using ArGetResolver(), ArGetUnderlyingResolver(), or ArCreateResolver()
        pxr::ArResolver*_Nullable get() const;

        /// If the ArResolver wrapped by this instance was acquired using ArGetResolver() or
        /// ArGetUnderlyingResolver(), returns the resolver. Otherwise returns null
        std::shared_ptr<pxr::ArResolver> get_shared() const;

        /// Returns `true` iff this wrapper holds an ArResolver instance.
        /// Note that `operator bool()` may return true even if `get_shared()`
        /// returns null; in that case, the ArResolver may have been acquired
        /// via `ArCreateResolver()`, and `get()` may return non-null
        explicit operator bool() const;


    public:
        friend ArResolverWrapper __Overlay::ArGetResolver_friend();
        friend ArResolverWrapper __Overlay::ArGetUnderlyingResolver_friend();
        friend ArResolverWrapper __Overlay::ArCreateResolver_friend(const pxr::TfType& resolverType);
        
        // Only one of these should be non-null at a time.
        // ArGetResolver() returns ArResolver&, but
        // ArCreateResolver() returns unique_ptr<ArResolver>.
        // So, we need to be able to handle both of those.
        // Also, use shared_ptr so that we're copyable,
        // because ~Copyables are harder to use in Swift
        
        pxr::ArResolver*_Nullable _unownedPtr;
        std::shared_ptr<pxr::ArResolver> _ownedPtr;
    };

    /// Returns the configured asset resolver.
    ///
    /// When first called, this function will determine the ArResolver subclass
    /// to use for asset resolution via the following process:
    ///
    /// - If a preferred resolver has been set via \ref ArSetPreferredResolver,
    ///   it will be selected.
    ///
    /// - Otherwise, a list of available ArResolver subclasses in plugins will
    ///   be generated. If multiple ArResolver subclasses are found, the list
    ///   will be sorted by typename. ArDefaultResolver will be added as the last
    ///   element of this list, and the first resolver in the list will be
    ///   selected.
    ///
    /// - The plugin for the selected subclass will be loaded and an instance
    ///   of the subclass will be constructed.
    ///
    /// - If an error occurs, an ArDefaultResolver will be constructed.
    ///
    /// The constructed ArResolver subclass will be cached and used to service
    /// function calls made on the returned resolver.
    ///
    /// Note that this function may not return the constructed subclass itself,
    /// meaning that dynamic casts to the subclass type may fail. See
    /// ArGetUnderlyingResolver if access to this object is needed.
    ArResolverWrapper ArGetResolver();

    /// \name Advanced API
    ///
    /// \warning These functions should typically not be used by consumers except
    /// in very specific cases. Consumers who want to retrieve an ArResolver to
    /// perform asset resolution should use \ref ArGetResolver.
    ///
    /// @{    

    /// Returns the underlying ArResolver instance used by ArGetResolver.
    ///
    /// This function returns the instance of the ArResolver subclass used by
    /// ArGetResolver and can be dynamic_cast to that type.
    ///
    /// \warning This function should typically not be used by consumers except
    /// in very specific cases. Consumers who want to retrieve an ArResolver to
    /// perform asset resolution should use \ref ArGetResolver.
    ArResolverWrapper ArGetUnderlyingResolver();

    /// Construct an instance of the ArResolver subclass specified by
    /// \p resolverType.
    ///
    /// This function will loade the plugin for the given \p resolverType and
    /// construct and return a new instance of the specified ArResolver subclass.
    /// If an error occurs, coding errors will be emitted and this function
    /// will return an ArDefaultResolver instance.
    ///
    /// Note that this function *does not* change the resolver used by
    /// \ref ArGetResolver to an instance of \p resolverType.
    ///
    /// This function is not safe to call concurrently with itself or
    /// \ref ArGetAvailableResolvers.
    ///
    /// \warning This function should typically not be used by consumers except
    /// in very specific cases. Consumers who want to retrieve an ArResolver to
    /// perform asset resolution should use \ref ArGetResolver.
    ArResolverWrapper ArCreateResolver(const pxr::TfType& resolverType);

    /// @}
}

#endif /* SWIFTUSD_WRAPPERS_ARRESOLVERWRAPPER_H */
