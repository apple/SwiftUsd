//
//  SwiftOverlay_ExpressibleByDictionaryLiteral.swift
//  
//
//  Created by Maddy Adams on 1/30/24.
//

import Foundation


extension pxr.VtDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (std.string, pxr.VtValue)...) {
        self.init()
        for (key, value) in elements {
            self[key] = value
        }
    }
}
