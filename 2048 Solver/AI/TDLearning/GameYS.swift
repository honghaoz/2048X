// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

class GameYS {
  func computeTransition(state: State2048, action: Action2048) -> Transition {
    let afterState = State2048(state: state)
    let reward: Double = Double(afterState.makeMove(action))
    return Transition(state: state, action: action, afterState: afterState, reward: reward)
  }

  func getNextState(state: State2048) -> State2048 {
    let nextState = State2048(state: state)
    nextState.addRandomTile()
    return nextState
  }

  func getPossibleActions(state: State2048) -> [Action2048] {
    return state.getPossibleMoves()
  }

  func sampleInitialStateDistribution() -> State2048 {
    return State2048.getInitialState()
  }

  func isTerminalState(state: State2048) -> Bool {
    return state.isTerminal()
  }
}
