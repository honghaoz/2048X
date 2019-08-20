//
//  GameBoard.swift
//  SwiftPractice
//
//  Created by xiaoyong on 15/3/8.
//  Copyright (c) 2015年 xiaoyong. All rights reserved.
//

import Foundation

class GameboardAssistant: CustomStringConvertible {
    private let _goal:Int = 2048
    
    private var _won:Bool = false
    // Size of the board
    private var _size:Int
    // Cells of the board
    private var _cell: [[Int]]
    
    // MARK: public properties
    var size: Int {
        get {
            return _size
        }
    }
    
    var won: Bool {
        get {
            return _won
        }
    }
    
    var cell: [[Int]] {
        get {
            return _cell
        }
    }
    
    /// The max value of the game board
    var max: Int {
        get {
            var maxVal: Int = Int.min
            for i in 0..<_size {
                for j in 0..<_size {
                    if _cell[i][j] > maxVal {
                        maxVal = _cell[i][j]
                    }
                }
            }
            return maxVal
        }
    }
    
    // MARK: Printable
    var description: String {
        var board:String = String()
        for i in 0..<_size {
            for j in 0..<_size {
                board += String(format: "%d\t", _cell[i][j])
            }
            board += "\n"
        }
        
        return board
    }
    
    subscript(x: Int, y: Int) -> Int {
        return _cell[y][x]
    }
    
    // MARK: Initializer
    init(size: Int = 4, won: Bool = false) {
        // Initialize the game board and add two new tiles
        _cell = [[Int]](count: size, repeatedValue: [Int](count: size, repeatedValue: 0))
        _size = size
        _won = won
        addNewTile()
        addNewTile()
    }
    
    init(cells: [[Int]], won: Bool = false) {
        // Initialize the game board with a given board state
        _cell = cells
        _size = _cell[0].count
        _won = won
    }
    
    // MARK: Deep copy
    func copy() -> GameboardAssistant {
        return GameboardAssistant(cells: _cell)
    }
    
    /// Get the location of all empty cells
    func getAllEmptyCells() -> [(x: Int, y: Int)] {
        var emptyCells: [(x: Int, y: Int)] = []
        for i in 0..<_size {
            for j in 0..<_size {
                if _cell[j][i] == 0 {
                    emptyCells.append(x: i, y: j)
                }
            }
        }
        
        return emptyCells
    }
    
