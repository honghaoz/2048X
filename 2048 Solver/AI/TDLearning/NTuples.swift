// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

func == (lhs: NTuples, rhs: NTuples) -> Bool {
  return allItemsMatch(lhs.mainNTuples, container2: rhs.mainNTuples)
}

class NTuples: Equatable {
  var mainNTuples: [NTuple]
  // MARKING

  class func getNTuplesFromPath(path: String) -> NTuples? {
    var documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentDirectory = documentDirectories[0]
    let path = (documentDirectory as NSString).stringByAppendingPathComponent(path)

    if let archievedNTuples = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [NTuple] {
      print("Here we enter here")
      return NTuples(tuples: archievedNTuples)
    }
    return nil
  }

  func saveNTuplesForPath(path: String) -> Bool {
    var documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentDirectory = documentDirectories[0]
    let path = (documentDirectory as NSString).stringByAppendingPathComponent(path)

    if NSKeyedArchiver.archiveRootObject(mainNTuples, toFile: path) {
      return true
    }
    return false
  }

  init(tuples: [NTuple]) {
    self.mainNTuples = [NTuple]()
    for tuple in tuples {
      mainNTuples.append(tuple)
    }
  }

  convenience init(tuple: NTuples) {
    self.init(tuples: tuple.mainNTuples)
  }

  func getMain() -> [NTuple] {
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
  func weights() -> [Double] {
    var weights = [Double]()
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
  func getValue(input: [Double]) -> Double {
    let evaluator = DefaultNTupleEvaluator()
    return evaluator.evaluate(self, board: Game2048Board(input: input))
  }

  // update NTuples
  func update(input: [Double], expectedValue: Double, learningRate: Double) {
    let evaluator = DefaultNTupleEvaluator()
    let val = evaluator.evaluate(self, board: Game2048Board(input: input))
    let error = expectedValue - val
    let delta = error * learningRate
    let board = Game2048Board(input: input)
    for tuple in getMain() {
      tuple.update(board, delta: delta)
    }
  }
}
