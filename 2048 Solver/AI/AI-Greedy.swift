//
//  AI-Greedy.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/18/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class AIGreedy {
    weak var gameModel: Game2048!
    init(gameModel: Game2048) {
        self.gameModel = gameModel
    }
    
    func nextState() -> MoveCommand {
        var choosenCommand: MoveCommand!
        var max = -1
        
        let commands = GameModelHelper.moveCommands(true)
        for command in commands {
            GameModelHelper.printOutCommand(command)
            var copy = GameModelHelper.copyGameBoard(&gameModel.gameBoard)
            let beforeEmptyCount = GameModelHelper.gameBoardEmptySpots(&copy).count
            let (_, score) = GameModelHelper.performMoveCommand(command, onGameBoard: &copy)
            let afterEmptyCount = GameModelHelper.gameBoardEmptySpots(&copy).count
            let reducedCount = afterEmptyCount - beforeEmptyCount + score
            if reducedCount > max {
                max = reducedCount
                choosenCommand = command
            }
        }
        
        GameModelHelper.printOutCommand(choosenCommand)
        
        return choosenCommand
    }
}