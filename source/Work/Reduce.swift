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

// Original documentation for pxr::WorkParallelReduceN from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/base/work/reduce.h

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
    /// Recursively splits the range [0, `n`) into subranges, which are then
    /// reduced by invoking `loopCallback` in parallel.
    ///
    /// Each invocation of `loopCallback` returns a single value that is the
    /// result of joining the elements in the respective subrange. These values
    /// are then further joined using the binary operator `reductionCallback`,
    /// until only a single value remains. This single value is then the result
    /// of joining all elements over the entire range [0, `n`).
    /// 
    /// `grainSize` specifies a minimum amount of work to be done per-thread.
    /// There is overhead to launching a task and a typical guideline is that
    /// you want to have at least 10,000 instructions to count for the overhead of
    /// launching that task.
    // Note: For whatever reason, this function doesn't have public documentation visibility by default
    @_documentation(visibility: public)
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

    /// Recursively splits the range [0, `n`) into subranges, which are then
    /// reduced by invoking `loopCallback` in parallel.
    ///
    /// Each invocation of `loopCallback` returns a single value that is the
    /// result of joining the elements in the respective subrange. These values
    /// are then further joined using the binary operator `reductionCallback`,
    /// until only a single value remains. This single value is then the result
    /// of joining all elements over the entire range [0, `n`).
    ///
    /// This overload does not accept a grain size parameter and instead attempts
    /// to automatically deduce a grain size that is optimal for the current
    /// resource utilization and provided workload.
    // Note: For whatever reason, this function doesn't have public documentation visibility by default
    @_documentation(visibility: public)
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