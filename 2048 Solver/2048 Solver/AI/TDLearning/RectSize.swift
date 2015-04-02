//
//  RectSize.swift
//  2048game
//
//  Created by yansong li on 2015-03-26.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation



struct RectSize :Equatable{
    let columns:Int
    let rows:Int
    
    var width:Int {
        get{
            return columns
        }
    }
    
    var height:Int {
        get{
            return rows
        }
    }
    
    init(rows:Int, cols:Int) {
        self.rows = rows
        self.columns = cols
    }
    
    init(size:Int) {
        self.init(rows:size, cols:size)
    }
    
    func contains(position: BoardPos) -> Bool {
        return 0 <= position.row() && position.row() < height && 0 <= position.column() && position.column() < width
    }
    
}

func == (lhs: RectSize, rhs:RectSize) -> Bool {
    if (lhs.columns == rhs.columns && lhs.rows == rhs.rows) {
        return true
    }
    return false
}
