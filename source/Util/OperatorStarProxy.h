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

#ifndef SWIFTUSD_UTIL_OPERATORSTARPROXY_H
#define SWIFTUSD_UTIL_OPERATORSTARPROXY_H

namespace __Overlay {
    // A proxy over an object with an `operator*()` method. Useful
    // for providing our own protocol conformances to certain Swift-Cxx interop
    // synthesized protocols where the compiler does the wrong thing. 
    template <typename T>
    struct OperatorStarProxy {
        T impl;
        
        OperatorStarProxy(T impl) :
            impl(impl) {}
        
        decltype(impl.operator*())  operator*() const {
            return impl.operator*();
        }
        
        decltype(impl.operator->())  operator->() const {
            return impl.operator->();
        }
    };
}

#endif /* SWIFTUSD_UTIL_OPERATORSTARPROXY_H */
