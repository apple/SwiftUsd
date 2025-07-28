//
//  SwiftOverlay_ExpressibleByArrayLiteral.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation



extension pxr.SdfPathSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral: pxr.SdfPath...) {
        self.init()
        for x in arrayLiteral {
            self.insert(x)
        }
    }
}
extension Overlay.SdfLayerHandle_Set: ExpressibleByArrayLiteral {
    public init(arrayLiteral: pxr.SdfLayerHandle...) {
        self.init()
        for x in arrayLiteral {
            self.insert(x)
        }
    }
}
