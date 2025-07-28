//
//  VtDictionaryConstIteratorWrapper.cpp
//
//  Created by Maddy Adams on 3/28/24.h

#include "swiftUsd/Wrappers/VtDictionaryConstIteratorWrapper.h"

Overlay::VtDictionaryConstIteratorWrapper::VtDictionaryConstIteratorWrapper(const pxr::VtDictionary& dict) :
    dict(dict),
    iterator(this->dict.begin()),
    shouldAdvanceBeforeGettingCurrent(false)
{
}
std::pair<std::string, pxr::VtValue> Overlay::VtDictionaryConstIteratorWrapper::advanceAndGetCurrent(bool *isValid) {
    if (shouldAdvanceBeforeGettingCurrent) {
        ++iterator;
    }
    shouldAdvanceBeforeGettingCurrent = true;
    *isValid = iterator == dict.end();
    return *isValid ? *iterator : std::make_pair("", pxr::VtValue());
}
