// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

// MARK: Game Basics

/// An enum representing either an empty space or a tile upon the board.
enum Tile {
  case Empty
  case Number(Int)
}

// MARK: Command Related

/// An enum representing directions supported by the game model.
enum MoveDirection {
  case up
  case down
  case left
  case right
}

/**
 *  Command is issued from view controller to game model, game model will use Command to mutate game state and generate a list of Actions
 */
struct MoveCommand {
  var direction: MoveDirection
}

// MARK: Action Related

// Action is for 2D board
/**
 *  Action is issued from game model to view controller, view controller use Actions to animate game board
 */
protocol Action { var actionType: ActionType { set get } }

enum ActionType {
  case Init // Create a new tile
  case Move // Move tiles
  case Remove // Remove a tile
}

struct InitAction: Action {
  var actionType: ActionType = .Init
  var initCoordinate: (Int, Int)
  var initNumber: Int
}

/**
 *  MoveAction stands for merging or moving
 *  If fromCoordinates has only one tile, e.g. [(0, 1)] and toCoordinate is (0, 2), this is a Move action, (0, 1) -> (0, 2)
 *  If fromCoordinates has two tiles, e.g. [(0, 1), (0, 2)], and toCoordinate is (0, 2), this means it's a merge action, (0, 1), (0, 2) -> (0, 2)
 */
struct MoveAction: Action {
  var actionType: ActionType = .Move
  var fromCoordinates: [(Int, Int)] // Either 1 tile or 2 tiles, 2 tiles means merge
  var toCoordinate: (Int, Int)
}

struct RemoveAction: Action {
  var actionType: ActionType = .Remove
  var removeCoordinate: (Int, Int)
}

// Private Use
// This is for 1D array
struct Action1D {
  // If fromIndexs contain two indexes, merge action
  // Else, move action
  var fromIndexs: [Int]
  var toIndex: Int
}

// MARK: General purpose square game board

/**
 *  A struct representing a square gameboard. Because this struct uses generics, it could conceivably be used to represent state for many other games without modification.
 */
struct SquareGameBoard<T> {
  let dimension: Int
  var boardArray: [T]

  init(dimension d: Int, initialValue: () -> T) {
    self.dimension = d
    var newBoardArray = [T]()
    for _ in 0..<d {
      for _ in 0..<d {
        newBoardArray.append(initialValue())
      }
    }
    self.boardArray = newBoardArray
  }

  subscript(row: Int, col: Int) -> T! {
    get {
      assert(row >= 0 && row < dimension)
      assert(col >= 0 && col < dimension)
      return boardArray[row * dimension + col]
    }
    set {
      assert(row >= 0 && row < dimension)
      assert(col >= 0 && col < dimension)
      boardArray[row * dimension + col] = newValue
    }
  }

  func getRow(_ row: Int, reversed: Bool = false) -> [T] {
    precondition(row >= 0 && row < dimension, "")
    var result = [T]()
    if reversed {
      for col in stride(from: dimension - 1, to: -1, by: -1) {
        result.append(boardArray[row * dimension + col])
      }
    } else {
      for col in stride(from: 0, to: dimension, by: 1) {
        result.append(boardArray[row * dimension + col])
      }
    }

    return result
  }

  func getColumn(_ col: Int, reversed: Bool = false) -> [T] {
    precondition(col >= 0 && col < dimension, "")
    var result = [T]()
    if reversed {
      for row in stride(from: dimension - 1, to: -1, by: -1) {
        result.append(boardArray[row * dimension + col])
      }
    } else {
      for row in stride(from: 0, to: dimension, by: 1) {
        result.append(boardArray[row * dimension + col])
      }
    }

    return result
  }

  // We mark this function as 'mutating' since it changes its 'parent' struct.
  mutating func setAll(_ item: T) {
    for i in 0..<dimension {
      for j in 0..<dimension {
        self[i, j] = item
      }
    }
  }
}
