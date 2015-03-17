//
//  ViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/6/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
//import AVFoundation

class ViewController: UIViewController {

    var gameModel: Game2048!
    var gameBoardView: GameBoardView!
    
    var commandQueue = [MoveCommand]()
    var kCommandQueueSize: Int = 2
    
    var isAnimating: Bool = false
    
    var metrics = [String: CGFloat]()
    var views = [String: UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameModel()
        setupViews()
        setupSwipeGestures()
        
        gameModel.start()
        
        sharedAnimationDuration = 0.12
//        NSTimer.scheduledTimerWithTimeInterval(sharedAnimationDuration, target: self, selector: "play", userInfo: nil, repeats: true)
    }
    
    func play() {
        let seed = Int(arc4random_uniform(UInt32(100)))
        if seed < 25 {
            queueCommand(MoveCommand(direction: MoveDirection.Up))
        } else if seed < 50 {
            queueCommand(MoveCommand(direction: MoveDirection.Down))
        } else if seed < 75 {
            queueCommand(MoveCommand(direction: MoveDirection.Left))
        } else {
            queueCommand(MoveCommand(direction: MoveDirection.Right))
        }
    }
    
    func setupGameModel() {
        gameModel = Game2048(dimension: 4, target: 0)
        gameModel.delegate = self
    }
    
    func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor

        gameBoardView = GameBoardView()
        gameBoardView.backgroundColor = view.backgroundColor
        gameBoardView.gameModel = gameModel
        
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["gameBoard"] = gameBoardView
        view.addSubview(gameBoardView)
        
        let gameBoardWidth = UIScreen.mainScreen().bounds.width * 0.9
        
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoardWidth))
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoardWidth))
        
        view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        // Must call this before start game
        view.layoutIfNeeded()
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
        queueCommand(MoveCommand(direction: MoveDirection.Up))
    }
    
    @objc(down:)
    func downCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        queueCommand(MoveCommand(direction: MoveDirection.Down))
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        queueCommand(MoveCommand(direction: MoveDirection.Left))
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        queueCommand(MoveCommand(direction: MoveDirection.Right))
    }
}

// MARK: Command Queue
extension ViewController {
    func queueCommand(command: MoveCommand) {
        if commandQueue.count > kCommandQueueSize {
            return
        }
        commandQueue.append(command)
        executeCommandQueue()
    }
    
    func executeCommandQueue() {
        if isAnimating {
            return
        }
        if commandQueue.count > 0 {
            let command = commandQueue[0]
            commandQueue.removeAtIndex(0)
            isAnimating = true
            gameModel.playWithCommand(command)
        }
    }
}

extension ViewController: Game2048Delegate {
    func game2048DidStartNewGame(game2048: Game2048) {
        println("Started")
    }
    
    func game2048DidUpdate(game2048: Game2048, moveActions: [MoveAction], initActions: [InitAction]) {
        println("Updated")
        
        gameBoardView.updateWithMoveActions(moveActions, initActions: initActions, completion: {
            self.isAnimating = false
            self.executeCommandQueue()
        })
    }
    
    func game2048DidReset(game2048: Game2048) {
        println("Reseted")
    }
}

extension ViewController {
//    func playSoundEffect() {
//        // Play sound effect
//        let path = NSBundle.mainBundle().pathForResource("move", ofType: "wav")
//        if let existedPath = path {
//            let pathURL = NSURL.fileURLWithPath(existedPath)
//            var audioEffect: SystemSoundID = 0
//            AudioServicesCreateSystemSoundID(pathURL, &audioEffect)
//            // Play
//            AudioServicesPlaySystemSound(audioEffect)
//            
//            // Using GCD, we can use a block to dispose of the audio effect without using a NSTimer or something else to figure out when it'll be finished playing.
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
//                Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
//                    AudioServicesDisposeSystemSoundID(audioEffect)
//            })
//        }
//    }
}
