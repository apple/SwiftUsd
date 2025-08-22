# Using libWork

Learn how to use the `pxr::Work` library for multithreading in Swift

## Overview

OpenUSD provides the [Work](https://openusd.org/release/api/work_page_front.html) library to simplify C++ multithreading. A select portion of this API is available in Swift.

> Note: `Work` is backed by a different multithreading implementation than Swift Concurrency. In some cases, Swift Concurrency may be a better fit for a problem than using `libWork` from Swift. 

## Detached tasks
Use [`pxr.WorkRunDetachedTask(_:)`](doc:/OpenUSD/C++/pxr/WorkRunDetachedTask(_:)) to invoke a closure asynchronously.

## Loops
Use [`pxr.WorkSerialForN(_:_:)`](doc:/OpenUSD/C++/pxr/WorkSerialForN(_:_:)) to easily temporarily turn off multithreading of a parallel loop for easier debugging.

Use [`pxr.WorkParallelForN(_:_:)`](doc:/OpenUSD/C++/pxr/WorkParallelForN(_:_:)) to run a closure in parallel over a range.

Use [`pxr.WorkParallelForEach(_:_:)`](doc:/OpenUSD/C++/pxr/WorkParallelForEach(_:_:)) to run a closure in parallel over a collection.

## Reduce

Use [`pxr.WorkParallelReduceN(_:_:_:_:)`](doc:/OpenUSD/C++/pxr/WorkParallelReduceN(_:_:_:_:)) to map and reduce a range in parallel. 