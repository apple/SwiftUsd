# ``OpenUSD/SwiftUsd/PassToSwiftAsFunctionParameter``

## Discussion

Use this function to pass a `pxr::TfRefPtr<T>` or `pxr::TfWeakPtr<T>` to Swift as a raw pointer when calling a Swift function from C++. Make sure that `SwiftUsd::PassToSwiftAsFunctionParameter(SmartPointer&)` isn't called until the function call expression:

```swift
// foo.swift
import OpenUSD
public func takeStageByRawPointer(_ stage: pxr.UsdStage) { ... }
```

```c++
// foo.mm
#include "MyTarget-Swift.h"
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"

void callSwiftWithRawPointer() {
    pxr::UsdStageRefPtr stage = pxr::UsdStageCreateInMemory();
    MyTarget::takeStageByRawPointer(SwiftUsd::PassToSwiftAsFunctionParameter(stage));
}
```

See <doc:SwiftCxxInteropMemorySafety> for more information. 