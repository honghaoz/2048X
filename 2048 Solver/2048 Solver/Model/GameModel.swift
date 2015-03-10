//
//  GameModel.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

protocol Game2048Delegate: class {
    func game2048DidStartNewGame(game2048: Game2048)
    func game2048DidUpdate(game2048: Game2048)
    func game2048DidReset(game2048: Game2048)
}

class Game2048: NSObject {
    let dimension: Int
    let target: Int
    
    var score: Int = 0
    var gameBoard: SquareGameBoard<Tile>
    
    var moveCommandsQueue = [MoveCommand]()
    var timer: NSTimer
    
    let queueSize = 3
    let queueDelay = 0.3
    
    weak var delegate: Game2048Delegate?
    
    /**
    Init a new game2048
    
    :param: d dimensin of game
    :param: t target value, e.g. 2048. if pass in 0, means target is unlimited
    
    :returns: an initialized Game2048
    */
    init(dimension d: Int, target t: Int) {
        dimension = d
        if t == 0 {
            target = Int.max
        } else {
            target = t
        }
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
        
        delegate?.game2048DidReset(self)
    }
    
    func start() {
        precondition(!gameboardFull(), "Game is not empty, before starting a new game, please reset a game")
        for i in 0 ..< 2 {
            insertTileAtRandomLocation(2)
            // TODO: Could randomly insert 4
        }
        
        printGameModel()
        
        // TODO: Could issue Actions
        delegate?.game2048DidStartNewGame(self)
        delegate?.game2048DidUpdate(self)
    }
    
    func performMoveCommand(moveCommand: MoveCommand) -> [Action] {
        switch moveCommand.direction {
        case .Up:
            for i in 0 ..< dimension {
                var tiles = gameBoard.getColumn(i, reversed: true)
                processOneDimensionTiles(&tiles)
            }
        case .Down:
            for i in 0 ..< dimension {
                var tiles = gameBoard.getColumn(i, reversed: false)
                processOneDimensionTiles(&tiles)
            }
        case .Left:
            for i in 0 ..< dimension {
                var tiles = gameBoard.getRow(i, reversed: true)
                processOneDimensionTiles(&tiles)
            }
        case .Right:
            for i in 0 ..< dimension {
                var tiles = gameBoard.getRow(i, reversed: false)
                processOneDimensionTiles(&tiles)
            }
        }
        delegate?.game2048DidUpdate(self)
        return []
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
    
    func processOneDimensionTiles(inout tiles: [Tile]) -> [OneDimensionAction] {
        var actions = mergeOneDimensionTiles(&tiles)
        actions.extend(condenseOneDimensionTiles(&tiles))
        return actions
    }
    
    /**
    Merge a list of Tiles to right
    E.g. [2,2,4,4] -> [_,_,4,8], [4,2,2,2] -> [_,4,2,4]
    More detailed examples:
         [2,2,2,_] -> [2,2,_,2] -> [2,_,_,4] -> [_,_,2,4] (Move leave it as an empty tile)
         [2,_,2,2] -> [2,_,2,2] -> [2,_,0,4] -> [_,2,0,4] -> [_,_,2,4] (Merge creates 0 tile)
         [_,4,2,2] -> [_,4,2,2] -> [_,4,0,4] -> [_,4,0,4] -> [_,_,4,4] (Last step is condense, not include in this method)
         [4,2,_,2,_] -> [4,2,_,_,2] -> [4,0,_,_,4] -(condense)-> [_,_,_,4,4]
    Note: Tiles will be mutated
    
    :param: tiles the reference of an array of references of Tiles
    
    :returns: Return a list of actions
    */
    func mergeOneDimensionTiles(inout tiles: [Tile]) -> [OneDimensionAction] {
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i] {
            case .Empty:
                continue
            case let .Number(tileNumber):
                // Right most tile
                if i == count - 1 {
                    continue
                } else {
                    let (rightTile, rightIndex) = getFirstRightNonEmptyTileForIndex(i, inTiles: tiles)
                    switch rightTile {
                    case .Empty:
                        // Right wall
                        // [2,_,_] -> [_,_,2]
                        tiles[rightIndex - 1] = Tile.Number(tileNumber)
                        tiles[i] = Tile.Empty
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if tileNumber == rightTileNumber {
                            // Merge
                            tiles[rightIndex] = Tile.Number(tileNumber * 2)
                            tiles[i] = Tile.Number(0)
                        } else if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1] = Tile.Number(tileNumber)
                            tiles[i] = Tile.Empty
                        }
                    }
                }
            }
        }
        
        return []
    }
    
    /**
    Condense tiles, remove .Empty tiles and .0 tiles, and generate associated Actions
    E.g. [_,2,_,2] -> [_,_,2,2]
         [0,2,_,_] -> [_,_,_,2]
    
    :param: tiles the reference of an array of references of Tiles
    
    :returns: a list of actions
    */
    func condenseOneDimensionTiles(inout tiles: [Tile]) -> [OneDimensionAction] {
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i] {
            case .Empty:
                continue
            case let .Number(tileNumber):
                if tileNumber == 0 {
                    tiles[i] = Tile.Empty
                    continue
                } else {
                    let (rightTile, rightIndex) = getFirstRightNonEmptyTileForIndex(i, inTiles: tiles)
                    switch rightTile {
                    case .Empty:
                        // Right wall
                        // [2,_,_] -> [_,_,2]
                        tiles[rightIndex - 1] = Tile.Number(tileNumber)
                        tiles[i] = Tile.Empty
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1] = Tile.Number(tileNumber)
                            tiles[i] = Tile.Empty
                        }
                    }
                }
            }
        }
        return []
    }
    
    /**
    Get the first valid right tile
    E.g. tiles: [_,4,_,2,_]
                   1
    return 3
    
    :param: index current index
    :param: tiles an array of tiles
    
    :returns: (rightTile, rightIndex), if there's no right vaild tile, return .Empty
    */
    func getFirstRightNonEmptyTileForIndex(index: Int, inTiles tiles: [Tile]) -> (Tile, Int) {
        let count = tiles.count
        for i in (index + 1) ..< count {
            switch tiles[i] {
            case .Empty:
                continue
            case .Number:
                return (tiles[i], i)
            }
        }
        return (Tile.Empty, count)
    }
    
    func printGameModel() {
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j] {
                case .Empty:
                    print("_\t")
                case let .Number(num):
                    print("\(num)\t")
                }
            }
            print("\n")
        }
    }
}
