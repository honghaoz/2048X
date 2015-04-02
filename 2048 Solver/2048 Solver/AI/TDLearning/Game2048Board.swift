//
//  Game2048Board.swift
//  2048game
//
//  Created by yansong li on 2015-03-27.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation

class BoardUtils {
    
    struct METRICS {
        static var MARGIN_WIDTH = 1
        static var TOTAL_MARGIN = 2 * MARGIN_WIDTH
    }
    
    /*
    * Returned position is margin-based
    */
    class func toMarginPos(boardSize: RectSize, pos: BoardPos)->Int {
        return (pos.row() + 1) * (boardSize.width + METRICS.TOTAL_MARGIN) + pos.column() + 1
    }
    
    
    class func toMarginPos(boardWidth:Int, row:Int, col:Int) -> Int {
        return toMarginPos(RectSize(size: boardWidth), pos: BoardPos(row: row, col: col))
    }
    
    class func isValidPosition(pos:Int, boardSize:Int) -> Bool {
        return isValidPosition(pos, rows: boardSize, cols: boardSize)
    }
    
    class func isValidPosition(pos:Int, rows:Int, cols:Int) -> Bool {
        var row = rowFromPos(pos, boardWidth: cols)
        var col = colFromPos(pos, boardWidth: cols)
        return 0 <= row && row < rows && 0 <= col && col < cols
    }
    
    class func rowFromPos(pos:Int, boardWidth:Int) -> Int {
        return pos / (boardWidth + METRICS.TOTAL_MARGIN) - 1
    }
    
    class func colFromPos(pos:Int, boardWidth:Int) -> Int {
        return pos % (boardWidth + METRICS.TOTAL_MARGIN) - 1
    }
}

func == (lhs: Game2048Board, rhs:Game2048Board) -> Bool {
    
    if (lhs.buffer.count != rhs.buffer.count) {
        return false
    }
    
    for i in 0..<lhs.buffer.count {
        if (lhs.buffer[i] != rhs.buffer[i]) {
            return false
        }
    }
    return true
}

class Game2048Board:Equatable {
    var SIZE:Int = 4
    var MARGIN_WIDTH = BoardUtils.METRICS.MARGIN_WIDTH
    var WIDTH:Int
    var BUFFER_SIZE:Int
    var WALL = -2
    
    var buffer:[Int]
    
    
    init() {
        WIDTH = SIZE + 2 * MARGIN_WIDTH
        BUFFER_SIZE = WIDTH * WIDTH
        self.buffer = Array(count: BUFFER_SIZE, repeatedValue: 0)
    }
    
    convenience init(input:[Double]) {
        self.init()
        initMargins()
        for r in 0..<SIZE {
            for c in 0..<SIZE {
                setValue(r, col: c, color:inputToBoardValue(input, r: r, c: c))
            }
        }
    }
    
    
    convenience init(buffer:[Int]) {
        self.init()
        self.buffer = buffer
    }
    
    private func inputToBoardValue(input:[Double], r:Int, c:Int)->Int {
        return Int(input[r*SIZE + c] + 0.5)
    }
    
    private func initMargins() {
        for i in 0..<WIDTH {
            setValueInternal(0, col: i, color: WALL)
            setValueInternal(WIDTH-1, col: i, color: WALL)
            setValueInternal(i, col: 0, color: WALL)
            setValueInternal(i, col: WIDTH-1, color: WALL)
        }
    }
    
    func toPos(row:Int, col:Int)->Int {
        return (row+1) * WIDTH + col + 1
    }
    
    private func toPosInternal(row:Int, col:Int) -> Int {
        return row * WIDTH + col
    }
    
    func setValue(row:Int, col:Int, color:Int) {
        buffer[toPos(row,col:col)] = color
    }
    
    private func setValueInternal(row:Int, col:Int, color:Int){
        buffer[toPosInternal(row, col:col)] = color
    }
    
    func getValue(row:Int, col:Int)->Int{
        return buffer[toPos(row, col: col)]
    }
    
    func getValue(pos:Int) -> Int{
        return buffer[pos]
    }
    
    func getSize()-> Int {
        return SIZE
    }
    
    func toString()->String {
        var stringBoard = "\n"
        for r in 0..<getSize() {
            stringBoard += String(r+1)
            stringBoard += " "
            
            for c in 0..<getSize() {
                stringBoard += String(getValue(r,col:c))
            }
            
            stringBoard += "\n"
        }
        return stringBoard
    }
    
    
    func getWidth()->Int {
        return getSize()
    }
    
    func getHeight()->Int {
        return getSize()
    }
    
    func clone() -> Game2048Board {
        return Game2048Board(buffer: self.buffer)
    }
}