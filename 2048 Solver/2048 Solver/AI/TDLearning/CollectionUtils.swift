//
//  CollectionUtils.swift
//  2048 Solver
//
//  Created by yansong li on 2015-04-01.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class CollectionUtils {
    class func flatten(arr:Array<Array<[Int]>>) -> Array<[Int]> {
        var res = Array<[Int]>()
        for list in arr {
            res += list
        }
        return res
    }
    
    
}