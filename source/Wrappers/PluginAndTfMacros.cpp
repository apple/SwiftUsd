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

#include "swiftUsd/Wrappers/PluginAndTfMacros.h"

#include <memory>
#include "pxr/base/tf/type.h"
#include "pxr/usd/sdf/fileFormat.h"



namespace __Overlay {
    class SwiftSdfFileFormatFactory: public pxr::Sdf_FileFormatFactoryBase {
    public:
        void*_Nonnull(*_Nonnull newImpl)();

        SwiftSdfFileFormatFactory(void*_Nonnull(*_Nonnull newImpl)()) : newImpl(newImpl) {}

        pxr::SdfFileFormatRefPtr New() const {
            void* p = newImpl();
            return pxr::TfCreateRefPtr(static_cast<pxr::SdfFileFormat*>(p));
        }
    };

    void setSwiftSdfFileFormatPluginFactory(std::string typeName, void*_Nonnull(*_Nonnull newImpl)()) {
        pxr::TfType t = pxr::TfType::Declare(typeName);
        t.SetFactory(std::make_unique<SwiftSdfFileFormatFactory>(newImpl));
    }
}


#include "swiftUsd/defines.h"
#if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
#include "pxr/imaging/hio/image.h"

namespace __Overlay {
    class SwiftHioImageFactory: public pxr::HioImageFactoryBase {
    public:
        void*_Nonnull(*_Nonnull newImpl)();

        SwiftHioImageFactory(void*_Nonnull(*_Nonnull newImpl)()) : newImpl(newImpl) {}
        
        pxr::HioImageSharedPtr New() const {
            void* p = newImpl();
            return pxr::HioImageSharedPtr(static_cast<pxr::HioImage*>(p));
        }
    };

    void setSwiftHioImagePluginFactory(std::string typeName, void*_Nonnull(*_Nonnull newImpl)()) {
        pxr::TfType t = pxr::TfType::Declare(typeName);
        t.SetFactory(std::make_unique<SwiftHioImageFactory>(newImpl));
    }
}
    
#endif // #if SwiftUsd_PXR_ENABLE_IMAGING_SUPPORT
