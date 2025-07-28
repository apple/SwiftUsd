# ``OpenUSD/C++/Overlay/UsdPrimRangeIteratedSequence``

## Overview

Use [`UsdPrimRange.withIterator()`](doc:OpenUSD/C++/pxr/UsdPrimRange/withIterator()) to access the `PruneChildren()` and `IsPostVisit()` properties. 

```swift
for (iter, prim) in pxr.UsdPrim.PreAndPostVisit(stage.GetPseudoRoot()).withIterator() {
    let path = String(prim.GetPath().GetAsString())
    print(path, iter.IsPostVisit()
    if path == "/Hello" {
        iter.PruneChildren()
    }
}
```
