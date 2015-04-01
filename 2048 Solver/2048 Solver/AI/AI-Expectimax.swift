//
//  AI-Expectimax.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/31/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class AIExpectimax {
    
    var dimension: Int = 0
    weak var gameModel: Game2048!
    init(gameModel: Game2048) {
        self.gameModel = gameModel
        dimension = gameModel.dimension
    }
    
    func nextCommand() -> MoveCommand? {
        if GameModelHelper.isGameEnded(&gameModel.gameBoard) {
            return nil
        } else {
            return _nextCommand(&gameModel.gameBoard, level: 0)
        }
    }
    
    func _nextCommand(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, level: Int = 0) -> MoveCommand? {
        
        var choosenCommand: MoveCommand!
        var maxScore: Float = -1.0
        
        let commands = GameModelHelper.validMoveCommandsInGameBoard(&gameBoard, shuffle: true)
        
        for command in commands {
            GameModelHelper.printOutCommand(command, level: ZHLogLevel.Error)
            
            var score: Float = 0.0
            // Copy a new board, Alloc
            var gameBoardCopy = GameModelHelper.copyGameBoard(&gameModel.gameBoard)
            
            // Perform command
            GameModelHelper.performMoveCommand(command, onGameBoard: &gameBoardCopy)
            
            // availableSpot
            let availableSpots = GameModelHelper.gameBoardEmptySpots(&gameBoardCopy)
            if availableSpots.count == 0 {
                // Dealloc
                GameModelHelper.deallocGameBoard(&gameBoardCopy)
                continue
            }
            
            for eachAvailableSpot in availableSpots {
                // Try to insert 2
                GameModelHelper.insertTile(&gameBoardCopy, pos: eachAvailableSpot, value: 2)
                score += heuristicScore(&gameBoardCopy) * 0.85
                
                // Restore
                gameBoardCopy[eachAvailableSpot.0, eachAvailableSpot.1].memory = .Empty
                
                // Try to insert 4
                GameModelHelper.insertTile(&gameBoardCopy, pos: eachAvailableSpot, value: 4)
                score += heuristicScore(&gameBoardCopy) * 0.15
                
                // Restore
                gameBoardCopy[eachAvailableSpot.0, eachAvailableSpot.1].memory = .Empty
            }
            if score > maxScore {
                maxScore = score
                choosenCommand = command
            }
            
            // Dealloc
            GameModelHelper.deallocGameBoard(&gameBoardCopy)
        }
        
        return choosenCommand
    }
    
    
    // MARK: Heuristic
    func heuristicScore(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Float {
       
        let (score, (_, _)) = evaluateUsingMonoHeuristic(GameModelHelper.intGameBoardFromGameBoard(&gameBoard))
        return Float(score)
//        let free = heuristicFreeTiles(&gameBoard)
//        let mono = heuristicMonotonicity(&gameBoard)
//        logError("free: \(free), mono: \(mono)")
//        return free + mono
    }
    
    func heuristicFreeTiles(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Float {
        let maxLimit: Float = Float(dimension * dimension)
        return Float(GameModelHelper.gameBoardEmptySpotsCount(&gameBoard)) / maxLimit * 12
    }
    
    func heuristicMonotonicity(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Float {
        let r: Float = 0.5
        let dimension = gameBoard.dimension
        var maxResult: Float = 0.0
        var result: Float = 0.0
        // Top Left
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    continue
                case let .Number(num):
                     result += Float(num) * pow(r, Float(i + j))
                }
            }
        }
        if result > maxResult {
            maxResult = result
        }
        
        // Top Right
        result = 0
        for i in 0 ..< dimension {
            for j in stride(from: dimension - 1, to: -1, by: -1) {
                switch gameBoard[i, j].memory {
                case .Empty:
                    continue
                case let .Number(num):
                    result += pow(r, Float(i + j))
                }
            }
        }
        if result > maxResult {
            maxResult = result
        }
        
        // Bottom Left
        result = 0
        for i in stride(from: dimension - 1, to: -1, by: -1) {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    continue
                case let .Number(num):
                    result += pow(r, Float(i + j))
                }
            }
        }
        if result > maxResult {
            maxResult = result
        }
        
        // Bottom Right
        result = 0
        for i in stride(from: dimension - 1, to: -1, by: -1) {
            for j in stride(from: dimension - 1, to: -1, by: -1) {
                switch gameBoard[i, j].memory {
                case .Empty:
                    continue
                case let .Number(num):
                    result += pow(r, Float(i + j))
                }
            }
        }
        if result > maxResult {
            maxResult = result
        }
        
        return maxResult
    }
    
    private func evaluateUsingMonoHeuristic(gameboard: [[Int]], ratio: Double = 0.25) -> (Double, (Int, Int)) {
        let yRange = (0...gameboard.count - 1).map{$0}
        let yRangeReverse = (0...gameboard.count - 1).map{$0}.reverse()
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
                let curVal = gameboard[jCopy][iCopy]
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
                let curVal = gameboard[jCopy][iCopy]
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
                let curVal = gameboard[jCopy][iCopy]
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
                let curVal = gameboard[jCopy][iCopy]
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
                let curVal = gameboard[jCopy][iCopy]
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
                let curVal = gameboard[jCopy][iCopy]
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
                let curVal = gameboard[jCopy][iCopy]
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