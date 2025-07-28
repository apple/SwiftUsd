# Working with TfErrorMark

Learn how to use TfErrorMark in Swift

## Overview

OpenUSD includes a non-fatal error tracking system via `pxr::TfErrorMark`. `TfErrorMark` can't be directly used in Swift, so SwiftUsd provides the [`Overlay.withTfErrorMark(_:)`](doc:/OpenUSD/C++/Overlay/withTfErrorMark(_:)) function and the wrapping type [`TfErrorMarkWrapper`](doc:/OpenUSD/Overlay/TfErrorMarkWrapper) instead.

Example usage:
```swift
Overlay.withTfErrorMark { mark in
    // do some work...
    let stage = Overlay.DereferenceOrNil(pxr.UsdStage.CreateNew(path, .LoadAll))

    if !mark.IsClean() {
        // errors occurred during work
        for error in mark.errors {
            print(error.GetCommentary())
        }
    }
}
```

> Important: `pxr::TfErrorMark` uses thread-local storage, which is incompatible with Swift Concurrency's task execution model. For this reason, the body of [`Overlay.withTfErrorMark(_:)`](doc:/OpenUSD/C++/Overlay/withTfErrorMark(_:)) is intentionally forced to be synchronous (i.e. cannot `await` calls to `async` functions.)