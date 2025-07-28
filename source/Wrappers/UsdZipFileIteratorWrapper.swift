//
//  UsdZipFileIteratorWrapper.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 4/23/25.
//

import Foundation
import OpenUSD
import CxxStdlib

extension pxr.UsdZipFile {
    /// Returns iterator to the file with the given \p path in this zip
    /// archive, or end() if no such file exists.
    public func Find(_ path: std.string) -> Overlay.UsdZipFileIteratorWrapper {
        __Overlay.UsdZipFileIteratorWrapper(self, self.__FindUnsafe(path))
    }        
}

extension pxr.UsdZipFile: Sequence {
    public typealias Iterator = Overlay.UsdZipFileIteratorWrapper
    public typealias Element = Overlay.UsdZipFileIteratorWrapper
    
    public func makeIterator() -> Overlay.UsdZipFileIteratorWrapper {
        __Overlay.UsdZipFileIteratorWrapper(self, self.__beginUnsafe())
    }
}

extension Overlay.UsdZipFileIteratorWrapper: IteratorProtocol {
    public mutating func next() -> Self? {
        let zipFile = __Overlay.UsdZipFileIteratorWrapper__zipFile(self)
        let end = __Overlay.UsdZipFileIteratorWrapper(zipFile, zipFile.__endUnsafe())
        
        guard self != end else { return nil }
        let result = self
        self = self.successor()
        return result
    }
}

extension Overlay.UsdZipFileIteratorWrapper: Equatable {}
@available(*, unavailable) extension Overlay.UsdZipFileIteratorWrapper: @unchecked Sendable {}