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
    var runsPerMove: Int = 2
    weak var gameModel: Game2048!
    
    init(gameModel: Game2048) {
        self.gameModel = gameModel
    }
    
    func nextStepWithCurrentState(gameBoard: [[Int]]) -> MoveCommand? {
        if gameModel.isGameBoardEnded(gameBoard) {
            return nil
        }
        
        var choosedMoveCommand: MoveCommand?
        
        var commands = [MoveCommand]()
        commands.append(MoveCommand(direction: MoveDirection.Up))
        commands.append(MoveCommand(direction: MoveDirection.Down))
        commands.append(MoveCommand(direction: MoveDirection.Left))
        commands.append(MoveCommand(direction: MoveDirection.Right))
//
//        var currentMaxAverageScore: Float = -1
//        for command in commands {
//            var totalScore = 0
//            var moveCount = 0
//            
//            var increasedScores = 0
//            
//            // Run certain times for a MoveCommand
//            for i in 0 ..< runsPerMove {
//                var currentState = gameBoard
////                logDebug("Run \(i) time")
//                // Every run, clean moveCount, totalScoreThisRun
//                var totalScoreThisRun = 0
//                moveCount = 0
//                while true {
//                    if moveCount == 0 {
//                        (currentState, increasedScores) = gameModel.nextStateFromGameBoard(currentState, withCommand: command, shouldInsertNewTile: true)
//                    } else {
//                        (currentState, increasedScores) = gameModel.nextStateFromGameBoard(currentState, withCommand: randomMoveCommand(), shouldInsertNewTile: true)
//                    }
//                    
//                    moveCount += 1
//                    totalScoreThisRun += increasedScores
//                    
//                    if gameModel.isGameBoardEnded(currentState) {
//                        break
//                    }
//                }
////                logDebug("TotalScore this run \(totalScoreThisRun)")
//                totalScore += totalScoreThisRun
//            }
//            
//            let averageScore = Float(totalScore) / Float(runsPerMove)
////            logDebug("average score: \(averageScore)")
//            if averageScore > currentMaxAverageScore {
//                currentMaxAverageScore = averageScore
//                choosedMoveCommand = command
//            }
//        }
        
        //
        
//        var maxIncreasedScores = -1
//        
//        for command in commands {
//            var increasedScores = 0
//            var currentState = gameBoard
//            
//            (currentState, increasedScores) = gameModel.nextStateFromGameBoard(currentState, withCommand: command, shouldInsertNewTile: false)
//            if increasedScores > maxIncreasedScores {
//                choosedMoveCommand = command
//            }
//        }
//        
//        assert(choosedMoveCommand != nil, "choosedMoveCommand Shouldn't be nil")
//        return choosedMoveCommand
        
        return GameModelHelper.randomMoveCommand()
    }
}

extension AIRandom {
    func printOutGameBoard(gameBoard: [[Int]]) {
        logDebug("Game Board:")
        let dimension = gameBoard.count
        var buffer = ""
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if gameBoard[i][j] == 0 {
                    buffer += "_\t"
//                    print("_\t")
                } else {
                    buffer += "\(gameBoard[i][j])\t"
//                    print("\(gameBoard[i][j])\t")
                }
            }
            buffer += "\n"
        }
        logDebug(buffer)
    }
}