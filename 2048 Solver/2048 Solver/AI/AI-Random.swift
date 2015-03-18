//
//  AI-Random.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/17/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

// Reference: http://stackoverflow.com/a/23853848/3164091

class AIRandom {
    var runsPerMove: Int = 50
    weak var gameModel: Game2048!
    
    init(gameModel: Game2048) {
        self.gameModel = gameModel
    }
    
    func randomMoveCommand() -> MoveCommand {
        let seed = Int(arc4random_uniform(UInt32(100)))
        if seed < 25 {
            return MoveCommand(direction: MoveDirection.Up)
        } else if seed < 50 {
            return MoveCommand(direction: MoveDirection.Down)
        } else if seed < 75 {
            return MoveCommand(direction: MoveDirection.Left)
        } else {
            return MoveCommand(direction: MoveDirection.Right)
        }
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
        
        var currentMaxAverageScore: Float = -1
        for command in commands {
//            printOutCommand(command)
            var currentState = gameBoard
            var totalScore = 0
            var moveCounts = 0
            for i in 0 ..< runsPerMove {
                moveCounts += 1
//                printOutGameBoard(currentState)
                
                var increasedScores = 0
                if i == 0 {
                    (currentState, increasedScores) = gameModel.nextStateFromGameBoard(currentState, withCommand: command, shouldInsertNewTile: true)
                } else {
                    (currentState, increasedScores) = gameModel.nextStateFromGameBoard(currentState, withCommand: randomMoveCommand(), shouldInsertNewTile: true)
                }
                
                totalScore += increasedScores
//                logDebug("total score: \(totalScore)")
                
                // If game is ended, calculate average score
                if gameModel.isGameBoardEnded(currentState) {
                    let averageScore = Float(totalScore) / Float(moveCounts)
//                    logDebug("average score: \(averageScore)")
                    if averageScore > currentMaxAverageScore {
                        currentMaxAverageScore = averageScore
                        choosedMoveCommand = command
                    }
                    break
                }
            }
            
            logDebug("moveCounts: \(moveCounts)")
            
            if moveCounts == runsPerMove {
                let averageScore = Float(totalScore) / Float(moveCounts)
                logDebug("average score: \(averageScore)")
                if averageScore > currentMaxAverageScore {
                    currentMaxAverageScore = averageScore
                    choosedMoveCommand = command
                }
            }
        }
        
        assert(choosedMoveCommand != nil, "choosedMoveCommand Shouldn't be nil")
        return choosedMoveCommand
    }
}

extension AIRandom {
    func printOutGameBoard(gameBoard: [[Int]]) {
        println("Game Board:")
        let dimension = gameBoard.count
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if gameBoard[i][j] == 0 {
                    print("_\t")
                } else {
                    print("\(gameBoard[i][j])\t")
                }
            }
            println()
        }
    }
}