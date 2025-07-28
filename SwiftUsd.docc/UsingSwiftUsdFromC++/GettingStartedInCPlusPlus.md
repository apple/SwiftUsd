# Getting Started In C++

Using SwiftUsd from C++

## Getting Started
Before you can start using SwiftUsd, you need to add it as a dependency to your Xcode project or Swift Package, and then configure a few build settings.

> Note: Despite the fact that SwiftUsd is a Swift Package, you can use it in a pure-C++ Xcode project/target, as well as in a pure-C++ Swift Package target.

> Important: Swift Package targets cannot mix Swift and C++ code in a single target. [https://github.com/swiftlang/swift-package-manager/issues/8945: Support Swift-Cxx reverse interop, bidirectional interop, and mixed Swift-Cxx targets](https://github.com/swiftlang/swift-package-manager/issues/8945)

To do so, follow the steps in [Getting Started for Swift](<doc:GettingStarted#Getting-Started>). If you're using a pure-C++ target, you don't need to change the `C++ and Objective-C Interoperability` mode in Xcode or add `.interoperabilityMode(.Cxx)` to your target's `swiftSettings` in your Swift Package manifest.

### Using SwiftUsd
Once you've added SwiftUsd as a package dependency to your Xcode project or Swift package and set the C++ version to GNU++17, you're ready to start using SwiftUsd:
```c++
#include <iostream>
#include "pxr/usd/usd/stage.h"
#include "pxr/usd/usd/prim.h"
#include "pxr/usd/usdGeom/tokens.h"

std::string makeHelloWorldString() {
    pxr::UsdStageRefPtr stage = pxr::UsdStage::CreateInMemory();
    stage->DefinePrim(pxr::SdfPath("/hello"), pxr::UsdGeomTokens->Cube);
    stage->DefinePrim(pxr::SdfPath("/hello/world"), pxr::UsdGeomTokens->Sphere);
    std::string result;
    stage->ExportToString(&result);
    return result;
}

int main(int argc, const char * argv[]) {
    std::cout << makeHelloWorldString() << std::endl;
    return 0;
}
```

To use new functions or types added by SwiftUsd, include the SwiftUsd umbrella header:
```c++
#include "swiftUsd/swiftUsd.h"
```
This header lets you use macros useful for Swift-Cxx interop, functions that are important for memory safety with Swift-Cxx interop, and Swift wrapper types for C++ types not imported by Swift-Cxx interop. 

> Note: Don't include other files in `OpenUSD/swiftUsd`, as they are implementation details and may change without warning