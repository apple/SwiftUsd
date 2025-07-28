//
//  SdfSpecHandle.h
//  SwiftUsd
//
//  Created by Maddy Adams on 6/2/25.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_SDFSPECHANDLE_H
#define SWIFTUSD_SWIFTOVERLAY_SDFSPECHANDLE_H

#include "pxr/usd/sdf/spec.h"
#include "pxr/usd/sdf/propertySpec.h"
#include "pxr/usd/sdf/primSpec.h"
#include "pxr/usd/sdf/variantSetSpec.h"
#include "pxr/usd/sdf/variantSpec.h"
#include "pxr/usd/sdf/attributeSpec.h"
#include "pxr/usd/sdf/relationshipSpec.h"
#include "pxr/usd/sdf/pseudoRootSpec.h"

namespace __Overlay {
    pxr::SdfSpec operatorArrow(const pxr::SdfSpecHandle& x);
    pxr::SdfPropertySpec operatorArrow(const pxr::SdfPropertySpecHandle& x);
    pxr::SdfPrimSpec operatorArrow(const pxr::SdfPrimSpecHandle& x);
    pxr::SdfVariantSetSpec operatorArrow(const pxr::SdfVariantSetSpecHandle& x);
    pxr::SdfVariantSpec operatorArrow(const pxr::SdfVariantSpecHandle& x);
    pxr::SdfAttributeSpec operatorArrow(const pxr::SdfAttributeSpecHandle& x);
    pxr::SdfRelationshipSpec operatorArrow(const pxr::SdfRelationshipSpecHandle& x);
    pxr::SdfPseudoRootSpec operatorArrow(const pxr::SdfPseudoRootSpecHandle& x);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_SDFSPECHANDLE_H */
