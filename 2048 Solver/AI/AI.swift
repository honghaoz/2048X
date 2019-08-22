// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

// MARK: Player type

enum Player: Int {
  case Min, Max
}

// MARK: AI

class AI {
  private let rawValToDirection: [Int: MoveCommand] = [
    0: MoveCommand(direction: .up),
    1: MoveCommand(direction: .down),
    2: MoveCommand(direction: .left),
    3: MoveCommand(direction: .right),
  ]

  private static var _ai: AI = AI()

  private init() {}

  class func CreateInstance() -> AI {
    return _ai
  }

  // MARK: Calculate next move using Mono Heuristic

  /// Calculate next optimal movement using Mono Heuristic
  func nextMoveUsingMonoHeuristic(_ curState: [[Int]], searchDepth: Int = 3) -> MoveCommand? {
    let gameboardAssistant = GameboardAssistant(cells: curState)
    let (direction, _) = monoHeuristicRecursion(gameboardAssistant, curDepth: searchDepth, searchDepth: searchDepth)
    return direction
  }

  /// Calculate optimal movement for method "monotonic heuristic" using recursion
  private func monoHeuristicRecursion(_ gameboardAssistant: GameboardAssistant, curDepth: Int, searchDepth: Int, ratio: Double = 0.9) -> (MoveCommand?, Double) {
    var bestScore = 0.0
    var bestMove: MoveDirection?

    // Try each direction
    for i in 0...3 {
      let dir = rawValToDirection[i]!.direction
      // Current direction is valid
      if gameboardAssistant.isMoveValid(dir) {
        let newAssistant = gameboardAssistant.copy()
        newAssistant.makeMove(dir, toAddNewTile: false)
        var (evaluateVal, initialTile) = evaluateUsingMonoHeuristic(newAssistant.cell)
        newAssistant.setCell(initialTile.0, y: initialTile.1, val: 2)
        if curDepth != 0 {
          let (nextM, nextEvaluateVal) = monoHeuristicRecursion(newAssistant, curDepth: curDepth - 1, searchDepth: searchDepth)
          if nextM != nil {
            evaluateVal = evaluateVal + nextEvaluateVal * pow(ratio, Double(searchDepth - curDepth + 1))
          }
        }
        if evaluateVal > bestScore {
          bestScore = evaluateVal
          bestMove = dir
        }
      }
    }

    if bestMove == nil {
      return (nil, bestScore)
    }
    return (MoveCommand(direction: bestMove!), bestScore)
  }

