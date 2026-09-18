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

enum JsDecodingError: Error {
    case typeHintWasEmpty
    case mismatchedVecLength
    case mismatchedMatLength
    case decodingTypeFailure(_ typeHint: String)
    case unknownTypeName(pxr.TfToken, String)
    case timeSampleMapKeyWasntDouble(String)
    case sdfAnimationBlockDeserializationError
    case sdfUnregisteredValueDeserializationError
    case jsAnyParseWasNull
    case failedToSetMetadataOnPrim(String, pxr.SdfPath, pxr.VtValue)
    case unknownSpecifier(String, pxr.SdfPath)
    case failedToSetDefaultAttributeValue(String, pxr.SdfPath, pxr.VtValue)
    case layerRelocatesEntryInvalid
    case variantSetSuperObjectInvalid
    case invalidSdfLayerOffset
    case unknownTypeNameAndValue(pxr.TfToken, String, std.string, String)
    case sdfPathSdfUnregisteredValueWasntHoldingAString
}
