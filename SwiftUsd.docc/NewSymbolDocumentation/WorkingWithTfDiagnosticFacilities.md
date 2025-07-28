# Working with Tf Diagnostic Facilities

Learn how to use the Tf diagnostic facilities in Swift

## Overview

OpenUSD includes several C++ macros for issuing coding errors, runtime errors, warnings and status messages. SwiftUsd exposes this system to Swift via Swift functions and Swift macros.

See [OpenUSD documentation](https://openusd.org/release/api/page_tf__diagnostic.html) for more information.

## Topics

### Tf diagnostic functions
- ``/OpenUSD/TF_CODING_ERROR(_:_:_:_:_:)``
- ``/OpenUSD/TF_CODING_WARNING(_:_:_:_:_:)``
- ``/OpenUSD/TF_DIAGNOSTIC_FATAL_ERROR(_:_:_:_:_:)``
- ``/OpenUSD/TF_DIAGNOSTIC_NONFATAL_ERROR(_:_:_:_:_:)``
- ``/OpenUSD/TF_DIAGNOSTIC_WARNING(_:_:_:_:_:)``
- ``/OpenUSD/TF_ERROR(_:_:_:_:_:_:)-(pxr.TfEnum,_,_,_,_,_)``
- ``/OpenUSD/TF_ERROR(_:_:_:_:_:_:)-(pxr.TfDiagnosticType,_,_,_,_,_)``
- ``/OpenUSD/TF_ERROR(_:_:_:_:_:_:_:)``
- ``/OpenUSD/TF_FATAL_CODING_ERROR(_:_:_:_:_:)``
- ``/OpenUSD/TF_FATAL_ERROR(_:_:_:_:_:)``
- ``/OpenUSD/TF_QUIET_ERROR(_:_:_:_:_:_:)``
- ``/OpenUSD/TF_QUIET_ERROR(_:_:_:_:_:_:_:)``
- ``/OpenUSD/TF_RUNTIME_ERROR(_:_:_:_:_:)``
- ``/OpenUSD/TF_STATUS(_:_:_:_:_:)``
- ``/OpenUSD/TF_STATUS(_:_:_:_:_:_:)``
- ``/OpenUSD/TF_STATUS(_:_:_:_:_:_:_:)``
- ``/OpenUSD/TF_WARN(_:_:_:_:_:)``
- ``/OpenUSD/TF_WARN(_:_:_:_:_:_:)-(pxr.TfEnum,_,_,_,_,_)``
- ``/OpenUSD/TF_WARN(_:_:_:_:_:_:)-(pxr.TfDiagnosticType,_,_,_,_,_)``
- ``/OpenUSD/TF_WARN(_:_:_:_:_:_:_:)``

### Tf diagnostic macros
- ``/OpenUSD/TF_AXIOM(_:)``
- ``/OpenUSD/TF_DEV_AXIOM(_:)``
- ``/OpenUSD/TF_VERIFY(_:_:)``

Note: In Swift, ``/OpenUSD/#TF_DEV_AXIOM(_:)`` only runs when the Swift source code that uses it was compiled with the `-DDEBUG` flag (i.e. compiled in Debug and not in Release). This differs from the behavior in C++, where `TF_DEV_AXIOM` only runs when the OpenUSD binary was compiled in Debug mode.