  /// Evaluate the current board using "monotonic heuristic", the default progress ratio is 0.25.
  /// Return the evaluation result of current state and the (x, y) localtion of tile which should
  /// be assigned with 2.
  private func evaluateUsingMonoHeuristic(_ gameboard: [[Int]], ratio: Double = 0.25) -> (Double, (Int, Int)) {
    let yRange = (0...gameboard.count - 1).map { $0 }
    let yRangeReverse = Array((0...gameboard.count - 1).map { $0 }.reversed())
    let xRange = yRange
    let xRangeReverse = yRangeReverse
    let size = gameboard.count
    // Array that contains evaluation results and initial tiles
    var results: [Double] = [Double]()
    var initialTiles: [(Int, Int)] = [(Int, Int)]()
    // Row first, col first
    var tempResult = 0.0
    var initialTile: (Int, Int) = (-1, -1)
    var reverse = false
    var weight = 1.0
    for j in yRange {
      let jCopy = j
      for i in xRange {
        let iCopy = !reverse ? i : size - i - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x, y) = (initialTile.0, initialTile.1)
    initialTiles.append((x, y))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for j in yRange {
      let jCopy = j
      for i in xRangeReverse {
        let iCopy = !reverse ? i : size - i - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x2, y2) = (initialTile.0, initialTile.1)
    initialTiles.append((x2, y2))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for i in xRange {
      let iCopy = i
      for j in yRange {
        let jCopy = !reverse ? j : size - j - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x3, y3) = (initialTile.0, initialTile.1)
    initialTiles.append((x3, y3))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for i in xRange {
      let iCopy = i
      for j in yRangeReverse {
        let jCopy = !reverse ? j : size - j - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x4, y4) = (initialTile.0, initialTile.1)
    initialTiles.append((x4, y4))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for j in yRangeReverse {
      let jCopy = j
      for i in xRangeReverse {
        let iCopy = !reverse ? i : size - i - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x5, y5) = (initialTile.0, initialTile.1)
    initialTiles.append((x5, y5))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for j in yRangeReverse {
      let jCopy = j
      for i in xRange {
        let iCopy = !reverse ? i : size - i - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x6, y6) = (initialTile.0, initialTile.1)
    initialTiles.append((x6, y6))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for i in xRangeReverse {
      let iCopy = i
      for j in yRange {
        let jCopy = !reverse ? j : size - j - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x7, y7) = (initialTile.0, initialTile.1)
    initialTiles.append((x7, y7))

    tempResult = 0.0
    initialTile = (-1, -1)
    reverse = false
    weight = 1.0
    for i in xRangeReverse {
      let iCopy = i
      for j in yRangeReverse {
        let jCopy = !reverse ? j : size - j - 1
        let curVal = gameboard[jCopy][iCopy]
        if curVal == 0, initialTile == (-1, -1) {
          initialTile = (iCopy, jCopy)
        }
        tempResult += Double(curVal) * weight
        weight *= ratio
      }
      reverse = !reverse
    }
    results.append(tempResult)
    let (x8, y8) = (initialTile.0, initialTile.1)
    initialTiles.append((x8, y8))

    let maxIndex = results.findMaxIndex()
    return (results[maxIndex], initialTiles[maxIndex])
  }

  // MARK: Calculate next move using Combined Heuristic

  /// Calculate next optimal movement using Combined Heuristic
  func nextMoveUsingCombinedStrategy(_ curState: [[Int]], searchDepth: Int = 3) -> MoveCommand? {
    let gameboardAssistant = GameboardAssistant(cells: curState)
    let (direction, _) = combinedHeuristicRecursion(gameboardAssistant, curDepth: searchDepth, searchDepth: searchDepth)
    return direction
  }

  /// Calculate optimal movement for method "combined heuristic" using recursion
  private func combinedHeuristicRecursion(_ gameboardAssistant: GameboardAssistant, curDepth: Int, searchDepth: Int) -> (MoveCommand?, Double) {
    var bestScore = 0.0
    var bestMove: MoveDirection?

    // Try each direction
    for i in 0...3 {
      let dir = rawValToDirection[i]!.direction
      // Current direction is valid
      if gameboardAssistant.isMoveValid(dir) {
        let newAssistant = gameboardAssistant.copy()
        newAssistant.makeMove(dir)
        var evaluateVal = evaluateUsingCombinedHeuristic(newAssistant.cell)
        if curDepth != 0 {
          let (nextM, nextEvaluateVal) = combinedHeuristicRecursion(newAssistant, curDepth: curDepth - 1, searchDepth: searchDepth)
          if nextM != nil {
            evaluateVal += nextEvaluateVal
          }
        }
        if evaluateVal > bestScore {
          bestScore = evaluateVal
          bestMove = dir
        }
      }
    }

    if bestMove == nil {
      return (nil, bestScore)
    }
    return (MoveCommand(direction: bestMove!), bestScore)
  }

  /// Evaluate the current board using combined heuristic.
  /// Return the evaluation result of current state.
  private func evaluateUsingCombinedHeuristic(_ gameboard: [[Int]]) -> Double {
    // The size of the board
    let size = gameboard[0].count
    let squareSize = Double(size * size)

    // Constants & Weight
    let LARGE_EDGE_TILE_WEIGHT = 0.5
    let EMPTY_CELL_WEIGHT = 0.5

    var numOfEmptyCells = 0
    var edgeTiles = [Int]()

    for row in 0..<size {
      for col in 0..<size {
        // Count empty cell
        numOfEmptyCells += gameboard[row][col] == 0 ? 1 : 0
        // Determine if this cell is located on the edge
        if row == 0 || row == size - 1 || col == 0 || col == size - 1 {
          if gameboard[row][col] != 0 {
            edgeTiles.append(gameboard[row][col])
          }
        }
      }
    }

    return EMPTY_CELL_WEIGHT * Double(numOfEmptyCells) / squareSize +
      LARGE_EDGE_TILE_WEIGHT * edgeTiles.map {
        element -> Double in Double(element)
      }.sum() / 2048.0
  }

  // MARK: Calculate next move using Minimax Algorigthm with Alpha-beta pruning

  let directionToOffset: [MoveDirection: (rowOffset: Int, colOffset: Int)] = [.up: (1, 0), .down: (-1, 0), .left: (0, -1), .right: (0, 1)]

  /// Calculate optimal movement for method "minimax alpha-beta pruning"
  func nextMoveUsingAlphaBetaPruning(_ curState: [[Int]], depth: Int = 10) -> MoveCommand? {
    let gameboardAssistant = GameboardAssistant(cells: curState)

    var bestDirection: MoveDirection?

    for depth in 0...3 {
      let tempBestResult = minimaxAlphaBetaPruning(gameboardAssistant, curDepth: depth, player: .Max, alpha: -10000, beta: 10000, lastPositions: 0, lastCutoffs: 0)
      if tempBestResult.bestDirection == nil {
        break
      } else {
        bestDirection = tempBestResult.bestDirection
      }
    }

    return bestDirection == nil ? nil : MoveCommand(direction: bestDirection!)
  }

  /// Calculate optimal movement for method "minimax alpha-beta pruning" using recursion
  private func minimaxAlphaBetaPruning(_ gameboardAssistant: GameboardAssistant, curDepth: Int, player: Player,
                                       alpha: Double, beta: Double, lastPositions: Int, lastCutoffs: Int) -> (bestDirection: MoveDirection?, score: Double, positions: Int, cutoffs: Int) {
    // Size of the board
    let size = gameboardAssistant.cell[0].count

    var lastPositions = lastPositions
    var lastCutoffs = lastCutoffs

    var bestScore = 0.0
    var bestMove: MoveDirection?

    var tempResult: (bestDirection: MoveDirection?, score: Double, positions: Int, cutoffs: Int) = (nil, -1.0, -1, -1)

    // If current player is Max
    if player == .Max {
      bestScore = alpha
      for i in 0..<size {
        let nextDirection = rawValToDirection[i]!.direction
        if gameboardAssistant.isMoveValid(nextDirection) {
          let newAssistant = gameboardAssistant.copy()
          newAssistant.makeMove(nextDirection, toAddNewTile: false)
          lastPositions += 1
          if curDepth == 0 {
            tempResult = (nextDirection, evaluateUsingSmoothnessAndMonotonicity(newAssistant), lastPositions, lastCutoffs)
          } else {
            tempResult = minimaxAlphaBetaPruning(newAssistant, curDepth: curDepth - 1, player: .Min, alpha: alpha, beta: beta, lastPositions: lastPositions, lastCutoffs: lastCutoffs)
            // Penalize score achieved with higher depth
            if tempResult.score > 9900.0 {
              tempResult.score -= 1
            }
            // Update parameters
            lastPositions = tempResult.positions
            lastCutoffs = tempResult.cutoffs
          }

          if tempResult.score > bestScore {
            bestScore = tempResult.score
            bestMove = nextDirection
          }
          if bestScore > beta {
            lastCutoffs += 1
            return (bestMove, beta, lastPositions, lastCutoffs)
          }
        }
      }
    }
    // If current player is Min
    else {
      bestScore = beta

      let emptyCells = gameboardAssistant.getAllEmptyCells()

      // Candidate cells which will achieve max evaluation score
      var candidates: [(pos: (row: Int, col: Int), tileVal: Int)] = []
      // Evaluation score achieved by 2 and 4
      var newValToScore: [Int: [(pos: (row: Int, col: Int), val: Double)]] = [2: [], 4: []]

      // Try every empty cells, assigning both 2 and 4 to each one of them
      // Get the position(s) to which assigning 2 or 4 get maximum evaluation
      for key in newValToScore.keys {
        for emptyPos in emptyCells {
          gameboardAssistant.setCell(emptyPos.x, y: emptyPos.y, val: key)
          // Once assign 2 or 4 to an emtpy cell, evaluate the current board
          newValToScore[key]!.append((pos: (row: emptyPos.x, col: emptyPos.y), val: -smoothness(gameboardAssistant.cell) + Double(numberOfIsolated(gameboardAssistant.cell))))
          gameboardAssistant.setCell(emptyPos.x, y: emptyPos.y, val: 0)
        }
      }

      let maxScore = max(newValToScore[2]!.maxVal(), newValToScore[4]!.maxVal())

      for key in newValToScore.keys {
        for value in newValToScore[key]! {
          if value.val == maxScore {
            candidates.append((pos: value.pos, tileVal: key))
          }
        }
      }

      for value in candidates {
        let emptyCellPos = value.pos

        let newAssistant = gameboardAssistant.copy()
        newAssistant.setCell(emptyCellPos.row, y: emptyCellPos.col, val: value.tileVal)

        lastPositions += 1

        tempResult = minimaxAlphaBetaPruning(newAssistant, curDepth: curDepth, player: .Max, alpha: alpha, beta: bestScore, lastPositions: lastPositions, lastCutoffs: lastCutoffs)
        lastPositions = tempResult.positions
        lastCutoffs = tempResult.cutoffs

        if tempResult.score < bestScore {
          bestScore = tempResult.score
        }
        if bestScore < alpha {
          lastCutoffs += 1
          return (nil, alpha, lastPositions, lastCutoffs)
        }
      }
    }

    return (bestMove, bestScore, lastPositions, lastCutoffs)
  }

  /// Evaluate the current board using the combination of monotonicity and smoothness.
  /// Return the evaluation result of current state.
  private func evaluateUsingSmoothnessAndMonotonicity(_ gameboardAssistant: GameboardAssistant) -> Double {
    let EMPTY_CELL_WEIGHT = 2.7
    let MONOTONICITY_WEIGHT = 1.0
    let SMOOTHNESS_WEIGHT = 0.1
    let MAXVAL_WEIGHT = 1.0

    let cell = gameboardAssistant.cell
    return SMOOTHNESS_WEIGHT * smoothness(cell) +
      MONOTONICITY_WEIGHT * monotonicity(cell) +
      EMPTY_CELL_WEIGHT * Double(gameboardAssistant.getAllEmptyCells().count) +
      MAXVAL_WEIGHT * Double(gameboardAssistant.max)
  }

  /// Calculate the number of isolated cells
  private func numberOfIsolated(_ gameboard: [[Int]]) -> Int {
    // Size fo the board
    let size = gameboard[0].count
    var marked = [[Bool]](repeating: [Bool](repeating: true, count: size), count: size)

    var numOfIsolated = 0

    for row in 0..<size {
      for col in 0..<size {
        marked[row][col] = gameboard[row][col] == 0
      }
    }

    for row in 0..<size {
      for col in 0..<size {
        if gameboard[row][col] != 0, !marked[row][col] {
          numOfIsolated += 1
          deMark(row, col: col, val: gameboard[row][col], gameboard: gameboard, marked: &marked)
        }
      }
    }

    return numOfIsolated
  }

  /// Calculate the smoothness of the gameboard
  private func smoothness(_ gameboard: [[Int]]) -> Double {
    // Size of the board
    let size = gameboard[0].count

    var smoothness = 0.0
    for row in 0..<size {
      for col in 0..<size {
        if gameboard[row][col] != 0 {
          let curVal = log2(Double(gameboard[row][col]))
          // Only check successive cells below or to the right of the current cell
          for nextDirection in [1, 3] {
            var targetVal = Double(getNextAdjCellVal(gameboard, curRow: row, curCol: col, offset: directionToOffset[rawValToDirection[nextDirection]!.direction]!))
            if targetVal != 0 {
              targetVal = log2(Double(targetVal))
              smoothness -= abs(curVal - targetVal)
            }
          }
        }
      }
    }

    return smoothness
  }

  /// Calculate the monotonicity of the board
  private func monotonicity(_ gameboard: [[Int]]) -> Double {
    // Size of the board
    let size = gameboard[0].count
    // The monotonicity in all four directions, which are: .up, .down, .left, .right
    var monoInFourDirection = [Double](repeating: 0.0, count: 4)

    // Up and Down direction
    for col in 0..<size {
      var curRow = 0
      var nextRow = 1
      while nextRow < size {
        while nextRow < size, gameboard[nextRow][col] == 0 {
          nextRow += 1
        }
        if nextRow == size {
          nextRow -= 1
        }
        let curVal = gameboard[curRow][col] != 0 ? log2(Double(gameboard[curRow][col])) : 0.0
        let nextVal = gameboard[nextRow][col] != 0 ? log2(Double(gameboard[nextRow][col])) : 0.0
        if curVal > nextVal {
          monoInFourDirection[0] += nextVal - curVal
        } else if curVal < nextVal {
          monoInFourDirection[1] += curVal - nextVal
        }
        curRow = nextRow
        nextRow += 1
      }
    }

    // Left and Right direction
    for row in 0..<size {
      var curCol = 0
      var nextCol = 1
      while nextCol < size {
        while nextCol < size, gameboard[row][nextCol] != 0 {
          nextCol += 1
        }
        if nextCol == size {
          nextCol -= 1
        }
        let curVal = gameboard[row][curCol] != 0 ? log2(Double(gameboard[row][curCol])) : 0.0
        let nextVal = gameboard[row][curCol] != 0 ? log2(Double(gameboard[row][curCol])) : 0.0
        if curVal > nextVal {
          monoInFourDirection[2] += nextVal - curVal
        } else if curVal < nextVal {
          monoInFourDirection[3] += curVal - nextVal
        }
        curCol = nextCol
        nextCol += 1
      }
    }

    return max(monoInFourDirection[0], monoInFourDirection[1]) + max(monoInFourDirection[2], monoInFourDirection[3])
  }

  /// Restore cells which have been marked as isolated
  private func deMark(_ row: Int, col: Int, val: Int, gameboard: [[Int]], marked: inout [[Bool]]) {
    // Size of the board
    let size = gameboard[0].count

    if row > -1, row < size, col > -1, col < size,
      gameboard[row][col] == val, !marked[row][col] {
      marked[row][col] = true

      for i in 0..<size {
        let directionOffset = directionToOffset[rawValToDirection[i]!.direction]!
        deMark(row + directionOffset.rowOffset, col: col + directionOffset.colOffset, val: val, gameboard: gameboard, marked: &marked)
      }
    }
  }

  /// For a certain cell which is not empty, find the next non-empty cell (skip any empty cell(s)), return
  /// its value as, if no such cell exists, return 0
  private func getNextAdjCellVal(_ gameboard: [[Int]], curRow: Int, curCol: Int, offset: (rowOffset: Int, colOffset: Int)) -> Int {
    // Size of the board
    let size = gameboard[0].count
    var prevPos = (row: curRow, col: curCol)
    var nextPos = (row: curRow + offset.rowOffset, col: curCol + offset.colOffset)
    while nextPos.row > -1 && nextPos.row < size && nextPos.col > -1 && nextPos.col < size &&
      gameboard[nextPos.row][nextPos.col] == 0 {
      prevPos = nextPos
      nextPos = (prevPos.row + offset.rowOffset, prevPos.col + offset.colOffset)
    }

    return nextPos.row == size || nextPos.row == -1 || nextPos.col == size || nextPos.col == -1 ? 0 : gameboard[nextPos.row][nextPos.col]
  }
}

// MARK: operator overload for tuples

func == (t1: (Int, Int), t2: (Int, Int)) -> Bool {
  return t1.0 == t2.0 && t1.1 == t2.1
}

// MARK: extension

/// Used for [Double]
extension Array {
  func maxVal() -> Double {
    var maxEle = Double(Int.min)
    for i in 0..<count {
      if let curVal = (self[i] as? (pos: (row: Int, col: Int), val: Double))?.val {
        if curVal > maxEle {
          maxEle = curVal
        }
      }
    }

    return maxEle
  }

  func findMaxIndex() -> Int {
    var maxEle = Double(Int.min)
    var maxIndex = -1
    for i in 0..<count {
      if let curEle = self[i] as? Double {
        if curEle > maxEle {
          maxEle = curEle
          maxIndex = i
        }
      }
    }

    return maxIndex
  }

  func sum() -> Double {
    var total = 0.0
    for i in 0..<count {
      total += self[i] as! Double
    }

    return total
  }
}
