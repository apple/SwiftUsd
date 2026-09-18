//===----------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0
//===----------------------------------------------------------------------===//

#include "fileFormat.hpp"
#include "pxr/base/tf/pathUtils.h"
#include "pxr/base/trace/trace.h"
#include "pxr/usd/usd/stage.h"
#include "pxr/usd/ar/resolver.h"
#include "pxr/usd/ar/asset.h"
#include "pxr/usd/ar/writableAsset.h"
#include <iostream>
#include "Diagnostics.hpp"
#include "CoreSpecSerialization.hpp"

TF_DEFINE_PUBLIC_TOKENS(SdfJsonFileFormatTokens, SDFJSON_FILE_FORMAT_TOKENS);

TF_REGISTRY_FUNCTION(TfType) {
    SDF_DEFINE_FILE_FORMAT(SdfJsonFileFormat, SdfFileFormat);
}

SdfJsonFileFormat::SdfJsonFileFormat()
: pxr::SdfFileFormat(SdfJsonFileFormatTokens->Id,
                     SdfJsonFileFormatTokens->Version,
                     SdfJsonFileFormatTokens->Target,
                     SdfJsonFileFormatTokens->Id)
{
}

SdfJsonFileFormat::~SdfJsonFileFormat()
{
}

bool SdfJsonFileFormat::CanRead(const std::string &file) const {
    std::string extension = pxr::TfGetExtension(file);
    if (extension != GetFormatId()) {
        return false;
    }
    return true;
}

bool _read(pxr::SdfLayer* layer, const pxr::JsValue& value) {
    if (value.IsNull()) {
        TF_RUNTIME_ERROR("Can't read layer, JsValue parse was null");
        return false;
    }
    
    pxr::SdfLayerRefPtr myLayer = pxr::SdfLayer::CreateAnonymous();
    
    pxr::TfErrorMark m;
    readLayer(myLayer, value);
    if (!m.IsClean()) {
        return false;
    }
    
    layer->TransferContent(myLayer);
    return true;
}

bool _write(std::string* str, const pxr::SdfLayer& l, const std::string& comment) {
    pxr::TfErrorMark m;
    writeLayer(str, l, comment);
    return m.IsClean();
}

bool SdfJsonFileFormat::Read(pxr::SdfLayer *layer, const std::string &resolvedPath, bool metadataOnly) const {
    TRACE_FUNCTION();
    
    std::shared_ptr<pxr::ArAsset> asset = pxr::ArGetResolver().OpenAsset(pxr::ArResolvedPath(resolvedPath));
    if (!asset) { return false; }
    size_t buflen = asset->GetSize();
    std::shared_ptr<const char> buf = asset->GetBuffer();
    std::string s{buf.get(), buflen};
    
    pxr::JsParseError err;
    pxr::JsValue js = pxr::JsParseString(s, &err);
    if (!err.reason.empty()) {
        MY_RUNTIME_ERROR_AND_RETURN("JsParseString failed with '%s' at line %d column %d", err.reason.c_str(), err.line, err.column) false;
    }
    return _read(layer, js);
}

bool SdfJsonFileFormat::ReadFromString(pxr::SdfLayer *layer, const std::string &str) const {
    return _read(layer, pxr::JsParseString(str));
}

bool SdfJsonFileFormat::WriteToFile(const pxr::SdfLayer& layer, const std::string &filePath, const std::string& comment, const FileFormatArguments& args) const {
    std::shared_ptr<pxr::ArWritableAsset> asset = pxr::ArGetResolver().OpenAssetForWrite(pxr::ArResolvedPath(filePath), pxr::ArResolver::WriteMode::Replace);
    if (!asset) {
        TF_RUNTIME_ERROR("Couldn't OpenAssetForWrite(%s)", filePath.c_str());
        return false;
    }
    std::string s;
    if (!_write(&s, layer, comment)) {
        TF_RUNTIME_ERROR("FileFormat write failed");
        return false;
    }
    if (!asset->Write(s.data(), s.size(), 0)) {
        TF_RUNTIME_ERROR("ArWritableAsset->Write failed");
        return false;
    }
    return asset->Close();
}

bool SdfJsonFileFormat::SaveToFile(const pxr::SdfLayer& layer, const std::string &filePath, const std::string& comment, const FileFormatArguments& args) const {
    return WriteToFile(layer, filePath, comment, args);
}

bool SdfJsonFileFormat::WriteToString(const pxr::SdfLayer& layer, std::string *str, const std::string& comment) const {
    return _write(str, layer, comment);
}
