//
//  GameModelHelper.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/18/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import ChouTi

struct GameModelHelper {
    /**
    Get number of empty spots in game board
    * Game board is not mutated
    
    - parameter gameBoard: gameBoard description
    
    - returns: number of empty spots
    */
    static func gameBoardEmptySpotsCount(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Int {
        let dimension = gameBoard.dimension
        var result = 0
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].pointee {
                case .Empty:
                    result += 1
                case .Number:
                    break
                }
            }
        }
        return result
    }
    
    /**
    Return a list of tuples describing the coordinates of empty spots remaining on the gameboard.
    * Game board is not mutated
    
    - returns: coordinates for empty spots
    */
    static func gameBoardEmptySpots(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> [(Int, Int)] {
        let dimension = gameBoard.dimension
        var buffer = Array<(Int, Int)>()
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].pointee {
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
    * Game board is not mutated
    
    - returns: true is game board is full
    */
    static func gameBoardFull(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        return gameBoardEmptySpots(&gameBoard).count == 0
    }
    
    // * Game board is not mutated
    static func isGameEnded(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        if !gameBoardFull(&gameBoard) {
            return false
        }
        
        _ = gameBoard.dimension
        let canMove = (moveCommand(MoveCommand(direction: .up), isValidInGameBoard: &gameBoard) || moveCommand(MoveCommand(direction: .left), isValidInGameBoard: &gameBoard))
        
        return !canMove
    }
    
    static func moveCommands(_ shuffle: Bool = false) -> [MoveCommand] {
        var commands = [MoveCommand]()
        commands.append(MoveCommand(direction: MoveDirection.up))
        commands.append(MoveCommand(direction: MoveDirection.left))
        commands.append(MoveCommand(direction: MoveDirection.down))
        commands.append(MoveCommand(direction: MoveDirection.right))
        
        if shuffle {
            commands.shuffle()
        }
        return commands
    }
    
    static func randomMoveCommand() -> MoveCommand {
        let seed = Int(arc4random_uniform(UInt32(100)))
        if seed < 25 {
            return MoveCommand(direction: MoveDirection.up)
        } else if seed < 50 {
            return MoveCommand(direction: MoveDirection.down)
        } else if seed < 75 {
            return MoveCommand(direction: MoveDirection.left)
        } else {
            return MoveCommand(direction: MoveDirection.right)
        }
    }
    
    // * Game board is not mutated
    static func validMoveCommandsInGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, shuffle: Bool = false) -> [MoveCommand] {
        var commands = [MoveCommand]()
        let fullCommands = moveCommands(false)
        for command in fullCommands {
            if moveCommand(command, isValidInGameBoard: &gameBoard) {
                commands.append(command)
            }
        }
        
        if shuffle {
            commands.shuffle()
        }
        
        return commands
    }
    
    // * Game board is not mutated
    static func randomValidMoveCommandInGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> MoveCommand? {
        let validCommands = validMoveCommandsInGameBoard(&gameBoard, shuffle: true)
        if validCommands.count > 0 {
            return validCommands[0]
        } else {
            return nil
        }
    }
    
    // * Game board is not mutated
    static func moveCommand(_ moveCommand: MoveCommand, isValidInGameBoard gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        let dimension = gameBoard.dimension
        switch moveCommand.direction {
        case .up:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: true)
                if oneDimensionTilesCanMove(&tilePointers) {
                    return true
                }
            }
        case .down:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: false)
                if oneDimensionTilesCanMove(&tilePointers) {
                    return true
                }
            }
        case .left:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: true)
                if oneDimensionTilesCanMove(&tilePointers) {
                    return true
                }
            }
        case .right:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: false)
                if oneDimensionTilesCanMove(&tilePointers) {
                    return true
                }
            }
        }
        
        return false
    }
    
    static func gameBoard(_ gameBoard1: [[Int]], IsEqualTo gameBoard2: [[Int]]) -> Bool {
        let dimension = gameBoard1.count
        precondition(dimension == gameBoard2.count, "dimension must be equal")
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if gameBoard1[i][j] != gameBoard2[i][j] {
                    return false
                }
            }
        }
        return true
    }
    
    /**
    Return a copy of gameBoard (a 2d matrix contains integers, 0 stands for .Empty)
    
    - returns: 2d array of Int
    */
    static func intGameBoardFromGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> [[Int]] {
        let dimension = gameBoard.dimension
        var result = [[Int]]()
        for i in 0 ..< dimension {
            var row = [Int]()
            for j in 0 ..< dimension {
                switch gameBoard[i, j].pointee {
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

}

// MARK: Memory Management
extension GameModelHelper {
    static func allocInitGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        let dimension = gameBoard.dimension
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j].initialize(to: Tile.Empty)
            }
        }
    }
    
    static func allocInitGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, withGameBoard intGameBoard: [[Int]]) {
        let dimension = gameBoard.dimension
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if intGameBoard[i][j] == 0 {
                    gameBoard[i, j].initialize(to: Tile.Empty)
                } else {
                    gameBoard[i, j].initialize(to: Tile.Number(intGameBoard[i][j]))
                }
            }
        }
    }
    
    static func resetGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, withGameBoard intGameBoard: [[Int]]) {
        let dimension = gameBoard.dimension
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if intGameBoard[i][j] == 0 {
                    gameBoard[i, j].pointee = Tile.Empty
                } else {
                    gameBoard[i, j].pointee = Tile.Number(intGameBoard[i][j])
                }
            }
        }
    }
    
    static func emptyGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> [(Int, Int)] {
        var removedCoordinates = [(Int, Int)]()
        let dimension = gameBoard.dimension
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].pointee {
                case .Empty:
                    continue
                case .Number:
                    gameBoard[i, j].pointee = Tile.Empty
                    removedCoordinates.append((i, j))
                }
            }
        }
        return removedCoordinates
    }
    
    static func deallocGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        let dimension = gameBoard.dimension
        // Dealloc temp memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j].deallocate()
            }
        }
    }
    
    static func copyGameBoard(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> SquareGameBoard<UnsafeMutablePointer<Tile>> {
        let dimension = gameBoard.dimension
        // Init a temp game board
        var tempGameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>> = SquareGameBoard(dimension: dimension, initialValue: { return UnsafeMutablePointer<Tile>.allocate(capacity: 1) })
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                tempGameBoard[i, j].initialize(to: gameBoard[i, j].pointee)
            }
        }
        
        return tempGameBoard
    }
}

