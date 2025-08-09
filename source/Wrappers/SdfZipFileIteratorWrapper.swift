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
