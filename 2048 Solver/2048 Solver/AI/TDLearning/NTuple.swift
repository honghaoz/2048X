//
//  NTuple.swift
//  2048game
//
//  Created by yansong li on 2015-03-26.
//  Copyright (c) 2015 yansong li. All rights reserved.
//
//
//import Foundation
//
//
//infix operator ** {associativity left precedence 160}
//
//func ** (left:Double, right:Double) -> Double {
//    return pow(left, right)
//}
//
//func == (lhs:NTuple, rhs:NTuple) {
//    
//}
//
//class NTuple:Equatable {
//    var numValues:Int
//    var locations:[Int]
//    var LUT:[Double] // LUT Table
//    
//    init(numValues:Int, locations:[Int], weights:[Double]) {
//        self.numValues = numValues
//        self.locations = locations
//        self.LUT = weights
//    }
//    
//    convenience init(numValues:Int, locations:[Int], minWeight:Double, maxWeight:Double) {
//        var weights = Array(count: NTuple.computeNumWeights(numValues, numFields: locations.count), repeatedValue: 0.0)
//        
//        for i in 0..<weights.count {
//            weights[i] = Double(Float.random(lower: Float(minWeight), upper: Float(maxWeight)))
//        }
//        self.init(numValues: numValues, locations: locations, weights: weights)
//    }
//    
//    convenience init(template:NTuple) {
//        self.init(numValues:template.numValues, locations:template.locations,weights:template.LUT )
//    }
//    
//    // Value for a board
//    func valueFor(board:Game2048Board) -> Double {
//        return LUT[address(board)]
//    }
//    
//    func address(board:Game2048Board) -> Int {
//        var address = 0
//        for loc in locations {
//            address *= numValues
//            address += board.getValue(loc)
//        }
//        return address
//    }
//    
//    func getWeights() -> [Double] {
//        return LUT
//    }
//    
//    func getNumWeights() -> Int {
//        return LUT.count
//    }
//    
//    func getLocations() -> [Int] {
//        return locations
//    }
//    
//    func getSize() -> Int {
//        return locations.count
//    }
//    
//    func getNumValues() -> Int {
//        return numValues
//    }
//    
//    class func computeNumWeights(numValues:Int, numFields:Int) -> Int{
//        return Int(Double(numValues)**Double(numFields) + 0.5)
//    }
//}