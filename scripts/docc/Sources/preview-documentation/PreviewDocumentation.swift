//
//  PreviewDocumentation.swift
//  SwiftUsd-DocC-Helper
//
//  Created by Maddy Adams on 12/12/24.
//

import Foundation
import SwiftUsdDoccUtil

@main
struct PreviewDocumentation {
    static func main() async throws {
        var hasOpenedAddress = false
        
        for try await line in try ShellUtil.runCommandAndGetOutput(arguments: [
            "xcrun", "docc", "preview",
            "--additional-symbol-graph-dir", Driver.shared.symbolGraphsURL,
            Driver.shared.doccCatalogURL
        ]) {
            print(line)
            
            guard !hasOpenedAddress else { continue }
            guard let match = line.wholeMatch(of: /\s*Address: (http:\/\/localhost:.*)\s*/)?.output.1 else { continue }
            hasOpenedAddress = true
            try await ShellUtil.runCommandAndWait(arguments: ["open", String(match)])
        }
    }
}
