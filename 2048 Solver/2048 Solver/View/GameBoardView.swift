//
//  GameBoard.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class GameBoardView: UIView {
    var dimension: Int = 4
    var width: CGFloat = UIScreen.mainScreen().bounds.width * 0.9 {
        didSet {
            self.bounds = CGRectMake(0, 0, width, width)
            self.updateBackgroundTileViews()
            self.updateForgroundTileViews()
        }
    }
    
    var padding: CGFloat = 8.0
    var tilePadding: CGFloat = 3.0
    var tileWidth: CGFloat {
        return (width - padding * 2 - tilePadding * (CGFloat(dimension) - 1)) / CGFloat(dimension)
    }
    
    var backgroundTiles = [[TileView]]()
    var forgroundTiles = [[TileView?]]()
    
    var gameModel: Game2048!
    
    // MARK:- Init Methods
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(frame.origin.x, frame.origin.y, width, width))
        setupViews()
    }
    
    init(width: CGFloat, dimension: Int) {
        super.init(frame: CGRectMake(0, 0, width, width))
        self.width = width
        self.dimension = dimension
        setupViews()
    }
    
    private func setupViews() {
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 5.0
        setupBackgroundTileViews()
        setupForgroundTileViews()
    }
    
    private func setupBackgroundTileViews() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        // Layout tiles
        for i in 0 ..< dimension {
            var tiles = [TileView]()
            for j in 0 ..< dimension {
                y = padding
                y += (tilePadding + tileWidth) * CGFloat(i)
                
                x = padding
                x += (tilePadding + tileWidth) * CGFloat(j)
                
                let frame = CGRectMake(x, y, tileWidth, tileWidth)
                let tile = TileView(frame: frame)
                tile.borderColor = UIColor(white: 0.0, alpha: 0.2)
                self.addSubview(tile)
                tiles.append(tile)
            }
            backgroundTiles.append(tiles)
        }
    }
    
    private func updateBackgroundTileViews() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        // Layout tiles
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                y = padding
                y += (tilePadding + tileWidth) * CGFloat(i)
                
                x = padding
                x += (tilePadding + tileWidth) * CGFloat(j)
                
                let frame = CGRectMake(x, y, tileWidth, tileWidth)

                let tile = backgroundTiles[i][j]
                tile.frame = frame
            }
        }
    }
    
    private func setupForgroundTileViews() {
        for i in 0 ..< dimension {
            var tiles = [TileView?]()
            for j in 0 ..< dimension {
                tiles.append(nil)
            }
            forgroundTiles.append(tiles)
        }

//        var x: CGFloat = 0
//        var y: CGFloat = 0
//        let tileWidth = self.tileWidth
//
//        // Layout tiles
//        for i in 0 ..< dimension {
//            var tiles = [TileView]()
//            for j in 0 ..< dimension {
//                y = padding
//                y += (tilePadding + tileWidth) * CGFloat(i)
//                
//                x = padding
//                x += (tilePadding + tileWidth) * CGFloat(j)
//                
//                let frame = CGRectMake(x, y, tileWidth, tileWidth)
//                let tile = TileView(frame: frame)
//                tile.number = 0
//                self.addSubview(tile)
//                tiles.append(tile)
//            }
//            forgroundTiles.append(tiles)
//        }
    }
    
    private func updateForgroundTileViews() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        // Layout tiles
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if let tile = forgroundTiles[i][j] {
                    y = padding
                    y += (tilePadding + tileWidth) * CGFloat(i)
                    
                    x = padding
                    x += (tilePadding + tileWidth) * CGFloat(j)
                    
                    let frame = CGRectMake(x, y, tileWidth, tileWidth)
                    tile.frame = frame
                }
            }
        }
    }
    
//    func updateTiles() {
//        for i in 0 ..< dimension {
//            for j in 0 ..< dimension {
//                if let tile = forgroundTiles[i][j] {
//                    switch gameModel.gameBoard[i, j].memory {
//                    case .Empty:
//                        tile.number = 0
//                    case let .Number(tileNumber):
//                        tile.number = tileNumber
//                    }
//                }
//            }
//        }
//    }
    
    func updateWithMoveActions(moveActions: [MoveAction], initActions: [InitAction]) {
        updateWithMoveActions(moveActions)
        updateWithInitActions(initActions)
    }
    
    func updateWithInitActions(initActions: [InitAction]) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        for action in initActions {
            let coordinate = action.initCoordinate
            let number = action.initNumber
            
            y = padding
            y += (tilePadding + tileWidth) * CGFloat(coordinate.0)
            
            x = padding
            x += (tilePadding + tileWidth) * CGFloat(coordinate.1)
            
            let frame = CGRectMake(x, y, tileWidth, tileWidth)
            let tile = TileView(frame: frame)
            tile.number = number
            
            forgroundTiles[coordinate.0][coordinate.1] = tile
            self.addSubview(tile)
            
            UIView.animateWithDuration(0.15, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.Autoreverse | UIViewAnimationOptions.Repeat, animations: { () -> Void in
                UIView.setAnimationRepeatCount(2)
                tile.alpha = 0.0
                }, completion: { (finish) -> Void in
                    tile.alpha = 1.0
            })
        }
    }
    
    func updateWithMoveActions(moveActions: [MoveAction]) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        gameModel.printOutMoveActions(moveActions)
        
        for action in moveActions {
            if action.fromCoordinates.count == 1 {
                // Move Action
                let from = action.fromCoordinates[0]
                let to = action.toCoordinate
                
                forgroundTiles[to.0][to.1] = forgroundTiles[from.0][from.1]
                forgroundTiles[from.0][from.1] = nil
                
                y = padding + (tilePadding + tileWidth) * CGFloat(to.0)
                x = padding + (tilePadding + tileWidth) * CGFloat(to.1)
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.forgroundTiles[to.0][to.1]!.frame = CGRectMake(x, y, tileWidth, tileWidth)
                    }, completion: { (finished) -> Void in
                    //
                })
            } else {
                // Merge Action
                let from1 = action.fromCoordinates[0]
                let from2 = action.fromCoordinates[1]
                let to = action.toCoordinate
                
                y = padding + (tilePadding + tileWidth) * CGFloat(to.0)
                x = padding + (tilePadding + tileWidth) * CGFloat(to.1)
                
                self.insertSubview(forgroundTiles[from1.0][from1.1]!, belowSubview: forgroundTiles[from2.0][from2.1]!)
                
                let fromTileView = self.forgroundTiles[from1.0][from1.1]!
                self.forgroundTiles[from1.0][from1.1] = nil
                let toTileView = self.forgroundTiles[to.0][to.1]!
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    fromTileView.frame = CGRectMake(x, y, tileWidth, tileWidth)
                    }, completion: { (finished) -> Void in
                        fromTileView.removeFromSuperview()
                        toTileView.number *= 2
                })
            }
        }
    }
}
