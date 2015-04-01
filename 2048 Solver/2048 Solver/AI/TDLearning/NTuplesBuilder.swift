//
//  NTuplesBuilder.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class NTuplesBuilder {
    private var all:Array<Array<[Int]>> = Array<Array<[Int]>>()
    private var main:Array<[Int]> = Array<[Int]>()
    
    private var numValues:Int
    private var minWeight:Double
    private var maxWeight:Double
    //private var removeSubtuples: Bool
    
    init(numValues:Int, minWeight:Double, maxWeight:Double){
        self.maxWeight = maxWeight
        self.minWeight = minWeight
        self.numValues = numValues
        //self.removeSubtuples = removeSubtuples
    }
    
    func addTuple(locations:[Int]) {
        var sortedLocations = locations
        sortedLocations.sort{$0 < $1}
        
        for sortedTuple in CollectionUtils.flatten(all) {
            if allItemsMatch(sortedTuple, sortedLocations) {
                return
            }
        }
        
        var tmp = Array<[Int]>()
        tmp.append(locations)
        
        all.append(tmp)
        main.append(sortedLocations)
    }
    
    
    func buildNTuples() -> NTuples {
        var newMain = Array<[Int]>()
        newMain += main
        
        var mainTuples = createNTuplesFromLocations(newMain)
        return NTuples(tuples: mainTuples)
    }
    
    func createNTuplesFromLocations(newMain:Array<[Int]>) -> Array<NTuple>{
        var mainNTuples = Array<NTuple>()
        for location in newMain {
            mainNTuples.append(NTuple.newWithRandomWeights(numValues, locations: location, minWeight: minWeight, maxWeight: maxWeight))
        }
        return mainNTuples
    }
//    
//    func getMainWithoutDuplicates() -> Array<[Int]> {
//        var newMain = Array<[Int]>()
//        var n = main.count
//        for a in 0..<n {
//            var aContainsInB = false
//            for var b = 0; b < n && !aContainsInB; ++b {
//                if (a == b || main[a].count > main[b].count) {
//                    continue;
//                }
//                aContainsInB
//            }
//        }
//    }
}