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
    public static func random(lower: Float = 0.0, upper: Float = 1.0) -> Float {
        let divided = Float(arc4random_uniform(100000))
        let dividor = Float(100000)
        let r = divided/dividor
        
        //println("currentRandom is \((r*(upper - lower)) + lower)")
        return (r*(upper - lower)) + lower
    }
}


extension Int {
    func format(f:String) -> String {
        return NSString(format: "%\(f)d", self) as! String
    }
}

extension Double {
    func format(f:String) -> String {
        return NSString(format: "%\(f).2f", self) as! String
    }
}

protocol Container {
    typealias ItemType
    mutating func append(item:ItemType)
    var count:Int {get}
    subscript(i: Int) -> ItemType {get}
}

extension Array : Container {}

func allItemsMatch <C1: Container, C2:Container where C1.ItemType == C2.ItemType, C1.ItemType: Equatable>(container1:C1, container2:C2)->Bool {
    
    if container1.count != container2.count {
        return false
    }
    
    for i in 0..<container1.count {
        if container1[i] != container2[i] {
            return false
        }
    }
    return true
}



                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             