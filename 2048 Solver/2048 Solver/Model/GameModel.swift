//
//  GameModel.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class Game2048: NSObject {
    let dimension: Int
    let target: Int
    
    var score: Int = 0
    var gameBoard: SquareGameBoard<Tile>
    
    var moveCommandsQueue = [MoveCommand]()
    var timer: NSTimer
    
    let queueSize = 3
    let queueDelay = 0.3
    
    init(dimension d: Int, target t: Int) {
        dimension = d
        target = t
        timer = NSTimer()
        gameBoard =  SquareGameBoard(dimension: d, initialValue: Tile.Empty)
        super.init()
    }
}

// MARK: Game Logics
extension Game2048 {
    func reset() {
        score = 0
        gameBoard.setAll(Tile.Empty)
        moveCommandsQueue.removeAll(keepCapacity: true)
        timer.invalidate()
    }
    
    func start() {
        precondition(!gameboardFull(), "Game is not empty, before starting a new game, please reset a game")
        for i in 0 ..< 2 {
            insertTileAtRandomLocation(2)
        }
        
        // TODO: Could issue Actions
    }
}

// MARK: Helpers
extension Game2048 {
    /// Return a list of tuples describing the coordinates of empty spots remaining on the gameboard.
    func gameboardEmptySpots() -> [(Int, Int)] {
        var buffer = Array<(Int, Int)>()
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameBoard[i, j] {
                case .Empty:
                    buffer += [(i, j)]
                case .Number:
                    break
                }
            }
        }
        return buffer
    }
    
    func gameboardFull() -> Bool {
        return gameboardEmptySpots().count == 0
    }
    
    /// Insert a tile with a given value at a random open position upon the gameboard.
    func insertTileAtRandomLocation(value: Int) {
        let openSpots = gameboardEmptySpots()
        if openSpots.count == 0 {
            // No more open spots; don't even bother
            return
        }
        // Randomly select an open spot, and put a new tile there
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        insertTile((x, y), value: value)
    }
    
    /// Insert a tile with a given value at a position upon the gameboard.
    func insertTile(pos: (Int, Int), value: Int) {
        let (x, y) = pos
        switch gameBoard[x, y] {
        case .Empty:
            gameBoard[x, y] = Tile.Number(value)
//            delegate.insertTile(pos, value: value)
        case .Number:
            break
        }
    }
}