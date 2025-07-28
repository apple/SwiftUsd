# ``OpenUSD/SwiftUsd/TakeReturnValueFromSwift``

## Discussion

Use this function to create a `pxr::TfRefPtr<T>` or `pxr::TfWeakPtr<T>` from a raw pointer returned from calling a Swift function in C++. Make sure that `SwiftUsd::TakeReturnValueFromSwift(SmartPointer::DataType*)` is called on the return value from Swift, even if the result of `SwiftUsd::TakeReturnValueFromSwift(SmartPointer::DataType*)` isn't used. 

```swift
// foo.swift
import OpenUSD
public func returnStageByRawPointer() -> pxr.UsdStage { ... }
```

```c++
// foo.mm
#include "MyTarget-Swift.h"
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"

void takeRawPointerFromSwift() {
    pxr::UsdStageRefPtr stage = SwiftUsd::TakeReturnValueFromSwift<pxr::UsdStageRefPtr>(MyTarget::returnStageByRawPointer());
}
```

See <doc:SwiftCxxInteropMemorySafety> for more information. 