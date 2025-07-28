//
//  Miscellaneous.cpp
//
//  Created by Maddy Adams on 3/28/24.h

#include "swiftUsd/SwiftOverlay/Miscellaneous.h"

const std::function<bool (const pxr::TfToken& propertyName)> Overlay::DefaultPropertyPredicateFunc = {};


// Workaround for rdar://124105392 (UsdMetadataValueMap subscript getter is mutating (5.10 regression))
pxr::VtValue __Overlay::operatorSubscript(const pxr::UsdMetadataValueMap& m, const pxr::TfToken& x, bool* isValid) {
    auto it = m.find(x);
    *isValid = it != m.end();
    return *isValid ? it->second : pxr::VtValue();
}

// SdfPathSet is std::set<SdfPath>, which isn't caught by Equatable codegen
bool __Overlay::operatorEqualsEquals(const pxr::SdfPathSet& l, const pxr::SdfPathSet& r) {
    return l == r;
}
