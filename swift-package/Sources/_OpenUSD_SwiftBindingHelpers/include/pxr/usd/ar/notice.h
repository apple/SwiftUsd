//
// Copyright 2021 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef PXR_USD_AR_NOTICE_H
#define PXR_USD_AR_NOTICE_H

#include "pxr/pxr.h"

#include "pxr/usd/ar/api.h"
#include "pxr/usd/ar/resolverContext.h"

#include "pxr/base/tf/notice.h"

#include <functional>

PXR_NAMESPACE_OPEN_SCOPE

/// \class ArNotice
///
class ArNotice
{
public:
    /// \class ResolverNotice
    /// Base class for all ArResolver-related notices.
    class ResolverNotice
        : public TfNotice
    {
    public:
        AR_API virtual ~ResolverNotice();
    protected:
        AR_API ResolverNotice();
    };

    /// \class ResolverChanged
    /// Notice sent when asset paths may resolve to a different path than
    /// before due to a change in the resolver.
    class ResolverChanged 
        : public ResolverNotice
    {
    public:
        /// Create a notice indicating that the results of asset resolution
        /// might have changed, regardless of what ArResolverContext object
        /// is bound.
        AR_API
        ResolverChanged();

        /// Create a notice using \p affectsFn to determine the
        /// ArResolverContext objects that are affected by this resolver
        /// change. If \p affectsFn returns true, it means the results of asset
        /// resolution when the given ArResolverContext is bound might have
        /// changed.
        AR_API
        ResolverChanged(
            const std::function<bool(const ArResolverContext&)>& affectsFn);

        /// Create a notice indicating that the results of asset resolution when
        /// any ArResolverContext containing \p ctx is bound might have changed.
        ResolverChanged(const ArResolverContext& ctx)
            : _affects(
                [ctx](const ArResolverContext& otherCtx) {
                    return otherCtx.Contains(ctx);
                })
        {
        }

        /// Create a notice indicating that the results of asset resolution when
        /// any ArResolverContext containing \p contextObj is bound might have
        /// changed.
        template <
            class ContextObj,
            std::enable_if_t<ArIsContextObject<ContextObj>::value>* = nullptr
        >
        ResolverChanged(
            const ContextObj& contextObj)
            : _affects(
                [contextObj](const ArResolverContext& ctx) {
                    return ctx.Contains(contextObj);
                })
        {
        }
 
        AR_API
        virtual ~ResolverChanged();

        /// Returns true if the results of asset resolution when \p ctx
        /// is bound may be affected by this resolver change.
        AR_API 
        bool AffectsContext(const ArResolverContext& ctx) const;

    private:
        std::function<bool(const ArResolverContext&)> _affects;
    };

};

PXR_NAMESPACE_CLOSE_SCOPE

#endif
