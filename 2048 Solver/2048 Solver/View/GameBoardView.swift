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
    
    /// GameModel dimension
    var dimension: Int { return gameModel.dimension }
    
    /// padding: paddings around the board view
    var padding: CGFloat = 8.0 { didSet { updateTileWidth() } }
    /// paddings betwwen tiles
    var tilePadding: CGFloat = 3.0 { didSet { updateTileWidth() } }
    
    // TileWidth is updated automatically
    var tileWidth: CGFloat = 0.0
    
    /// Background tiles provide a grid like background layout
    var backgroundTiles = [[TileView]]()
    
    // Reason to use (TileView?, TileView?):
    // For animation convenience. When merging two tiles are followed by a condense action, both two tiles' frame need to be updated. Thus, the tuple.1 will store the tile underneath and provide the tile view
    var forgroundTiles = [[(TileView?, TileView?)]]()
    
    /// GameModel for GameBoardView
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
        super.init(frame: frame)
        setupViews()
    }
    
    override var bounds: CGRect {
        didSet {
            // If views are not set up, set up first then update
            if backgroundTiles.count == 0 {
                setupBackgroundTileViews()
                setupForgroundTileViews()
            }
            // If bounds changed, update tile views
            updateTileWidth()
            updateBackgroundTileViews()
            updateForgroundTileViews()
        }
    }
    
    private func setupViews() {
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 5.0
    }
    
    private func setupBackgroundTileViews() {
        precondition(gameModel != nil, "GameModel must not be nil")
        // Remove old ones
        backgroundTiles.map{ $0.map { $0.removeFromSuperview() }}
        // Layout tiles
        for i in 0 ..< dimension {
            var tiles = [TileView]()
            for j in 0 ..< dimension {
                let tile = TileView(frame: tileFrameForCoordinate((i, j)))
                tile.number = 0
                self.addSubview(tile)
                tiles.append(tile)
            }
            backgroundTiles.append(tiles)
        }
    }
    
    private func setupForgroundTileViews() {
        precondition(gameModel != nil, "GameModel must not be nil")
        forgroundTiles.map { $0.map { $0.0?.removeFromSuperview() } }
        forgroundTiles.map { $0.map { $0.1?.removeFromSuperview() } }
        
        for i in 0 ..< dimension {
            var tiles = [(TileView?, TileView?)]()
            for j in 0 ..< dimension {
                tiles.append((nil, nil))
            }
            forgroundTiles.append(tiles)
        }
    }
    
    private func updateBackgroundTileViews() {
        precondition(gameModel != nil, "GameModel must not be nil")
        // Update background tiles' frame
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                backgroundTiles[i][j].frame = tileFrameForCoordinate((i, j))
            }
        }
    }
    
    private func updateForgroundTileViews() {
        precondition(gameModel != nil, "GameModel must not be nil")
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if let tile = forgroundTiles[i][j].0 {
                    tile.frame = tileFrameForCoordinate((i, j))
                }
            }
        }
    }
}

// MARK: Update View Actions
extension GameBoardView {
    
    func removeWithRemoveActions(removeActions: [RemoveAction], completion: (() -> ())? = nil) {
        logDebug("removeWithRemoveActions: ")
        GameModelHelper.printOutGameBoard(self.currentDisplayingGameBoard())
        let count = removeActions.count
        for (index, action) in enumerate(removeActions) {
            let i = action.removeCoordinate.0
            let j = action.removeCoordinate.1
            
            logDebug("Removed: (\(i), \(j))")
            let tile = forgroundTiles[i][j].0!
            let underneathTile = forgroundTiles[i][j].1
            self.forgroundTiles[i][j] = (nil, nil)
            // Animation
            UIView.animateWithDuration(sharedAnimationDuration * 2,
                animations: { () -> Void in
                    tile.alpha = 0.0
                    underneathTile?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    tile.removeFromSuperview()
                    underneathTile?.removeFromSuperview()
                    
                    // If this is the very last actions, call completion block
                    if index == count - 1 {
                        logDebug("after removeWithRemoveActions: ")
                        GameModelHelper.printOutGameBoard(self.currentDisplayingGameBoard())
                        completion?()
                    }
            })
        }
    }
    
    /**
    When game model is updated, view controller should call this method and passed in corresponding MoveActions and InitActions
    Note: this method will update MoveActions first and then InitActions
    
    :param: moveActions a list of actions which specify how tiles are merged or moved
    :param: initActions a list of actions which specify how new tiles are inserted
    */
    func updateWithMoveActions(moveActions: [MoveAction], initActions: [InitAction], completion: (() -> ())? = nil) {
        updateWithMoveActions(moveActions, completion: {
            self.updateWithInitActions(initActions, completion: {
                completion?()
            })
        })
    }
    
