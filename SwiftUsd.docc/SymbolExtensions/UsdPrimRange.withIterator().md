# ``OpenUSD/C++/pxr/UsdPrimRange/withIterator()``

## Discussion
This method provides access to the `PruneChildren()` and `IsPostVisit()` properties when iterating. 

```swift
for (iter, prim) in pxr.UsdPrim.PreAndPostVisit(stage.GetPseudoRoot()).withIterator() {
    let path = String(prim.GetPath().GetAsString())
    print(path, iter.IsPostVisit())
    if path == "/Hello" {
        iter.PruneChildren()
    }
}
```
