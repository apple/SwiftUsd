//
//  SwiftOverlay_ExpressibleByFloatLiteral.swift
//
//
//  Created by Maddy Aadams on 2/9/24.
//

import Foundation


extension pxr.GfHalf: ExpressibleByIntegerLiteral {
    public init(integerLiteral: Int) {
        self.init(Float(integerLiteral))
    }
}
