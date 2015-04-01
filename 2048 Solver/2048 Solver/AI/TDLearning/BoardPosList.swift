//
//  BoardPosList.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class BoardPosList {
    private var positions:Array<BoardPos>
    
    init(positions:Array<BoardPos>){
        self.positions = positions
    }
    
    func getAligned() -> BoardPosList {
        var minPos = getMinCorner()
        return getShifted(-minPos.row(), shiftColumn: -minPos.column())
    }
    
    func getShifted(shiftRow:Int, shiftColumn:Int) -> BoardPosList {
        var shifted = Array(count: positions.count, repeatedValue: BoardPos(row: 0, col: 0))
        for i in 0..<positions.count {
            shifted[i] = positions[i].add(BoardPos(row: shiftRow, col: shiftColumn))
        }
        return BoardPosList(positions: shifted)
    }
    
    private func getMinCorner() -> BoardPos {
        var minRow = positions[0].row()
        var minCol = positions[0].column()
        for pos in positions {
            if pos.row() < minRow {
                minRow = pos.row()
            }
            
            if pos.column() < minCol {
                minCol = pos.column()
            }
        }
        return BoardPos(row: minRow, col: minCol)
    }
    
    
    func toLocations(boardSize:RectSize) -> [Int] {
        var locations = Array(count: positions.count, repeatedValue: 0)
        for i in 0..<positions.count {
            locations[i] = BoardUtils.toMarginPos(boardSize, pos: positions[i])
        }
        return locations
    }
    
    func fitOnBoard(boardSize: RectSize) -> Bool {
        for pos in positions {
            if (!boardSize.contains(pos)) {
                return false
            }
        }
        return true
    }
    
    func size() -> Int {
        return positions.count
    }
}