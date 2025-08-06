// ===-------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd authors. All Rights Reserved. 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at: 
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.     
// 
// SPDX-License-Identifier: Apache-2.0
// ===-------------------------------------------------------------------===//

import Foundation


extension Overlay {
    class Box<T> {
        var value: T
        init(value: T) {
            self.value = value
        }
    }

    /// A wrapper for `pxr.UsdPrimRange.iterator` that exposes the `IsPostVisit()` and `PruneChildren()` methods for a `UsdPrimRange`
    public struct UsdPrimRangeIteratedSequence: Sequence {
        var box: Box<Overlay.UsdPrimRangeIteratorWrapper>

        init(_ range: pxr.UsdPrimRange) {
            box = Box(value: range.makeIterator())
        }

        public func makeIterator() -> Iterator {
            .init(box: box)
        }

        public struct Iterator: IteratorProtocol {
            var box: Box<Overlay.UsdPrimRangeIteratorWrapper>

            public mutating func next() -> (View, pxr.UsdPrim)? {
                box.value.next().map { (View(box: box), $0) }
            }

            public struct View {
                var box: Box<Overlay.UsdPrimRangeIteratorWrapper>

                /// Return true if the iterator points to a prim visited the second time
                /// (in post order) for a pre- and post-order iterator, false otherwise.
                // Original documentation from https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/usd/usd/primRange.h
                public func IsPostVisit() -> Bool {
                    box.value.IsPostVisit()
                }

                /// Behave as if the current prim has no children when next advanced.
                /// Issue an error if this is a pre- and post-order iterator that
                /// IsPostVisit().
                // Original documentation from https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/usd/usd/primRange.h
                public func PruneChildren() {
                    box.value.PruneChildren()
                }
            }
        }
    }
}
