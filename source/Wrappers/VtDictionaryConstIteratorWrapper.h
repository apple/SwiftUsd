//
//  VtDictionaryConstIteratorWrapper.h
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_WRAPPERS_VTDICTIONARYCONSTITERATORWRAPPER_h
#define SWIFTUSD_WRAPPERS_VTDICTIONARYCONSTITERATORWRAPPER_h

#include <utility>
#include "pxr/base/vt/dictionary.h"

namespace Overlay {
    struct VtDictionaryConstIteratorWrapper {
    private:
        pxr::VtDictionary dict;
        pxr::VtDictionary::const_iterator iterator;
        bool shouldAdvanceBeforeGettingCurrent;
        
    public:
        VtDictionaryConstIteratorWrapper(const pxr::VtDictionary& dict);
        std::pair<std::string, pxr::VtValue> advanceAndGetCurrent(bool* isValid);
    };

}

#endif /* SWIFTUSD_WRAPPERS_VTDICTIONARYCONSTITERATORWRAPPER_h */
