# Foreign Reference Types and Smart Pointers

Learn about `pxr::TfRefPtr` and `pxr::TfWeakPtr` in Swift

## Overview

In C++, types that inherit from `pxr::TfRefBase` should be used via the `pxr::TfRefPtr<T>` templated smart pointer. This smart pointer manipulates the reference count of the underlying value, ensuring that the lifetime of resources is managed properly and safely. But when using SwiftUsd to write Swift code, types that inherit from `pxr::TfRefBase` are marked as `SWIFT_SHARED_REFERENCE`, meaning they can be used directly in Swift with automatic reference counting.

Using `SWIFT_SHARED_REFERENCE` types directly improves the ergonomics of Swift code while maintaining the memory safety and lifetime guarantees of `pxr::TfRefPtr<T>`. You can use the `SWIFT_SHARED_REFERENCE` type (for example, `pxr.UsdStage`) as the types of variables instead of `pxr.TfRefPtr<pxr.UsdStage>` or `pxr.UsdStageRefPtr` (a typealias for `pxr::TfRefPtr<pxr::UsdStage>`), and you can directly call methods on the `SWIFT_SHARED_REFERENCE` type that aren't available directly on the `pxr::TfRefPtr<T>`. For these reasons, when working with Swift code, prefer using the `SWIFT_SHARED_REFERENCE` types directly.

In C++, types that inherit from `pxr::TfWeakBase` can be used via the `pxr::TfWeakPtr<T>` templated smart pointer. This smart pointer detects when the underlying value is deleted, without maintaining a strong reference to the underlying value. When C++ types inherit from both `pxr::TfRefBase` and `pxr::TfWeakBase`, they are marked as `SWIFT_SHARED_REFERENCE`. Since `pxr::TfWeakPtr<T>` suffers from similar ergonomics issues as `pxr::TfRefPtr<T>`, you should avoid using `pxr::TfWeakPtr<T>`'s in your code. If you need to detect when an underlying value is deleted without maintaining a strong reference, use ``OpenUSD/C++/Overlay/WeakReferenceHolder`` instead. 

## Using OpenUSD APIs

Since the OpenUSD APIs are written using smart pointers, but Swift code should use `SWIFT_SHARED_REFERENCE` types directly instead of smart pointers, you may need to convert to and from smart pointers. For example, you should use [`Overlay.TfWeakPtr(_:)`](doc:OpenUSD/C++/Overlay/TfWeakPtr(_:)-8de9g) when calling the function `pxr::TfToken pxr::UsdGeomGetStageUpAxis(const pxr::UsdStageWeakPtr& stage);`

- Use [`Overlay.DereferenceOrNil(_:)`](doc:OpenUSD/C++/Overlay/DereferenceOrNil(_:)-4yt4i) to conditionally convert a smart pointer to its underlying type. If the smart pointer was pointing to null, Swift returns a `nil` optional value.
- Use [`Overlay.Dereference(_:)`](doc:OpenUSD/C++/Overlay/Dereference(_:)-67vpz) to unconditionall convert a smart pointer to its underlying type. If the smart pointer was pointing to null, Swift terminates with an "unexpectedly found nil" error message.
- Use [`Overlay.TfRefPtr(_:)`](doc:OpenUSD/C++/Overlay/TfRefPtr(_:)-7quy3) to create a `pxr::TfRefPtr<T>` that strongly points to a `SWIFT_SHARED_REFERENCE` type.
- Use [`Overlay.TfWeakPtr(_:)`](doc:OpenUSD/C++/Overlay/TfWeakPtr(_:)-8de9g) to create a `pxr::TfWeakPtr<T>` that weakly points to a `SWIFT_SHARED_REFERENCE` type. 
- Use [`Bool.init(_:)`](doc:OpenUSD/Swift/Bool/init(_:)-63kny) to determine whether a `pxr::TfRefPtr<T>` points to a valid instance or to null
- Use [`Bool.init(_:)`](doc:OpenUSD/Swift/Bool/init(_:)-6azcc) to determine whether a `pxr::TfWeakPtr<T>` currently points to a valid instance or to null. (Keep in mind that a `pxr::TfWeakPtr<T>` that currently points to a valid instance could point to null the next time it is used, even if that's in the very next line of code.)


> Warning: When mixing custom Swift and C++ code in the same target or project, using `SWIFT_SHARED_REFERENCE` types directly can cause memory safety issues if you aren't careful. See <doc:SwiftCxxInteropMemorySafety> for how to avoid these issues. 