//
//  SwiftOverlay_TypeConversionInitializers.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation

extension Float {
    public init(_ h: pxr.GfHalf) {
        self = __Overlay.halfToFloat(h)
    }
}
// GfHalf.init(Float) provided by ilmbase_half.h


extension String {
    public init(_ token: pxr.TfToken) {
        self.init(token.GetString())
    }
}
extension pxr.TfToken {
    public init(_ string: String) {
        self.init(std.string(string))
    }
}


extension String {
    public init(_ path: pxr.ArResolvedPath) {
        self.init(path.GetPathString())
    }
}
extension pxr.ArResolvedPath {
    public init(_ string: String) {
        self.init(std.string(string))
    }
}


extension String {
    public init(_ path: pxr.SdfPath) {
        self.init(path.GetAsString())
    }
}
extension pxr.SdfPath {
    public init(_ string: String) {
        self.init(std.string(string))
    }
}


extension String {
    /// Uses `path.GetAssetPath()`. To use a different accessor, call that accessor explicitly
    public init(_ path: pxr.SdfAssetPath) {
        self.init(path.GetAssetPath())
    }
}
extension pxr.SdfAssetPath {
    public init(_ s: String) {
        self.init(std.string(s))
    }
}


extension std.string {
    public init(_ token: pxr.TfToken) {
        self = token.GetString()
    }
}
// TfToken.init(std.string) provided by token.h


extension std.string {
    public init(_ path: pxr.ArResolvedPath) {
        self = path.GetPathString()
    }
}
// ArResolvedPath.init(std.string) provided by resolvedPath.h
