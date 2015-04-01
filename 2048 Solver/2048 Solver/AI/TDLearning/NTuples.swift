//
//  NTuples.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-30.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

func == (lhs:NTuples, rhs:NTuples) -> Bool {
    return allItemsMatch(lhs.mainNTuples, rhs.mainNTuples)
}

class NTuples: Equatable{
    var mainNTuples:Array<NTuple>
    // MARKING
    
    
    
    class func getNTuplesFromPath(path:String) -> NTuples? {
        var documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentDirectory = documentDirectories[0] as! String
        var path = documentDirectory.stringByAppendingPathComponent(path)
        
        if let archievedNTuples = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? Array<NTuple> {
            println("Here we enter here")
            return NTuples(tuples: archievedNTuples)
        }
        return nil
    }
    
    func saveNTuplesForPath(path:String) -> Bool {
        var documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentDirectory = documentDirectories[0] as! String
        var path = documentDirectory.stringByAppendingPathComponent(path)
        
        if NSKeyedArchiver.archiveRootObject(self.mainNTuples, toFile: path) {
            return true
        }
        return false
    }
    
    
    init(tuples:Array<NTuple>) {
        mainNTuples = Array<NTuple>()
        for tuple in tuples{
            mainNTuples.append(tuple)
        }
    }
    
    convenience init(tuple:NTuples) {
        self.init(tuples: tuple.mainNTuples)
    }
    
    func getMain() -> Array<NTuple> {
        return mainNTuples
    }
    
    func add(other: NTuples) -> NTuples {
        var tmp = getMain()
        tmp += other.getMain()
        return NTuples(tuples: tmp)
    }
    
    // get NTuple at some position
    func getTuple(idx: Int) -> NTuple {
        return mainNTuples[idx]
    }
    
    // get all weights of this NTuples
    func weights() -> Array<Double> {
        var weights = Array<Double>()
        for tuple in mainNTuples {
            weights += tuple.getWeights()
        }
        return weights
    }
    
    // the total weights number
    func totalWeights() -> Int {
        return weights().count
    }
    
    // the size of this NTuples 
    func size() -> Int {
        return mainNTuples.count
    }
    
    
    // get the value for a board
    func getValue(input:[Double]) -> Double {
        var evaluator = DefaultNTupleEvaluator()
        return evaluator.evaluate(self, board: Game2048Board(input: input))
    }
    
    // update NTuples
    func update(input:[Double], expectedValue:Double, learningRate:Double) {
        var evaluator = DefaultNTupleEvaluator()
        var val = evaluator.evaluate(self, board: Game2048Board(input: input))
        var error = expectedValue - val
        var delta = error * learningRate
        var board = Game2048Board(input: input)
        for tuple in getMain() {
            tuple.update(board, delta: delta)
        }
    }
    
    
}