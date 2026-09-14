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

#ifndef SWIFTUSD_WRAPPERS_STDOSTREAMWRAPPER_H
#define SWIFTUSD_WRAPPERS_STDOSTREAMWRAPPER_H

#include <ostream>
#include <string>

namespace Overlay {
    /// Minimal std::ostream wrapper for SdfFileFormat plugins. 
    /// Intentionally not fully-featured. Don't use this unless you're
    /// writing an SdfFileFormat plugin. 
    class StdOstreamWrapper {
    public:
        #if !__swift__
        // Intentionally return void because Swift's syntax doesn't support
        // `a << b << c` without parentheses, so we'd rather users use multiple
        // lines for multi-step outputing.
        //
        // Also, hide from Swift because Swift 6.1 crashes during a SIL phase. 
        void operator<<(std::string const&) const;
        #endif // #if !__swift__
        void __operatorLessThanLessThan(std::string const&) const;

        // MARK: SwiftUsd implementation access

        /// SwiftUsd wrapping constructor
        StdOstreamWrapper(std::ostream&);

        StdOstreamWrapper(const StdOstreamWrapper&) = delete;
        StdOstreamWrapper& operator=(const StdOstreamWrapper&) = delete;
        StdOstreamWrapper(StdOstreamWrapper&&) = default;
        StdOstreamWrapper& operator=(StdOstreamWrapper&&) = default;
        ~StdOstreamWrapper();

        std::ostream* get() const;

    private:
        std::ostream* _impl;
    };
}


#endif /* SWIFTUSD_WRAPPERS_STDOSTREAMWRAPPER_H */
