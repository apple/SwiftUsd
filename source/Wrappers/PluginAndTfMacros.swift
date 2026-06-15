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

#if canImport(Darwin)

/// Apply this macro to a Swift function to make it participate
/// in TfRegistry operations. This is the Swift equivalent of the C++
/// macro `TF_REGISTRY_FUNCTION`.
/// ```swift
/// @TF_REGISTRY_FUNCTION(pxr.TfType)
/// private func myFunction() {
///     ...
/// }
/// ```
@attached(peer)
public macro TF_REGISTRY_FUNCTION(_ type: Any.Type) = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "TF_REGISTRY_FUNCTION_Macro")

/// Apply this macro to an OpenUSD plugin entry point to
/// register your plugin with the OpenUSD runtime. See
/// <doc:WritingAndUsingOpenUSDPlugins> for more information.
@attached(peer)
public macro SWIFTUSD_PLUGIN() = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "SWIFTUSD_PLUGIN_Macro")

extension __Overlay {
    fileprivate static nonisolated(unsafe) var Tf_RegistryInitCtor_libraries = Set<String>()
    
    /// Don't call this from user code.
    //
    // Fake C++ static initialization of `_ARCH_ENSURE_PER_LIB_INIT(Tf_RegistryStaticInit, _tfRegistryInit);`
    // in the C++ version of `TF_REGISTRY_DEFINE` in Swift. See the comment in
    // _OpenUSD_MacroImplementations/PluginAndTfMacros.swift. 
    public static func Tf_RegistryInitCtor(_ library: String) {
        if Tf_RegistryInitCtor_libraries.insert(library).inserted {
            pxr.Tf_RegistryInitCtor(library)
        }
    }
}

#else

// Add unavailable macro declarations for any platforms we don't support so users get a clear diagnostic.
// 
// In theory it shouldn't be too hard to add support for other platforms, since TF_REGISTRY_FUNCTION in Swift
// is just copying TF_REGISTRY_FUNCTION in C++, which delegates its platform-specific stuff to
// ARCH_CONSTRUCTOR in pxr/base/arch/attributes.h. 

@available(*, unavailable, message: "TF_REGISTRY_FUNCTION is only available on Apple platforms in Swift")
@attached(peer)
public macro TF_REGISTRY_FUNCTION(_ type: Any.Type) = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "TF_REGISTRY_FUNCTION_Macro")

@available(*, unavailable, message: "SWIFTUSD_PLUGIN is only available on Apple platforms in Swift")
@attached(peer)
public macro SWIFTUSD_PLUGIN() = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "SWIFTUSD_PLUGIN_Macro")

#endif // #if canImport(Darwin)