// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUsd-DocC-Helper",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-docc-symbolkit.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SwiftUsdDoccUtil"),
        
        .executableTarget(name: "build-documentation",
                          dependencies: [
                            "SwiftUsdDoccUtil",
                            .product(name: "SymbolKit", package: "swift-docc-symbolkit"),
                            .product(name: "ArgumentParser", package: "swift-argument-parser")
                          ]
                         ),
        .executableTarget(name: "preview-documentation",
                          dependencies: ["SwiftUsdDoccUtil"]),
        .executableTarget(name: "update-documentation",
                          dependencies: ["SwiftUsdDoccUtil"])
    ]
)

