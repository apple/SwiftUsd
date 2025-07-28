# ``OpenUSD/SwiftUsd/TakeFunctionParameterFromSwift``

## Discussion

Use this function to create a `pxr::TfRefPtr<T>` or `pxr::TfWeakPtr<T>` from a raw pointer passed into a C++ function called by Swift. Make sure that `SwiftUsd::TakeFunctionParameterFromSwift(SmartPointer::DataType*)` is called on the return value from Swift, even if the result of `SwiftUsd::TakeFunctionParameterFromSwift(SmartPointer::DataType*)` isn't used. 

```c++
// foo.hpp
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"
void useRawPointerPassedBySwift(pxr::UsdStage* _Nonnull _stage);
```

```c++
// foo.mm
#include "foo.hpp"

void useRawPointerPassedBySwift(pxr::UsdStage* _Nonnull _stage) {
    pxr::UsdStageRefPtr stage = SwiftUsd::TakeFunctionParameterFromSwift<pxr::UsdStageRefPtr>(_stage);
}
```

See <doc:SwiftCxxInteropMemorySafety> for more information. 