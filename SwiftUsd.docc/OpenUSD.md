# ``OpenUSD``

## Overview

This repo modifies Pixar's [OpenUSD](https://openusd.org/release/index.html) to enable Swift-Cxx interoperability, letting developers use the OpenUSD C++ API directly from Swift, distributed as a Swift package.

The documentation in this repo goes over differences when using OpenUSD in Swift. The full C++ documentation for OpenUSD can be found [here](https://openusd.org/release/api/index.html). 

## Topics

### Essentials
- <doc:GettingStarted>
- <doc:Capabilities>
- <doc:DifferencesInSwift>
- <doc:CurrentLimitations>

### Wrapped symbol documentation
In Swift, some parts of the OpenUSD API aren't directly available. This Swift Package re-exposes a subset of the API, documented here. (See <doc:CurrentLimitations> for more information.)
- ``OpenUSD/Overlay``
- <doc:WrappedTypes>
- <doc:WrappedEnums>
- <doc:WrappedFunctions>
- <doc:WrappedOperators>

### New symbol documentation
This Swift package adds new functions/types to make OpenUSD more natural to use in Swift.
- <doc:DereferencingPointers>
- <doc:CreatingPointers>
- <doc:CheckingForValidity>
- <doc:UsingEditContexts>
- <doc:WorkingWithTfNotice>
- <doc:WorkingWithTfErrorMark>
- <doc:WorkingWithTfDiagnosticFacilities>
- <doc:ConvenientExtensions>
- <doc:TypeConversion>

### Protocol conformances
This Swift Package provides a number of protocol conformances to make OpenUSD more natural to use in Swift. 
- <doc:Equatable>
- <doc:Comparable>
- <doc:Hashable>
- <doc:CustomStringConvertible>
- <doc:Sendable>
- <doc:Codable>

### Working with foreign reference types
- <doc:WhatIsAForeignReferenceType>
- <doc:ForeignReferenceTypesAndSmartPointers>
- <doc:CastingBetweenForeignReferenceTypes>

### Using SwiftUsd from C++
- <doc:GettingStartedInCPlusPlus>
- <doc:SwiftCxxInteropMemorySafety>
- <doc:SwiftCxxMacros>

### Technical details
- <doc:DetectingOpenUSDFeatureFlags>
- <doc:BuildingLocally>
- <doc:ChangesToOpenUSD>

### Deprecated
- <doc:DeprecatedSymbols>

### About this repo
- <doc:ChangeLog>
- <doc:OngoingWork>
- <doc:CheatSheet>
- <doc:UpgradeChecklist>
- <doc:ReleaseChecklist>
- <doc:Miscellaneous>