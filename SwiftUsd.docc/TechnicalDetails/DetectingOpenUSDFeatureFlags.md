# Detecting OpenUSD feature flags

Learn how to detect OpenUSD feature flags

## Overview

SwiftUsd comes with a pre-built version of OpenUSD, but it supports creating Swift Packages from existing OpenUSD builds, including builds with different OpenUSD feature flags. For example, OpenUSD might be built without imaging support, or with OpenVDB support. To write code that supports different feature flag sets (or handles incompatible feature flag sets gracefully), use these techniques.

## Supported feature flags:
- Alembic plugin (`ALEMBIC`): `--alembic`, `--no-alembic`
- Draco plugin (`DRACO`): `--draco`, `--no-draco`
- Embree plugin (`EMBREE`): `--embree`, `--no-embree`
- OpenColorIO plugin (`OPENCOLORIO`): `--opencolorio`, `--no-opencolorio`
- OpenImageIO plugin (`OPENIMAGEIO`): `--openimageio`, `--no-openimageio`
- RenderMan plugin (`PRMAN`): `--prman`, `--no-prman`
- Imaging component (`IMAGING`): `--imaging`, `--no-imaging`
- UsdImaging component (`USD_IMAGING`): `--usd-imaging`
- MaterialX support (`MATERIALX`): `--materialx`, `--no-materialx`
- OpenVDB support (`OPENVDB`): `--openvdb`, `--no-openvdb`
- Ptex support (`PTEX`): `--ptex`, `--no-ptex`
- Python support (`PYTHON`): `--python`, `--no-python`

## Detecting feature flags in Swift

You can detect OpenUSD feature flags at compile time by using `#if canImport(SwiftUsd_PXR_ENABLE_<flag>_SUPPORT)`. For example,

```swift
#if canImport(SwiftUsd_PXR_ENABLE_OPENVDB_SUPPORT)
// Compiled when SwiftUsd is based on an OpenUSD build with OpenVDB
#else
// Compiled when SwiftUsd is based on an OpenUSD build without OpenVDB
#endif

#if !canImport(SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT)
// Compiled when SwiftUsd is based on an OpenUSD build without UsdImaging
#else
// Compiled when SwiftUsd is based on an OpenUSD build with UsdImaging
#endif
```

## Detecting feature flags in C++

You can detect OpenUSD feature flags at compile time by using `#if SwiftUsd_PXR_ENABLE_<FLAG>_SUPPORT`. For example,

```c++
#include "swiftUsd/swiftUsd.h"

#if SwiftUsd_PXR_ENABLE_OPENVDB_SUPPORT
// Compiled when SwiftUsd is based on an OpenUSD build with OpenVDB
#else
// Compiled when SwiftUsd is based on an OpenUSD build without OpenVDB
#endif

#if !SwiftUsd_PXR_ENABLE_USD_IMAGING_SUPPORT
// Compiled when SwiftUsd is based on an OpenUSD build without UsdImaging
#else
// Compiled when SwiftUsd is based on an OpenUSD build with UsdImaging
#endif
```