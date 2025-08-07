# SwiftUsd

A Swift Package for using OpenUSD in Swift

## Getting Started
Before you can start using SwiftUsd, you need to add it as a dependency to your Xcode project or Swift Package, and then configure a few build settings. 

### Xcode project
1. To use SwiftUsd in an Xcode project, select File > Add Package Dependency, and enter `https://github.com/apple/SwiftUsd` as the URL. 
2. In the build settings for your target, set `C++ and Objective-C Interoperability` to `C++ / Objective-C++` (`SWIFT_OBJC_INTEROP_MODE=objcxx`). 
3. In the build settings for your target, set `C++ Language Dialect` to `GNU++17 [-std=gnu++17]` (`CLANG_CXX_LANGUAGE_STANDARD=gnu++17`). 

### Swift Package
1. To use SwiftUsd in a Swift Package, first add it as a dependency:
```swift
dependencies: [
    .package(url: "https://github.com/apple/SwiftUsd", from: "5.0.1"),
]
```

2. Then enable Swift-Cxx interoperability on your Swift targets:
```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "OpenUSD", package: "SwiftUsd")],
        swiftSettings: [
            .interoperabilityMode(.Cxx)
        ]),
```

3. Then set the C++ language standard to GNU++17:
```swift
let package = Package(
    name: "MyPackage",
    targets: [...],
    cxxLanguageStandard: .gnucxx17
)
```

### Using SwiftUsd
Once you've added SwiftUsd as a package depedency to your Xcode project or Swift Package, enabled Swift-Cxx interop, and set the C++ version to GNU++17, you're ready to start using SwiftUsd:
```swift
import OpenUSD

func makeHelloWorldString() -> String {
    let stage = Overlay.Dereference(pxr.UsdStage.CreateInMemory())
    stage.DefinePrim("/hello", .UsdGeomTokens.Xform)
    stage.DefinePrim("/hello/world", .UsdGeomTokens.Sphere)
    return stage.ExportToString() ?? "nil"
}
```

## Related repositories
- [SwiftUsd-Tests](https://github.com/apple/SwiftUsd-Tests), unit tests for SwiftUsd
- [SwiftUsd-ast-answerer](https://github.com/apple/SwiftUsd-ast-answerer), code generation tool for SwiftUsd

## Documentation
See the online documentation [here](https://apple.github.io/SwiftUsd/documentation/openusd/).
Alternatively, open the included `SwiftUsd.doccarchive` in Xcode for local viewing. 
