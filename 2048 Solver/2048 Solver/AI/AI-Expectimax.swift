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
            let (command, _) = _nextCommand(&gameModel.gameBoard, level: 0)
            return command
        }
    }
    
    func _nextCommand(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, level: Int = 0, maxDepth: Int = 3) -> (MoveCommand?, Double) {
        var choosenCommand: MoveCommand? = nil
        var maxScore: Double = 0.0
        
        var commands = GameModelHelper.validMoveCommandsInGameBoard(&gameBoard, shuffle: false)
        for command in commands {            
            // Copy a new board, Alloc
            var copyGameBoard = GameModelHelper.copyGameBoard(&gameBoard)
            
            // Perform command
            let (a, b) = GameModelHelper.performMoveCommand(command, onGameBoard: &copyGameBoard)
            
//            var (score, (x, y)) = evaluateUsingMonoHeuristic(GameModelHelper.intGameBoardFromGameBoard(&copyGameBoard))
//            GameModelHelper.insertTile(&copyGameBoard, pos: (y, x), value: 2)
            var score = heuristicSMonotonic(&copyGameBoard)
            GameModelHelper.insertTileAtRandomLocation(&copyGameBoard)

            if level < maxDepth {
                var (nextCommand, nextLevelScore) = _nextCommand(&copyGameBoard, level: level + 1, maxDepth: maxDepth)
                if nextCommand != nil {
                    score += nextLevelScore * pow(0.9, Double(level) + 1.0)
                }
            }
            
            if score > maxScore {
                maxScore = score
                choosenCommand = command
            }
            
            // Dealloc
            GameModelHelper.deallocGameBoard(&copyGameBoard)
            
            // Expectimax
//            score += heuristicScore(&gameBoardCopy)
            
//            // availableSpot
//            let availableSpots = GameModelHelper.gameBoardEmptySpots(&gameBoardCopy)
//            if availableSpots.count == 0 {
//                // Dealloc
//                GameModelHelper.deallocGameBoard(&gameBoardCopy)
//                continue
//            }
//            
//            for eachAvailableSpot in availableSpots {
//                // Try to insert 2
//                GameModelHelper.insertTile(&gameBoardCopy, pos: eachAvailableSpot, value: 2)
//                score += heuristicScore(&gameBoardCopy) * 0.85 * powf(0.25, Float(level))
//                var (_, nextLevelScore) = _nextCommand(&gameBoardCopy, level: level + 1, maxDepth: maxDepth)
//                score += nextLevelScore
//                
//                // Restore
//                gameBoardCopy[eachAvailableSpot.0, eachAvailableSpot.1].memory = .Empty
//                
//                // Try to insert 4
//                GameModelHelper.insertTile(&gameBoardCopy, pos: eachAvailableSpot, value: 4)
//                score += heuristicScore(&gameBoardCopy) * 0.15 * powf(0.25, Float(level))
//                (_, nextLevelScore) = _nextCommand(&gameBoardCopy, level: level + 1, maxDepth: maxDepth)
//                score += nextLevelScore
//                
//                // Restore
//                gameBoardCopy[eachAvailableSpot.0, eachAvailableSpot.1].memory = .Empty
//            }
        }
        return (choosenCommand, maxScore)
    }
    
    // MARK: Heuristic
    func heuristicScore(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Double {
        let myScore = heuristicSMonotonic(&gameBoard)
        return myScore
    }
    
    func heuristicSMonotonic(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Double {
        var ratio: Double = 0.25
        var maxScore: Double = -1.0
        
        // Construct 8 different patterns into one linear array
        // Direction for the first row
        for startDirection in 0 ..< 2 {
            // Whether flip the board
            for flip in 0 ..< 2 {
                // Whether it's row or column
                for rOrC in 0 ..< 2 {
                    var oneDimension = [UnsafeMutablePointer<Tile>]()
                    for row in stride(from: 0, to: dimension, by: 2) {
                        let firstRow = Bool(flip) ? (dimension - 1 - row) : row
                        if Bool(rOrC) {
                            oneDimension.extend(gameBoard.getRow(firstRow, reversed: Bool(startDirection)))
                        } else {
                            oneDimension.extend(gameBoard.getColumn(firstRow, reversed: Bool(startDirection)))
                        }
                        
                        let secondRow = Bool(flip) ? (dimension - 1 - row - 1) : row + 1
                        if 0 <= secondRow && secondRow < dimension {
                            if Bool(rOrC) {
                                oneDimension.extend(gameBoard.getRow(firstRow, reversed: !Bool(startDirection)))
                            } else {
                                oneDimension.extend(gameBoard.getColumn(firstRow, reversed: !Bool(startDirection)))
                            }
                        }
                    }
                    
                    var weight: Double = 1.0
                    var result: Double = 0.0
                    for (index, tile) in enumerate(oneDimension){
                        switch tile.memory {
                        case .Empty:
                            break
                        case .Number(let num):
                            result += Double(num) * weight
                        }
                        weight *= ratio
                    }
                    if result > maxScore {
                        maxScore = result
                    }
                }
            }
        }
        
        return maxScore
    }
    
    func heuristicFreeTiles(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Float {
        let maxLimit: Float = Float(dimension * dimension)
        return Float(GameModelHelper.gameBoardEmptySpotsCount(&gameBoard)) / maxLimit * 12
    }
    
    func heuristicMonotonicity(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Float {
        
        let r: Float = 0.25
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
        let d = gameboard.count
        var hasZero = false
        for i in 0 ..< d {
            for j in 0 ..< d {
                if gameboard[i][j] == 0 {
                    hasZero = true
                }
            }
        }
        assert(hasZero == true, "")
        
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