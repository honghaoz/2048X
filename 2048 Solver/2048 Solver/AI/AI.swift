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
    func nextMoveUsingProgressRecursion(curState: [[Int]], searchDepth: Int = 3) -> MoveCommand? {
        var gameBoardAssistant = GameBoardAssistant(cells: curState)
        let (direction, score) = nextMoveWithRecur(gameBoardAssistant, curDepth: searchDepth, searchDepth: searchDepth)
        return direction
    }
    
    /// Calculate optimal movement with recursion
    private func nextMoveWithRecur(gameBoardAssistant: GameBoardAssistant, curDepth: Int, searchDepth: Int, ratio: Double = 0.9) -> (MoveCommand?, Double) {
        var bestScore = 0.0
        var bestMove: MoveDirection? = nil
        
        // Try each direction
        for i in 0...3 {
            let dir = rawValToDirection[i]!.direction
            // Current direction is valid
            if gameBoardAssistant.isMoveValid(dir) {
                var newAssistant = gameBoardAssistant.copy()
                newAssistant.makeMove(dir, toAddNewTile: false)
                var (evaluateVal, initialTile) = evaluateCurBoard(newAssistant.cell)
                newAssistant.setCell(initialTile.0, y: initialTile.1, val: 2)
                if curDepth != 0 {
                    let (nextM, nextEvaluateVal) = nextMoveWithRecur(newAssistant, curDepth: curDepth - 1, searchDepth: searchDepth)
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
    
    /// Evaluate the current board for choosing further steps, the default progress ratio is 0.25.
    /// Return the evaluation result as next optimal movement and the localtion of tile which should
    /// be assigned with 2.
    private func evaluateCurBoard(gameBoard: [[Int]], ratio: Double = 0.25) -> (Double, (Int, Int)) {
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
            for i in xRange {
                let jCopy = j
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
            for i in xRangeReverse {
                let jCopy = j
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
            for j in yRange {
                let jCopy = !reverse ? j : size - j - 1
                let iCopy = i
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
            for j in yRangeReverse {
                let jCopy = !reverse ? j : size - j - 1
                let iCopy = i
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
            for i in xRangeReverse {
                let jCopy = j
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
            for i in xRange {
                let jCopy = j
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
            for j in yRange {
                let jCopy = !reverse ? j : size - j - 1
                let iCopy = i
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
            for j in yRangeReverse {
                let jCopy = !reverse ? j : size - j - 1
                let iCopy = i
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
}
