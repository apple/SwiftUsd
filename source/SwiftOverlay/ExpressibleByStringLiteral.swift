//
//  SwiftOverlay_ExpressibleByStringLiteral.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation


extension pxr.TfToken: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self = pxr.TfToken(std.string(stringLiteral))
    }
}

extension pxr.SdfPath: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self = pxr.SdfPath(std.string(stringLiteral))
    }
}
extension pxr.SdfAssetPath: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self = pxr.SdfAssetPath(std.string(stringLiteral))
    }
}
