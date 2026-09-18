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

func extractTfToken(_ js: JsAny) throws -> pxr.TfToken {
    try pxr.TfToken(js.castAsString())
}
func writeTfToken(_ x: pxr.TfToken) -> JsAny {
    .string(String(x))
}

func extractTfTokenVector(_ js: JsAny) throws -> pxr.TfTokenVector {
    var result = pxr.TfTokenVector()
    for x in try js.castAsArray() {
        try result.push_back(extractTfToken(x))
    }
    return result
}

func extractTfEnum(_ js: JsAny) throws -> pxr.TfEnum {
    try pxr.TfEnum.GetValueFromFullName(std.string(js.castAsString()))
}
func writeTfEnum(_ x: pxr.TfEnum) -> JsAny {
    .string(String(pxr.TfEnum.GetFullName(x)))
}

