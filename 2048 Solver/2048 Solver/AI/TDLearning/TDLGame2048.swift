//
//  TDLGame2048.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class TDLGame2048 {
    class Game2048Outcome {
        var _score:Int
        var _maxTile:Int
        
        init(score:Int, maxTile:Int){
            self._score = score
            self._maxTile = maxTile
        }
        
        func score() -> Int{
            return _score
        }
        
        func maxTile() -> Int {
            return _maxTile
        }
    }
    
    private var game:GameYS
    
    init() {
        game = GameYS()
    }
    
    func getBestValueAction(state:State2048,ntuples:NTuples) -> Double {
        var actions = game.getPossibleActions(state)
        
        var bestValue = -Double.infinity
        for action in actions {
            var transition = game.computeTransition(state, action: action)
            var value = transition.getReward() + ntuples.getValue(transition.getAfterState().getFeatures())
            if value > bestValue {
                bestValue = value
            }
        }
        return bestValue
    }
    
    func chooseBestTransitionAfterstate(state:State2048, ntuples:NTuples) -> Transition? {
        var actions = game.getPossibleActions(state)
        
        var bestTransition:Transition? = nil
        
        var bestValue = -Double.infinity
        for action in actions {
            var transition = game.computeTransition(state, action: action)
            var value = transition.getReward() + ntuples.getValue(transition.getAfterState().getFeatures())
            if value > bestValue {
                bestValue = value
                bestTransition = transition
            }
        }
        return bestTransition
    }
    
    func playByAfterstates(nTuples:NTuples) -> Game2048Outcome {
        var sumRewards = 0
        
        var state = game.sampleInitialStateDistribution()
        while (!game.isTerminalState(state)){
            if let transition = chooseBestTransitionAfterstate(state, ntuples: nTuples){
                sumRewards += Int(transition.getReward())
                state = game.getNextState(transition.getAfterState())
            }
        }
        
        return Game2048Outcome(score: sumRewards, maxTile: state.getMaxTile())
    }
    
    
    func TDAfterstateLearn(ntuples:NTuples, explorationRate:Double, learningRate:Double) {
        var state = game.sampleInitialStateDistribution()
        
        while(!game.isTerminalState(state)) {
            var actions = game.getPossibleActions(state)
            var transition:Transition? = nil
            
            if (Double(Float.random(lower: 0.0, upper: 1.0)) < explorationRate) {
                var randomAction = Action2048.randomAction()
                transition = game.computeTransition(state, action: randomAction)
            } else {
                transition = chooseBestTransitionAfterstate(state, ntuples: ntuples)
            }
            
            var nextState = game.getNextState(transition!.getAfterState())
            
            var correctActionValue = 0.0
            if (!game.isTerminalState(nextState)) {
                correctActionValue += getBestValueAction(nextState, ntuples: ntuples)
            }
            ntuples.update(transition!.getAfterState().getFeatures(), expectedValue: correctActionValue, learningRate: learningRate)
            state = nextState
        }
    }
    
}
