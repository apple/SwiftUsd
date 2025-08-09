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

#ifndef SWIFTUSD_SWIFTOVERLAY_SWIFTCXXMACROS_H
#define SWIFTUSD_SWIFTOVERLAY_SWIFTCXXMACROS_H

#include <swift/bridging>

#define SWIFT_UNAVAILABLE_MESSAGE(msg) __attribute__((availability(swift, unavailable, message=msg)))
#define SWIFT_UNAVAILABLE __attribute__((availability(swift, unavailable)))



// Swift 6.1 compiler provides SWIFT_RETURNS_RETAINED and SWIFT_RETURNS_UNRETAINED,
// but we want to have clear annotations for Swift 6.0, even if they don't do anything
#ifndef SWIFT_RETURNS_RETAINED
#define SWIFT_RETURNS_RETAINED __attribute__((swift_attr("returns_retained"))) __attribute__((cf_returns_retained))
#endif

#ifndef SWIFT_RETURNS_UNRETAINED
#define SWIFT_RETURNS_UNRETAINED __attribute__((swift_attr("returns_unretained"))) __attribute__((cf_returns_not_retained))
#endif



#endif /* SWIFTUSD_SWIFTOVERLAY_SWIFTCXXMACROS_H */
