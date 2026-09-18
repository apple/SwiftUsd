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

import Foundation
import OpenUSD
import TemporaryImplementations_Cxx

public typealias pxr = pxrInternal_v0_26_8__pxrReserved__

// Prior to Swift 6.3, there's no way to directly create a non-empty
// std::optional in Swift, so we add a way to do that.

#if compiler(<6.3)
extension Overlay.Double_Optional {
    public init(_ x: Double) {
        self = __Overlay.DoubleOptional(x)
    }
}
#endif // #if compiler(<6.3)
