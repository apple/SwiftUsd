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

#ifndef SWIFTUSD_WORK_LOOPS_H
#define SWIFTUSD_WORK_LOOPS_H

#include "swiftUsd/Util/Util.h"
#include "pxr/base/work/loops.h"

namespace _Overlay {
    struct WorkParallelForNFunctor:
    public SwiftClosure<void (*_Nonnull)(RetainableSwiftClass::object_t, size_t, size_t)> {
        using SwiftClosure::SwiftClosure;

        void WorkSerialForN(size_t n) const;
        void WorkParallelForN(size_t n, size_t grainSize) const;
        void WorkParallelForN(size_t n) const;
    };
}

namespace _Overlay {
    struct WorkParallelForEachFunctor:
    public SwiftClosure<void (*_Nonnull)(RetainableSwiftClass::object_t, CopyableSwiftClass::object_t)> {
        using SwiftClosure::SwiftClosure;

        struct Iterator {
            typedef void (*_Nonnull increment_t)(CopyableSwiftClass::object_t);
            typedef bool (*_Nonnull isEqual_t)(CopyableSwiftClass::object_t, CopyableSwiftClass::object_t);

            Iterator(CopyableSwiftClass obj, increment_t increment, isEqual_t isEqual);

            Iterator operator*();
            Iterator& operator->();
            Iterator operator++();
            Iterator operator++(int);
            bool operator==(const Iterator&);
            bool operator!=(const Iterator&);

            operator CopyableSwiftClass::object_t() const;

        private:
            CopyableSwiftClass _obj;
            increment_t _increment;
            isEqual_t _isEqual;
        };
        
        void WorkParallelForEach(Iterator start, Iterator end) const;
    };
}

template <> struct std::iterator_traits<_Overlay::WorkParallelForEachFunctor::Iterator> {
    using iterator_category = std::input_iterator_tag;
    using reference = _Overlay::WorkParallelForEachFunctor::Iterator&;
};

#endif /* SWIFTUSD_WORK_LOOPS_H */
