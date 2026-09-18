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
import Subprocess
import ArgumentParser

struct FileHandleTextOutputStream: TextOutputStream {
    let handle: FileHandle
    
    func write(_ string: String) {
        handle.write(Data(string.utf8))
    }
    
    init(handle: FileHandle) {
        self.handle = handle
    }
    
    static var stderr: FileHandleTextOutputStream {
        get {
            return FileHandleTextOutputStream(handle: .standardError)
        } set {
            
        }
    }
}

extension ExecutionResult {
    func check(_ command: String) throws {
        switch terminationStatus {
        case .exited(let x):
            if x != 0 {
                print("Error: \(command) failed with exit code \(x).", to: &FileHandleTextOutputStream.stderr)
                throw ExitCode(x)
            }
            
        case .signaled(let x):
            print("Error: \(command) failed with signal \(x).", to: &FileHandleTextOutputStream.stderr)
            throw ExitCode(x)
        }
    }
}
