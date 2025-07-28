# Wrapped enums

## Overview
Most public enums in OpenUSD aren't correctly imported due to a bug in Swift-Cxx interop: [https://github.com/swiftlang/swift/issues/62127: C++ interop: nested enum not imported](https://github.com/swiftlang/swift/issues/62127)  
This Swift Package provides a workaround by migrating the enums to the `Overlay` namespace. For example,

```swift
let stage = Overlay.Dereference(pxr.UsdStage.CreateInMemory(pxr.UsdStage.LoadAll)) // error: can't find pxr.UsdStage.LoadAll
let stage = Overlay.Dereference(pxr.UsdStage.CreateInMemory(Overlay.UsdStage.LoadAll)) // success: finds Overlay.UsdStage.LoadAll
```

Additionally, when Swift can infer the type of the enum, you can use implicit member expressions. For example,
```swift
let stage = Overlay.Dereference(pxr.UsdStage.CreateInMemory(.LoadAll)) // success: infers pxr.UsdStage.LoadAll
```
