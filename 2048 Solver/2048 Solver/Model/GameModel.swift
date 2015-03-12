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
    func game2048DidUpdate(game2048: Game2048, moveActions: [MoveAction], initActions: [InitAction])
    func game2048DidReset(game2048: Game2048)
}

class Game2048: NSObject {
    let dimension: Int
    let target: Int
    
    var score: Int = 0
    // Store pointers to Tiles, this will give a chance to modify in place
    var gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>
    
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
        
        // Initialize gameBoard, alloc memory and initialize it
        gameBoard =  SquareGameBoard(dimension: d, initialValue: nil)
        super.init()
        
        allocateGameBoard()
    }
    
    deinit {
        deallocateGameBoard()
    }
}

// MARK: Game Logics
extension Game2048 {
    func reset() {
        score = 0
        emptyGameBoard()
        moveCommandsQueue.removeAll(keepCapacity: true)
        timer.invalidate()
        
        delegate?.game2048DidReset(self)
    }
    
    func start() {
        precondition(!gameboardFull(), "Game is not empty, before starting a new game, please reset a game")
        
        var resultInitActions = [InitAction]()
        
        for i in 0 ..< 2 {
            let insertedCoordinate = insertTileAtRandomLocation(2)
            // TODO: Could randomly insert 4
            resultInitActions.append(InitAction(actionType: .Init, initCoordinate: insertedCoordinate, initNumber: 2))
        }
        
        printOutGameBoard()
        
        // TODO: Could issue Actions
        delegate?.game2048DidStartNewGame(self)
        delegate?.game2048DidUpdate(self, moveActions: [], initActions: resultInitActions)
    }
    
    func performMoveCommand(moveCommand: MoveCommand) {
        var resultMoveActions = [MoveAction]()
        switch moveCommand.direction {
        case .Up:
            for i in 0 ..< dimension {
                var tiles = gameBoard.getColumn(i, reversed: true)
                let actions = processOneDimensionTiles(&tiles)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (self.dimension - 1 - $0, i) })
                    let toCoordinate = (self.dimension - 1 - action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
            }
        case .Down:
            for i in 0 ..< dimension {
                var tiles = gameBoard.getColumn(i, reversed: false)
                let actions = processOneDimensionTiles(&tiles)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ ($0, i) })
                    let toCoordinate = (action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
            }
        case .Left:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: true)
                let actions = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, self.dimension - 1 - $0) })
                    let toCoordinate = (i, self.dimension - 1 - action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
            }
        case .Right:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: false)
                let actions = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, $0) })
                    let toCoordinate = (i, action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
            }
        }
        
        var resultInitActions = [InitAction]()
        
        if resultMoveActions.count > 0 {
            let insertedCoordinate = insertTileAtRandomLocation(2)
            resultInitActions.append(InitAction(actionType: .Init, initCoordinate: insertedCoordinate, initNumber: 2))
        }
        
        printOutGameBoard()
        delegate?.game2048DidUpdate(self, moveActions: resultMoveActions, initActions: resultInitActions)
    }
}

// MARK: Game Helpers
extension Game2048 {
    /// Return a list of tuples describing the coordinates of empty spots remaining on the gameboard.
    func gameboardEmptySpots() -> [(Int, Int)] {
        var buffer = Array<(Int, Int)>()
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameBoard[i, j].memory {
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
    func insertTileAtRandomLocation(value: Int) -> (Int, Int) {
        let openSpots = gameboardEmptySpots()
        if openSpots.count == 0 {
            // No more open spots; don't even bother
            return (-1, -1)
        }
        // Randomly select an open spot, and put a new tile there
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        insertTile((x, y), value: value)
        return (x, y)
    }
    
    /// Insert a tile with a given value at a position upon the gameboard.
    func insertTile(pos: (Int, Int), value: Int) {
        let (x, y) = pos
        switch gameBoard[x, y].memory {
        case .Empty:
            gameBoard[x, y].memory = Tile.Number(value)
        case .Number:
            break
        }
    }
    
    func processOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> [Action1D] {
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
    func mergeOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> [Action1D] {
        var resultActions = [Action1D]()
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].memory {
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
                        tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                        tiles[i].memory = Tile.Empty
                        resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if tileNumber == rightTileNumber {
                            // Merge
                            tiles[rightIndex].memory = Tile.Number(tileNumber * 2)
                            tiles[i].memory = Tile.Number(0)
                            resultActions.append(Action1D(fromIndexs: [i, rightIndex], toIndex: rightIndex))
                        } else if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                            tiles[i].memory = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    }
                }
            }
        }
        
