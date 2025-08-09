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

// Use @_exported to allow clients that `import OpenUSD` to get access
// to the underlying C++ libraries
// use @_documentation(visibility: internal) to hide imported symbols
// from showing up in DocC (e.g. Boost macros, public constants)
@_documentation(visibility: internal) @_exported import _OpenUSD_SwiftBindingHelpers


// Makes it easier for clients to access Usd types without
// having to do the full typealias
// use @_documentation(visibility: internal) to hide this
// from showing up in DocC
@_documentation(visibility: internal) public typealias pxr = pxrInternal_v0_25_8__pxrReserved__
