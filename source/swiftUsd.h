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

#ifndef SWIFTUSD_SWIFTUSD_H
#define SWIFTUSD_SWIFTUSD_H

/// This header acts as an umbrella header for C++ code that wants to access
/// SwiftUsd-specific additions to OpenUSD, such as for interoperating with
/// Swift code.
///
/// Include this file instead of including other files in `<swiftUsd>`.
/// Other header files are treated as implementation details and are subject to change.



// Important: For DocC purposes, do not rely on transitive includes! 
// Directly include all C++-exposed headers here.

#include "swiftUsd/defines.h"

#include "swiftUsd/SwiftOverlay/SwiftCxxMacros.h"

#include "swiftUsd/TfNotice/SwiftKey.h"

#include "swiftUsd/CxxOnly/RefcountingAcrossLanguages.h"
#include "swiftUsd/CxxOnly/Deprecated.h"

#include "swiftUsd/Wrappers/ArResolverWrapper.h"
#include "swiftUsd/Wrappers/HgiMetalWrapper.h"
#include "swiftUsd/Wrappers/HgiWrapper.h"
#include "swiftUsd/Wrappers/HioImageWrapper.h"
#include "swiftUsd/Wrappers/UsdAppUtilsFrameRecorderWrapper.h"
#include "swiftUsd/Wrappers/UsdImagingGLEngineWrapper.h"
#include "swiftUsd/Wrappers/UsdPrimTypeInfoWrapper.h"



// Swift DocC works great for symbols defined in Swift,
// but we need to do some work for symbols defined in C++.
// Symbols defined in C++ can be defined for use in Swift only,
// or for use in C++ only, or for use in Swift and C++.
//
// The headers listed above are picked up as being for C++,
// but we need to tell DocC which headers are meant for Swift.
// (If a header is listed twice, that just means that it's
// meant for both Swift and C++.)

#ifdef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS

#includeforswiftdocc "swiftUsd/TfNotice/SwiftKey.h"

#includeforswiftdocc "swiftUsd/Wrappers/ArResolverWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/HgiMetalWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/HgiWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/HioImageWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/SdfZipFileIteratorWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/TfErrorMarkWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/UsdAppUtilsFrameRecorderWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/UsdImagingGLEngineWrapper.h"
#includeforswiftdocc "swiftUsd/Wrappers/UsdPrimTypeInfoWrapper.h"

#includeforswiftdocc "swiftUsd/SwiftOverlay/HydraHelpers.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/Miscellaneous.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/SdfLayer.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/TfEnum.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/Typedefs.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/UsdAttribute.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/UsdRelationship.h"
#includeforswiftdocc "swiftUsd/SwiftOverlay/Usd_PrimFlags.h"

#endif /* OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS */

#endif /* SWIFTUSD_SWIFTUSD_H */
