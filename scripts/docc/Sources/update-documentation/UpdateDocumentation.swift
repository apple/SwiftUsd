//
//  UpdateDocumentation.swift
//  SwiftUsd-DocC-Helper
//
//  Created by Maddy Adams on 12/12/24.
//

import Foundation
import SwiftUsdDoccUtil

@main
struct UpdateDocumentation {
    static func main() async throws {
        try await ShellUtil.runCommandAndWait(arguments: [
            "xcrun", "docc", "convert",
            "--emit-lmdb-index",
            "--output-path", Driver.shared.doccArchiveURL,
            Driver.shared.doccCatalogURL,
            "--additional-symbol-graph-dir", Driver.shared.symbolGraphsURL
        ])
        
        try await ShellUtil.runCommandAndWait(arguments: [
            "xcrun", "docc", "convert",
            "--emit-lmdb-index",
            "--output-path", Driver.shared.docsURL,
            Driver.shared.doccCatalogURL,
            "--additional-symbol-graph-dir", Driver.shared.symbolGraphsURL,
            "--transform-for-static-hosting",
            "--hosting-base-path", "SwiftUsd"
        ])
    }
}
