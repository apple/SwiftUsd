# Changes to OpenUSD

Learn about the changes this Swift Package makes to OpenUSD

## Overview

This repo makes changes to OpenUSD to support Swift-Cxx interop and make Usd easier to use in Xcode. 

### Changes to OpenUSD before building
These changes are contained in `SwiftUsd/openusd-patch.patch`:  

#### Usd-specific changes to OpenUSD before building  
These changes fix bugs or add features to Usd that aren't part of vanilla OpenUSD
- None

#### Swift-specific changes to OpenUSD before building
These changes work around Swift-specific issues in vanilla OpenUSD, add Swift-specific features, and work around issues in the Swift compiler.  
- Header modularization fixes:
    - Modified: `pxr/base/arch/fileSystem.h`
    - Modified: `pxr/base/tf/notice.h`
    - Modified: `pxr/base/vt/dictionary.h`
    - Modified: `pxr/usd/sdf/predicateProgram.h`
    - Modified: `pxr/exec/vdf/parallelExecutorEngineBase.h`
    - Modified: `pxr/exec/vdf/pullBasedExecutorEngine.h`

- Support importing `pxr::TfRefBase` subclasses as reference types in Swift:
    - Modified: `pxr/base/tf/CMakeLists.txt`
    - Modified: `pxr/base/tf/refBase.h`
    - Modified: `pxr/base/tf/refPtr.h`
    - Added: `pxr/base/tf/retainReleaseHelper.h`

- Support MaterialX in Swift Package:
    - Modified: `pxr/usd/usdMtlx/utils.cpp`

- Support using `pxr::TfNotice::Register` from Swift:
    - Modified: `pxr/base/tf/notice.h`

- [rdar://148534260: API notes should support annotating C++ operators](rdar://148534260)
    Annotations of C++ operators have to go in header files until they're supported in API Notes
    - Modified: `pxr/base/tf/refPtr.h`
    - Modified: `pxr/base/tf/weakPtrFacade.h`

- [https://github.com/swiftlang/swift/issues/83117: Swift Array addition causes unrelated C++ static_assert to fail](https://github.com/swiftlang/swift/issues/83117)  
    - Modified: `pxr/base/tf/iterator.h`

- [https://github.com/swiftlang/swift/issues/83116: Swift instantiates default arguments for function templates too eagerly](https://github.com/swiftlang/swift/issues/83116)  
    This issue can be worked around by making sure that the default arguments to methods in class templates are valid expressions for all specialization of that template, even if a particular specialization does not use some methods.  
    - Modified: `pxr/imaging/hd/dependencySchema.h`
    - Modified: `pxr/imaging/hd/schema.h`

- [rdar://150456875: Forward declaring std::map's value causes an error for Swift but not C++ (Swift 6.1 regression)](rdar://150456875)
    This issue is worked around by moving the definition of a type from a source file into a header file, and by making a private header publig
    - Modified: `pxr/exec/exec/CMakeLists.txt`
    - Modified: `pxr/imaging/hdsi/debuggingSceneIndex.cpp`
    - Modified: `pxr/imaging/hdsi/debuggingSceneIndex.h`

### Changes to OpenUSD while making a Swift Package
These changes are applied by `SwiftUsd/scripts/make-swift-package`, after `build_usd.py` has finished compiling OpenUSD. (This list is non-exhaustive, see `SwiftUsd/scripts/make-swift-package` for full details)
- Wrapping dylibs into frameworks:  
    All required dylibs are found using `otool`, then each dylib is converted to a framework bundle. This involves:
    - Modifying `plugInfo.json` files
    - Uppercasing Usd plugin `resources` directories to `Resources`
    - Copying Usd plugins, Hydra plugins, and MaterialX libraries
    - Fixing the dylib's load commands
    - Code-signing the framework

- Combining versions of the same framework compiled for different platforms into a single multi-platform XCFramework

- Making a Swift Package:  
    This includes:
    - Copying headers from `USD_BUILD_DIRECTORY/include` into the Swift Package
    - Writing out a modulemap file and copying an API Notes file into the public headers directory
    - Other Swift-Package specific manipulation that doesn't modify OpenUSD

### Improving OpenUSD ergonomics in Swift
#### Automatic improvements  
Some ergonomic improvements are done automatically using [https://github.com/apple/SwiftUsd-ast-answerer](https://github.com/apple/SwiftUsd-ast-answerer) for code generation:  
- `pxr::TfRefBase` subclasses like `pxr::UsdStage` and `pxr::SdfLayer` are imported as reference types, along with functions to convert to/from Usd smart pointers to raw pointers
- `operator bool()` is mapped to `Bool.init(_:)` for smart pointers, Usd schemas, and other Usd types
- Many Usd types are conformed to standard library protocols:
    - `Comparable`
    - `CustomStringConvertible`
    - `Equatable`
    - `Hashable`
    - `Sendable`
- Unscoped enums are wrapped to work around [https://github.com/swiftlang/swift/issues/62127: C++ interop: nested enum not imported](https://github.com/swiftlang/swift/issues/62127)
- Unscoped enums have support for implicit member expressions
- `Overlay.GetPrim(_:T)` is provided to workaround `T.GetPrim()` [https://github.com/swiftlang/swift/pull/81709: [cxx-interop] Fix ambiguous methods in long chains of inheritance](https://github.com/swiftlang/swift/pull/81709), for all `T: UsdSchemaBase`

#### Manual improvements
Other ergonomic improvements are done by hand:  
- Support for implicit member expressions for all token types  (e.g. `UsdGeomTokensType`)
- Conformances of a few types to `ExpressibleByFOOLiteral` protocols
- Wrapping of various behavior/types that can't be implemented/imported into Swift
- Wrapping of various methods on Usd types that return const-ref values to return the result by copied value
- Wrapping of methods on `pxr::UsdReferences` and `pxr::UsdPayloads` to have nonmutating Swift versions, despite having non-const C++ versions
- Conformances of a few Usd types to `Sequence`
- Conformances of some `std::vector` specializations to `Equatable` and `CustomStringConvertible`
- Typedefs to work around [rdar://121886233: Support specializing class templates with concrete types using <> syntax](rdar://121886233)  
- Support for iterating over `pxr::UsdPrimRange` while calling `IsPostVisit()` and `PruneChildren()`
- Conformances of many `pxr::VtArray` specializations to `Equatable`, `ExpressibleByArrayLiteral`, `Sequence`, and `CustomStringConvertible`
- [`Overlay.withUsdEditContext(_:_:_:)`](doc:OpenUSD/C++/Overlay/withUsdEditContext(_:_:_:)) to wrap `pxr::UsdEditContext`
- [`Overlay.withTfErrorMark(_:)`](doc:OpenUSD/C++/Overlay/withTfErrorMark(_:)) to wrap `pxr::TfErrorMark`

