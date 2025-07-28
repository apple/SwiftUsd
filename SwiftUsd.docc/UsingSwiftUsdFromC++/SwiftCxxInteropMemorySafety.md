# Swift-Cxx Interop and Memory Safety

Learn how to avoid unsafe memory management issues when using Swift-Cxx interop

## Overview

When directly moving `pxr::TfRefBase` subclasses, such as `pxr::UsdStage` or `pxr::SdfLayer`, back and forth between Swift and C++, it is very easy to create a memory safety issue if you're not careful. This article explains how to avoid these issues, and why they occur in the first place.

### The safe cases

Memory safety issues only arise when moving `pxr::TfRefBase` subclasses back and forth between Swift and C++. When working just in C++ or just in Swift, follow these best practices to guarantee that your code is memory safe:

When working purely in C++, C++ lifetime rules and memory management apply. In particular, C++ code should use the `pxr::TfRefPtr<T>` and `pxr::TfWeakPtr<T>` smart pointers instead of handling raw pointers, because raw pointers in C++ do not do any reference counting or memory management. For example, use `pxr::TfRefPtr<pxr::UsdStage>` or the equivalent typealias `pxr::UsdStageRefPtr`, instead of using `pxr::UsdStage *`.

When working purely in Swift, Swift lifetime rules and memory management apply. In particular, Swift may deallocate variables sooner than expected, especially temporary values. Swift code should directly use types that derive from `pxr::TfRefBase` instead of using the `pxr::TfRefPtr<T>` and `pxr::TfWeakPtr<T>` smart pointers, because Swift can provide better ergonomics with `pxr::TfRefBase` subclasses while doing reference counting and memory management. For example, use `pxr.UsdStage` instead of `pxr.TfRefPtr<pxr.UsdStage>` or `pxr.UsdStageRefPtr`.


### The unsafe cases

When a Swift function takes or returns a `pxr::TfRefBase` subclass, it is exposed to C++ as taking a raw pointer:
```swift
// Swift source code
public func takeStage(_ stage: pxr.UsdStage) { ... }
public func returnStage() -> pxr.UsdStage { ... }
```
```c++
// Generated C++ interface
void SwiftModule::takeStage(pxr::UsdStage* _Nonnull);
pxr::UsdStage* _Nonnull SwiftModule::returnStage();
```

This violates the best practices for C++, because C++ code should work with the `pxr::TfRefPtr<T>` and `pxr::TfWeakPtr<T>` smart pointers instead of raw pointers.

Similarly, when a C++ function violates C++ best practices and takes or returns a raw pointer to a `pxr::TfRefBase`, it is imported to Swift as taking the `pxr::TfRefBase` directly, which can improve ergonomics for Swift:
```c++
// C++ source code
void takeStageByRawPointer(pxr::UsdStage* _Nonnull);
void takeStageBySmartPointer(pxr::TfRefPtr<pxr::UsdStage>);
pxr::UsdStage* _Nonnull returnStageByRawPointer();
pxr::TfRefPtr<pxr::UsdStage> returnStageBySmartPointer();
```
```swift
// Generated Swift interface
func takeStageByRawPointer(_: pxr.UsdStage);
func takeStageBySmartPointer(_: pxr.TfRefPtr<pxr.UsdStage>);
func returnStageByRawPointer() -> pxr.UsdStage;
func returnStageBySmartPointer() -> pxr.TfRefPtr<pxr.UsdStage>);
```

When working with raw pointers in any of these cases, the C++ code needs to take care to match Swift's expectations for memory management. Think carefully about the raw pointer's _direction of movement_ and its _method of movement_:

**Direction of movement**: Is the raw pointer moving from C++ to Swift, or from Swift to C++?
- Moving from C++ to Swift: Use a `PassToSwift` function
- Moving from Swift to C++: Use a `TakeFromSwift` function

**Method of movement**. Is the raw pointer being passed a parameter to a function call, or is it the value returned from a function call?
- Moving as a return value: Use a `AsReturnValue` function
- Moving as a function parameter: Use a `AsFunctionParameter` function

Combine the direction of movement and the method of movement to determine which of the four following functions to use.


