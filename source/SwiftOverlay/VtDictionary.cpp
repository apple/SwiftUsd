//
//  VtDictionary.cpp
//
//  Created by Maddy Adams on 3/28/24

#include "swiftUsd/SwiftOverlay/VtDictionary.h"

std::pair<pxr::VtDictionary::iterator, bool> __Overlay::insert(pxr::VtDictionary* d, const pxr::VtDictionary::value_type& obj) {
    return d->insert(obj);
}
pxr::VtDictionary::const_iterator __Overlay::find(const pxr::VtDictionary& d, const std::string& key) {
    return d.find(key);
}
pxr::VtDictionary::iterator __Overlay::findMutating(pxr::VtDictionary* d, const std::string& key) {
    return d->find(key);
}
pxr::VtValue __Overlay::operatorSubscript(const pxr::VtDictionary& d, const std::string& key, bool* isValid) {
    auto it = d.find(key);
    *isValid = it != d.end();
    return *isValid ? it->second : pxr::VtValue();
}
