//
//  ArResolverWrapper.cpp
//  SwiftUsd
//
//  Created by Maddy Adams on 4/17/25.
//

#include "swiftUsd/Wrappers/ArResolverWrapper.h"
#include "pxr/usd/ar/assetInfo.h"
#include "pxr/usd/ar/asset.h"

std::string Overlay::ArResolverWrapper::CreateIdentifier(const std::string& assetPath,
                                                         const pxr::ArResolvedPath& anchorAssetPath) const {
    return get()->CreateIdentifier(assetPath, anchorAssetPath);
}

std::string Overlay::ArResolverWrapper::CreateIdentifierForNewAsset(const std::string& assetPath,
                                                                    const pxr::ArResolvedPath& anchorAssetPath) const {
    return get()->CreateIdentifierForNewAsset(assetPath, anchorAssetPath);
}

pxr::ArResolvedPath Overlay::ArResolverWrapper::Resolve(const std::string& assetPath) const {
    return get()->Resolve(assetPath);
}

pxr::ArResolvedPath Overlay::ArResolverWrapper::ResolveForNewAsset(const std::string& assetPath) const {
    return get()->ResolveForNewAsset(assetPath);
}

void Overlay::ArResolverWrapper::BindContext(const pxr::ArResolverContext& context,
                                             pxr::VtValue* bindingData) {
    return get()->BindContext(context, bindingData);
}

void Overlay::ArResolverWrapper::UnbindContext(const pxr::ArResolverContext& context,
                                               pxr::VtValue* bindingData) {
    return get()->UnbindContext(context, bindingData);
}

pxr::ArResolverContext Overlay::ArResolverWrapper::CreateDefaultContext() const {
    return get()->CreateDefaultContext();
}

pxr::ArResolverContext Overlay::ArResolverWrapper::CreateDefaultContextForAsset(const std::string& assetPath) const {
    return get()->CreateDefaultContextForAsset(assetPath);
}

pxr::ArResolverContext Overlay::ArResolverWrapper::CreateContextFromString(const std::string& contextStr) const {
    return get()->CreateContextFromString(contextStr);
}

pxr::ArResolverContext Overlay::ArResolverWrapper::CreateContextFromString(const std::string& uriScheme,
                                                                           const std::string& contextStr) const {
    return get()->CreateContextFromString(uriScheme, contextStr);
}

pxr::ArResolverContext Overlay::ArResolverWrapper::CreateContextFromStrings(const std::vector<std::pair<std::string, std::string>>& contextStrs) const {
    return get()->CreateContextFromStrings(contextStrs);
}

void Overlay::ArResolverWrapper::RefreshContext(const pxr::ArResolverContext& context) {
    return get()->RefreshContext(context);
}

pxr::ArResolverContext Overlay::ArResolverWrapper::GetCurrentContext() const {
    return get()->GetCurrentContext();
}

bool Overlay::ArResolverWrapper::IsContextDependentPath(const std::string& assetPath) const {
    return get()->IsContextDependentPath(assetPath);
}

std::string Overlay::ArResolverWrapper::GetExtension(const std::string& assetPath) const {
    return get()->GetExtension(assetPath);
}

pxr::ArAssetInfo Overlay::ArResolverWrapper::GetAssetInfo(const std::string& assetPath,
                                                          const pxr::ArResolvedPath& resolvedPath) const {
    return get()->GetAssetInfo(assetPath, resolvedPath);
}

pxr::ArTimestamp Overlay::ArResolverWrapper::GetModificationTimestamp(const std::string& assetPath,
                                                                      const pxr::ArResolvedPath& resolvedPath) const {
    return get()->GetModificationTimestamp(assetPath, resolvedPath);
}

std::shared_ptr<pxr::ArAsset> Overlay::ArResolverWrapper::OpenAsset(const pxr::ArResolvedPath& resolvedPath) const {
    return get()->OpenAsset(resolvedPath);
}

std::shared_ptr<pxr::ArWritableAsset> Overlay::ArResolverWrapper::OpenAssetForWrite(const pxr::ArResolvedPath& resolvedPath, Overlay::ArResolverWrapper::WriteMode writeMode) const {
    return get()->OpenAssetForWrite(resolvedPath, static_cast<pxr::ArResolver::WriteMode>(writeMode));
}

bool Overlay::ArResolverWrapper::CanWriteAssetToPath(const pxr::ArResolvedPath& resolvedPath,
                                                     std::string* whyNot) const {
    return get()->CanWriteAssetToPath(resolvedPath, whyNot);
}

void Overlay::ArResolverWrapper::BeginCacheScope(pxr::VtValue* cacheScopeData) {
    return get()->BeginCacheScope(cacheScopeData);
}

void Overlay::ArResolverWrapper::EndCacheScope(pxr::VtValue* cacheScopeData) {
    return get()->EndCacheScope(cacheScopeData);
}

bool Overlay::ArResolverWrapper::IsRepositoryPath(const std::string& path) const {
    return get()->IsRepositoryPath(path);
}

Overlay::ArResolverWrapper __Overlay::ArGetResolver_friend() {
    return Overlay::ArResolverWrapper(&pxr::ArGetResolver());
}
Overlay::ArResolverWrapper Overlay::ArGetResolver() {
    return __Overlay::ArGetResolver_friend();
}

Overlay::ArResolverWrapper __Overlay::ArGetUnderlyingResolver_friend() {
    return Overlay::ArResolverWrapper(&pxr::ArGetUnderlyingResolver());
}
Overlay::ArResolverWrapper Overlay::ArGetUnderlyingResolver() {
    return __Overlay::ArGetUnderlyingResolver_friend();
}

Overlay::ArResolverWrapper __Overlay::ArCreateResolver_friend(const pxr::TfType& resolverType) {
    return Overlay::ArResolverWrapper(std::shared_ptr<pxr::ArResolver>(pxr::ArCreateResolver(resolverType)));
}
Overlay::ArResolverWrapper Overlay::ArCreateResolver(const pxr::TfType& resolverType) {
    return __Overlay::ArCreateResolver_friend(resolverType);
}

// MARK: SwiftUsd implementation access

Overlay::ArResolverWrapper::ArResolverWrapper(pxr::ArResolver* unowned)
  : _unownedPtr(unowned) {}
Overlay::ArResolverWrapper::ArResolverWrapper(std::shared_ptr<pxr::ArResolver> shared)
  : _ownedPtr(shared) {}

pxr::ArResolver*_Nullable Overlay::ArResolverWrapper::get() const {
    return _unownedPtr ? _unownedPtr : _ownedPtr.get();
}

std::shared_ptr<pxr::ArResolver> Overlay::ArResolverWrapper::get_shared() const {
    // Important: don't try `_unownedPtr`, because it's not held by shared pointer
    return _ownedPtr;
}

Overlay::ArResolverWrapper::operator bool() const {
    return (bool)get();
}
