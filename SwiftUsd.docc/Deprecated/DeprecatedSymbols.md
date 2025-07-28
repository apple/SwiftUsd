# Deprecated

## Overview

These functions have been deprecated in either Swift or C++. They will be removed in a future version of SwiftUsd. 


### Deprecated Swift functions
@Links(visualStyle: list) {
  - ``/OpenUSD/C++/Overlay/SdfLayer/IsMuted(_:)``
  - ``/OpenUSD/C++/Overlay/VtValue(_:)``
  - ``/OpenUSD/C++/Overlay/push_back(_:_:)``
  - ``/OpenUSD/C++/Overlay/GetOpType(_:)``
  - ``/OpenUSD/C++/Overlay/SdfLayerStateDelegateBaseRefPtr(_:)``
  - ``/OpenUSD/C++/Overlay/SdfLayerStateDelegateBasePtr(_:)``
}


### Deprecated typedefs
@Links(visualStyle: list) {
  - ``/OpenUSD/C++/Overlay/UsdZipFileWriterWrapper``
}

### Deprecated C++ functions
- [`Overlay::Dereference(pxr::TfRefPtr<T>)`](doc:OpenUSD/Overlay/Dereference-3t65r)
- [`Overlay::Dereference(pxr::TfWeakPtr<T>)`](doc:OpenUSD/Overlay/Dereference-9or49)
> Note: Only the C++ versions of these functions are deprecated. Swift code should continue to use [`Overlay.Dereference(_: pxr.TfRefPtr<T>`)](doc:OpenUSD/C++/Overlay/Dereference(_:)-67vpz) and [`Overlay.Dereference(_: pxr.TfWeakPtr<T>)`](doc:OpenUSD/C++/Overlay/Dereference(_:)-3edgv)