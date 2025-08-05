//
//  UsdPrimTypeInfoWrapper.h
//
//  Created by Maddy Adams on 3/28/24.
//

// Original documentation for pxr::UsdPrimTypeInfo from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/usd/usd/primTypeInfo.h

#ifndef SWIFTUSD_WRAPPERS_USDPRIMTYPEINFOWRAPPER_H
#define SWIFTUSD_WRAPPERS_USDPRIMTYPEINFOWRAPPER_H

#include <vector>
#include "pxr/usd/usd/primTypeInfo.h"
#include "pxr/base/tf/token.h"
#include "pxr/base/tf/type.h"

namespace Overlay {
    /// Class that holds the full type information for a prim. It holds the type
    /// name, applied API schema names, and possibly a mapped schema type name which
    /// represent a unique full type.
    /// The info this holds is used to cache and provide the "real" schema type for
    /// the prim's type name regardless of whether it is a recognized prim type or
    /// not. The optional "mapped schema type name" is used to obtain a valid schema
    /// type for an unrecognized prim type name if the stage provides a fallback
    /// type for the unrecognized type. This class also provides access to the prim
    /// definition that defines all the built-in properties and metadata of a prim
    /// of this type.
    struct UsdPrimTypeInfoWrapper {
        /// Returns the concrete prim type name.
        pxr::TfToken GetTypeName() const;

        /// Returns the list of applied API schemas, directly authored on the prim,
        /// that impart additional properties on its prim definition. This does NOT
        /// include the applied API schemas that may be defined in the concrete prim
        /// type's prim definition.
        pxr::TfTokenVector GetAppliedAPISchemas() const;

        /// Returns the TfType of the actual concrete schema that prims of this
        /// type will use to create their prim definition. Typically, this will
        /// be the type registered in the schema registry for the concrete prim type
        /// returned by GetTypeName. But if the stage provided this type info with
        /// a fallback type because the prim type name is not a recognized schema,
        /// this will return the provided fallback schema type instead.
        pxr::TfType GetSchemaType() const;

        /// Returns the type name associated with the schema type returned from
        /// GetSchemaType. This will always be equivalent to calling
        /// UsdSchemaRegistry::GetConcreteSchemaTypeName on the type returned by
        /// GetSchemaType and will typically be the same as GetTypeName as long as
        /// the prim type name is a recognized prim type.
        ///
        /// \sa \ref Usd_OM_FallbackPrimTypes
        pxr::TfToken GetSchemaTypeName() const;

        
        bool operator==(const UsdPrimTypeInfoWrapper& other) const;
        
        bool operator!=(const UsdPrimTypeInfoWrapper& other) const;

        /// Returns the empty prim type info.
        static UsdPrimTypeInfoWrapper GetEmptyPrimType();

        /// MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor
        UsdPrimTypeInfoWrapper(const pxr::UsdPrimTypeInfo& _impl);

        /// SwiftUsd wrapping constructor
        UsdPrimTypeInfoWrapper(const pxr::UsdPrim& prim);

        /// Returns the underlying UsdPrimTypeInfo instance
        const pxr::UsdPrimTypeInfo* get() const;

        /// Returns `true` iff the underlying instance is valid
        explicit operator bool() const;
        
    private:
        const pxr::UsdPrimTypeInfo* _impl;
    };
}

#endif /* SWIFTUSD_WRAPPERS_USDPRIMTYPEINFOWRAPPER_H */
