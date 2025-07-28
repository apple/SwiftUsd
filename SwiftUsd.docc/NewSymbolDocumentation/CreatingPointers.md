# Creating pointers
Creating `pxr.TfRefPtr` and `pxr.TfWeakPtr` in Swift

In Swift, it's recommended to hold a `pxr.UsdStage` or `pxr.SdfLayer` directly. However, when calling into the OpenUSD API, it may be necessary to convert the directly held reference type into a smart pointer. 

This Swift Package provides [`Overlay.TfRefPtr(_:)`](doc:OpenUSD/C++/Overlay/TfRefPtr(_:)-7quy3) and [`Overlay.TfWeakPtr(_:)`](doc:OpenUSD/C++/Overlay/TfWeakPtr(_:)-8de9g) for that purpose.

For more information, see <doc:WhatIsAForeignReferenceType> and <doc:ForeignReferenceTypesAndSmartPointers>

## Topics
In Swift, these functions live under `Overlay`.
- ``/OpenUSD/C++/Overlay/TfRefPtr(_:)-7quy3``
- ``/OpenUSD/C++/Overlay/TfRefPtr(_:)-v2wi``
- ``/OpenUSD/C++/Overlay/TfRefPtr(_:)-4647l``
- ``/OpenUSD/C++/Overlay/TfWeakPtr(_:)-8de9g``
- ``/OpenUSD/C++/Overlay/TfWeakPtr(_:)-1gjl1``
- ``/OpenUSD/C++/Overlay/TfWeakPtr(_:)-69u6l``