    // MARK: Public methods
    /// Test if a move to certain directino is valid
    func isMoveValid(_ dir: MoveDirection) -> Bool {
        for i in 0..<_size {
            for j in 0..<_size {
                switch dir {
                case .up:
                    if j > 0 && (_cell[j][i] == _cell[j - 1][i] && _cell[j][i] != 0 || _cell[j][i] != 0 && _cell[j - 1][i] == 0) {
                        return true
                    }
                case .down:
                    if j < _size - 1 && (_cell[j][i] == _cell[j + 1][i] && _cell[j][i] != 0 || _cell[j][i] != 0 && _cell[j + 1][i] == 0) {
                        return true
                    }
                case .left:
                    if i > 0 && (_cell[j][i] == _cell[j][i - 1] && _cell[j][i] != 0 || _cell[j][i] != 0 && _cell[j][i - 1] == 0) {
                        return true
                    }
                case .right:
                    if i < _size - 1 && (_cell[j][i] == _cell[j][i + 1] && _cell[j][i] != 0 || _cell[j][i] != 0 && _cell[j][i + 1] == 0) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /// Make a move in certain direction, the precondition must be met that the move to this direction is valid.
    /// Return the score of such move
    func makeMove(_ dir: MoveDirection, toAddNewTile: Bool = true) -> Int {
        var hasMoved = false
        var score: Int = 0
        
//        var setFun = dir == .up || dir == .down ? setRow : setCol
//        var getFun = dir == .up || dir == .down ? getRow : getRow
		
        // Move col
        if dir == .left || dir == .right {
            for j in 0..<_size {
                var oriRow = getRow(j)
                moveRowToDirection(&oriRow, dir: dir)
                let points = mergeRow(&oriRow, dir: dir)
                moveRowToDirection(&oriRow, dir: dir)
                setRow(j, vals: oriRow, moved: &hasMoved)
                score += points
            }
        }
        // Move row
        else {
            for i in 0..<_size {
                var oriCol = getCol(i)
                moveColToDirection(&oriCol, dir: dir)
                let points = mergeCol(&oriCol, dir: dir)
                moveColToDirection(&oriCol, dir: dir)
                setCol(i, vals: oriCol, moved: &hasMoved)
                score += points
            }
        }
        
        if hasMoved && toAddNewTile {
            addNewTile()
        }
        
        return score
    }
    
    /// Assign a value to a specific cell
    func setCell(_ x: Int, y: Int, val: Int) {
        _cell[y][x] = val
    }
    
    // MARK: Private methods
    /// Randomly assign a value to an empty cell
    private func addNewTile(_ valueSpecified: Int = 2) {
        var newTiles: [Int] = [Int](count: 10, repeatedValue: valueSpecified)
        // If the tile value is not specified, then give a array of choices consisted of [2,2,2,2,2,2,2,2,2,4]
        if valueSpecified == 2 {
            newTiles[9] = 4
        }
        
        // Get a random choice
        let randomChoice = newTiles[Int(arc4random_uniform(10))]
        var emptyCells = getAllEmptyCells()
        // If there exists some empty cell(s)
        if emptyCells.count != 0 {
            let randomCellLoc = emptyCells[Int(arc4random_uniform(UInt32(emptyCells.count)))]
            setCell(randomCellLoc.x, y: randomCellLoc.y, val: randomChoice)
        }
    }
    
    /// See if every cell has a value
    private func allCellFull() -> Bool {
        return getAllEmptyCells().count == 0;
    }
    
    /// Get a copy of certain row
    private func getRow(_ x: Int) -> [Int] {
        return _cell[x]
    }
    
    /// Get a copy of certain col
    private func getCol(_ y: Int) -> [Int] {
        var col = [Int](count: _size, repeatedValue: -1)
        for i in 0..<_size {
            col[i] = _cell[i][y]
        }
        
        return col
    }
    
    /// Assign values to an entire row
    private func setRow(_ row: Int, vals: [Int], moved: inout Bool) {
        for i in 0..<vals.count {
            if _cell[row][i] != vals[i] {
                moved = true
            }
            _cell[row][i] = vals[i]
        }
    }
    
    /// Assign values to an entire col
    private func setCol(_ col: Int, vals: [Int], moved: inout Bool) {
        for i in 0..<vals.count {
            if _cell[i][col] != vals[i] {
                moved = true
            }
            _cell[i][col] = vals[i]
        }
    }
    
    /// Merge row
    private func mergeRow(_ row: inout [Int], dir: MoveDirection) -> Int {
        assert(dir == .left || dir == .right, "The direction is not valid!")
        
        var points: Int = 0
        var offset = 0
        var range: [Int]? = nil
        
        if dir == .left {
            range = (0..._size - 2).map{$0}
            offset = 1
        }
        else {
            range = Array((1..._size - 1).map{$0}.reverse())
            offset = -1
        }

        for j in range! {
            if row[j] == 0 {
                continue
            }
            if row[j] == row[j + offset] {
                points += row[j] * 2
                row[j] = row[j] * 2
                row[j + offset] = 0
                // Has reached the goal, win
                if row[j] == _goal {
                    _won = true
                }
            }

        }
        
        return points
    }
    
    /// Merge col
    private func mergeCol(_ col: inout [Int], dir: MoveDirection) -> Int {
        assert(dir == .up || dir == .down, "The direction is not valid!")
        
        var points: Int = 0
        var offset = 0
        var range: [Int]? = nil
        
        if dir == .up {
            range = (0..._size - 2).map{$0}
            offset = 1
        }
        else {
            range = Array((1..._size - 1).map{$0}.reverse())
            offset = -1
        }

        for i in range! {
            if col[i] == 0 {
                continue
            }
            if col[i] == col[i + offset] {
                points += col[i] * 2
                col[i] = col[i] * 2
                col[i + offset] = 0
                if col[i] == _goal {
                    _won = true
                }
            }
        }
        
        return points
    }
    
    /// Move a row to a certain direction
    private func moveColToDirection(_ col: inout [Int], dir: MoveDirection) {
        assert(dir == .up || dir == .down, "The direction is not valid!")
        col = col.filter({element -> Bool in element != 0})
        if dir == .up {
            col += [Int](count: _size - col.count, repeatedValue: 0)
        }
        else {
            col = [Int](count: _size - col.count, repeatedValue: 0) + col
        }
    }
    
    /// Move a col to a certain direction
    private func moveRowToDirection(_ row: inout [Int], dir: MoveDirection) {
        assert(dir == .left || dir == .right, "The direction is not valid!")
        row = row.filter({element -> Bool in element != 0})
        if dir == .left {
            row += [Int](count: _size - row.count, repeatedValue: 0)
        }
        else {
            row = [Int](count: _size - row.count, repeatedValue: 0) + row
        }
    }
}
