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

#ifndef SWIFTUSD_UTIL_TYPETRAITS_H
#define SWIFTUSD_UTIL_TYPETRAITS_H

namespace _Overlay {
    /// replace_all_t<In, Pattern, Replacement> will yield `In` with all
    /// occurrences of `Pattern` replaced with `Replacement`, recursively.
    /// This is a workaround for Workaround for rdar://158808673 (size_t imported as UInt instead of Int when passed through class template),
    /// and you probably shouldn't use this unless you really need to. 
    template <typename In, typename Pattern, typename Replacement>
    struct replace_all;

    
    // Base cases
    template <typename In, typename Pattern, typename Replacement>
    struct replace_all { using type = In; };

    template <typename In, typename Replacement>
    struct replace_all<In, In, Replacement> { using type = Replacement; };

    // Helper class
    template <typename In, typename Pattern, typename Replacement>
    using replace_all_t = typename replace_all<In, Pattern, Replacement>::type;

    // CV qualifiers
    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<const In, Pattern, Replacement> { using type = const replace_all_t<In, Pattern, Replacement>; };

    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<volatile In, Pattern, Replacement> { using type = volatile replace_all_t<In, Pattern, Replacement>; };

    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<const volatile In, Pattern, Replacement> { using type = const volatile replace_all_t<In, Pattern, Replacement>; };

    // Pointer, L-value ref, R-value ref
    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<In*, Pattern, Replacement> { using type = replace_all_t<In, Pattern, Replacement>*; };

    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<In&, Pattern, Replacement> { using type = replace_all_t<In, Pattern, Replacement>&; };

    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<In&&, Pattern, Replacement> { using type = replace_all_t<In, Pattern, Replacement>&&; };

    // Pointer to data member, pointer to member function
    template <typename Member, typename Base, typename Pattern, typename Replacement>
    struct replace_all<Member Base::*, Pattern, Replacement> { using type = replace_all_t<Member, Pattern, Replacement> replace_all_t<Base, Pattern, Replacement>::*; };

    template <typename R, typename Base, typename... Args, typename Pattern, typename Replacement>
    struct replace_all<R(Base::*)(Args...), Pattern, Replacement> { using type = replace_all_t<R, Pattern, Replacement>(replace_all_t<Base, Pattern, Replacement>::*)(replace_all_t<Args, Pattern, Replacement>...); };

    // Array
    template <typename In, typename Pattern, typename Replacement>
    struct replace_all<In[], Pattern, Replacement> { using type = replace_all_t<In, Pattern, Replacement>[]; };

    template <typename In, typename Pattern, typename Replacement, size_t n>
    struct replace_all<In[n], Pattern, Replacement> { using type = replace_all_t<In, Pattern, Replacement>[n]; };

    // Function type
    template <typename R, typename... Args, typename Pattern, typename Replacement>
    struct replace_all<R(Args...), Pattern, Replacement> { using type = replace_all_t<R, Pattern, Replacement>(replace_all_t<Args, Pattern, Replacement>...); };

    // Template template type
    template <template<typename...> typename In, typename... Args, typename Pattern, typename Replacement>
    struct replace_all<In<Args...>, Pattern, Replacement> { using type = In<replace_all_t<Args, Pattern, Replacement>...>; };

}

#endif /* SWIFTUSD_UTIL_TYPETRAITS_H */
