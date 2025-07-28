# ``OpenUSD/SwiftUsd/PassToSwiftAsReturnValue``

## Discussion

Use this function to pass a `pxr::TfRefPtr<T>` or `pxr::TfWeakPtr<T>` to Swift as a raw pointer being returned from a C++ function. Apply the `SWIFT_RETURNS_RETAINED` macro to your function declaration, and make sure that `SwiftUsd::PassToSwiftAsReturnValue(SmartPointer&)` isn't called until the return statement:

```c++
// foo.hpp
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"

pxr::UsdStage* _Nonnull returnStageByRawPointer() SWIFT_RETURNS_RETAINED;
```

```c++
// foo.mm
#include "foo.h"

pxr::UsdStage* _Nonnull returnStageByRawPointer() SWIFT_RETURNS_RETAINED {
    pxr::UsdStageRefPtr stage = pxr::UsdStage::CreateInMemory();
    return SwiftUsd::PassToSwiftAsReturnValue(stage);
}
```

See <doc:SwiftCxxInteropMemorySafety> for more information. 