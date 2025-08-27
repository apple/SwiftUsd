# Change Log

Changes to SwiftUsd

@Comment {
    If you're adding to the ChangeLog and there isn't an existing "TBD release" section,
    please create one by adding the following lines above the most recent release's section
    ```
    ### TBD
    Released TBD, based on OpenUSD TBD
    ```
}

### 5.1.0
Released 2025-08-27, based on OpenUSD v25.08
- Exposed some libWork APIs to Swift (see [Using libWork](<doc:UsingLibWork>))
- Changed dylib bundling to pick up OpenEXR again for default macOS and iOS packages
- Cherry pick a commit from the OpenUSD dev branch to fix a memory footprint regression with UsdImagingGLEngine on macOS

### 5.0.2
Released 2025-08-11, based on OpenUSD v25.08
- Fixed deployment error when using Xcode 26 beta 5 to target iOS devices

### 5.0.1
Released 2025-08-07, based on OpenUSD v25.08
- Fixed compiler errors when using Xcode 26 beta 5 (17A5295f)

### 5.0.0
Released 2025-08-06, based on OpenUSD v25.08
- Move from OpenUSD v25.05.01 to v25.08
- Added ImageIO to default macOS and iOS packages, and removed OpenImageIO from default macOS package
- Added OpenVDB to default macOS package

### 4.1.1
Released 2025-07-28, based on OpenUSD v25.05.01
- Moved to final repo URLs for public release

### 4.1.0
Released 2025-07-18, based on OpenUSD v25.05.01
- Added Alembic to default macOS and iOS packages
- Restructured make-swift-package, added clearer command line options
- Added better documentation for wrapped types
- Changed source/generated/StaticTokens to use `extern const* const` variables for better Swift Concurrency safety

### 4.0.0
Released 2025-06-20, based on OpenUSD v25.05.01
- Added ArResolverWrapper, UsdZipFileIteratorWrapper, UsdAppUtilsFrameRecorderWrapper
- Added Codable support for many Gf types, VtArray specializations, and a handful of other types
- Added UsdUtilsTimeCodeRange and GfMultiInterval conformances to Sequence and Codable
- Added Swift `pointee` properties for SdfFooSpecHandle specializations
- Added CustomStringConvertible implementation for TfErrorMarkWrapper.ErrorSequence
- Added `template <typename T> pxr::TfEnum Overlay::formTfEnum(T t)` for Swift
- Added more const-ref-returning wrapper methods
- Added LICENSE.txt

- Fixed UsdTimeCode Codable implementation for PreTime values
- Improve HgiWrapper, HgiMetalWrapper
- Internal cleanup/tidying
- Allowed codegen for types previously blocked by compiler bugs

- Simplified patch to `pxr/base/tf/notice.h`
- Removed patch modifications for reading back depth from Hydra

- Removed UsdView, UsdTransportBar, and source/SwiftUI
- Removed UsdZipFileWriterWrapper. Usd pxr.UsdZipFileWriter instead
- Remove support for old-style framework includes, i.e. `#include <OpenUSD/pxr/usd/usd/stage.h>`. Use `#include "pxr/usd/usd/stage.h"` instead.
- Removed dead deprecated code


### 3.0.1
Released 2025-05-28, based on OpenUSD v25.05.01
- Added OpenImageIO to default macOS package
- Added warning about dylibs with non-relocatable dependencies to makes-swift-package
- Blocked pxr/imaging/hdEmbree headers from the modulemap for now
- Neatened changes to pxr/usd/usdMtlx/utils.cpp

### 3.0.0
Released 2025-05-20, based on OpenUSD v25.05.01
- Increased minimum supported Swift compiler version to Swift 6.1
- Added importing of non-movable `pxr::TfSingleton<T>` specializations as immortal reference types
- Added support for dereferencing and checking validity of `pxr::TfRefPtr<const T>` and `pxr::TfWeakPtr<const T>` specializations
- Upgraded the Embree Hydra Render Delegate to embree4
- Used new Swift 6.1 features to shrink the patch to OpenUSD

### 2.1.1
Released 2025-04-02, based on OpenUSD v25.02a
- Added the Embree Hydra Render Delegate to the macOS default Swift Package. (Note: Embree is not available on iOS)
- Fixed some documentation typos

