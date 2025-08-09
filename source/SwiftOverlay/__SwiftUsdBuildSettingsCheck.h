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

#ifndef SWIFTUSD_SWIFTOVERLAY___SWIFTUSDBUILDSETTINGSCHECK_H
#define SWIFTUSD_SWIFTOVERLAY___SWIFTUSDBUILDSETTINGSCHECK_H

// Note: This file checks for the correct build settings when using SwiftUsd.
// Don't include this file in a C++ source file.

#if __cplusplus < 201700 || __cplusplus > 201799
#error "Invalid C++ language version, C++17 or GNU++17 is required for SwiftUsd. Check `CLANG_CXX_LANGUAGE_STANDARD` in Xcode build settings or `-std=` on the command line"
#endif // __cplusplus < 201700 || __cplusplus > 201799


#ifndef __swift__
#error "Invalid Swift-Cxx interop mode, enabled interop is required for SwiftUsd. Check `SWIFT_OBJC_INTEROP_MODE` in Xcode build settings or `-cxx-interoperability-mode=` on the command line"
#endif // __swift__

#endif /* SWIFTUSD_SWIFTOVERLAY___SWIFTUSDBUILDSETTINGSCHECK_H */
