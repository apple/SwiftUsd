//
//  VtDictionary.h
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_VTDICTIONARY_H
#define SWIFTUSD_SWIFTOVERLAY_VTDICTIONARY_H

#include <utility>
#include <string>
#include "pxr/pxr.h"
#include "pxr/base/vt/dictionary.h"

namespace __Overlay {
    std::pair<pxr::VtDictionary::iterator, bool> insert(pxr::VtDictionary* d, const pxr::VtDictionary::value_type& obj);
    pxr::VtDictionary::const_iterator find(const pxr::VtDictionary& d, const std::string& key);
    pxr::VtDictionary::iterator findMutating(pxr::VtDictionary* d, const std::string& key);
    pxr::VtValue operatorSubscript(const pxr::VtDictionary& d, const std::string& key, bool* isValid);
}

#endif /* SWIFTUSD_SWIFTOVERLAY_VTDICTIONARY_H */
