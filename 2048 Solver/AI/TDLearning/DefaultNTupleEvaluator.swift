// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

protocol NTupleBoardEvaluator { func evaluate(tuples: NTuples, board: Game2048Board) -> Double }

class DefaultNTupleEvaluator: NTupleBoardEvaluator {
  func evaluate(tuples: NTuples, board: Game2048Board) -> Double {
    var result: Double = 0
    for tuple in tuples.getMain() {
      result += tuple.valueFor(board)
    }
    return result
  }
}
