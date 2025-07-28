# Checking for validity

Checking for `IsValid()` and null pointers in Swift

In Swift, `operator bool()` and `IsValid()` are mapped to initializers on `Bool`, like so:
```swift
let prim = stage.GetPrimAtPath("/foo")
if Bool(prim) {
    // prim is valid
} else {
    // prim is invalid
}
```

The following types have support using `Bool` to check for validity in Swift:

### Smart pointers
- `pxr::TfRefPtr<T>` supports this `Bool` initializer:
@Links(visualStyle: list) {
    - ``OpenUSD/Swift/Bool/init(_:)-63kny``
}
- `pxr::TfRefPtr<const T>` supports this `Bool` initializer:
@Links(visualStyle: list) {
    - ``OpenUSD/Swift/Bool/init(_:)-8lpgx``
}
- `pxr::TfWeakPtr<T>` supports this `Bool` initializer:
@Links(visualStyle: list) {
    - ``OpenUSD/Swift/Bool/init(_:)-6azcc``
}
- `pxr::TfWeakPtr<T>` supports this `Bool` initializer:
@Links(visualStyle: list) {
    - ``OpenUSD/Swift/Bool/init(_:)-6azcc``
}
- ``OpenUSD/C++/pxr/SdfHandle<pxr.SdfPrimSpec>``

### Usd objects
- ``OpenUSD/C++/pxr/UsdObject``
- ``OpenUSD/C++/pxr/UsdPrim``
- ``OpenUSD/C++/pxr/UsdProperty``
- ``OpenUSD/C++/pxr/UsdAttribute``
- ``OpenUSD/C++/pxr/UsdRelationship``
- ``OpenUSD/C++/pxr/UsdShadeInput``
- ``OpenUSD/C++/pxr/UsdShadeOutput``
- ``OpenUSD/C++/pxr/UsdGeomXformOp``
- ``OpenUSD/Overlay/HioImageWrapper``

### Usd schemas
All subclasses of `UsdSchemaBase` support using `Bool` to check for validity in Swift. 
