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

// See the note in CoreSpecSerialization.swift

struct DereferencedInvalidSdfHandleError: Error {
    var type: pxr.SdfSpecType
}

extension pxr.SdfSpecHandle {
    var pointeeOrThrow: pxr.SdfSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypeUnknown) }
            return self.pointee
        }
    }
}

extension pxr.SdfPropertySpecHandle {
    var pointeeOrThrow: pxr.SdfPropertySpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypeUnknown) }
            return self.pointee
        }
    }
}

extension pxr.SdfPrimSpecHandle {
    var pointeeOrThrow: pxr.SdfPrimSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypePrim) }
            return self.pointee
        }
    }
}

extension pxr.SdfVariantSetSpecHandle {
    var pointeeOrThrow: pxr.SdfVariantSetSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypeVariantSet) }
            return self.pointee
        }
    }
}

extension pxr.SdfVariantSpecHandle {
    var pointeeOrThrow: pxr.SdfVariantSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypeVariant) }
            return self.pointee
        }
    }
}

extension pxr.SdfAttributeSpecHandle {
    var pointeeOrThrow: pxr.SdfAttributeSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypeAttribute) }
            return self.pointee
        }
    }
}

extension pxr.SdfRelationshipSpecHandle {
    var pointeeOrThrow: pxr.SdfRelationshipSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypeRelationship) }
            return self.pointee
        }
    }
}

extension pxr.SdfPseudoRootSpecHandle {
    var pointeeOrThrow: pxr.SdfPseudoRootSpec {
        get throws {
            guard Bool(self) else { throw DereferencedInvalidSdfHandleError(type: .SdfSpecTypePseudoRoot) }
            return self.pointee
        }
    }
}

