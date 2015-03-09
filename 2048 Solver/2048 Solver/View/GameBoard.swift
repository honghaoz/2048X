//
//  GameBoard.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class GameBoard: UIView {
    var dimension: Int = 4
    var width: CGFloat = UIScreen.mainScreen().bounds.width * 0.9 {
        didSet {
            self.bounds = CGRectMake(0, 0, width, width)
        }
    }
    
    var padding: CGFloat = 8.0
    var tilePadding: CGFloat = 3.0
    var tileWidth: CGFloat {
        return (width - padding * 2 - tilePadding * (CGFloat(dimension) - 1)) / CGFloat(dimension)
    }
    
    // MARK:- Init Methods
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
//    init(width: CGFloat, dimension: Int) {
//        self.width = width
//        self.dimension = dimension
//        super.init(frame: CGRectMake(frame.origin.x, frame.origin.y, width, width))
//    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(frame.origin.x, frame.origin.y, width, width))
        setupViews()
    }
    
    private func setupViews() {
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 5.0
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        // Layout tiles
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                x = padding
                x += (tilePadding + tileWidth) * CGFloat(i)
                
                y = padding
                y += (tilePadding + tileWidth) * CGFloat(j)
                
                let frame = CGRectMake(x, y, tileWidth, tileWidth)
                let tile = Tile(frame: frame)
                self.addSubview(tile)
                
                tile.number = (i + 1) * (j + 1) * 98
            }
        }
    }
}
