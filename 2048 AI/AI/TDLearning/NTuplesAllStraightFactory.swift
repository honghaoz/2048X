// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

class NTuplesGenericFactory {
  private var maxWeight: Double
  private var minWeight: Double
  private var boardSize: RectSize
  private var numValue: Int
  private var positionsList: [BoardPosList]

  init(positionsList: [BoardPosList], boardSize: RectSize, numValues: Int, minWeight: Double, maxWeight: Double) {
    self.positionsList = positionsList
    self.boardSize = boardSize
    self.numValue = numValues
    self.minWeight = minWeight
    self.maxWeight = maxWeight
  }

  convenience init(positions: BoardPosList, boardSize: RectSize, numValues: Int, minWeight: Double, maxWeight: Double) {
    var boardPoslist = [BoardPosList]()
    boardPoslist.append(positions)
    self.init(positionsList: boardPoslist, boardSize: boardSize, numValues: numValues, minWeight: minWeight, maxWeight: maxWeight)
  }

  func createRandomIndividual() -> NTuples {
    let builder = NTuplesBuilder(numValues: numValue, minWeight: minWeight, maxWeight: maxWeight)

    for position in positionsList {
      for r in 0..<boardSize.rows {
        for c in 0..<boardSize.columns {
          let nextPositions = position.getAligned().getShifted(r, shiftColumn: c)
          if nextPositions.fitOnBoard(boardSize) {
            builder.addTuple(nextPositions.toLocations(boardSize))
          }
        }
      }
    }
    return builder.buildNTuples()
  }
}

class NTuplesAllStraightFactory {
  private var genericFactory: NTuplesGenericFactory

  init(tupleLength: Int, boardSize: RectSize, numValues: Int, minWeight: Double, maxWeight: Double) {
    var positions: [[BoardPos]] = Array(count: 2, repeatedValue: Array(count: tupleLength, repeatedValue: BoardPos(row: 0, col: 0)))

    for i in 0..<tupleLength {
      positions[0][i] = BoardPos(row: i, col: 0)
      positions[1][i] = BoardPos(row: 0, col: i)
    }

    var list = [BoardPosList]()
    list.append(BoardPosList(positions: positions[0]))
    list.append(BoardPosList(positions: positions[1]))

    genericFactory = NTuplesGenericFactory(positionsList: list, boardSize: boardSize, numValues: numValues, minWeight: minWeight, maxWeight: maxWeight)
  }

  func createRandomIndividual() -> NTuples {
    return genericFactory.createRandomIndividual()
  }
}
