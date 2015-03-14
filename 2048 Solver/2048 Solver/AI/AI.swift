//
//  AI.swift
//  SwiftPractice
//
//  Created by xiaoyong on 15/3/9.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import Foundation

/// MARK: operator overload for tuples
func == (t1: (Int, Int), t2: (Int, Int)) -> Bool {
    return t1.0 == t2.0 && t1.1 == t2.1
}

/// MARK: AI
class AI {
    private let rawValToDirection: [Int : MoveCommand] = [0 : MoveCommand(direction: .Up), 1 : MoveCommand(direction: .Down), 2 : MoveCommand(direction: .Left), 3 : MoveCommand(direction: .Right)]
    
    private static var _ai: AI = AI()
    
    init() {}
    
    class func CreateInstance() -> AI {
        return _ai
    }
    
    /// Calculate next optimal movement using Progess Recursion Heuristic
    func nextMoveUsingMonoHeuristic(curState: [[Int]], searchDepth: Int = 3) -> MoveCommand? {
        var gameBoardAssistant = GameBoardAssistant(cells: curState)
        let (direction, score) = monoHeuristicRecursion(gameBoardAssistant, curDepth: searchDepth, searchDepth: searchDepth)
        return direction
    }
    
    func nextMoveUsingCombinedStrategy(curState: [[Int]], searchDepth: Int = 3) -> MoveCommand? {
        var gameBoardAssistant = GameBoardAssistant(cells: curState)
        let (direction, score) = combinedHeuristicRecursion(gameBoardAssistant, curDepth: searchDepth, searchDepth: searchDepth)
        return direction
    }
    
