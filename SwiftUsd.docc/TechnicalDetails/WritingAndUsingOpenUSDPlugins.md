# Writing and Using OpenUSD Plugins

Learn how to write and use OpenUSD plugins written in Swift or C++

## Overview

OpenUSD has a plugin system for extending its core capabilities, such as adding support for new image or Sdf file formats or adding new Hydra Render Delegates. With SwiftUsd, you can write plugins in either C++ or Swift, and use them in both SwiftUsd-based apps and vanilla OpenUSD runtimes (e.g. `usdview` and `usdrecord` from a vanilla install of OpenUSD).

## Writing plugins in C++ with SwiftUsd
See [SwiftUsd/Examples/Plugins/HioImage/hioPpm_Cxx](https://github.com/apple/SwiftUsd/tree/main/Examples/Plugins/HioImage/hioPpm_Cxx) for an example plugin.

1. Create a Swift Package for your plugin.

2. Within the `Package.swift` package manifest, add a `.library` product that depends on your C++ target or targets.  
For example:
```swift
products: [.library(name: "hioPpm", targets: ["hioPpm"]),],
```

3. In your package manifest, add these lines to the definition of your C++ target:
```swift
resources: [.copy("plugInfo.json")],
plugins: [.plugin(name: "generate-plug-info-json", package: "SwiftUsd")],
```

4. Add a `plugInfo.json` file to your C++ target.  
Make sure to use the following key-value pairs within your plugin instead of hard-coding in specific values. This will ensure that the correct values are inserted into your `plugInfo.json` file at compile time.
```json
"LibraryPath": "@PLUG_INFO_LIBRARY_PATH@",
"ResourcePath": "@PLUG_INFO_RESOURCE_PATH@",
"Root": "@PLUG_INFO_ROOT@",
```

5. Subclass one or more OpenUSD types as needed for your plugin.  
For example, to write a PPM HioImage plugin, you might write: 
```cpp
class HioPpm_Image final: public pxr::HioImage { 
   ...
 };
```
> Important: The type name in the `Types` object in your `plugInfo.json` file must match the name of your C++ plugin subclass. 
 
6. Within a `.cpp` file, make sure to use `TF_REGISTRY_FUNCTION` to let the OpenUSD runtime know about your plugin subclass.  
For example:
```cpp
#include "pxr/base/tf/type.h"
#include "pxr/base/tf/registryManager.h"
#include "pxr/imaging/hio/image.h"

PXR_NAMESPACE_OPEN_SCOPE
TF_REGISTRY_FUNCTION(TfType) {
    TfType t = pxr::TfType::Define<HioPpm_Image, pxr::TfType::Bases<pxr::HioImage>>();
    t.SetFactory<pxr::HioImageFactory<HioPpm_Image>>();
}
PXR_NAMESPACE_CLOSE_SCOPE
```

## Writing plugins in Swift with SwiftUsd
See [SwiftUsd/Examples/Plugins/HioImage/hioPpm_Swift](https://github.com/apple/SwiftUsd/tree/main/Examples/Plugins/HioImage/hioPpm_Swift) for an example plugin.
> Note: Currently, only HioImage plugins can be written in Swift. 

1. Create a Swift Package for your plugin

2. Within the `Package.swift` package manifest, add a `.library` product that depends on your Swift target or targets.  
For example:
```swift
products: [.library(name: "hioPpm", targets: ["hioPpm"]),],
```

3. In your package manifest, add these lines to the definition of your Swift target:
```swift
resources: [.copy("plugInfo.json")],
swiftSettings: [.interoperabilityMode(.Cxx)],
plugins: [.plugin(name: "generate-plug-info-json", package: "SwiftUsd")],
```
> Important: On Swift 6.1-6.2, you also need to add `.enableExperimentalFeature("SymbolLinkageMarkers")` to the `swiftSettings` array. 

4. Add a `plugInfo.json` file to your target.
Make sure to use the following key-value pairs within your plugin instead of hard-coding in specific values. This will ensure that the correct values are inserted into your `plugInfo.json` file at compile time.
```json
"LibraryPath": "@PLUG_INFO_LIBRARY_PATH@",
"ResourcePath": "@PLUG_INFO_RESOURCE_PATH@",
"Root": "@PLUG_INFO_ROOT@",
```

5. Subclass one or more OpenUSD types as needed for your plugin using `Overlay.FooSubclass`.  
For example:
```swift
final class HioPpm_Image: Overlay.HioImageSubclass {
   ....
}
```
> Note: Not all OpenUSD types can be subclassed in Swift. See <doc:SwiftSubclassCxx> for the complete list. 

6. Apply `@SWIFTUSD_PLUGIN` to your plugin entry point. For example:
```swift
@SWIFTUSD_PLUGIN
final class HioPpm_Image: Overlay.HioImageSubclass {
    ...
}
```
> Note: You only need to use the macro once per plugin, on the plugin entry point, not on every Swift subclass of an OpenUSD type. The name of the Swift class you apply the macro to must match the value in the `Types` object in your `plugInfo.json` file.  

## Using plugins within a SwiftUsd-based application
1. Add the SwiftUsd-based plugin you want to use as a remote or local package dependency to your app. The OpenUSD runtime will automatically discover and use the plugin when needed. 

## Using plugins within a vanilla OpenUSD-based application
1. Clone the SwiftUsd-based plugin you want to use.

2. Run the following commands:
```zsh
cd /path/to/cloned-swiftusd-plugin
swift build
swift package build-vanilla-openusd-plugin
```
The `swift build` command builds the package like normal, and the `swift package build-vanilla-openusd-plugin` invokes a SwiftUsd-provided custom build command that converts the output from `swift build` into an OpenUSD plugin.

3. Set the `PXR_PLUGINPATH_NAME` environment variable to include the path to the plugin produced by `swift package build-vanilla-openusd-plugin`. For example:
```
export PXR_PLUGINPATH_NAME="/Users/maddyadams/SwiftUsd/Examples/Plugins/HioImage/hioPpm_Swift/.build/plugins/build-vanilla-openusd-plugin/outputs/hioPpm.usdplugin:$PXR_PLUGINPATH_NAME"
```
Then, use a command like `usdview` or `usdrecord`.
> Note: The `.usdplugin` directory produced by `swift package build-vanilla-openusd-plugin` is fully relocatable, so you can move it to another directory after compiling.  

## Technical details
After you add `plugins: [.plugin(name: "generate-plug-info-json", package: "SwiftUsd")],` to a target in your Swift Package manifest, the build system will automatically invoke the Swift Package Manager plugin `generate-plug-info-json` provided by SwiftUsd when building that target. (Note that Swift Package Manager plugins are completely unrelated to OpenUSD plugins.)  
`generate-plug-info-json` produces three modified copies of your `plugInfo.json` file: `plugInfo_macOS.json`, `plugInfo_iOS.json`, and `plugInfo_vanilla.json`. SwiftUsd-based applications will automatically use `plugInfo_macOS.json` in macOS apps and `plugInfo_iOS.json` in iOS/visionOS apps, ignoring the other files. After using `swift package build-vanilla-openusd-plugin` on a plugin, vanilla OpenUSD runtimes will automatically use `plugInfo_vanilla.json`, ignoring the other files.
The different files are required because macOS, iOS, and vanilla OpenUSD plugins use different bundle structures. When you use the `@PLUG_INFO_FOO@` values in your `plugInfo.json` file instead of hard-coding values, `generate-plug-info-json` automatically fills them in with the right values for the intended target architecture/use case. 

`swift package build-vanilla-openusd-plugin` invokes the Swift Package Manager plugin `build-vanilla-openusd-plugin` provided by SwiftUsd. (Note that Swift Package Manager plugins are completely unrelated to OpenUSD plugins.)  
`build-vanilla-openusd-plugin` expects that you've already run `swift build` to compile your code. It traverses the build directory to find and link together object files produced by your targets. It also weak-links the OpenUSD frameworks provided by SwiftUsd. This means that your dylib may still work if the host application wasn't built with certain feature flags (e.g. Alembic), but it also means that your dylib may crash the host application if it tries to use missing symbols without checking for their existence at runtime. Finally, `build-vanilla-openusd-plugin` uses `install_name_tool` to change the `LC_LOAD_DYLIB` commands to the form used by vanilla OpenUSD installs. 