# Using edit contexts

Using `pxr.UsdEditContext` in Swift

`pxr.UsdEditContext` is a move-only type that can't be imported into Swift. This Swift Package provides [`Overlay.withUsdEditContext(_:_:_:)`](doc:OpenUSD/C++/Overlay/withUsdEditContext(_:_:_:)) as a convenient way to access the RAII behavior of `pxr.UsdEditContext` in C++. 

In C++, we would use the following pattern:
```c++
{
    pxr::UsdEditContext ctxt(vset.GetVariantEditContext());

    // All Usd mutation of the UsdStage on which vset sits will
    // now go "inside" the currently selected variant of vset

    pxr::VtVec3fArray colorValue;
    colorValue.push_back(pxr::GfVec3f(1, 0, 0));
    colorAttr.Set(colorValue);
}
// Mutations no longer go inside the selected variant of vset
```

In Swift, the pattern is:
```swift
Overlay.withUsdEditContext(vset.GetVariantEditContext(pxr.SdfLayerHandle())) {
    // Mutations go inside the selected variant of vset
    
    let colorValue: pxr.VtVec3fArray = [pxr.GfVec3f(1, 0, 0)]
    colorAttr.Set(colorValue, pxr.UsdTimeCode.Default())
}
// Mutations no longer go inside the selected variant of vset
```

## Topics
In Swift, these functions live under `Overlay`.
- ``OpenUSD/C++/Overlay/withUsdEditContext(_:_:_:)``
- ``OpenUSD/C++/Overlay/withUsdEditContext(_:_:)``
