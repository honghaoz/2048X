//
//  Util.swift
//  2048game
//
//  Created by yansong li on 2015-03-26.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation
import Darwin

public extension Float {
    public static func random(lower: Float = 0.0, upper: Float = 0.0) -> Float {
        let divided = Float(arc4random_uniform(100000))
        let dividor = Float(100000)
        let r = divided/dividor
        
        println("currentRandom is \((r*(upper - lower)) + lower)")
        return (r*(upper - lower)) + lower
    }
}


extension Int {
    func format(f:String) -> String {
        return NSString(format: "%\(f)d", self) as! String
    }
}




                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             