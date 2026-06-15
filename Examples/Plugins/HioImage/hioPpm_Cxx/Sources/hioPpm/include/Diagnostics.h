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


#ifndef HIOPPM_DIAGNOSTICS_H
#define HIOPPM_DIAGNOSTICS_H

#include "pxr/base/tf/diagnostic.h"

// TfDiagnostic macros expect to be within `PXR_NAMESPACE_USING_DIRECTIVE` or `PXR_NAMESPACE_OPEN_SCOPE`,
// but we don't want to have to repeat those everywhere, so expose our own version of the macros

#define MY_RUNTIME_ERROR(s) { PXR_NAMESPACE_USING_DIRECTIVE; TF_RUNTIME_ERROR(s); }
#define MY_CODING_ERROR(s) { PXR_NAMESPACE_USING_DIRECTIVE; TF_CODING_ERROR(s); }
#define MY_VERIFY(s) { PXR_NAMESPACE_USING_DIRECTIVE; TF_VERIFY(s); }

#endif // HIOPPM_DIAGNOSTICS_H
