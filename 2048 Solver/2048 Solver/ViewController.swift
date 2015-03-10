//
//  ViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/6/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var gameModel: Game2048!
    var gameBoardView: GameBoardView!
    
    var metrics = [String: CGFloat]()
    var views = [String: UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameModel()
        setupViews()
        setupSwipeGestures()
        
        gameModel.start()
    }
    
    func setupGameModel() {
        gameModel = Game2048(dimension: 4, target: 0)
        gameModel.delegate = self
    }
    
    func setupViews() {
        self.view.backgroundColor = SharedColors.BackgroundColor

        gameBoardView = GameBoardView(width: UIScreen.mainScreen().bounds.width * 0.9, dimension: 4)
        gameBoardView.gameModel = gameModel
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        views["gameBoard"] = gameBoardView
        self.view.addSubview(gameBoardView)
        
        metrics["width"] = gameBoardView.width
        
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoardView.width))
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoardView.width))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
    }
    
    func setupSwipeGestures() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("up:"))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        gameBoardView.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("down:"))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        gameBoardView.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("left:"))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        gameBoardView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("right:"))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        gameBoardView.addGestureRecognizer(rightSwipe)
    }
}

// MARK: Swipe Gestures
extension ViewController {
    // Commands
    @objc(up:)
    func upCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        gameModel.performMoveCommand(MoveCommand(direction: MoveDirection.Up))
    }
    
    @objc(down:)
    func downCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        gameModel.performMoveCommand(MoveCommand(direction: MoveDirection.Down))
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        gameModel.performMoveCommand(MoveCommand(direction: MoveDirection.Left))
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        gameModel.performMoveCommand(MoveCommand(direction: MoveDirection.Right))
    }
}

extension ViewController: Game2048Delegate {
    func game2048DidStartNewGame(game2048: Game2048) {
        println("Started")
    }
    
    func game2048DidUpdate(game2048: Game2048) {
        println("Updated")
        gameBoardView.updateTiles()
    }
    
    func game2048DidReset(game2048: Game2048) {
        println("Reseted")
    }
}