    /**
    Insert new tile views using InitActions
    
    :param: initActions a list of actions which specify how new tiles are inserted
    */
    private func updateWithInitActions(initActions: [InitAction], completion: (() -> ())? = nil) {
        logDebug("updateWithInitActions: ")
        GameModelHelper.printOutGameBoard(self.currentDisplayingGameBoard())
        let count = initActions.count
        if count == 0 {
            completion?()
            return
        }
        
        for (index, action) in enumerate(initActions) {
            let initCoordinate = action.initCoordinate
            let number = action.initNumber
            
            logDebug("Init: \(initCoordinate), \(number)")
            let tile = TileView(frame: tileFrameForCoordinate(initCoordinate))
            tile.number = number
            
            // Store new tile views
            forgroundTiles[initCoordinate.0][initCoordinate.1].0 = tile
            self.addSubview(tile)
            
            // Blink pattern: 0 -> 1
            tile.alpha = 0.0
            UIView.animateWithDuration(sharedAnimationDuration * 2,
                animations: { () -> Void in
                    tile.alpha = 1.0
                },
                completion: { (finished) -> Void in
                    // If this is the very last actions, call completion block
                    if index == count - 1 {
                        completion?()
                    }
            })
        }
    }
    
    /**
    Move or merge tile views using MoveActions
    
    :param: moveActions a list of actions which specify how tiles are merged or moved
    :param: completion  an optional completion clousure, which will be called once all move actions are done
    */
    private func updateWithMoveActions(moveActions: [MoveAction], completion: (() -> ())? = nil) {
        logDebug("updateWithMoveActions: ")
        GameModelHelper.printOutGameBoard(self.currentDisplayingGameBoard())
        
        let count = moveActions.count
        // If there's no MoveActions, execute completion closure
        if count == 0 {
            completion?()
            return
        }
        
        for (index, action) in enumerate(moveActions) {
            if action.fromCoordinates.count == 1 {
                // Move Action
                let from = action.fromCoordinates[0]
                let to = action.toCoordinate
                
                logDebug("Move: from: \(from) -> to: \(to)")
                
                let fromView = forgroundTiles[from.0][from.1].0!
                // There may exist an underneath tile
                let fromUnderneath = forgroundTiles[from.0][from.1].1
                
                // Set from tile to to tile and clean from tile
                forgroundTiles[to.0][to.1] = forgroundTiles[from.0][from.1]
                forgroundTiles[from.0][from.1] = (nil, nil)
                
                // Animation
                UIView.animateWithDuration(sharedAnimationDuration,
                    animations: { () -> Void in
                        fromView.frame = self.tileFrameForCoordinate(to)
                        fromUnderneath?.frame = fromView.frame
                    }, completion: { (finished) -> Void in
                        // If this is the very last actions, call completion block
                        if index == count - 1 {
                            completion?()
                        }
                })
            } else {
                // Merge Action
                let from1 = action.fromCoordinates[0]
                let from2 = action.fromCoordinates[1]
                let to = action.toCoordinate
                
                logDebug("Move: from1: \(from1) + from2: \(from2) -> to: \(to)")
                
                // Make sure the inserting tile are under the inserted tile
                self.insertSubview(forgroundTiles[from1.0][from1.1].0!, belowSubview: forgroundTiles[from2.0][from2.1].0!)
                
                let fromTileView = forgroundTiles[from1.0][from1.1].0!
                let toTileView = self.forgroundTiles[to.0][to.1].0!
                
                forgroundTiles[from1.0][from1.1] = (nil, nil)
                
                // Put fromTileView underneath toTileView
                forgroundTiles[to.0][to.1] = (toTileView, fromTileView)
                
                UIView.animateWithDuration(sharedAnimationDuration,
                    animations: { () -> Void in
                        fromTileView.frame = self.tileFrameForCoordinate(to)
                    }, completion: { (finished) -> Void in
                        fromTileView.removeFromSuperview()
                        
                        // Double tile number and animate this tile
                        toTileView.number *= 2
                        toTileView.flashTile()
                        
                        // If this is the very last actions, call completion block
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

// MARK: Property helpers
extension GameBoardView {
    /**
    Update tileWidth when related properties are modified
    */
    func updateTileWidth() {
        tileWidth = (self.bounds.width - padding * 2 - tilePadding * (CGFloat(dimension) - 1)) / CGFloat(dimension)
    }
}

// MARK: Generic helpers
extension GameBoardView {
    /**
    Return the tile frame for a tile coordinate
    
    :param: coordinate tile coordinate, within range [0 ..< dimension, 0 ..< dimension]
    
    :returns: CGRect frame
    */
    func tileFrameForCoordinate(coordinate: (Int, Int)) -> CGRect {
        let y = padding + (tilePadding + tileWidth) * CGFloat(coordinate.0)
        let x = padding + (tilePadding + tileWidth) * CGFloat(coordinate.1)
        return CGRectMake(x, y, tileWidth, tileWidth)
    }
    
    func currentDisplayingGameBoard() -> [[Int]] {
        var result = [[Int]]()
        for i in 0 ..< dimension {
            var row = [Int]()
            for j in 0 ..< dimension {
                if let tile = forgroundTiles[i][j].0 {
                    row.append(tile.number)
                } else{
                    row.append(0)
                }
            }
            result.append(row)
        }
        
        return result
    }
}
