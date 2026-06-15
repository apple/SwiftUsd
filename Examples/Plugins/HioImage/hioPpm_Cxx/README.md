# HioImage PPM plugin (C++)

This package is an example of how to write an HioImage plugin in C++.

## Key details
- In `plugInfo.json`, we use `@PLUG_INFO_LIBRARY_PATH@`, `@PLUG_INFO_RESOURCE_PATH@`, and `@PLUG_INFO_ROOT@` to allow our plugin to be used in both SwiftUsd-based apps and vanilla OpenUSD-based runtimes.
- In `Package.swift`, we use `.copy("plugInfo.json")` and `.plugin(name: "generate-plug-info-json", package: "SwiftUsd")` to have the build system fill in the `@PLUG_INFO_*@` values based on the target architecture
- In `hioPpm.h`, we subclass from `pxr::HioImage` and implement its pure-virtual methods. 
- In `hioPpm.cpp`, we use the `TF_REGISTRY_FUNCTION` macro along with `pxr::TfType::Define` and `pxr::TfType::SetFactory` to tell the OpenUSD runtime how to use our custom plugin. 

## Usage
To use this plugin in a SwiftUsd-based app:
1. Add it as a package dependency to your Swift Package/Xcode project.

To use this plugin in a vanilla OpenUSD-based app:
1. `cd` into the package directory
2. Run `swift build`
3. Run `swift package build-vanilla-openusd-plugin` and note the outputed plugin path
4. Set the `PXR_PLUGINPATH_NAME` environment variable to point to your plugin. For example:
```
export PXR_PLUGINPATH_NAME="/Users/maddyadams/SwiftUsd/Examples/HioImage/hioPpm_Cxx/.build/plugins/build-vanilla-openusd-plugin/outputs/hioPpm.usdplugin/:$PXR_PLUGINPATH_NAME"
usdview example.usda
```
