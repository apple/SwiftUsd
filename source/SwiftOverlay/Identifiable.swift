//
//  SwiftOverlay_Identifiable.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation


extension pxr.TfToken: Identifiable {
    public var id: Self { self }
}
extension pxr.SdfPath: Identifiable {
    public var id: Self { self }
}
extension pxr.UsdAttribute: Identifiable {
    public var id: pxr.UsdAttribute { self }
}
extension pxr.UsdPrim: Identifiable {
    public var id: pxr.UsdPrim { self }
}
