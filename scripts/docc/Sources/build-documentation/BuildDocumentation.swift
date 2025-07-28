//
//  BuildDocumentation.swift
//  SwiftUsd-DocC-Helper
//
//  Created by Maddy Adams on 12/12/24.
//

import Foundation
import ArgumentParser
import SymbolKit
import SwiftUsdDoccUtil

@main
struct BuildDocumentation: AsyncParsableCommand {
    fileprivate func removeIfExists(_ url: URL, isDirectory: Bool) async {
        if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
            try! await ShellUtil.runCommandAndWait(arguments: ["rm"] + (isDirectory ? ["-rf"] : []) + [url])
        }
    }
    
    fileprivate func buildSwiftSymbolGraph() async {
        print("Building Swift symbol graph...")
        try! await ShellUtil.runCommandAndWait(arguments: [
            "swift", "build",
            "--target", "OpenUSD",
            "-Xswiftc", "-emit-symbol-graph",
            "-Xswiftc", "-emit-symbol-graph-dir",
            "-Xswiftc", Driver.shared.symbolGraphsURL,
            "-Xswiftc", "-emit-extension-block-symbols",
            "-Xswiftc", "-DOPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS",
            "-Xswiftc", "-DOPENUSD_SWIFT_BUILD_FROM_CLI",
            "-Xcxx", "-DOPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS",
            "-Xcxx", "-DOPENUSD_SWIFT_BUILD_FROM_CLI",
        ], currentDirectoryURL: Driver.shared.swiftUsdRepoURL)
        
        try! FileManager.default.moveItem(at: Driver.shared.moduleAtObjcSymbolsURL,
                                          to: Driver.shared.moduleAtCppSymbolsURL)
        
        // SwiftSyntax makes a bunch of symbol graph files, but we don't want to get any of them
        for item in Array(FileManager.default.allUrls(under: Driver.shared.symbolGraphsURL)) {
            if !item.lastPathComponent.starts(with: "OpenUSD") {
                try! FileManager.default.removeItem(at: item)
            }
        }
    }
    
    func extractHeadersFromUmbrellaUrl(forCpp: Bool) async -> [URL] {
        // Take the lines in the umbrella header,
        // match them against a regex,
        // and extract the url
        
        let lines = Driver.shared.umbrellaHeaderURL.lines
        let compactMapped = lines.compactMap { (line) -> URL? in
            let regex = if forCpp {
                /\s*#include\s*"swiftUsd\/(.*)"\s*/
            } else {
                /\s*#includeforswiftdocc\s*"swiftUsd\/(.*)"\s*/
            }
            
            guard let match = line.wholeMatch(of: regex) else { return nil }

            let urlInSource = Driver.shared.sourceURL.appending(path: match.output.1)
            let urlInGeneratedPackage = Driver.shared.includeURL.appending(components: "swiftUsd", match.output.1)

            if FileManager.default.fileExists(atPath: urlInSource.path(percentEncoded: false)) {
                return urlInSource
            } else {
                return urlInGeneratedPackage
            }
        }
        return try! await compactMapped.reduce(into: []) { $0.append($1) }
    }
    
    fileprivate func buildCppSymbolGraph() async {
        print("Building C++ symbol graph...")
        
        // clang -extract-api is somehow dependent on the order of headers,
        // and will gain or lose 20 KB (20% of the file size), as well as
        // gaining or losing symbols, just if headers are reordered.
        // This seems like a clang bug. To work around it, we run
        // `clang -extract-api` once per header, instead of once
        // with all the headers
        func _run(header: URL, forCpp: Bool) async {
            let dest = Driver.shared.clangExtractAPISymbolsURL(header: header, forCpp: forCpp)
            
            try! await ShellUtil.runCommandAndWait(arguments: [
                "clang", "-extract-api",
                "-o", dest,
                "-x", "objective-c++-header",
                "-isystem", Driver.shared.includeURL,
                "-isystem", Driver.shared.sourceURL,
                "-std=gnu++17",
                "--product-name=OpenUSD",
                "-DOPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS",
                "-DOPENUSD_SWIFT_BUILD_FROM_CLI",
            ] + [header])
        }

        // Extract symbols from each header file meant for C++ usage,
        // and for each header file meant for Swift usage. If there's
        // overlap, that's okay, that means a header should produce
        // both Swift and C++ symbols in the symbol graph
        for header in await extractHeadersFromUmbrellaUrl(forCpp: true) {
            await _run(header: header, forCpp: true)
        }
        for header in await extractHeadersFromUmbrellaUrl(forCpp: false) {
            await _run(header: header, forCpp: false)
        }
    }
    
    fileprivate func saveUncleanedSymbolGraphs() {
        let toSave = try! FileManager.default.contentsOfDirectory(atPath: Driver.shared.symbolGraphsURL.path(percentEncoded: false))
        for f in toSave {
            try! FileManager.default.moveItem(at: Driver.shared.symbolGraphsURL.appending(path: f), to: Driver.shared.symbolGraphsURL.appending(path: f + ".safe"))
        }
    }
    
    fileprivate func cleanSymbolGraphs() async {
        print("Cleaning symbol graphs...")
        
        // Modify the symbol graphs, moving .symbols.json.safe to .symbols.json
        for srcFilename in try! FileManager.default.contentsOfDirectory(atPath: Driver.shared.symbolGraphsURL.path(percentEncoded: false))
        where srcFilename.hasSuffix(".safe") {
            let destFilename = srcFilename.prefix(srcFilename.count - ".safe".count)
            let srcURL = Driver.shared.symbolGraphsURL.appending(path: srcFilename)
            let destURL = Driver.shared.symbolGraphsURL.appending(path: destFilename)
            
            let changeFromCppToSwift = destURL.lastPathComponent.hasSuffix(".swift.symbols.json")
            
            var symbolGraph = try! JSONDecoder().decode(SymbolGraph.self, from: try! Data(contentsOf: srcURL))
            await _cleanSymbolGraph(symbolGraph: &symbolGraph, changeFromCppToSwift: changeFromCppToSwift)
            try! JSONEncoder().encode(symbolGraph).write(to: destURL)
        }
    }
    
    @Flag()
    var cleanOnly: Bool = false
    
    func run() async throws {
        if !cleanOnly {
            // First, remove any stale data
            await removeIfExists(Driver.shared.symbolGraphsURL, isDirectory: true)
            await removeIfExists(Driver.shared.dotBuildURL, isDirectory: true)
            await removeIfExists(Driver.shared.packageResolvedURL, isDirectory: false)
            
            // Build and clean the symbol graphs
            await buildSwiftSymbolGraph()
            await buildCppSymbolGraph()
            saveUncleanedSymbolGraphs()
        }

        await cleanSymbolGraphs()
        
        // Lastly, symlink generated markdown into the documentation catalog
        try! await ShellUtil.runCommandAndWait(arguments: ["rm", "-rf", Driver.shared.doccGeneratedArticlesURL])
        try! await ShellUtil.runCommandAndWait(arguments: ["mkdir", Driver.shared.doccGeneratedArticlesURL])
        
        for f in try! FileManager.default.contentsOfDirectory(atPath: Driver.shared.sourceURL.appending(path: "generated").path(percentEncoded: false))
        where f.hasSuffix(".md") {
            try! FileManager.default.createSymbolicLink(
                atPath: Driver.shared.doccGeneratedArticlesURL.appending(path: f).path(percentEncoded: false),
                withDestinationPath: "../../source/generated/\(f)"
            )
        }
    }
}