### SwiftUsd::PassToSwiftAsReturnValue

When a `pxr::TfRefBase` subclass in C++ is being moved to Swift by returning it from a C++ function, use the function [`SwiftUsd::PassToSwiftAsReturnValue(SmartPointer&)`](doc:OpenUSD/SwiftUsd/PassToSwiftAsReturnValue) in the return statement, and apply the `SWIFT_RETURNS_RETAINED` macro to your function declaration:

```c++
// foo.hpp
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"

pxr::UsdStage* _Nonnull returnStageByRawPointer() SWIFT_RETURNS_RETAINED;
```
```c++
// foo.mm
#include "foo.hpp"

pxr::UsdStage* _Nonnull returnStageByRawPointer() SWIFT_RETURNS_RETAINED {
    pxr::UsdStageRefPtr stage = pxr::UsdStage::CreateInMemory();
    return SwiftUsd::PassToSwiftAsReturnValue(stage);
}
```

> Warning: If [`SwiftUsd::PassToSwiftAsReturnValue(SmartPointer&)`](doc:OpenUSD/SwiftUsd/PassToSwiftAsReturnValue) is called earlier than the return statement, the resulting value may become a use-after-free memory safety issue.


### SwiftUsd::PassToSwiftAsFunctionParameter

When a `pxr::TfRefBase` subclass in C++ is being moved to Swift by passing it to a Swift function, use the function [`SwiftUsd::PassToSwiftAsFunctionParameter(SmartPointer&)`](doc:OpenUSD/SwiftUsd/PassToSwiftAsFunctionParameter) in the function call expression:

```swift
// foo.swift
public func takeStageByRawPointer(_ stage: pxr.UsdStage) { ... }
```
```c++
// foo.mm
#include "MyTarget-Swift.h"
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"

void callSwiftWithRawPointer() {
    pxr::UsdStageRefPtr stage = pxr::UsdStage::CreateInMemory();
    MyTarget::takeStageByRawPointer(SwiftUsd::PassToSwiftAsFunctionParameter(stage));
}
```

> Warning: If [`SwiftUsd::PassToSwiftAsFunctionParameter(SmartPointer&)`](doc:OpenUSD/SwiftUsd/PassToSwiftAsFunctionParameter) is called earlier than the function call expression, the resulting value may become a use-after-free memory issue.

### SwiftUsd:TakeReturnValueFromSwift

When a `pxr::TfRefBase` subclass in Swift is being moved to C++ by returning it from a Swift function, use the function [`SwiftUsd::TakeReturnValueFromSwift(SmartPointer::DataType*)`](doc:OpenUSD/SwiftUsd/TakeReturnValueFromSwift) on the return value of the function call expression:

```swift
// foo.swift
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

> Warning: If [`SwiftUsd::TakeReturnValueFromSwift(SmartPointer::DataType*)`](doc:OpenUSD/SwiftUsd/TakeReturnValueFromSwift) is not called on the return value of the function call expression, the resulting value will become a memory leak.

### SwiftUsd::TakeFunctionParameterFromSwift

When a `pxr::TfRefBase` subclass in Swift is being moved to C++ by passing it to a C++ function, use the function [`SwiftUsd::TakeFunctionParameterFromSwift(SmartPointer::DataType*)`](doc:OpenUSD/SwiftUsd/TakeFunctionParameterFromSwift) at the start of the function body:

```c++
// foo.hpp
#include "swiftUsd/swiftUsd.h"
#include "pxr/usd/usd/stage.h"

void useRawPointerPassedBySwift(pxr::UsdStage* _Nonnull _stage);
```
```c++
// foo.mm
#include "foo.mm"

void useRawPointerPassedBySwift(pxr::UsdStage* _Nonnull _stage) {
    pxr::UsdStageRefPtr stage = SwiftUsd::TakeFunctionParameterFromSwift<pxr::UsdStageRefPtr>(_stage);
}
```

> Warning: If [`SwiftUsd::TakeFunctionParameterFromSwift(SmartPointer::DataType*)`](doc:OpenUSD/SwiftUsd/TakeFunctionParameterFromSwift) is not called on the function parameter, using the resulting value may result in a null pointer dereference memory issue. 