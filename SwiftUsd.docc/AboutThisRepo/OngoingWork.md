# Ongoing Work

In-progress and future tasks for improving OpenUSD in Swift

## Overview
SwiftUsd is currently a work-in-progress. Here is a list of potential future improvements, organized by topic. 

### Ease of set up
- Include visionOS, tvOS, simulators in XCFrameworks


### Small items
- Add missing `SWIFT_NONMUTATING`:
    - `pxr.UsdInherits`
    - `pxr.UsdPrim.RemoveProperty`
    - `pxr.UsdGeomPrimvar`
    - `pxr.UsdGeomBboxCache`
- Investigate what happens when you're iterating over a range backed by a stage that closes during iteration
- Simplify `Sequence`/`Collection` conformances, replacing with `CxxSequence` where possible
- Can upstream warnings in SwiftUsd can be hidden from downstream clients?
- Does API Notes support renaming extern variables, e.g. for `pxr::TfStaticData`?

### Medium items
- Paper over `pxr::UsdSchemaBase::GetPrim()` by renaming the method and extending each subclass to have a definition of it. 
- Investigate adding `requires cplusplus` in the modulemap, which may or may not improve code completion
- Why wasn't the typedef `pxr::SdfLayer::FileFormatArguments` found by ast-answerer?
- Add an unavailable Swift struct `pxr.UsdEditContext` that redirects to `Overlay.withUsdEditContext(_:_:_:)`
- Should `extension pxr.TfToken: ExpressibleByStringLiteral` be removed?
    - C++ doesn't support that even though Python does
    - Should `ExpressibleByStringLiteral`-constructed tokens be immortal instead?
- Add support for casting between UsdSchemaBase subclasses
- Expose VTOPERATOR_CPPARRAY, i.e. math operators on VtArray specializations, to Swift
- Import nested TfRefBase subclasses as SWIFT_SHARED_REFERENCE
- Add `CustomDebugStringConvertible` and `@DebugDescription` for Usd types
- Investigate papering over Overlay enum wrapping by extern consting the values in `PXR_NS` with a different name, then `swift_name`ing them to what users expect? 
    - If that doesn't work, investigate API notes enum case renaming to paper over enum wrapping
- Investigate automatically wrapping missing operator auto-conversion initializers, e.g. `pxr::UsdGeomPrimvar::operator UsdAttribute()`
- Investigate automatically wrapping missing math operators
- Automatically generate `Bool(_:)` initializers for C++ types with a suitable `operator bool() const`-like operator
- Add support for TfNotice in Swift on Linux


### Big items
- Investigate if immortal/singleton types (TfSingleton, TfStaticData, various Usd registries) can be imported as immortal types in Swift
- Investigate if using ImportAsMember could reduce Swift compile times, and how it interacts with default arguments
- Investigate automatically wrapping non-imported types (i.e. non-moveable non-reference types)
- Remove `pxr::TfRefPtr` and `pxr::TfWeakPtr` completely from Swift using API notes in Swift 6.1
    - Nullability heuristics. Are arguments typically nonnull, and return values typically nullable? Are there functions where passing a null smart pointer isn't a misuse of the API and isn't a noop?
- Add support for SwiftUI views using Usd types via custom Swift macros + TfNotice
    - Should propagate to computed properties and function bodies in views
    - Should be able to wire up a model to observation tracking, so app models that vend wrapper types for Usd data are compatible
    - Use macros in unit tests to catch observation keypaths by tracking the same way SwiftUI does
- Add support for custom file format plugins implemented in Swift
    - Requires supporting static initialization in Swift via `@_section`. Could probably be wrapped in a macro
- ~~Investigate if SwiftUsd works on Linux~~
    - Experimental Linux support added in SwiftUsd 2.0.1
- Add Swift function body macros for validity warning
- Add Swift DSL for inline stage building
    - Should support usda -> DSL conversion
- Find a better solution for making `pxr::Foo` work nicely in Swift
- Add support for embedding custom OpenUSD plugins in SwiftUsd builds