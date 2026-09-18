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

#ifndef SdfJson_fileFormat_hpp
#define SdfJson_fileFormat_hpp

#include <stdio.h>
#include "pxr/usd/sdf/fileFormat.h"
#include "pxr/base/js/json.h"

PXR_NAMESPACE_USING_DIRECTIVE;

#define SDFJSON_FILE_FORMAT_TOKENS \
((Id, "json")) \
((Version, "1.0")) \
((Target, "usd"))

TF_DECLARE_PUBLIC_TOKENS(SdfJsonFileFormatTokens, SDFJSON_FILE_FORMAT_TOKENS);

TF_DECLARE_WEAK_AND_REF_PTRS(SdfJsonFileFormat);


class SdfJsonFileFormat: public pxr::SdfFileFormat {
public:

    bool CanRead(const std::string& file) const override;
    bool Read(pxr::SdfLayer* layer, const std::string& resolvedPath, bool metadataOnly) const override;
    
    bool WriteToFile(
                     const pxr::SdfLayer&,
                     const std::string& filePath,
                     const std::string& comment = std::string(),
                     const FileFormatArguments& args = FileFormatArguments()
                     ) const override;
    bool SaveToFile(
                    const pxr::SdfLayer& layer,
                    const std::string& filePath,
                    const std::string& comment = std::string(),
                    const FileFormatArguments& args = FileFormatArguments()
                    ) const override;
    
    bool ReadFromString(
                        pxr::SdfLayer* layer,
                        const std::string& str
                        ) const override;
        
    bool WriteToString(
                       const pxr::SdfLayer& layer,
                       std::string* str,
                       const std::string& comment = std::string()
                       ) const override;

protected:
    SDF_FILE_FORMAT_FACTORY_ACCESS;
    
    SdfJsonFileFormat();
    ~SdfJsonFileFormat() override;
};

#endif /* SdfJson_fileFormat_hpp */
