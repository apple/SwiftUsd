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

// Important: In C++, size_t is an unsigned value, but Swift implicitly converts
// this value to _signed_ Int. (Except for a template-related bug, which is worked
// around in Util/Utils.h). For greater consistency with Swift-Cxx, we choose
// to expose libWork APIs as taking Int in Swift. (But be aware, size_t in Swift
// is generally a different type than size_t in C++)

fileprivate class WorkParallelReduceNLoopClosureHolder: _Overlay.RetainableByCxx {
    func run(_ start: Int, _ end: Int, _ identity: _Overlay.CopyableSwiftClass) -> _Overlay.CopyableSwiftClass { fatalError() }

    func toCxx() -> _Overlay.WorkParallelReduceNLoopFunctor {
        .init(giveCxxOwnership(),
              { WorkParallelReduceNLoopClosureHolder.takeSelfFromCxx($0!).run($1, $2, $3) })
    }

    class Generic<T>: WorkParallelReduceNLoopClosureHolder {
        var closure: @Sendable (Int, Int, T) -> (T)

        init(_ closure: @escaping @Sendable (Int, Int, T) -> (T)) {
            self.closure = closure
        }

        override func run(_ start: Int, _ end: Int, _ _identity: _Overlay.CopyableSwiftClass) -> _Overlay.CopyableSwiftClass {
            let identity = withExtendedLifetime(_identity) { _Overlay.CopyableValueHolder<T>.takeSelfFromCxx($0.get()) }
            let ret = _Overlay.CopyableValueHolder(closure(start, end, identity.value))
            return ret.giveCxxOwnership()
        }
    }
}

fileprivate class WorkParallelReduceNReductionClosureHolder: _Overlay.RetainableByCxx {
    func run(_ lhs: _Overlay.CopyableSwiftClass, _ rhs: _Overlay.CopyableSwiftClass) -> _Overlay.CopyableSwiftClass { fatalError() }

    func toCxx() -> _Overlay.WorkParallelReduceNReductionFunctor {
        .init(giveCxxOwnership(),
              { WorkParallelReduceNReductionClosureHolder.takeSelfFromCxx($0!).run($1, $2) })
    }

    class Generic<T>: WorkParallelReduceNReductionClosureHolder {
        var closure: @Sendable (T, T) -> T

        init(_ closure: @escaping @Sendable (T, T) -> T) {
            self.closure = closure
        }

        override func run(_ _lhs: _Overlay.CopyableSwiftClass, _ _rhs: _Overlay.CopyableSwiftClass) -> _Overlay.CopyableSwiftClass {
            let lhs = withExtendedLifetime(_lhs) { _Overlay.CopyableValueHolder<T>.takeSelfFromCxx($0.get()).value }
            let rhs = withExtendedLifetime(_rhs) { _Overlay.CopyableValueHolder<T>.takeSelfFromCxx($0.get()).value }
            let ret = _Overlay.CopyableValueHolder(closure(lhs, rhs))
            return ret.giveCxxOwnership()
        }
    }
}


extension pxr {
    public static func WorkParallelReduceN<T>(_ _identity: T,
                                              _ n: Int,
                                              _ grainSize: Int,
                                              _ loopCallback: @Sendable (Int, Int, T) -> T,
                                              _ reductionCallback: @Sendable (T, T) -> T) -> T {
        withoutActuallyEscaping(loopCallback) { loopCallback in
            withoutActuallyEscaping(reductionCallback) { reductionCallback in
                let loopHolder = WorkParallelReduceNLoopClosureHolder.Generic<T>(loopCallback)
                let reductionHolder = WorkParallelReduceNReductionClosureHolder.Generic<T>(reductionCallback)
                let identity = _Overlay.CopyableValueHolder<T>(_identity)
                
                let result = reductionHolder.toCxx().WorkParallelReduceN(identity.giveCxxOwnership(),
                                                                         n,
                                                                         loopHolder.toCxx(),
                                                                         grainSize)
                return withExtendedLifetime(result) {
                    _Overlay.CopyableValueHolder<T>.takeSelfFromCxx(result.get()).value
                }
            }
        }
    }

    public static func WorkParallelReduceN<T>(_ _identity: T,
                                              _ n: Int,
                                              _ loopCallback: @Sendable (Int, Int, T) -> T,
                                              _ reductionCallback: @Sendable (T, T) -> T) -> T {
        withoutActuallyEscaping(loopCallback) { loopCallback in
            withoutActuallyEscaping(reductionCallback) { reductionCallback in
                let loopHolder = WorkParallelReduceNLoopClosureHolder.Generic<T>(loopCallback)
                let reductionHolder = WorkParallelReduceNReductionClosureHolder.Generic<T>(reductionCallback)
                let identity = _Overlay.CopyableValueHolder<T>(_identity)
                
                let result = reductionHolder.toCxx().WorkParallelReduceN(identity.giveCxxOwnership(),
                                                                         n,
                                                                         loopHolder.toCxx())
                return withExtendedLifetime(result) {
                    _Overlay.CopyableValueHolder<T>.takeSelfFromCxx(result.get()).value
                }
            }
        }
    }

}