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


// SdfPathSet is std::set<SdfPath>, which isn't caught by Equatable codegen
extension pxr.SdfPathSet: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        __Overlay.operatorEqualsEquals(lhs, rhs)
    }
}

extension Overlay.UsdPrimTypeInfoWrapper: Equatable {}

// ArResolvedPath doesn't have operator<< functions, but does have
// `operator const std::string&()`, which isn't caught by CustomStringConvertible code gen

extension pxr.ArResolvedPath: CustomStringConvertible {
    public var description: String {
        String(GetPathString())
    }
}

#if os(Linux)
// https://github.com/swiftlang/swift/pull/77890
// On Swift 6.0.3 on Linux, Observation runs into a linker error that swift::threading::fatal can't be found.
// So, stub it out. 
@_cdecl("_ZN5swift9threading5fatalEPKcz") func swift_threading_fatal() { fatalError("swift::threading::fatal") }
#endif
