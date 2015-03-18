//
//  GameModel.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

protocol Game2048Delegate: class {
    func game2048DidReset(game2048: Game2048)
    func game2048DidStartNewGame(game2048: Game2048)
    func game2048DidUpdate(game2048: Game2048, moveActions: [MoveAction], initActions: [InitAction])
    func game2048DidEnd(game2048: Game2048)
}

class Game2048: NSObject {
    let dimension: Int
    
    /// Target score to win
    var targetScore: Int = 0
    
    /// Current score
    var score: Int = 0
    
    // Store pointers to Tiles, this will give a chance to modify tiles in place
    var gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>
    
    /// A queue which will store upcomming commands, this queue if helpful for delaying too fast operation
    var commandQueue = [MoveCommand]()
    var commandQueueSize = 5
    
    /// Game delegate, normally this shoudl be the controller
    weak var delegate: Game2048Delegate?
    
    /**
    Init a new game2048
    
    :param: d dimensin of game
    :param: t target value, e.g. 2048. if pass in 0, means target is unlimited
    
    :returns: an initialized Game2048
    */
    init(dimension d: Int, target t: Int) {
        dimension = d
        targetScore = t
        
        // Initialize gameBoard
        gameBoard =  SquareGameBoard(dimension: d, initialValue: nil)
        super.init()
        // Allocate memory and initialize it
        allocateGameBoard()
    }
    
    deinit {
        // Be sure to deallocate memory
        deallocateGameBoard()
    }
}

// MARK: Game Logics
extension Game2048 {
    func reset() {
        score = 0
        emptyGameBoard()
        commandQueue.removeAll(keepCapacity: true)
        
        delegate?.game2048DidReset(self)
    }
    
    func start() {
        precondition(!gameBoardFull(gameBoard), "Game is not empty, before starting a new game, please reset a game")
        
        var resultInitActions = [InitAction]()
        
        // TODO: Different dimension could insert different numbers of tiles
        for i in 0 ..< 2 {
            let insertedCoordinate = insertTileAtRandomLocation(gameBoard, value: 2)
            resultInitActions.append(InitAction(actionType: .Init, initCoordinate: insertedCoordinate, initNumber: 2))
        }
        
        delegate?.game2048DidStartNewGame(self)
        delegate?.game2048DidUpdate(self, moveActions: [], initActions: resultInitActions)
    }
    
    func playWithCommand(command: MoveCommand) {
        if commandQueue.count > commandQueueSize {
            // Queue is wedged. This should actually never happen in practice.
            return
        }
        commandQueue.append(command)
        executeCommandQueue()
    }
    
    private func executeCommandQueue() {
        while commandQueue.count > 0 {
            let command = commandQueue[0]
            commandQueue.removeAtIndex(0)
            performMoveCommand(command)
        }
    }
    
    private func performMoveCommand(moveCommand: MoveCommand) {
        var resultMoveActions = [MoveAction]()
        var increasedScore: Int = 0
        switch moveCommand.direction {
        case .Up:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (self.dimension - 1 - $0, i) })
                    let toCoordinate = (self.dimension - 1 - action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .Down:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: false)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ ($0, i) })
                    let toCoordinate = (action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .Left:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, self.dimension - 1 - $0) })
                    let toCoordinate = (i, self.dimension - 1 - action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .Right:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: false)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, $0) })
                    let toCoordinate = (i, action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        }
        
        var resultInitActions = [InitAction]()
        
        if resultMoveActions.count > 0 {
            let (initNumber, insertedCoordinate) = insertTileAtRandomLocation(gameBoard)
            resultInitActions.append(InitAction(actionType: .Init, initCoordinate: insertedCoordinate, initNumber: initNumber))
        }
        
        self.score += increasedScore
        delegate?.game2048DidUpdate(self, moveActions: resultMoveActions, initActions: resultInitActions)
        
        if isGameEnded(gameBoard) {
            delegate?.game2048DidEnd(self)
        }
    }
    
    private func insertTileAtRandomLocation(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> (Int, (Int, Int)) {
        let seed = Int(arc4random_uniform(UInt32(100)))
        let initNumber: Int = seed < 0 ? 4 : 2
        let insertedCoordinate = insertTileAtRandomLocation(gameBoard, value: initNumber)
        return (initNumber, insertedCoordinate)
    }
    
//    private func checkGameStopped
}

