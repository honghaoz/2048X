//
//  Game2048.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class GameYS {
    
    func computeTransition(state:State2048, action:Action2048) -> Transition{
        var afterState = State2048(state: state)
        var reward:Double = Double(afterState.makeMove(action))
        return Transition(state: state, action: action, afterState: afterState, reward: reward)
    }
    
    func getNextState(state:State2048) -> State2048 {
        var nextState = State2048(state: state)
        nextState.addRandomTile()
        return nextState
    }
    
    func getPossibleActions(state:State2048) -> Array<Action2048>{
        return state.getPossibleMoves()
    }
    
    func sampleInitialStateDistribution() -> State2048 {
        return State2048.getInitialState()
    }
    
    func isTerminalState(state:State2048) -> Bool {
        return state.isTerminal()
    }
    
    
}