### 2.1.0
Released 2025-03-26, based on OpenUSD v25.02a
- Added `Overlay.withTfErrorMark(_:)` to expose `pxr::TfErrorMark` to Swift
- Added `TF_ERROR`, `#TF_VERIFY`, and others to expose Tf diagnostic functions/macros to Swift
- Switched to ast-answerer for exposing TfStaticData token types (e.g. pxr::UsdGeomTokens->Cube)
- Added std::size_t fix from [https://github.com/PixarAnimationStudios/OpenUSD/pull/3535](https://github.com/PixarAnimationStudios/OpenUSD/pull/3535) for prerelease compilers
- Added std.string initializer from TfToken

### 2.0.1
Released 2025-03-05, based on OpenUSD v25.02a
- Moved from OpenUSD v25.02 to OpenUSD v25.02a
- Added back `#include "pxr/pxr.h"` includes. `#include <OpenUSD/pxr/pxr.h>` includes are still supported, but will be removed in a future release.
- Rewrote `scripts/make-swift-package` in Swift. Now has experimental support for Linux, non-app-bundled SwiftUsd packages, and multiple Usd feature flags
- Simplified workaround for [rdar://117091104: Swift overspecializes templates, causing an error that C++ avoids (Usd v23.11rc-1)](rdar://117091104)
- Added [https://github.com/PixarAnimationStudios/OpenUSD/pull/3553](https://github.com/PixarAnimationStudios/OpenUSD/pull/3553)

### 2.0.0
Released 2025-01-27, based on OpenUSD v25.02
- Move from OpenUSD v24.11 to OpenUSD v25.02
- Two small source-breaking changes to types (`Overlay::SdfSubLayerProxyIteratorWrapper`, `pxr.SdfPath.AbsoluteRootPath()`)
- Hide `pxr.TfRefPtr<T>.pointee` and `pxr.TfWeakPtr<T>.pointee` completely from Swift

### 1.2.0
Released 2025-01-22, based on OpenUSD v24.11
- Exposed the `pxr.TfNotice.Register` notification subsystem to Swift
- Added `protocol SwiftUsd.TfNoticeProtocol` and conformed all types deriving from `pxr::TfNotice` to it
- Added `pxr::TfNotice::SwiftKey`, `pxr::TfNotice::SwiftKeys` types for revoking Swift/C++ listeners
- Added `pxr.TfNotice.NoticeCaster` for conditionally downcasting notices during a `pxr.TfNotice.Register` callback
- Marked types nested under `pxr::UsdNotice` with `SWIFT_SELF_CONTAINED` and wrapped their const-ref accessors

### 1.1.0
Released 2024-12-19, based on OpenUSD v24.11
- Added importing all `pxr::TfRefBase` subclasses as `SWIFT_SHARED_REFERENCE`
- Added C++ API for safely moving raw pointers of `SWIFT_SHARED_REFERENCE` types across the Swift-Cxx language boundary
- Added C++ umbrella header `<OpenUSD/swiftUsd/swiftUsd.h>` for API added by SwiftUsd usable in C++
- Added casting between `pxr::TfRefBase` subclasses via `as` protocol method
- Added `Bool.init(_:)` initializer for all `pxr::TfRefPtr<T>` and `pxr::TfWeakPtr<T>` specializations
- Applied [https://github.com/PixarAnimationStudios/OpenUSD/pull/3434](https://github.com/PixarAnimationStudios/OpenUSD/pull/3434) to allow building on newer Clangs
- Added workaround for [rdar://140940883: Swift calling Swift subscript across module boundary in Release accesses uninitialized memory (C++ interop)](rdar://140940883)

### 1.0.1
Released 2024-10-31, based on OpenUSD v24.11
- Add missing non-mutating function `pxr.UsdReferences.ClearReferences()`
- Make `Overlay.SdfLayer.TraversalFunction` take its value by const-ref to work around [rdar://134358343: Second call to SdfLayer.Traverse function causes Sdf_PathNodeHandleImpl use-after-free](rdar://134358343)
- Add `source/SwiftOverlay/__SwiftUsdBuildSettingsCheck.h` to catch incorrect build settings

### 1.0.0
Released 2024-10-29, based on OpenUSD v24.11
- Move from OpenUSD v24.08 to OpenUSD v24.11
- Simplified openusd-patch.patch

### 0.0.3
Released 2024-10-23, based on OpenUSD v24.08
- Add documentation
- Add Swift 6.1-compatible workaround for [rdar://136691907: Linker error in Release because std::__1::__voidify and C++ inline functions are missing](rdar://136691907)

### 0.0.2
Released 2024-10-21, based on OpenUSD v24.08
- Update code generation for C++ types imported as ~Copyable values
- Simplified openusd-patch.patch

### 0.0.1
Released 2024-10-07, based on OpenUSD v24.08
- Initial release