        return resultActions
    }
    
    /**
    Condense tiles, remove .Empty tiles and .0 tiles, and generate associated Actions
    E.g. [_,2,_,2] -> [_,_,2,2]
         [0,2,_,_] -> [_,_,_,2]
    
    :param: tiles the reference of an array of references of Tiles
    
    :returns: a list of actions
    */
    func condenseOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> [Action1D] {
        var resultActions = [Action1D]()
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].memory {
            case .Empty:
                continue
            case let .Number(tileNumber):
                if tileNumber == 0 {
                    tiles[i].memory = Tile.Empty
                    continue
                } else {
                    let (rightTile, rightIndex) = getFirstRightNonEmptyTileForIndex(i, inTiles: tiles)
                    switch rightTile {
                    case .Empty:
                        // Right wall
                        // [_,_,4] -> [_,_,4]
                        // [2,_,_] -> [_,_,2]
                        if rightIndex > i + 1 {
                            tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                            tiles[i].memory = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                            tiles[i].memory = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    }
                }
            }
        }
        
        return resultActions
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
    func getFirstRightNonEmptyTileForIndex(index: Int, inTiles tiles: [UnsafeMutablePointer<Tile>]) -> (Tile, Int) {
        let count = tiles.count
        for i in (index + 1) ..< count {
            switch tiles[i].memory {
            case .Empty:
                continue
            case .Number:
                return (tiles[i].memory, i)
            }
        }
        return (Tile.Empty, count)
    }
}

// MARK: Fundamental Helpers
extension Game2048 {
    /**
    Allocate memory for game board and initialize it with .Empty
    */
    func allocateGameBoard() {
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j] = UnsafeMutablePointer<Tile>.alloc(1)
                gameBoard[i, j].initialize(Tile.Empty)
            }
        }
    }
    
    /**
    Set all values in game board to .Empty
    PRE: gameboard memory is allocated
    */
    func emptyGameBoard() {
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j].memory = Tile.Empty
            }
        }
    }
    
    /**
    Destory value in game board and deallocate memory
    */
    func deallocateGameBoard() {
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j].destroy()
                gameBoard[i, j].dealloc(1)
            }
        }
    }
}

// MARK: Debug Methods
extension Game2048 {
    func printOutGameBoard() {
        println("Game Board:")
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    print("_\t")
                case let .Number(num):
                    print("\(num)\t")
                }
            }
            println()
        }
    }
    
    func printOutTilePointers(tilePointers: [UnsafeMutablePointer<Tile>]) {
        println("Tile Pointers:")
        for p in tilePointers {
            switch p.memory {
            case .Empty:
                print("_\t")
            case let .Number(num):
                print("\(num)\t")
            }
        }
        println()
    }
    
    func printOutMoveActions(actions: [MoveAction]) {
        for action in actions {
            println("From: \(action.fromCoordinates) To:\(action.toCoordinate)")
        }
    }
}

// MARK: Expose to AI
extension Game2048 {
    // Return a copy of gameBoard (a 2d matrix contains integers, 0 stands for .Empty)
    func currentGameBoard() -> [[Int]] {
        var result = [[Int]]()
        for i in 0 ..< dimension {
            var row = [Int]()
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    row.append(0)
                case let .Number(num):
                    row.append(num)
                }
            }
            result.append(row)
        }
        return result
    }
    
    func nextStateFromGameBoard(gameBoard: [[Int]], withCommand command: MoveCommand) -> [[Int]] {
//        switch command.direction {
//        case .Up:
//            for i in 0 ..< dimension {
//                var tiles = gameBoard.getColumn(i, reversed: true)
//                processOneDimensionTiles(&tiles)
//            }
//        case .Down:
//            for i in 0 ..< dimension {
//                var tiles = gameBoard.getColumn(i, reversed: false)
//                processOneDimensionTiles(&tiles)
//            }
//        case .Left:
//            for i in 0 ..< dimension {
//                var tilePointers = gameBoard.getRow(i, reversed: true)
//                processOneDimensionTiles(&tilePointers)
//            }
//        case .Right:
//            for i in 0 ..< dimension {
//                var tilePointers = gameBoard.getRow(i, reversed: false)
//                processOneDimensionTiles(&tilePointers)
//            }
//        }
        return []
    }
}
