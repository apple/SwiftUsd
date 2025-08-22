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

// Original documentation for pxr::WorkSerialForN, pxr::WorkParallelForN, and pxr::WorkParallelForEach from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/base/work/loops.h


// Important: In C++, size_t is an unsigned value, but Swift implicitly converts
// this value to _signed_ Int. (Except for a template-related bug, which is worked
// around in Util/Utils.h). For greater consistency with Swift-Cxx, we choose
// to expose libWork APIs as taking Int in Swift. (But be aware, size_t in Swift
// is generally a different type than size_t in C++)

fileprivate class WorkParallelForNClosureHolder: _Overlay.RetainableByCxx {
    var closure: @Sendable (Int, Int) -> ()

    init(_ closure: @escaping @Sendable (Int, Int) -> ()) {
        self.closure = closure
    }

    func toCxx() -> _Overlay.WorkParallelForNFunctor {
        .init(giveCxxOwnership(),
              { WorkParallelForNClosureHolder.takeSelfFromCxx($0!).closure($1, $2) })
    }
}




// Note: We use a generic subclass because a C function pointer
// cannot be formed from a closure that captures generic arguments,
// which includes generic metatypes
fileprivate class WorkParallelForEachIndexHolder: _Overlay.CopyableByCxx {
     func makeCopy() -> Self { fatalError() }
     func increment() { fatalError() }
     func isEqual(_ other: WorkParallelForEachIndexHolder) -> Bool { fatalError() }

     func toCxx() -> _Overlay.WorkParallelForEachFunctor.Iterator {
         .init(giveCxxOwnership(),
               { WorkParallelForEachIndexHolder.takeSelfFromCxx($0).increment() },
               { let slf = WorkParallelForEachIndexHolder.takeSelfFromCxx($0)
                 let other = WorkParallelForEachIndexHolder.takeSelfFromCxx($1)
                 return slf.isEqual(other) }
          )
     }

     class Generic<C: Collection>: WorkParallelForEachIndexHolder {
         var collection: WorkParallelForEachClosureHolder.Generic<C>
         var index: C.Index

         init(_ collection: WorkParallelForEachClosureHolder.Generic<C>, _ index: C.Index) {
             self.collection = collection
             self.index = index
         }

         override func increment() {
             index = collection.collection.index(after: index)
         }

         override func makeCopy() -> Self {
             Generic<C>.init(collection, index) as! Self
         }

         override func isEqual(_ _other: WorkParallelForEachIndexHolder) -> Bool {
             let other = _other as! Generic<C>
             return index == other.index
         }
     }
}

fileprivate class WorkParallelForEachClosureHolder: _Overlay.RetainableByCxx {
    func run(_ other: UnsafeRawPointer) { fatalError() }

    func toCxx() -> _Overlay.WorkParallelForEachFunctor {
        .init(giveCxxOwnership(),
              { WorkParallelForEachClosureHolder.takeSelfFromCxx($0!).run($1!) })
    }

    class Generic<C: Collection>: WorkParallelForEachClosureHolder {
        var closure: @Sendable (C.Element) -> ()
        var collection: C

        init(_ closure: @escaping @Sendable (C.Element) -> (), _ collection: C) {
            self.closure = closure
            self.collection = collection
        }

        override func run(_ other: UnsafeRawPointer) {
            let index = WorkParallelForEachIndexHolder.Generic<C>.takeSelfFromCxx(other)
            closure(collection[index.index])
        }
    }
}

extension pxr {
    /// A serial version of WorkParallelForN as a drop in replacement to
    /// selectively turn off multithreading for a single parallel loop for easier
    /// debugging. 
    public static func WorkSerialForN(_ n: Int, _ closure: @Sendable (_ begin: Int, _ end: Int) -> ()) {
        withoutActuallyEscaping(closure) {
            WorkParallelForNClosureHolder($0).toCxx().WorkSerialForN(n)
        }
    }

    /// Runs `closure` in parallel over the range 0 to n.
    ///
    /// `grainSize` specifies a minimum amount of work to be done per-thread. There
    /// is overhead to launching a thread (or task) and a typical guideline is that
    /// you want to have at least 10,000 instructions to count for the overhead of
    /// launching a thread.
    public static func WorkParallelForN(_ n: Int, _ grainSize: Int, _ closure: @Sendable (_ begin: Int, _ end: Int) -> ()) {
        withoutActuallyEscaping(closure) {
            WorkParallelForNClosureHolder($0).toCxx().WorkParallelForN(n, grainSize)
        }
    }

    /// Runs `closure` in parallel over the range 0 to n.
    public static func WorkParallelForN(_ n: Int, _ closure: @Sendable (_ begin: Int, _ end: Int) -> ()) {
        withoutActuallyEscaping(closure) {
            WorkParallelForNClosureHolder($0).toCxx().WorkParallelForN(n)
        }
    }

    /// Runs `closure` in parallel over the elements in `collection`
    public static func WorkParallelForEach<C: Collection>(_ collection: C, _ closure: @Sendable (C.Element) -> ()) {
        withoutActuallyEscaping(closure) {
            let closureHolder = WorkParallelForEachClosureHolder.Generic($0, collection)
            let start = WorkParallelForEachIndexHolder.Generic<C>(closureHolder, closureHolder.collection.startIndex)
            let end = WorkParallelForEachIndexHolder.Generic<C>(closureHolder, closureHolder.collection.endIndex)
            
            closureHolder.toCxx().WorkParallelForEach(start.toCxx(), end.toCxx())
        }
    }
}