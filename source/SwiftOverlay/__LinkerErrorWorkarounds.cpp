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

#include "pxr/base/arch/defines.h"

#if defined(ARCH_OS_DARWIN) && defined(OPENUSD_SWIFT_BUILD_FROM_CLI)
// The asm("") trick makes macOS non-Xcode build invocations fail due to duplicate symbols,
// so disable it for that.
  #define CUSTOM_MANGLING(mangled_name, f_decl...) f_decl
#else
  #define CUSTOM_MANGLING(mangled_name, f_decl...) f_decl asm(#mangled_name); f_decl
#endif // #if defined(ARCH_OS_DARWIN) && defined(OPENUSD_SWIFT_BUILD_FROM_CLI)




#ifdef ARCH_OS_DARWIN

#include <atomic>
#include "pxr/base/tf/refPtr.h"

// No current linker error workarounds required on Darwin

#endif // #ifdef ARCH_OS_DARWIN




#ifdef ARCH_OS_LINUX
#include <vector>
#include "pxr/base/tf/weakPtr.h"
#include "pxr/base/plug/plugin.h"

template class std::_Vector_base<pxrInternal_v0_25_5__pxrReserved__::TfWeakPtr<pxrInternal_v0_25_5__pxrReserved__::PlugPlugin>, std::allocator<pxrInternal_v0_25_5__pxrReserved__::TfWeakPtr<pxrInternal_v0_25_5__pxrReserved__::PlugPlugin> > >;
void __swiftUsd_LinkerErrorWorkaround_linux1() {
    std::_Vector_base<pxrInternal_v0_25_5__pxrReserved__::TfWeakPtr<pxrInternal_v0_25_5__pxrReserved__::PlugPlugin>, std::allocator<pxrInternal_v0_25_5__pxrReserved__::TfWeakPtr<pxrInternal_v0_25_5__pxrReserved__::PlugPlugin> > > x;
}

#ifndef DEBUG
// On Linux, the custom mangling should start with one underscore, not two like Darwin.

CUSTOM_MANGLING(_ZN34pxrInternal_v0_25_5__pxrReserved__23Tf_RefPtrTracker_DeleteEPKvPKNS_9TfRefBaseES1_,
void __0(void const* a, const pxr::TfRefBase* b, void const* c)) {
    pxr::Tf_RefPtrTracker_Delete(a, b, c);
}
CUSTOM_MANGLING(_ZN34pxrInternal_v0_25_5__pxrReserved__24Tf_RefPtrTracker_LastRefEPKvPKNS_9TfRefBaseES1_,
void __1(void const* a, const pxr::TfRefBase* b, void const* c)) {
    pxr::Tf_RefPtrTracker_LastRef(a, b, c);
}

#endif // #ifndef DEBUG

#endif // #ifdef ARCH_OS_LINUX
