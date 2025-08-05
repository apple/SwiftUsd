//
//  SwiftOverlay_UsdPrimRangeIteratedSequence.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

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