// MARK: Game Logic
extension GameModelHelper {
    
    // * Game board is MUTATED
    static func performMoveCommand(_ moveCommand: MoveCommand, onGameBoard gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, shouldInsertNewTiles: Bool) -> (Bool, Int) {
        let (moveActions, increasedScore) = performMoveCommand(moveCommand, onGameBoard: &gameBoard)
        
        if moveActions.count == 0 {
            return (false, increasedScore)
        }
        
        if shouldInsertNewTiles && moveActions.count > 0 {
            performInsertCommand(&gameBoard)
        }
        
        return (true, increasedScore)
    }
    
    // * Game board is MUTATED
    @discardableResult
    static func performInsertCommand(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> InitAction {
        let (initNumber, insertedCoordinate) = insertTileAtRandomLocation(&gameBoard)
        return InitAction(actionType: .Init, initCoordinate: insertedCoordinate, initNumber: initNumber)
    }
    
    // * Game board is MUTATED
    static func performInsertCommand(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, multipleTimes times: Int) -> [InitAction] {
        precondition(times > 0, "Times must be greater than 0")
        var resultInitActions = [InitAction]()
        
        for _ in 0 ..< times {
            log.debug("perform insert command")
            resultInitActions.append(GameModelHelper.performInsertCommand(&gameBoard))
        }
        
        return resultInitActions
    }
    
    // * Game board is MUTATED
    static func performMoveCommand(_ moveCommand: MoveCommand, onGameBoard gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> ([MoveAction], Int) {
        let dimension = gameBoard.dimension
        var resultMoveActions = [MoveAction]()
        var increasedScore: Int = 0
        switch moveCommand.direction {
        case .up:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (dimension - 1 - $0, i) })
                    let toCoordinate = (dimension - 1 - action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .down:
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
        case .left:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, dimension - 1 - $0) })
                    let toCoordinate = (i, dimension - 1 - action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .right:
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
        
        return (resultMoveActions, increasedScore)
    }
}

// MARK: Game Logic Helper
extension GameModelHelper {
    // MARK: Move and Merge
    /**
    Process a list of tiles, for a 2048 board game, commands with any directions will eventually go into an one dimension array whihc can be processed in same way
    
    - parameter tiles: a list of tile pointers
    
    - returns: result 1D actions
    */
    static func processOneDimensionTiles(_ tiles: inout [UnsafeMutablePointer<Tile>]) -> ([Action1D], Int) {
        var (actions, increasedScore) = mergeOneDimensionTiles(&tiles)
        actions.append(contentsOf: condenseOneDimensionTiles(&tiles))
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
    
    - parameter tiles: the reference of an array of references of Tiles
    
    - returns: Return a list of actions
    */
    static func mergeOneDimensionTiles(_ tiles: inout [UnsafeMutablePointer<Tile>]) -> ([Action1D], Int) {
        var resultActions = [Action1D]()
        var increasedScore: Int = 0
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].pointee {
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
                        tiles[rightIndex - 1].pointee = Tile.Number(tileNumber)
                        tiles[i].pointee = Tile.Empty
                        resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if tileNumber == rightTileNumber {
                            // Merge
                            tiles[rightIndex].pointee = Tile.Number(tileNumber * 2)
                            increasedScore += tileNumber * 2
                            tiles[i].pointee = Tile.Number(0)
                            resultActions.append(Action1D(fromIndexs: [i, rightIndex], toIndex: rightIndex))
                        } else if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1].pointee = Tile.Number(tileNumber)
                            tiles[i].pointee = Tile.Empty
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
    
    - parameter tiles: the reference of an array of references of Tiles
    
    - returns: a list of actions
    */
    static func condenseOneDimensionTiles(_ tiles: inout [UnsafeMutablePointer<Tile>]) -> [Action1D] {
        var resultActions = [Action1D]()
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].pointee {
            case .Empty:
                continue
            case let .Number(tileNumber):
                if tileNumber == 0 {
                    tiles[i].pointee = Tile.Empty
                    continue
                } else {
                    let (rightTile, rightIndex) = getFirstRightNonEmptyTileForIndex(i, inTiles: tiles)
                    switch rightTile {
                    case .Empty:
                        // Right wall
                        // [_,_,4] -> [_,_,4]
                        // [2,_,_] -> [_,_,2]
                        if rightIndex > i + 1 {
                            tiles[rightIndex - 1].pointee = Tile.Number(tileNumber)
                            tiles[i].pointee = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    case .Number(_):
                        // Exist rightTile
                        if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1].pointee = Tile.Number(tileNumber)
                            tiles[i].pointee = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    }
                }
            }
        }
        
