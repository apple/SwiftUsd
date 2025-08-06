// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

#include "swiftUsd/Wrappers/SdfZipFileIteratorWrapper.h"

// Important:
// We need to implement a custom copy constructor because Swift clients
// expect copies of iterators to be independent ("value semantics"),
// but we hold a shared_ptr to the SdfZipFile::Iterator, so the
// default copy constructor does a shallow copy of shared_ptr ("reference semantics")

Overlay::SdfZipFileIteratorWrapper::SdfZipFileIteratorWrapper(const Overlay::SdfZipFileIteratorWrapper& other) :
_iter(std::make_shared<pxr::SdfZipFile::Iterator>(*other._iter.get())),
_zipFile(other._zipFile) {}

Overlay::SdfZipFileIteratorWrapper& Overlay::SdfZipFileIteratorWrapper::operator=(const Overlay::SdfZipFileIteratorWrapper& other) {
    _iter = std::make_shared<pxr::SdfZipFile::Iterator>(*other._iter.get());
    _zipFile = other._zipFile;
    return *this;
}

Overlay::SdfZipFileIteratorWrapper::SdfZipFileIteratorWrapper(Overlay::SdfZipFileIteratorWrapper&& other) :
_iter(std::make_shared<pxr::SdfZipFile::Iterator>(*other._iter.get())),
_zipFile(other._zipFile) {}

Overlay::SdfZipFileIteratorWrapper& Overlay::SdfZipFileIteratorWrapper::operator=(Overlay::SdfZipFileIteratorWrapper&& other) {
    _iter = std::make_shared<pxr::SdfZipFile::Iterator>(*other._iter.get());
    _zipFile = other._zipFile;
    return *this;
}



Overlay::SdfZipFileIteratorWrapper& Overlay::SdfZipFileIteratorWrapper::operator++() {
    _iter = std::make_shared<pxr::SdfZipFile::Iterator>(_iter->operator++());
    return *this;
}

Overlay::SdfZipFileIteratorWrapper Overlay::SdfZipFileIteratorWrapper::operator++(int x) {
    _iter = std::make_shared<pxr::SdfZipFile::Iterator>(_iter->operator++(x));
    return *this;
}

bool Overlay::SdfZipFileIteratorWrapper::operator==(const SdfZipFileIteratorWrapper& rhs) const {
    // Require _zipFile's starts to match, because in Swift, iterators from different
    // sequences should not compare equal
    return *_iter == *rhs._iter && _zipFile.begin() == rhs._zipFile.begin();
}

bool Overlay::SdfZipFileIteratorWrapper::operator!=(const SdfZipFileIteratorWrapper& rhs) const {
    return !(*this == rhs);
}

const char* _Nullable Overlay::SdfZipFileIteratorWrapper::GetFile() const {
    return _iter->GetFile();
}

pxr::SdfZipFile::FileInfo Overlay::SdfZipFileIteratorWrapper::GetFileInfo() const {
    return _iter->GetFileInfo();
}

std::string Overlay::SdfZipFileIteratorWrapper::operator*() const {
    return _iter->operator*();
}

pxr::SdfZipFile::Iterator::pointer Overlay::SdfZipFileIteratorWrapper::operator->() const {
    return _iter->operator->();
}

Overlay::SdfZipFileIteratorWrapper::SdfZipFileIteratorWrapper(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter) :
_zipFile(zipFile),
_iter(std::make_shared<pxr::SdfZipFile::Iterator>(iter)) {}

Overlay::SdfZipFileIteratorWrapper __Overlay::SdfZipFileIteratorWrapper(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter) {
    return __Overlay::SdfZipFileIteratorWrapper_friend(zipFile, iter);
}

Overlay::SdfZipFileIteratorWrapper __Overlay::SdfZipFileIteratorWrapper_friend(pxr::SdfZipFile zipFile, pxr::SdfZipFile::Iterator iter) {
    return {zipFile, iter};
}

pxr::SdfZipFile __Overlay::SdfZipFileIteratorWrapper__zipFile_friend(Overlay::SdfZipFileIteratorWrapper wrapper) {
    return wrapper._zipFile;
}

pxr::SdfZipFile __Overlay::SdfZipFileIteratorWrapper__zipFile(Overlay::SdfZipFileIteratorWrapper wrapper) {
    return __Overlay::SdfZipFileIteratorWrapper__zipFile_friend(wrapper);
}
