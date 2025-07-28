//
//  SwiftOverlay_UsdPrimRange.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

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
