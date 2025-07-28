//
//  operatorBool.cpp
//
//  Created by Maddy Adams on 3/28/24.h

#include "swiftUsd/SwiftOverlay/operatorBool.h"

#define BOOL_DEF(TYPE) \
    bool Overlay::_operatorBool(const TYPE& x) {\
        return (bool) x;\
    }


bool __Overlay::convertToBool(const pxr::TfRefPtr<pxr::UsdStage>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::TfRefPtr<pxr::SdfLayer>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::TfWeakPtr<pxr::UsdStage>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::TfWeakPtr<pxr::SdfLayer>& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdShadeInput& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdShadeOutput& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdAttribute& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdGeomXformOp& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::UsdRelationship& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfPropertySpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfPrimSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfVariantSetSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfVariantSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfAttributeSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfRelationshipSpecHandle& x) {
    return (bool) x;
}
bool __Overlay::convertToBool(const pxr::SdfPseudoRootSpecHandle& x) {
    return (bool) x;
}