// MARK: Game Logic Helper
extension Game2048 {
    /**
    Process a list of tiles, for a 2048 board game, commands with any directions will eventually go into an one dimension array whihc can be processed in same way
    
    :param: tiles a list of tile pointers
    
    :returns: result 1D actions
    */
    private func processOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> ([Action1D], Int) {
        var (actions, increasedScore) = mergeOneDimensionTiles(&tiles)
        actions.extend(condenseOneDimensionTiles(&tiles))
        return (actions, increasedScore)
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
    private func mergeOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> ([Action1D], Int) {
        var resultActions = [Action1D]()
        var increasedScore: Int = 0
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
                            increasedScore += tileNumber * 2
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
        
        return (resultActions, increasedScore)
    }
    
    /**
    Condense tiles, remove .Empty tiles and .0 tiles, and generate associated Actions
    E.g. [_,2,_,2] -> [_,_,2,2]
    [0,2,_,_] -> [_,_,_,2]
    
    :param: tiles the reference of an array of references of Tiles
    
    :returns: a list of actions
    */
    private func condenseOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> [Action1D] {
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

// MARK: Game Helpers
extension Game2048 {
    /**
    Return a list of tuples describing the coordinates of empty spots remaining on the gameboard.
    
    :returns: coordinates for empty spots
    */
    func gameBoardEmptySpots(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> [(Int, Int)] {
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
    
    /**
    Get whether game board is full
    
    :returns: true is game board is full
    */
    func gameBoardFull(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        precondition(gameBoard.dimension == dimension, "dimension must be equal")
        return gameBoardEmptySpots(gameBoard).count == 0
    }
    
    /**
    Insert a tile with a given value at a random open position upon the game board.
    
    :param: value new number value to be inserted
    
    :returns: inserted coordinate, if game board is full, return (-1, -1)
    */
    func insertTileAtRandomLocation(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, value: Int) -> (Int, Int) {
        let openSpots = gameBoardEmptySpots(gameBoard)
        if openSpots.count == 0 {
            // No more open spots; don't even bother
            return (-1, -1)
        }
        // Randomly select an open spot, and put a new tile there
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        insertTile(gameBoard, pos: (x, y), value: value)
        return (x, y)
    }
    
    /**
    Insert a tile with a given value at a position upon the game board.
    
    :param: pos   insert position/ coordinate
    :param: value new inserted value
    */
    func insertTile(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, pos: (Int, Int), value: Int) {
        let (x, y) = pos
        switch gameBoard[x, y].memory {
        case .Empty:
            gameBoard[x, y].memory = Tile.Number(value)
        case .Number:
            break
        }
    }
    
    func isGameEnded(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        precondition(gameBoard.dimension == dimension, "dimension must be equal")
        if !gameBoardFull(gameBoard) {
            return false
        }
        
        // Init a temp game board
        var tempGameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>> = SquareGameBoard(dimension: dimension, initialValue: nil)
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                tempGameBoard[i, j] = UnsafeMutablePointer<Tile>.alloc(1)
                switch gameBoard[i, j].memory {
                case .Empty:
                    tempGameBoard[i, j].initialize(Tile.Empty)
                case let .Number(tileNumber):
                    tempGameBoard[i, j].initialize(gameBoard[i, j].memory)
                }
            }
        }
        
//        logDebug("GOD1")
//        printOutGameBoard(tempGameBoard)
        
        var resultActions = [Action1D]()
        for i in 0 ..< dimension {
            // UP
            var upMoveTilePointers = tempGameBoard.getColumn(i, reversed: true)
            let (upMoveActions, _) = processOneDimensionTiles(&upMoveTilePointers)
            resultActions.extend(upMoveActions)
            
            // Left
            var leftMoveTilePointers = tempGameBoard.getRow(i, reversed: true)
            let (leftMoveActions, _) = processOneDimensionTiles(&leftMoveTilePointers)
            resultActions.extend(leftMoveActions)
        }
        
//        logDebug("GOD2")
//        printOutGameBoard(tempGameBoard)
        
        // Dealloc temp memory
        deAllocGameBoard(&tempGameBoard)
        
        if resultActions.count == 0 {
//            logDebug("GOD")
//            printOutGameBoard(gameBoard)
            return true
        } else {
            return false
        }
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

// MARK: Expose to AI
extension Game2048 {
    /**
    Return a copy of gameBoard (a 2d matrix contains integers, 0 stands for .Empty)
    
    :returns: 2d array of Int
    */
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
    
    /**
    Get next state for a game board
    
    :param: gameBoard 2d array with Int type, representation for a game board
    :param: command   a valid command
    
    :returns: next game board and increased scores
    */
    func nextStateFromGameBoard(gameBoard: [[Int]], withCommand command: MoveCommand, shouldCheckGameEnd: Bool = false, shouldInsertNewTile: Bool = false) -> ([[Int]], Int) {
        precondition(gameBoard.count == dimension, "dimension must be equal")
        // Init a temp game board
        var tempGameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>> = SquareGameBoard(dimension: dimension, initialValue: nil)
        
        // Alloc memory
        allocInitGameBoard(&tempGameBoard, withGameBoard: gameBoard)
        
//        printOutGameBoard(tempGameBoard)
        
        var increasedScore: Int = 0
        
        // Mutate tempGameBoard
        switch command.direction {
        case .Up:
            for i in 0 ..< dimension {
                var tilePointers = tempGameBoard.getColumn(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                increasedScore += score
            }
        case .Down:
            for i in 0 ..< dimension {
                var tilePointers = tempGameBoard.getColumn(i, reversed: false)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                increasedScore += score
            }
        case .Left:
            for i in 0 ..< dimension {
                var tilePointers = tempGameBoard.getRow(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                increasedScore += score
            }
        case .Right:
            for i in 0 ..< dimension {
                var tilePointers = tempGameBoard.getRow(i, reversed: false)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                increasedScore += score
            }
        }
        
        if shouldInsertNewTile {
            insertTileAtRandomLocation(tempGameBoard)
        }
        
        // Create a new game board: [[Int]]
        var resultBoard = [[Int]]()
        for i in 0 ..< dimension {
            var row = [Int]()
            for j in 0 ..< dimension {
                switch tempGameBoard[i, j].memory {
                case .Empty:
                    row.append(0)
                case let .Number(tileNumber):
                    row.append(tileNumber)
                }
            }
            resultBoard.append(row)
        }
        
        // Dealloc temp memory
        deAllocGameBoard(&tempGameBoard)
        
//        logDebug("increasedScore: \(increasedScore)")
        return (resultBoard, increasedScore)
    }
    
    func isGameBoardEnded(gameBoard: [[Int]]) -> Bool {
        precondition(gameBoard.count == dimension, "dimension must be equal")
        
        // PreCheck
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if gameBoard[i][j] == 0 {
                    return false
                }
            }
        }
        
        // Init a temp game board
        var tempGameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>> = SquareGameBoard(dimension: dimension, initialValue: nil)
        
        // Alloc memory
        allocInitGameBoard(&tempGameBoard, withGameBoard: gameBoard)
        
        let result = isGameEnded(tempGameBoard)
        
        // Dealloc temp memory
        deAllocGameBoard(&tempGameBoard)
        
        return result
    }
    
    private func allocInitGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, withGameBoard intGameBoard: [[Int]]) {
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j] = UnsafeMutablePointer<Tile>.alloc(1)
                if intGameBoard[i][j] == 0 {
                    gameBoard[i, j].initialize(Tile.Empty)
                } else {
                    gameBoard[i, j].initialize(Tile.Number(intGameBoard[i][j]))
                }
            }
        }
    }
    
    private func deAllocGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        // Dealloc temp memory
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
        printOutGameBoard(self.gameBoard)
    }
    
    func printOutGameBoard(gameboard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
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
}
