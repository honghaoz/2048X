//
//  state2048.swift
//  2048game
//
//  Created by yansong li on 2015-03-26.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation

final class State2048 {
    
    struct METRIC {
        static var SIZE = 4
        static var BOARD_SIZE = RectSize(size: SIZE)
        static var num_initial_locations = 2
        static var four_probability = 1
    }
    let size = 4
    let board_size = RectSize(size: 4)
    let num_initial_locations = 2
    let four_probability:Int = 1 // out of 10
    
    let rewards:[Int] = [0, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
    
    var board:Array<Array<Int>>
    
    init() {
        board = Array(count: size, repeatedValue: Array(count: 4, repeatedValue: 0))
    }
    
    convenience init(state:State2048) {
        self.init()
        for i in 0..<size {
            for j in 0..<size {
                self.board[i][j] = state.board[i][j]
            }
        }
    }
    
    // initialize the state with features, which is a double Array
    convenience init(features:[Double]) {
        self.init()
        var index = 0
        for i in 0..<size {
            for j in 0..<size {
                self.board[i][j] = Int(features[index++])
            }
        }
    }
    
    // the number of values that a board could provide
    func getNumValues()->Int {
        return self.rewards.count
    }
    
    
    // return the powered grid
    func getPowerGrid() -> Array<Array<Int>> {
        var grid:Array<Array<Int>> = Array(count: size, repeatedValue: Array(count: 4, repeatedValue: 0))
        for i in 0..<size {
            for j in 0..<size {
                grid[i][j] = rewards[board[i][j]]
            }
        }
        return grid
    }
    
    
    // features is a list by flatten the board
    func getFeatures()-> [Double] {
        var index = 0
        
        // BUGFIXED: firstly we should create the empty pos.
        var features = Array(count: size*size, repeatedValue: 0.0)
        
        for i in 0..<size {
            for j in 0..<size {
                features[index++] = Double(board[i][j])
            }
        }
        return features
    }
    
    func getValue(flatLocation:Int)->Int {
        return board[flatLocation / size][flatLocation % size]
    }
    
    func setValue(flatLocation:Int, value:Int) {
        board[flatLocation / size][flatLocation % size] = value
    }
    
    
    
    // add random tile
    func addRandomTile() {
        var emptyLocations:Array<Int> = [Int]()
        
        for location in 0..<size*size {
            if (getValue(location) == 0) {
                emptyLocations.append(location)
            }
        }
        
        if emptyLocations.count == 0 {
            return
        }
        
        var randomLoc = emptyLocations[Int(arc4random_uniform(UInt32(emptyLocations.count)))]
        
        let isFour:Bool = (Int(arc4random_uniform(10)) < four_probability)
        if (isFour) {
            setValue(randomLoc, value: 2)
        } else {
            setValue(randomLoc, value: 1)
        }
        
    }
    
    // Move up a board
    func moveUp() -> Int {
        var reward = 0
        
        for col in 0..<size {
            var firstFreeRow = 0
            var alreadyAggregated = false
            for row in 0..<size {
                if (board[row][col] == 0) {
                    continue
                }
                
                if(firstFreeRow > 0 && !alreadyAggregated && board[firstFreeRow - 1][col] == board[row][col]) {
                    board[firstFreeRow - 1][col]++
                    board[row][col] = 0
                    reward += rewards[board[firstFreeRow - 1][col]]
                    alreadyAggregated = true
                } else {
                    let tmp = board[row][col]
                    board[row][col] = 0
                    board[firstFreeRow++][col] = tmp
                    alreadyAggregated = false
                }
            }
        }
        
        return reward
    }
    
    // rotate a state
    func rotateBoard() {
        for i in 0..<size/2 {
            for j in i..<size-i-1 {
                let tmp = board[i][j]
                board[i][j] = board[j][size - i - 1]
                board[j][size - i - 1] = board[size - i - 1][size - j - 1]
                board[size - i - 1][size - j - 1] = board[size - j - 1][i]
                board[size - j - 1][i] = tmp
            }
        }
    }
    
    // make a move
    func makeMove(action:Action2048) -> Int {
        var reward = 0
        
        switch(action) {
        case .UP:
            reward = moveUp()
        case .DOWN:
            rotateBoard()
            rotateBoard()
            reward = moveUp()
            rotateBoard()
            rotateBoard()
        case .RIGHT:
            rotateBoard()
            reward = moveUp()
            rotateBoard()
            rotateBoard()
            rotateBoard()
        case .LEFT:
            rotateBoard()
            rotateBoard()
            rotateBoard()
            reward = moveUp()
            rotateBoard()
        }
        
        return reward
        
    }
    
    
    // getPossibleMoves
    func getPossibleMoves() -> Array<Action2048> {
        
        var set:[Bool] = Array(count: 4, repeatedValue: false)
        
        var moves: Array<Action2048> = Array()
        for row in 0..<size {
            for col in 0..<size {
                if (board[row][col] > 0) {
                    continue
                }
                
                if(!set[Action2048.rawValue(Action2048.RIGHT).0] ){
                    for col2 in 0..<col {
                        if(board[row][col2] > 0) {
                            set[Action2048.rawValue(Action2048.RIGHT).0] = true
                            moves.append(Action2048.RIGHT)
                            break
                        }
                    }
                }
                
                
                if(!set[Action2048.rawValue(Action2048.LEFT).0]) {
                    for col2 in (col+1)..<size {
                        if(board[row][col2] > 0) {
                            set[Action2048.rawValue(Action2048.LEFT).0] = true
                            moves.append(Action2048.LEFT)
                            break
                        }
                    }
                }
                
                
                if(!set[Action2048.rawValue(Action2048.DOWN).0]) {
                    for row2 in 0..<row {
                        if(board[row2][col] > 0) {
                            set[Action2048.rawValue(Action2048.DOWN).0] = true
                            moves.append(Action2048.DOWN)
                            break
                        }
                    }
                }
                
                if(!set[Action2048.rawValue(Action2048.UP).0]) {
                    for row2 in (row+1)..<size {
                        if(board[row2][col] > 0) {
                            set[Action2048.rawValue(Action2048.UP).0] = true
                            moves.append(Action2048.UP)
                            break
                        }
                    }
                }
                
                if (moves.count == 4) {
                    return moves
                }
            }
        }
        
        if (!set[Action2048.rawValue(Action2048.RIGHT).0] || !set[Action2048.rawValue(Action2048.LEFT).0]) {
            for row in 0..<size {
                for col in 0..<size-1 {
                    if(board[row][col] > 0 && board[row][col] == board[row][col + 1]) {
                        set[Action2048.rawValue(Action2048.LEFT).0] = true
                        set[Action2048.rawValue(Action2048.RIGHT).0] = true
                        moves.append(Action2048.LEFT)
                        moves.append(Action2048.RIGHT)
                        break
                    }
                }
            }
        }
        
        
        if (!set[Action2048.rawValue(Action2048.DOWN).0] || !set[Action2048.rawValue(Action2048.UP).0]) {
            for col in 0..<size {
                for row in 0..<size-1 {
                    if(board[row][col] > 0 && board[row][col] == board[row+1][col]) {
                        set[Action2048.rawValue(Action2048.UP).0] = true
                        set[Action2048.rawValue(Action2048.DOWN).0] = true
                        moves.append(Action2048.UP)
                        moves.append(Action2048.DOWN)
                        break
                    }
                }
            }
        }
        
        return moves
        
    }
    
    
    private func hasEqualNeighbour(row:Int, col:Int) -> Bool {
        if ((row>0 && board[row-1][col] == board[row][col])
        || (col < size - 1 && board[row][col+1] == board[row][col])
        || (row < size - 1 && board[row + 1][col] == board[row][col])
            || (col > 0 && board[row][col - 1] == board[row][col])) {
                return true
        } else {
            return false
        }
    }
    
    // Determine the terminated state
    func isTerminal() -> Bool {
        for row in 0..<size {
            for col in 0..<size {
                if(board[row][col] == 0) {
                    return false
                }
            }
        }
        
        for row in 0..<size {
            for col in 0..<size {
                if(hasEqualNeighbour(row, col: col)) {
                    return false
                }
            }
        }
        
        return true
    }
    
    // Return the maximum score of current board
    func getMaxTile() -> Int {
        var maxTile:Int = 0
        for row in 0..<size {
            for col in 0..<size {
                if (board[row][col] > maxTile) {
                    maxTile = board[row][col]
                }
            }
        }
        return rewards[maxTile]
    }
    
    // Pretty Print
    func prettyPrint() {
        let DisplayFormat = "05"
        for row in 0..<size {
            for col in 0..<size {
                
                print("\(rewards[board[row][col]].format(DisplayFormat))       ")
            }
            println()
        }
        println()   
    }
    
    // Factory Method Return an initial State
    class func getInitialState(numLocations:Int)->State2048 {
        var state = State2048()
        for i in 0..<numLocations {
            state.addRandomTile()
        }
        return state
    }
    
    class func getInitialState() -> State2048 {
        return State2048.getInitialState(2)
    }
}