# Dereferencing pointers
Safely dereferencing `pxr.TfRefPtr` and `pxr.TfWeakPtr` in Swift

## Overview

Using Swift interop, the compiler automatically generates `pointee` properties for `pxr.TfRefPtr` and `pxr.TfWeakPtr`. However, these properties are unavailable. 

This Swift Package provides workarounds in the form of `Overlay.Dereference(_:)`.

For more information, see <doc:WhatIsAForeignReferenceType> and <doc:ForeignReferenceTypesAndSmartPointers>

## Topics
In Swift, these functions live under `Overlay`. 
- ``/OpenUSD/C++/Overlay/Dereference(_:)-67vpz``
- ``/OpenUSD/C++/Overlay/Dereference(_:)-3edgv``
- ``/OpenUSD/C++/Overlay/Dereference(_:)-6tke1``
- ``/OpenUSD/C++/Overlay/Dereference(_:)-4h0lb``
- ``/OpenUSD/C++/Overlay/DereferenceOrNil(_:)-4yt4i``
- ``/OpenUSD/C++/Overlay/DereferenceOrNil(_:)-5pwch``
- ``/OpenUSD/C++/Overlay/DereferenceOrNil(_:)-6ehce``
- ``/OpenUSD/C++/Overlay/DereferenceOrNil(_:)-34drv``