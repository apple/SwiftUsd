//
//  UsdPrimTypeInfoWrapper.cpp
//
//  Created by Maddy Adams on 3/28/24.h

#include "swiftUsd/Wrappers/UsdPrimTypeInfoWrapper.h"
#include "pxr/usd/usd/prim.h"

Overlay::UsdPrimTypeInfoWrapper::UsdPrimTypeInfoWrapper(const pxr::UsdPrimTypeInfo& _impl) : _impl(&_impl)
{}

Overlay::UsdPrimTypeInfoWrapper::UsdPrimTypeInfoWrapper(const pxr::UsdPrim& prim) : _impl(&prim.GetPrimTypeInfo()) {}

pxr::TfToken Overlay::UsdPrimTypeInfoWrapper::GetTypeName() const {
    return _impl->GetTypeName();
}

pxr::TfTokenVector Overlay::UsdPrimTypeInfoWrapper::GetAppliedAPISchemas() const {
    return _impl->GetAppliedAPISchemas();
}

pxr::TfType Overlay::UsdPrimTypeInfoWrapper::GetSchemaType() const {
    return _impl->GetSchemaType();
}

pxr::TfToken Overlay::UsdPrimTypeInfoWrapper::GetSchemaTypeName() const {
    return _impl->GetSchemaTypeName();
}

bool Overlay::UsdPrimTypeInfoWrapper::operator==(const Overlay::UsdPrimTypeInfoWrapper &other) const {
    return _impl == other._impl;
}

bool Overlay::UsdPrimTypeInfoWrapper::operator!=(const Overlay::UsdPrimTypeInfoWrapper &other) const {
    return _impl != other._impl;
}

Overlay::UsdPrimTypeInfoWrapper Overlay::UsdPrimTypeInfoWrapper::GetEmptyPrimType() {
    return Overlay::UsdPrimTypeInfoWrapper(pxr::UsdPrimTypeInfo::GetEmptyPrimType());
}

const pxr::UsdPrimTypeInfo* Overlay::UsdPrimTypeInfoWrapper::get() const {
    return _impl;
}

Overlay::UsdPrimTypeInfoWrapper::operator bool() const {
    return (bool)_impl;
}
