//
//  ViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/6/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var gameBoard: GameBoard!
    
    var metrics = [String: CGFloat]()
    var views = [String: UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        self.view.backgroundColor = SharedColors.BackgroundColor

        gameBoard = GameBoard(width: UIScreen.mainScreen().bounds.width * 0.9, dimension: 4)
        gameBoard.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        views["gameBoard"] = gameBoard
        self.view.addSubview(gameBoard)
        
        metrics["width"] = gameBoard.width
        
        gameBoard.addConstraint(NSLayoutConstraint(item: gameBoard, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoard.width))
        gameBoard.addConstraint(NSLayoutConstraint(item: gameBoard, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoard.width))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: gameBoard, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: gameBoard, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
    }
}

