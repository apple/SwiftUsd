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

#ifndef TemporaryImplementations_hpp
#define TemporaryImplementations_hpp

#include <stdio.h>
#include <optional>
#include <utility>
#include <map>
#include "pxr/usd/sdf/mapEditProxy.h"
#include "pxr/usd/sdf/proxyTypes.h"
#include "pxr/base/vt/value.h"
#include "pxr/usd/sdf/variantSetSpec.h"
#include "pxr/usd/sdf/variantSpec.h"
#include "pxr/base/vt/array.h"
#include "pxr/usd/sdf/pathExpression.h"

// Prior to Swift 6.3, there's no way to directly create a non-empty
// std::optional in Swift, so we add a function to do that. 

namespace Overlay {
    typedef std::optional<double> Double_Optional;
}

namespace __Overlay {
    std::optional<double> DoubleOptional(double d);    
}

#endif /* TemporaryImplementations_hpp */
