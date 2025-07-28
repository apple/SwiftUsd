//
//  UsdZipFileIteratorWrapper.cpp
//  SwiftUsd
//
//  Created by Maddy Adams on 4/23/25.
//

#include "swiftUsd/Wrappers/UsdZipFileIteratorWrapper.h"

// Important:
// We need to implement a custom copy constructor because Swift clients
// expect copies of iterators to be independent ("value semantics"),
// but we hold a shared_ptr to the UsdZipFile::Iterator, so the
// default copy constructor does a shallow copy of shared_ptr ("reference semantics")

Overlay::UsdZipFileIteratorWrapper::UsdZipFileIteratorWrapper(const Overlay::UsdZipFileIteratorWrapper& other) :
_iter(std::make_shared<pxr::UsdZipFile::Iterator>(*other._iter.get())),
_zipFile(other._zipFile) {}

Overlay::UsdZipFileIteratorWrapper& Overlay::UsdZipFileIteratorWrapper::operator=(const Overlay::UsdZipFileIteratorWrapper& other) {
    _iter = std::make_shared<pxr::UsdZipFile::Iterator>(*other._iter.get());
    _zipFile = other._zipFile;
    return *this;
}

Overlay::UsdZipFileIteratorWrapper::UsdZipFileIteratorWrapper(Overlay::UsdZipFileIteratorWrapper&& other) :
_iter(std::make_shared<pxr::UsdZipFile::Iterator>(*other._iter.get())),
_zipFile(other._zipFile) {}

Overlay::UsdZipFileIteratorWrapper& Overlay::UsdZipFileIteratorWrapper::operator=(Overlay::UsdZipFileIteratorWrapper&& other) {
    _iter = std::make_shared<pxr::UsdZipFile::Iterator>(*other._iter.get());
    _zipFile = other._zipFile;
    return *this;
}



Overlay::UsdZipFileIteratorWrapper& Overlay::UsdZipFileIteratorWrapper::operator++() {
    _iter = std::make_shared<pxr::UsdZipFile::Iterator>(_iter->operator++());
    return *this;
}

Overlay::UsdZipFileIteratorWrapper Overlay::UsdZipFileIteratorWrapper::operator++(int x) {
    _iter = std::make_shared<pxr::UsdZipFile::Iterator>(_iter->operator++(x));
    return *this;
}

bool Overlay::UsdZipFileIteratorWrapper::operator==(const UsdZipFileIteratorWrapper& rhs) const {
    // Require _zipFile's starts to match, because in Swift, iterators from different
    // sequences should not compare equal
    return *_iter == *rhs._iter && _zipFile.begin() == rhs._zipFile.begin();
}

bool Overlay::UsdZipFileIteratorWrapper::operator!=(const UsdZipFileIteratorWrapper& rhs) const {
    return !(*this == rhs);
}

const char* _Nullable Overlay::UsdZipFileIteratorWrapper::GetFile() const {
    return _iter->GetFile();
}

pxr::UsdZipFile::FileInfo Overlay::UsdZipFileIteratorWrapper::GetFileInfo() const {
    return _iter->GetFileInfo();
}

std::string Overlay::UsdZipFileIteratorWrapper::operator*() const {
    return _iter->operator*();
}

pxr::UsdZipFile::Iterator::pointer Overlay::UsdZipFileIteratorWrapper::operator->() const {
    return _iter->operator->();
}

Overlay::UsdZipFileIteratorWrapper::UsdZipFileIteratorWrapper(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter) :
_zipFile(zipFile),
_iter(std::make_shared<pxr::UsdZipFile::Iterator>(iter)) {}

Overlay::UsdZipFileIteratorWrapper __Overlay::UsdZipFileIteratorWrapper(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter) {
    return __Overlay::UsdZipFileIteratorWrapper_friend(zipFile, iter);
}

Overlay::UsdZipFileIteratorWrapper __Overlay::UsdZipFileIteratorWrapper_friend(pxr::UsdZipFile zipFile, pxr::UsdZipFile::Iterator iter) {
    return {zipFile, iter};
}

pxr::UsdZipFile __Overlay::UsdZipFileIteratorWrapper__zipFile_friend(Overlay::UsdZipFileIteratorWrapper wrapper) {
    return wrapper._zipFile;
}

pxr::UsdZipFile __Overlay::UsdZipFileIteratorWrapper__zipFile(Overlay::UsdZipFileIteratorWrapper wrapper) {
    return __Overlay::UsdZipFileIteratorWrapper__zipFile_friend(wrapper);
}
