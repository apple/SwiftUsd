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

// Original documentation for pxr::WorkRunDetachedTask from
// https://github.com/PixarAnimationStudios/OpenUSD/blob/v25.08/pxr/base/work/detachedTask.h


fileprivate class WorkRunDetachedTaskClosureHolder: _Overlay.RetainableByCxx {
    var closure: @Sendable () -> ()

    init(_ closure: @escaping @Sendable () -> ()) {
        self.closure = closure
    }

    func toCxx() -> _Overlay.WorkRunDetachedTaskFunctor {
        .init(giveCxxOwnership(),
              { WorkRunDetachedTaskClosureHolder.takeSelfFromCxx($0!).closure() })
    }
}

extension pxr {
    /// Invoke `closure` asynchronously, discard any errors it produces, and provide
    /// no way to wait for it to complete.
    public static func WorkRunDetachedTask(_ closure: @escaping @Sendable () -> ()) {
        WorkRunDetachedTaskClosureHolder(closure).toCxx().WorkRunDetachedTask()
    }
}