        return resultActions
    }
    
    // * Tile array is not mutated
    static func oneDimensionTilesCanMove(_ tiles: inout [UnsafeMutablePointer<Tile>]) -> Bool {
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].pointee {
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
                        return true
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if tileNumber == rightTileNumber {
                            // Merge
                            return true
                        } else if rightIndex > i + 1 {
                            // Move
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    /**
    Get the first valid right tile
    E.g. tiles: [_,4,_,2,_]
    1
    return 3
    
    - parameter index: current index
    - parameter tiles: an array of tiles
    
    - returns: (rightTile, rightIndex), if there's no right vaild tile, return .Empty
    */
    static func getFirstRightNonEmptyTileForIndex(_ index: Int, inTiles tiles: [UnsafeMutablePointer<Tile>]) -> (Tile, Int) {
        let count = tiles.count
        for i in (index + 1) ..< count {
            switch tiles[i].pointee {
            case .Empty:
                continue
            case .Number:
                return (tiles[i].pointee, i)
            }
        }
        return (Tile.Empty, count)
    }
    
    // MARK: Insert

    @discardableResult
    static func insertTileAtRandomLocation(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>) -> (Int, (Int, Int)) {
        let seed = Int(arc4random_uniform(UInt32(100)))
        let initNumber: Int = seed < 15 ? 4 : 2
        let insertedCoordinate = insertTileAtRandomLocation(&gameBoard, value: initNumber)
        return (initNumber, insertedCoordinate)
    }
    
    /**
    Insert a tile with a given value at a random open position upon the game board.
    
    - parameter value: new number value to be inserted
    
    - returns: inserted coordinate, if game board is full, return (-1, -1)
    */
    static func insertTileAtRandomLocation(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, value: Int) -> (Int, Int) {
        let openSpots = gameBoardEmptySpots(&gameBoard)
        if openSpots.count == 0 {
            // No more open spots; don't even bother
            assertionFailure()
            return (-1, -1)
        }
        // Randomly select an open spot, and put a new tile there
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        assert(x >= 0 && y >= 0)
        insertTile(&gameBoard, pos: (x, y), value: value)
        return (x, y)
    }
    
    /**
    Insert a tile with a given value at a position upon the game board.
    
    - parameter pos:   insert position/ coordinate
    - parameter value: new inserted value
    */
    static func insertTile(_ gameBoard: inout SquareGameBoard<UnsafeMutablePointer<Tile>>, pos: (Int, Int), value: Int) {
        let (x, y) = pos
        switch gameBoard[x, y].pointee {
        case .Empty:
            gameBoard[x, y].pointee = Tile.Number(value)
        case .Number:
            break
        }
    }
}

// MARK: Debug Helper
extension GameModelHelper {
    static func printOutGameBoard(_ gameBoard: [[Int]]) {
//        logDebug("Game Board:")
        let dimension = gameBoard.count
        var buffer = "\n"
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if gameBoard[i][j] == 0 {
                    buffer += "_\t"
                } else {
                    buffer += "\(gameBoard[i][j])\t"
                }
            }
            buffer += "\n"
        }
        log.debug(buffer)
    }
    
    static func printOutGameBoard(_ gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        let dimension = gameBoard.dimension
        var buffer = "\n"
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].pointee {
                case .Empty:
                    buffer += "_\t"
                case let .Number(num):
                    buffer += "\(num)\t"
                }
            }
            buffer += "\n"
        }
        log.debug(buffer)
    }
    
    static func printOutTilePointers(_ tilePointers: [UnsafeMutablePointer<Tile>]) {
        print("Tile Pointers:")
        for p in tilePointers {
            switch p.pointee {
            case .Empty:
                print("_\t", terminator: "")
            case let .Number(num):
                print("\(num)\t", terminator: "")
            }
        }
        print("")
    }
    
    static func printOutCommand(_ command: MoveCommand) {
        switch command.direction {
        case .up:
            log.debug("Up")
        case .down:
            log.debug("Down")
        case .left:
            log.debug("Left")
        case .right:
            log.debug("Right")
        }
    }
    
    static func printOutMoveActions(_ actions: [MoveAction]) {
        for action in actions {
            print("From: \(action.fromCoordinates) To:\(action.toCoordinate)")
        }
    }
}
