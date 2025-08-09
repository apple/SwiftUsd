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

import Foundation


extension pxr.UsdPrimRange: Sequence {
    public func makeIterator() -> Overlay.UsdPrimRangeIteratorWrapper {
        .init(self)
    }
}

extension Overlay.UsdPrimRangeIteratorWrapper: IteratorProtocol {
    public mutating func next() -> pxr.UsdPrim? {
        let result = advanceAndGetCurrent()
        return result.IsValid() ? result : nil
    }

    public typealias Element = pxr.UsdPrim
}


extension pxr.UsdPrimRange {
    /// Returns an iterator that exposes the `isPostVisit` and `pruneChildren()` properties for a `UsdPrimRange`
    public func withIterator() -> Overlay.UsdPrimRangeIteratedSequence {
        .init(self)
    }
}
