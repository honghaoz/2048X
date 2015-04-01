//
//  Transition.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//
//
import Foundation

class Transition {
    private var state: State2048
    private var action: Action2048
    private var afterState: State2048
    
    private var reward: Double
    private var isTerminal: Bool
    
    init(state:State2048, action:Action2048, afterState:State2048, reward:Double, isTerminal: Bool) {
        self.state = state
        self.action = action
        self.afterState = afterState
        self.reward = reward
        self.isTerminal = isTerminal
    }
    
    convenience init(state:State2048, action:Action2048, afterState:State2048, reward:Double) {
        self.init(state: state, action:action, afterState:afterState, reward:reward, isTerminal:false)
    }
    
    func getState() -> State2048 {
        return state
    }
    
    func getAction() -> Action2048 {
        return action
    }
    
    func getAfterState() -> State2048 {
        return afterState
    }
    
    func getReward() -> Double {
        return reward
    }
    
    func getTerminal() -> Bool {
        return self.isTerminal
    }
}