//
//  DefaultNTupleEvaluator.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-30.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

protocol NTupleBoardEvaluator { func evaluate (tuples:NTuples, board:Game2048Board) -> Double}

class DefaultNTupleEvaluator: NTupleBoardEvaluator {
    func evaluate(tuples: NTuples, board: Game2048Board) -> Double {
        var result:Double = 0
        for tuple in tuples.getMain() {
            result += tuple.valueFor(board)
        }
        return result
    }
}