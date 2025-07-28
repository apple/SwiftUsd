//
//  OpenUSD.swift
//
//
//  Created by Maddy Adams on 10/1/24.
//


// Use @_exported to allow clients that `import OpenUSD` to get access
// to the underlying C++ libraries
// use @_documentation(visibility: internal) to hide imported symbols
// from showing up in DocC (e.g. Boost macros, public constants)
@_documentation(visibility: internal) @_exported import _OpenUSD_SwiftBindingHelpers


// Makes it easier for clients to access Usd types without
// having to do the full typealias
// use @_documentation(visibility: internal) to hide this
// from showing up in DocC
@_documentation(visibility: internal) public typealias pxr = pxrInternal_v0_25_5__pxrReserved__
