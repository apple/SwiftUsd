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

#ifndef SWIFTUSD_WORK_REDUCE_H
#define SWIFTUSD_WORK_REDUCE_H

#include "swiftUsd/Util/Util.h"
#include "pxr/base/work/reduce.h"

namespace _Overlay {
    struct WorkParallelReduceNLoopFunctor:
    public SwiftClosure<CopyableSwiftClass(*_Nonnull)(RetainableSwiftClass::object_t, size_t, size_t, CopyableSwiftClass)> {
        using SwiftClosure::SwiftClosure;
    };

    struct WorkParallelReduceNReductionFunctor:
        public SwiftClosure<CopyableSwiftClass(*_Nonnull)(RetainableSwiftClass::object_t, CopyableSwiftClass, CopyableSwiftClass)> {
        using SwiftClosure::SwiftClosure;

        CopyableSwiftClass WorkParallelReduceN(CopyableSwiftClass, size_t, WorkParallelReduceNLoopFunctor, size_t) const;
        CopyableSwiftClass WorkParallelReduceN(CopyableSwiftClass, size_t, WorkParallelReduceNLoopFunctor) const;
    };
}

#endif /* SWIFTUSD_WORK_REDUCE_H */
