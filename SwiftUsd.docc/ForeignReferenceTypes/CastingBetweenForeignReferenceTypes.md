# Casting between Foreign Reference Types

Learn about casting with Foreign Reference Types

## Overview

When working with Swift types, Swift provides the `as`, `as?`, and `as!` operators to coerce types, conditionally cast types, and unconditionally cast types, respectively. However, due to compiler bugs and limitations, these operators do not work with C++ foreign reference types.

SwiftUsd provides [`func as<T>(_ t: T.Type) -> T?`](doc:OpenUSD/C++/Overlay/_TfRefBaseProtocol/as(_:)) on types that inherit from `pxr::TfRefBase`, to dynamically cast from one `pxr::TfRefBase` subclass to another. Use this instead of using `as`, `as?`, or `as!` to upcast or downcast. 