    /// Calculate optimal movement for method "monotonic heuristic" using recursion
    private func monoHeuristicRecursion(gameBoardAssistant: GameBoardAssistant, curDepth: Int, searchDepth: Int, ratio: Double = 0.9) -> (MoveCommand?, Double) {
        var bestScore = 0.0
        var bestMove: MoveDirection? = nil
        
        // Try each direction
        for i in 0...3 {
            let dir = rawValToDirection[i]!.direction
            // Current direction is valid
            if gameBoardAssistant.isMoveValid(dir) {
                var newAssistant = gameBoardAssistant.copy()
                newAssistant.makeMove(dir, toAddNewTile: false)
                var (evaluateVal, initialTile) = evaluateUsingMonoHeuristic(newAssistant.cell)
                newAssistant.setCell(initialTile.0, y: initialTile.1, val: 2)
                if curDepth != 0 {
                    let (nextM, nextEvaluateVal) = monoHeuristicRecursion(newAssistant, curDepth: curDepth - 1, searchDepth: searchDepth)
                    if (nextM != nil) {
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
    
    /// Calculate optimal movement for method "combined heuristic" using recursion
    private func combinedHeuristicRecursion(gameBoardAssistant: GameBoardAssistant, curDepth: Int, searchDepth: Int) -> (MoveCommand?, Double) {
        var bestScore = 0.0
        var bestMove: MoveDirection? = nil
        
        // Try each direction
        for i in 0...3 {
            let dir = rawValToDirection[i]!.direction
            // Current direction is valid
            if gameBoardAssistant.isMoveValid(dir) {
                var newAssistant = gameBoardAssistant.copy()
                newAssistant.makeMove(dir)
                var evaluateVal = evaluateUsingCombinedHeuristic(newAssistant.cell)
                if curDepth != 0 {
                    let (nextM, nextEvaluateVal) = combinedHeuristicRecursion(newAssistant, curDepth: curDepth - 1, searchDepth: searchDepth)
                    if (nextM != nil) {
                        evaluateVal += nextEvaluateVal                    }
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
    /// Return the evaluation result of current state and the (x, y) localtion of tile which should
    /// be assigned with 2.
    private func evaluateUsingCombinedHeuristic(gameBoard: [[Int]]) -> Double {
        // Weight value for different heuristic strategy
        let weightForOpenSquares = 0.2
        let weightForLargeTileOnEdge = 0.4
        let weightForNumOfAdjMerge = 0.4
        // The size of the board
        let size = gameBoard[0].count
        
        var score: Double = 0.0
        var numOfEmptyCells = 0
        var numOfAdjMerge = 0
        var edgeTiles = [Int]()
        
        for row in 0..<size {
            for col in 0..<size {
                // Count empty cell
                numOfEmptyCells += gameBoard[row][col] == 0 ? 1 : 0
                // Determine if this cell is located on the edge
                if row == 0 || row == size - 1 || col == 0 || col == size - 1 {
                    edgeTiles.append(gameBoard[row][col])
                }
                numOfAdjMerge += (row + 1 < size && gameBoard[row][col] == gameBoard[row + 1][col]) ? 1 : 0
                numOfAdjMerge += (col + 1 < size && gameBoard[row][col] == gameBoard[row][col + 1]) ? 1 : 0
            }
        }
        
        let squareSize = Double(size * size)
        score += (weightForOpenSquares * Double(numOfEmptyCells) / squareSize + weightForNumOfAdjMerge * Double(numOfAdjMerge) / squareSize + weightForLargeTileOnEdge * edgeTiles.map({ (element) -> Double in
            Double(element) / 2048.0}).sum())
    
        return score
    }
    
    /// Evaluate the current board using "monotonic heuristic", the default progress ratio is 0.25.
    /// Return the evaluation result of current state and the (x, y) localtion of tile which should
    /// be assigned with 2.
    private func evaluateUsingMonoHeuristic(gameBoard: [[Int]], ratio: Double = 0.25) -> (Double, (Int, Int)) {
        let yRange = (0...gameBoard.count - 1).map{$0}
        let yRangeReverse = (0...gameBoard.count - 1).map{$0}.reverse()
        let xRange = yRange
        let xRangeReverse = yRangeReverse
        let size = gameBoard.count
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
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x, y) = (initialTile.0, initialTile.1)
        initialTiles.append(x, y)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for j in yRange {
            let jCopy = j
            for i in xRangeReverse {
                let iCopy = !reverse ? i : size - i - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x2, y2) = (initialTile.0, initialTile.1)
        initialTiles.append(x2, y2)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for i in xRange {
            let iCopy = i
            for j in yRange {
                let jCopy = !reverse ? j : size - j - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x3, y3) = (initialTile.0, initialTile.1)
        initialTiles.append(x3, y3)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for i in xRange {
            let iCopy = i
            for j in yRangeReverse {
                let jCopy = !reverse ? j : size - j - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x4, y4) = (initialTile.0, initialTile.1)
        initialTiles.append(x4, y4)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for j in yRangeReverse {
            let jCopy = j
            for i in xRangeReverse {
                let iCopy = !reverse ? i : size - i - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x5, y5) = (initialTile.0, initialTile.1)
        initialTiles.append(x5, y5)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for j in yRangeReverse {
            let jCopy = j
            for i in xRange {
                let iCopy = !reverse ? i : size - i - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x6, y6) = (initialTile.0, initialTile.1)
        initialTiles.append(x6, y6)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for i in xRangeReverse {
            let iCopy = i
            for j in yRange {
                let jCopy = !reverse ? j : size - j - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x7, y7) = (initialTile.0, initialTile.1)
        initialTiles.append(x7, y7)
        
        tempResult = 0.0
        initialTile = (-1, -1)
        reverse = false
        weight = 1.0
        for i in xRangeReverse {
            let iCopy = i
            for j in yRangeReverse {
                let jCopy = !reverse ? j : size - j - 1
                let curVal = gameBoard[jCopy][iCopy]
                if curVal == 0 && initialTile == (-1, -1) {
                    initialTile = (iCopy, jCopy)
                }
                tempResult += Double(curVal) * weight
                weight *= ratio
            }
            reverse = !reverse
        }
        results.append(tempResult)
        let (x8, y8) = (initialTile.0, initialTile.1)
        initialTiles.append(x8, y8)
        
        let maxIndex = results.findMaxIndex()
        return (results[maxIndex], initialTiles[maxIndex])
    }
}

// MARK: extension
extension Array {
    func findMaxIndex() -> Int {
        var maxEle = -1.0
        var maxIndex = -1
        for i in 0..<self.count {
            if self[i] as! Double > maxEle {
                maxEle = self[i] as! Double
                maxIndex = i
            }
        }
        
        return maxIndex
    }
    
    func sum() -> Double {
        var total = 0.0
        for i in 0..<self.count {
            total += self[i] as! Double
        }
        
        return total
    }
}
