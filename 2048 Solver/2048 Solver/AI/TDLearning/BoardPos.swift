//
//  BoardPos.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
func == (lhs:BoardPos, rhs:BoardPos) -> Bool {
    return lhs._row == rhs._row && lhs._column == rhs._column
}

class BoardPos : Equatable{
    private var _row: Int
    private var _column: Int
    
    init(row:Int, col:Int) {
        _row = row
        _column = col
    }
    
    func row() -> Int {
        return _row
    }
    
    func column() -> Int {
        return _column
    }
    
    // add two BoardPos
    func add(pos:BoardPos) -> BoardPos {
        return BoardPos(row: self._row + pos._row, col: self._column + pos._column)
    }
    
}