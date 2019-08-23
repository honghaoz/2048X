// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

class Game2048ExperimentTDL {
  func RunMe() {
    print("Run Me")

    let tdlGame2048 = TDLGame2048()

    let path = "NTuples.archieves"
    var vFunction: NTuples

    if let archived = tdlGame2048.currentNTuples {
      vFunction = archived
    } else {
      let lines = NTuplesAllStraightFactory(tupleLength: 4, boardSize: State2048.METRIC.BOARD_SIZE, numValues: 15, minWeight: 0, maxWeight: 0).createRandomIndividual()

      let squares = NTuplesAllRectanglesFactory(rectSize: RectSize(size: 2), boardSize: State2048.METRIC.BOARD_SIZE, numValue: 15, minWeight: 0, maxWeight: 0).createRandomIndividual()

      // Question1, vFunction is passed by value not reference
      vFunction = lines.add(squares)
    }

    for i in 1..<100000 {
      print("Start a NEW ONE ---------\(i)")
      tdlGame2048.TDAfterstateLearn(vFunction, explorationRate: 0.001, learningRate: 0.01)
      print("Finish this ONE ---------\(i)")
      if i % 20 == 0 {
        vFunction.saveNTuplesForPath(path)
        evaluatePerformance(tdlGame2048, vFunctions: vFunction, numEpisodes: 10, e: i)
      }
    }
  }

  func evaluatePerformance(game: TDLGame2048, vFunctions: NTuples, numEpisodes: Int, e: Int) {
    var performance = 0
    var ratio = 0
    var maxTile = 0

    for _ in 0..<numEpisodes {
      let res = game.playByAfterstates(vFunctions)

      performance += res.score()

      if res.maxTile() >= 2048 {
        ratio += 1
      }
      if res.maxTile() > maxTile {
        maxTile = res.maxTile()
      }
      print("This time we got \(res.maxTile())")
    }
    let eF = e.format("5")
    let sF = (Double(performance) / Double(numEpisodes)).format("6")
    let rF = (Double(ratio) / Double(numEpisodes)).format("6")
    print("After \(eF) games: avg score = \(sF), avg ratio = \(rF), maxtile = \(maxTile)")
  }
}
