# Wrapped types

## Overview
The source code for these symbols can be found at `source/Wrappers`. Only a subset of unavailable symbols are provided; if you need a wrapper type not provided by this Swift Package, you can write your own.

## Topics

### Typedefs
Since Swift-Cxx interop doesn't currently support specializing class templates from Swift, these typedefs are provided under `Overlay`

- ``OpenUSD/Overlay/HgiBlitCmds_SharedPtr``
- ``OpenUSD/Overlay/UsdStagePtr_UsdEditTarget_Pair``
- ``OpenUSD/Overlay/String_Vector``
- ``OpenUSD/Overlay/Double_Vector``
- ``OpenUSD/Overlay/GfVec4f_Vector``
- ``OpenUSD/Overlay/UsdGeomXformOp_Vector``
- ``OpenUSD/Overlay/UsdAttribute_Vector``
- ``OpenUSD/Overlay/UsdRelationship_Vector``
- ``OpenUSD/Overlay/String_Set``
- ``OpenUSD/Overlay/SdfLayerHandle_Set``

### Namespace Overlay
Access these types by prefixing their name with `Overlay`
- ``OpenUSD/Overlay/TfErrorMarkWrapper``
- ``OpenUSD/Overlay/ArResolverWrapper``
- ``OpenUSD/Overlay/UsdPrimTypeInfoWrapper``
- ``OpenUSD/Overlay/HioImageWrapper``
- ``OpenUSD/Overlay/HgiWrapper``
- ``OpenUSD/Overlay/HgiMetalWrapper``
- ``OpenUSD/Overlay/UsdImagingGLEngineWrapper``
- ``OpenUSD/Overlay/UsdAppUtilsFrameRecorderWrapper``

