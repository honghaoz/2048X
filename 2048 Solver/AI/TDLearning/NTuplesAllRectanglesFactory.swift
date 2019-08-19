//
//  NTuplesAllRectanglesFactory.swift
//  2048 Solver
//
//  Created by yansong li on 2015-04-01.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class NTuplesAllRectanglesFactory {
    private var genericFactory: NTuplesGenericFactory
    
    init(rectSize:RectSize, boardSize: RectSize, numValue:Int, minWeight:Double, maxWeight: Double) {
        var pos1 = Array<BoardPos>()
        var pos2 = Array<BoardPos>()
        
        for r in 0..<rectSize.rows {
            for c in 0..<rectSize.columns {
                pos1.append(BoardPos(row: r, col: c))
                pos2.append(BoardPos(row:c, col:r))
            }
        }
        var list = Array<BoardPosList>()
        list.append(BoardPosList(positions: pos1))
        list.append(BoardPosList(positions: pos2))
        genericFactory = NTuplesGenericFactory(positionsList: list, boardSize: boardSize, numValues: numValue, minWeight: minWeight, maxWeight: maxWeight)
    }
    
    func createRandomIndividual()->NTuples {
        return genericFactory.createRandomIndividual()
    }
}