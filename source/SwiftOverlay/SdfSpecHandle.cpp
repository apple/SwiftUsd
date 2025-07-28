//
//  SdfSpecHandle.cpp
//  SwiftUsd
//
//  Created by Maddy Adams on 6/2/25.
//

#include "swiftUsd/SwiftOverlay/SdfSpecHandle.h"

pxr::SdfSpec __Overlay::operatorArrow(const pxr::SdfSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfPropertySpec __Overlay::operatorArrow(const pxr::SdfPropertySpecHandle& x) {
    return *x.operator->();
}
pxr::SdfPrimSpec __Overlay::operatorArrow(const pxr::SdfPrimSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfVariantSetSpec __Overlay::operatorArrow(const pxr::SdfVariantSetSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfVariantSpec __Overlay::operatorArrow(const pxr::SdfVariantSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfAttributeSpec __Overlay::operatorArrow(const pxr::SdfAttributeSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfRelationshipSpec __Overlay::operatorArrow(const pxr::SdfRelationshipSpecHandle& x) {
    return *x.operator->();
}
pxr::SdfPseudoRootSpec __Overlay::operatorArrow(const pxr::SdfPseudoRootSpecHandle& x) {
    return *x.operator->();
}
