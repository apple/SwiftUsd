//
//  SdfZipFileIteratorWrapper.swift
//  SwiftUsd
//
//  Created by Maddy Adams on 4/23/25.
//

import Foundation
import OpenUSD
import CxxStdlib

extension pxr.SdfZipFile {
    /// Returns iterator to the file with the given \p path in this zip
    /// archive, or end() if no such file exists.
    public func Find(_ path: std.string) -> Overlay.SdfZipFileIteratorWrapper {
        __Overlay.SdfZipFileIteratorWrapper(self, self.__FindUnsafe(path))
    }        
}

extension pxr.SdfZipFile: Sequence {
    public typealias Iterator = Overlay.SdfZipFileIteratorWrapper
    public typealias Element = Overlay.SdfZipFileIteratorWrapper
    
    public func makeIterator() -> Overlay.SdfZipFileIteratorWrapper {
        __Overlay.SdfZipFileIteratorWrapper(self, self.__beginUnsafe())
    }
}

extension Overlay.SdfZipFileIteratorWrapper: IteratorProtocol {
    public mutating func next() -> Self? {
        let zipFile = __Overlay.SdfZipFileIteratorWrapper__zipFile(self)
        let end = __Overlay.SdfZipFileIteratorWrapper(zipFile, zipFile.__endUnsafe())
        
        guard self != end else { return nil }
        let result = self
        self = self.successor()
        return result
    }
}

extension Overlay.SdfZipFileIteratorWrapper: Equatable {}
@available(*, unavailable) extension Overlay.SdfZipFileIteratorWrapper: @unchecked Sendable {}