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

extension Float {
    public init(_ h: pxr.GfHalf) {
        self = __Overlay.halfToFloat(h)
    }
}
// GfHalf.init(Float) provided by ilmbase_half.h


extension String {
    public init(_ token: pxr.TfToken) {
        self.init(token.GetString())
    }
}
extension pxr.TfToken {
    public init(_ string: String) {
        self.init(std.string(string))
    }
}


extension String {
    public init(_ path: pxr.ArResolvedPath) {
        self.init(path.GetPathString())
    }
}
extension pxr.ArResolvedPath {
    public init(_ string: String) {
        self.init(std.string(string))
    }
}


extension String {
    public init(_ path: pxr.SdfPath) {
        self.init(path.GetAsString())
    }
}
extension pxr.SdfPath {
    public init(_ string: String) {
        self.init(std.string(string))
    }
}


extension String {
    /// Uses `path.GetAssetPath()`. To use a different accessor, call that accessor explicitly
    public init(_ path: pxr.SdfAssetPath) {
        self.init(path.GetAssetPath())
    }
}
extension pxr.SdfAssetPath {
    public init(_ s: String) {
        self.init(std.string(s))
    }
}


extension std.string {
    public init(_ token: pxr.TfToken) {
        self = token.GetString()
    }
}
// TfToken.init(std.string) provided by token.h


extension std.string {
    public init(_ path: pxr.ArResolvedPath) {
        self = path.GetPathString()
    }
}
// ArResolvedPath.init(std.string) provided by resolvedPath.h
