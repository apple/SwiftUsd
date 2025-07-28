# What is a Foreign Reference Type?

Learn about foreign reference types and how to use them

## Overview

In Swift, a foreign reference type (FRT) is a C++ type that is annotated with `SWIFT_SHARED_REFERENCE`, `SWIFT_IMMORTAL_REFERENCE`, or `SWIFT_UNSAFE_REFERENCE`. When Swift encounters C++ pointers or references to such a type, Swift imports the pointer/reference as a class type with Swift reference semantics. These annotations can grant access in Swift to C++ types that are non-movable and non-copyable, which would otherwise not be directly usable in Swift.

- `SWIFT_SHARED_REFERENCE` types participate in automatic reference counting (ARC), just like Swift classes and actors. They are guaranteed to stay alive as long as there is at least one strong reference to it, such as a Swift variable containing the reference type. (However, using the `weak` keyword in Swift with these types does not work: [https://github.com/swiftlang/swift/issues/83080: Assigning a non-nil value to a weak SWIFT_SHARED_REFERENCE variable crashes at runtime](https://github.com/swiftlang/swift/issues/83080))

- `SWIFT_IMMORTAL_REFERENCE` types are immortal types that are allocated but never deallocated, like singletons.

- `SWIFT_UNSAFE_REFERENCE` types are types that have no lifetime guarantees and may be deallocated at some point.

See [swift.org](https://www.swift.org/documentation/cxx-interop/#mapping-c-types-to-swift-reference-types) for more information about FRTs. 

### OpenUSD and reference types

In OpenUSD, there are several ways that types can indicate that they have reference semantics:

- Inheriting from `pxr::TfRefBase`: For example, `pxr::UsdStage` inherits from `pxr::TfRefBase`. For these types, SwiftUsd tries to mark all of them as `SWIFT_SHARED_REFERENCE`, because `pxr::TfRefBase` provides intrusive reference counting semantics, which is a great match for `SWIFT_SHARED_REFERENCE`.

- Inheriting from `pxr::TfWeakBase`: For example, `pxr::UsdImagingDelegate` inherits from `pxr::TfWeakBase`. For these types, SwiftUsd currently doesn't annotate them, so they may not be usable directly in Swift. (However, types like `pxr::SdfLayer` which inherit from `pxr::TfRefBase` and `pxr::TfWeakBase` are usable in Swift. Those types are marked `SWIFT_SHARED_REFERENCE`, and additionally can be used with [`Overlay.WeakReferenceHolder`](doc:OpenUSD/C++/Overlay/WeakReferenceHolder) to hold them weakly instead of strongly.)

- Integrating with `pxr::TfStaticData<T>`. For example, `pxr::UsdGeomTokens` and `extern pxr::TfStaticData<UsdGeomTokensType> UsdGeomTokens;`. For these types, the template argument may be imported into Swift, but the `pxr::TfStaticData` specialization is not, and SwiftUsd currently doesn't annotate it. However, future versions of SwiftUsd might annotate `pxr::TfStaticData` specializations so that they are imported into Swift.

- Deleting/hiding copy and move constructors, but integrating with `pxr::TfSingleton<T>`. For example, `pxr::PlugRegistry`. For these types, SwiftUsd marks them as `SWIFT_IMMORTAL_REFERENCE`, so they should be usable directly in Swift. 

- Deleting/hiding copy and move constructors, used via stl smart pointer. For example, `pxr::UsdImagingGLEngine`. These types are expected to be used via `std::unique_ptr<T>` or `std::shared_ptr<T>`. For these types, SwiftUsd currently doesn't annotate them or their stl smart pointer specializations, and the stl smart pointer specializations may not be very useful in Swift.

- Deleting/hiding copy and move constructors, used by const-ref. For example, `pxr::UsdPrimDefinition`. For these types, SwiftUsd currently doesn't annotate them, so they may not be usable directly in Swift. 

> Note: Types like `pxr::UsdEditContext` and `pxr::TfErrorMark` are not directly imported into Swift because they are non-movable and non-copyable. However, they are intended to be used as automatic (local) variables for RAII, and do not have reference semantics. SwiftUsd provides [`Overlay.withUsdEditContext(_:_:_:)`](doc:OpenUSD/C++/Overlay/withUsdEditContext(_:_:_:)), and future versions of SwiftUsd might provide an easy way to directly or indirectly use these types.

> Note: This list is non-exhaustive; there may be other patterns in OpenUSD of using non-movable non-copyable types.


### SwiftUsd APIs

SwiftUsd conforms all imported FRTs to `Equatable`, `Hashable`, and `Comparable`, and also provides static `===` and `!==` operators for comparing the identity of two FRTs of the same type.

SwiftUsd also creates some underscored protocols to make FRTs easier to use in Swift, such as to provide default protocol conformances. Avoid using these protocols in your code, because they are not part of the stable API.
- ``OpenUSD/C++/Overlay/_SwiftUsdReferenceTypeProtocol``
- ``OpenUSD/C++/Overlay/_SwiftUsdImmortalReferenceTypeProtocol``
- ``OpenUSD/C++/Overlay/_TfRefBaseProtocol``
- ``OpenUSD/C++/Overlay/_TfRefPtrProtocol``
- ``OpenUSD/C++/Overlay/_TfConstRefPtrProtocol``
- ``OpenUSD/C++/Overlay/_TfWeakBaseProtocol``
- ``OpenUSD/C++/Overlay/_TfWeakPtrProtocol``
- ``OpenUSD/C++/Overlay/_TfConstWeakPtrProtocol``