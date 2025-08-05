# Capabilities

Learn about the current capabilities of OpenUSD in Swift

## Overview
OpenUSD in Swift is currently evolving and may change in the future. Here are some key features currently supported:

### Reference types in Swift
UsdStage and SdfLayer are imported as classes in Swift and behave like classes written in Swift. When Swift passes a raw pointer to UsdStage or SdfLayer, Swift automatically increments or decrements the underlying reference count as needed, allowing Swift or C++ to influence the lifetime of the same UsdStage or SdfLayer. 
```swift
func makeTempStage() -> pxr.UsdStage {
    return Overlay.Dereference(pxr.UsdStage.CreateNew("/tmp/myStage.usda", .LoadAll))
}

func defineXform(_ stage: pxr.UsdStage, _ path: pxr.SdfPath) {
    stage.DefinePrim(path, .UsdGeomTokens.Xform)
}

let stage = makeTempStage()
defineXform(stage, "/hello")
let layer = Overlay.Dereference(stage.GetRootLayer())
layer.Save(false)
```
See <doc:WhatIsAForeignReferenceType> and <doc:ForeignReferenceTypesAndSmartPointers> for more information.

> Warning: When working in Swift, do not use `TfRefPtr.pointee` or `TfWeakPtr.pointee` to dereference Pixar's smart pointers, as the `pointee` property is unsafe. Use `Overlay.Dereference(_:TfRefPtr)` and `Overlay.Dereference(_:TfWeakPtr)` instead. 

### Swift protocol conformances
Many OpenUSD types conform to one or more of the following protocols:
- `Equatable`
- `Hashable`
- `Identifiable`
- `CustomStringConvertible`
- `ExpressibleByStringLiteral`
- `ExpressibleByArrayLiteral`
- `Sequence`
- `Sendable`

```swift
let token: pxr.TfToken = "my custom token" // TfToken conforms to ExpressibleByStringLiteral
var prims: Set<pxr.UsdPrim> = Set<pxr.UsdPrim>() // UsdPrim conforms to Hashable
let numbers: pxr.VtIntArray = [1, 2, 3] // VtIntArray conforms to ExpressibleByArrayLiteral
```

### TfNotice support
Swift code can register for `TfNotice` callbacks by using [`pxr.TfNotice.Register`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-99j13).

```swift
class StageWatcher {
    var stage: pxr.UsdStage
    var key: pxr.TfNotice.SwiftKey

    init(stage: pxr.UsdStage) {
        self.stage = stage

        key = pxr.TfNotice.Register(stage, pxr.UsdNotice.ObjectsChanged.self) { notice in
            print("Resynced: \(notice.GetResyncedPaths())")
            print("Changed info only: \(notice.GetChangedInfoOnlyPaths())")
        }
    }
    deinit {
        pxr.TfNotice.Revoke(key)
    }
}
```
For more information, see <doc:WorkingWithTfNotice>.

### More details
For details about supported features, see <doc:DifferencesInSwift>. 
