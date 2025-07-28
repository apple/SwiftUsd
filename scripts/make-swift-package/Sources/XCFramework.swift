//
//  XCFramework.swift
//  make-swift-package
//
//  Created by Maddy Adams on 2/13/25.
//

import Foundation

/// Combines `.framework` bundles into a `.xcframework` bundle for Apple platforms
struct XCFramework {
    var frameworks: [Framework]
    
    var xcframeworkPath: URL!
    
    var name: String { frameworks.first!.name }
    
    /// Makes an XCFramework from versions of the same framework compiled for different platforms
    init(fsInfo: FileSystemInfo, frameworks: [Framework]) async {
        self.frameworks = frameworks
        
        print("Making XCFramework \(name).xcframework...")
        let xcframeworksDir = fsInfo.swiftUsdPackage.tmpDir.appending(path: "XCFrameworks")
        try! FileManager.default.createDirectory(at: xcframeworksDir, withIntermediateDirectories: true)
        
        xcframeworkPath = xcframeworksDir.appending(component: "\(name).xcframework")
        if FileManager.default.directoryExists(at: xcframeworkPath) {
            print("\(path: xcframeworkPath) already exists, returning early")
            return
        }
        
        var frameworkArguments = [any ShellUtil.Argument]()
        for framework in frameworks {
            frameworkArguments.append("-framework")
            frameworkArguments.append(framework.fsInfo.url)
        }
        try! await ShellUtil.runCommandAndWait(arguments: ["xcodebuild", "-create-xcframework"] + frameworkArguments + ["-output", xcframeworkPath],
                                               quiet: true)
    }
}
