//
//  AI-Random.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/17/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

// Reference: http://stackoverflow.com/a/23853848/3164091
// My Thoughts: Not sure how this works, it's purely randomizing, what a stupid AI it is

class AIRandom {
    var runsPerMove: Int = 70
    weak var gameModel: Game2048!
    
    init(gameModel: Game2048) {
        self.gameModel = gameModel
    }
    
    func nextCommand() -> MoveCommand? {
        log.debug("Calculate next step")
        if GameModelHelper.isGameEnded(&gameModel.gameBoard) {
            return nil
        }
        
        var bestScore: Float = -1.0
        var choosenCommand: MoveCommand!
        
        let commands = GameModelHelper.moveCommands()
        for command in commands {
            let (averageScore, _) = multipleRandomRun(&gameModel.gameBoard, withCommand: command, runTimes: runsPerMove)
            if averageScore > bestScore {
                bestScore = averageScore
                choosenCommand = command
            }
        }
        
        assert(choosenCommand != nil, "Impossible")
        return choosenCommand
    }
    
    private func multipleRandomRun(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, withCommand command: MoveCommand, runTimes: Int) -> (Float, Float) {
        var total: Float = 0.0
        var totalMoves = 0
        
        for _ in 0 ..< runTimes {
            let (score, moves) = randomRun(&gameBoard, withCommand: command)
            if score == -1 {
                return (-1, 0)
            }
            
            total += Float(score)
            totalMoves += moves
        }
        
        let average: Float = total / Float(runTimes)
        let averageMoves: Float = Float(totalMoves) / Float(runTimes)
        
        return (average, averageMoves)
    }
    
    private func randomRun(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, withCommand command: MoveCommand) -> (Int, Int) {
        var gameBoardCopy = GameModelHelper.copyGameBoard(&gameBoard)
        var score = 0
        
        let (moved, increasedScore) = GameModelHelper.performMoveCommand(command, onGameBoard: &gameBoardCopy, shouldInsertNewTiles: true)
        if !moved {
            GameModelHelper.deallocGameBoard(&gameBoardCopy)
            return (-1, 0)
        }
        
        score += increasedScore
        
        // Run till we can't
        var moves = 1
        while true {
            if GameModelHelper.isGameEnded(&gameBoardCopy) {
                break
            }
            
            let (moved, increasedScore) = GameModelHelper.performMoveCommand(GameModelHelper.randomMoveCommand(), onGameBoard: &gameBoardCopy, shouldInsertNewTiles: true)
            if !moved {
                continue
            }
            
            score += increasedScore
            moves += 1
        }
        
        // Done
        GameModelHelper.deallocGameBoard(&gameBoardCopy)
        return (score, moves)
    }
}
