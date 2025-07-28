//
//  SwiftOverlay_ExpressibleByFloatLiteral.swift
//
//
//  Created by Maddy Aadams on 2/9/24.
//

import Foundation


extension pxr.GfHalf: ExpressibleByFloatLiteral {
    public init(floatLiteral: Float) {
        self.init(floatLiteral)
    }
}
