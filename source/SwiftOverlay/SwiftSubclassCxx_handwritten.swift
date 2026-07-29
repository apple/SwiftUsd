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

fileprivate let envVarName = "SWIFTUSD_SWIFT_SUBCLASS_CXX_ZOMBIE_CREATION_BEHAVIOR"

extension __Overlay {
    fileprivate enum Behavior {
        case warn
        case terminate
        case ignore

        init(rawValue: String?) {
            switch rawValue {
                case nil, "", "warn", "default": self = .warn
                case "terminate": self = .terminate
                case "ignore": self = .ignore
                default:
                    print("Warning: Unknown value '\(rawValue)' for \(envVarName), defaulting to 'warn'")
                    self = .warn
            }
        }
    }

    fileprivate static nonisolated(unsafe) var behavior: Behavior = {
        Behavior(rawValue: ProcessInfo.processInfo.environment[envVarName])
    }()

    static func SwiftSubclassCxx_zombieCreated(swiftInstance: UnsafeMutableRawPointer?,
                                               cppInstance: UnsafeMutableRawPointer?,
                                               typeName: String) {
        func format(_ p: UnsafeMutableRawPointer?) -> String {
            guard let p else { return "0x0" }
            return String(describing: p)
        }
        let message = "Swift subclass of \(typeName) turned into a zombie. (Swift instance: \(format(swiftInstance)), C++ instance: \(format(cppInstance)))"
        switch behavior {
            case .ignore: return
            case .warn: print("Warning: \(message)")
            case .terminate: fatalError("Error: \(message)")
        }
    }
}







extension pxr.HioImage {
    // Note: In 9.0.0, change `deprecated` to `unavailable`. (Can't do it sooner without breaking source compatibility)
    
    /// Most users should use Overlay.HioImageWrapper instead of pxr.HioImage due to potential
    /// memory safety issues. Only use pxr.HioImage if you're writing an HioImage plugin in Swift
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "Use Overlay.HioImageWrapper.OpenForReading(_:_:_:_:_:) instead")
    public static func OpenForReading(_ filename: std.string,
                                      _ subimage: CInt = 0,
                                      _ mip: CInt = 0,
                                      _ sourceColorSpace: pxr.HioImage.SourceColorSpace = .init(rawValue: 2),
                                      _ suppressErrors: Bool = false) -> pxr.HioImageSharedPtr {
        // Nit: Should be `_ sourceColorSpace: pxr.HioImage.SourceColorSpace = .Auto`,
        // but that's a nested unscoped enum case, and in ast-answerer, SwiftSubclassCxx currently bypasses Import,
        // so FindEnums and EnumsCodeGen don't touch it. Not worth exposing by hand or via ast-answerer
        // just for this safety diagnostic that'll become unavailable in SwiftUsd 9.0.0. 
        
        return __OpenForReadingUnsafe(filename, subimage, mip, sourceColorSpace, suppressErrors)
    }

    /// Most users should use Overlay.HioImageWrapper instead of pxr.HioImage due to potential
    /// memory safety issues. Only use pxr.HioImage if you're writing an HioImage plugin in Swift
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "Use Overlay.HioImageWrapper.OpenForWriting(_:) instead")
    public static func OpenForWriting(_ filename: std.string) -> pxr.HioImageSharedPtr {
        return __OpenForWritingUnsafe(filename)
    }
}