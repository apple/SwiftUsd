# HioImage PPM plugin (Swift)

This package is an example of how to write an HioImage plugin in Swift.

## Key details
- In `plugInfo.json`, we use `@PLUG_INFO_LIBRARY_PATH@`, `@PLUG_INFO_RESOURCE_PATH@`, and `@PLUG_INFO_ROOT@` to allow our plugin to be used in both SwiftUsd-based apps and vanilla OpenUSD-based runtimes.
- In `Package.swift`, we use `.copy("plugInfo.json")` and `.plugin(name: "generate-plug-info-json", package: "SwiftUsd")` to have the build system fill in the `@PLUG_INFO_*@` values based on the target architecture
- In `Package.swift`, we add `.enableExperimentalFeature("SymbolLinkageMarkers")` as a Swift setting when using Swift 6.1/6.2, because Swift didn't gain official support for the `@used` and `@section` attributes until Swift 6.3. This allows us to write a plugin that can be used across as many Swift compiler versions as possible.
- In `hioPpm.swift`, we use the `@SWIFTUSD_PLUGIN` macro to tell the OpenUSD runtime how to use our custom plugin. We also subclass from `Overlay.HioImageSubclass` and implement its required (pure-virtual) methods.

## Usage
To use this plugin in a SwiftUsd-based app:
1. Add it as a package dependency to your Swift Package/Xcode project.

To use this plugin in a vanilla OpenUSD-based app:
1. `cd` into the package directory
2. Run `swift build`
3. Run `swift package build-vanilla-openusd-plugin` and note the outputed plugin path
4. Set the `PXR_PLUGINPATH_NAME` environment variable to point to your plugin. For example:
```
export PXR_PLUGINPATH_NAME="/Users/maddyadams/SwiftUsd/Examples/HioImage/hioPpm_Swift/.build/plugins/build-vanilla-openusd-plugin/outputs/hioPpm.usdplugin/:$PXR_PLUGINPATH_NAME"
usdview example.usda
```
