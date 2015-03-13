//
//  GameBoard.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import QuartzCore

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
    
//    override var backgroundColor: UIColor? {
//        didSet {
//            for i in 0 ..< dimension {
//                for j in 0 ..< dimension {
//                    if let tile = forgroundTiles[i][j].0 {
//                        tile.backgroundColor = backgroundColor
//                    }
//                }
//            }
//        }
//    }
    
    var backgroundTiles = [[TileView]]()
    
    // Reason to store (TileView?, TileView?):
    // For animation convenience. When merging two tiles are followed by a condense action, both two tiles' frame need to be updated. Thus, the tuple.1 will store the tile underneath and provide the tile view
    var forgroundTiles = [[(TileView?, TileView?)]]()
    
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
//                tile.borderColor = UIColor(white: 0.0, alpha: 0.15)
                tile.number = 0
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
            var tiles = [(TileView?, TileView?)]()
            for j in 0 ..< dimension {
                tiles.append((nil, nil))
            }
            forgroundTiles.append(tiles)
        }
    }
    
    private func updateForgroundTileViews() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        // Layout tiles
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if let tile = forgroundTiles[i][j].0 {
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
    
    func updateWithMoveActions(moveActions: [MoveAction], initActions: [InitAction]) {
        updateWithMoveActions(moveActions, completion: {
            self.updateWithInitActions(initActions)
        })
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
            
            forgroundTiles[coordinate.0][coordinate.1].0 = tile
            self.addSubview(tile)
            
            // Blink pattern: 0 -> 1 -> 0 -> 1
            tile.alpha = 0.0
            UIView.animateWithDuration(sharedAnimationDuration * 2, animations: { () -> Void in
                tile.alpha = 1.0
                }, completion: { (finished) -> Void in
//                    UIView.animateWithDuration(sharedAnimationDuration, animations: { () -> Void in
//                        tile.alpha = 0.0
//                        }, completion: { (finished) -> Void in
//                            UIView.animateWithDuration(sharedAnimationDuration, animations: { () -> Void in
//                                tile.alpha = 1.0
//                                }, completion: { (finished) -> Void in
//                                    //
//                            })
//                    })
            })
        }
    }
    
    func updateWithMoveActions(moveActions: [MoveAction], completion: (() -> ())? = nil) {
        let count = moveActions.count
        // If there's no MoveActions, execute completion closure
        if count == 0 {
            completion?()
            return
        }
        
        gameModel.printOutMoveActions(moveActions)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        let tileWidth = self.tileWidth
        
        for (index, action) in enumerate(moveActions) {
            if action.fromCoordinates.count == 1 {
                // Move Action
                let from = action.fromCoordinates[0]
                let to = action.toCoordinate
                
                let fromView = forgroundTiles[from.0][from.1].0!
                // There may exist an underneath tile
                let fromUnderneath = forgroundTiles[from.0][from.1].1
                
                forgroundTiles[to.0][to.1] = forgroundTiles[from.0][from.1]
                forgroundTiles[from.0][from.1] = (nil, nil)
                
                y = padding + (tilePadding + tileWidth) * CGFloat(to.0)
                x = padding + (tilePadding + tileWidth) * CGFloat(to.1)
                
                UIView.animateWithDuration(sharedAnimationDuration, animations: { () -> Void in
                    fromView.frame = CGRectMake(x, y, tileWidth, tileWidth)
                    fromUnderneath?.frame = CGRectMake(x, y, tileWidth, tileWidth)
                    }, completion: { (finished) -> Void in
                        if index == count - 1 {
                            completion?()
                        }
                })
            } else {
                // Merge Action
                let from1 = action.fromCoordinates[0]
                let from2 = action.fromCoordinates[1]
                let to = action.toCoordinate
                
                y = padding + (tilePadding + tileWidth) * CGFloat(to.0)
                x = padding + (tilePadding + tileWidth) * CGFloat(to.1)
                
                self.insertSubview(forgroundTiles[from1.0][from1.1].0!, belowSubview: forgroundTiles[from2.0][from2.1].0!)
                
                let fromTileView = forgroundTiles[from1.0][from1.1].0!
                let toTileView = self.forgroundTiles[to.0][to.1].0!
                
                forgroundTiles[from1.0][from1.1] = (nil, nil)
                
                // Put fromTileView underneath toTileView
                forgroundTiles[to.0][to.1] = (toTileView, fromTileView)
                
                UIView.animateWithDuration(sharedAnimationDuration, animations: { () -> Void in
                    fromTileView.frame = CGRectMake(x, y, tileWidth, tileWidth)
                    }, completion: { (finished) -> Void in
                        fromTileView.removeFromSuperview()
                        toTileView.number *= 2
                        toTileView.flashTile()
                                                
                        if index == count - 1 {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                Int64(sharedAnimationDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                                    completion?()

                            })
                        }
                })
            }
        }
    }
}
