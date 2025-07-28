//
//  SwiftOverlay_Miscellaneous.swift
//
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation


// SdfPathSet is std::set<SdfPath>, which isn't caught by Equatable codegen
extension pxr.SdfPathSet: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        __Overlay.operatorEqualsEquals(lhs, rhs)
    }
}

extension Overlay.UsdPrimTypeInfoWrapper: Equatable {}

// ArResolvedPath doesn't have operator<< functions, but does have
// `operator const std::string&()`, which isn't caught by CustomStringConvertible code gen

extension pxr.ArResolvedPath: CustomStringConvertible {
    public var description: String {
        String(GetPathString())
    }
}

#if os(Linux)
// https://github.com/swiftlang/swift/pull/77890
// On Swift 6.0.3 on Linux, Observation runs into a linker error that swift::threading::fatal can't be found.
// So, stub it out. 
@_cdecl("_ZN5swift9threading5fatalEPKcz") func swift_threading_fatal() { fatalError("swift::threading::fatal") }
#endif