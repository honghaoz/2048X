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

    var scoreView: ScoreView!
    var bestScoreView: ScoreView!
    var targetView: ScoreView!
    
    var gameBoardView: GameBoardView!
    
    var gameModel: Game2048!
    var commandQueue = [MoveCommand]()
    
    typealias ActionTuple = (moveActions: [MoveAction], initActions: [InitAction], score: Int)
    var actionQueue = [ActionTuple]()
    
    var kUserCommandQueueSize: Int = 3
    var kAiCommandQueueSize: Int = 10000
    
    var isGameEnd: Bool = false
    
    var isAnimating: Bool = false
    var isAiRunning: Bool = false
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    var ai: AI!
    var aiRandom: AIRandom!
    var aiGreedy: AIGreedy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        logLevel = .Off
        
        setupGameModel()
        setupViews()
        setupSwipeGestures()
        
        ai = AI.CreateInstance()
        aiRandom = AIRandom(gameModel: gameModel)
        aiGreedy = AIGreedy(gameModel: gameModel)
        
        gameModel.start()
        
        sharedAnimationDuration = 0.1
        
//        NSTimer.scheduledTimerWithTimeInterval(sharedAnimationDuration, target: self, selector: "play", userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: "tap")
        gameBoardView.addGestureRecognizer(tap)
    }
    
    func tap() {
//        let nextCommand = self.aiRandom.nextStepWithCurrentState(gameModel.currentGameBoard())
//        if nextCommand == nil {
//            logDebug("next: nil")
//        } else {
//            queueCommand(nextCommand!)
//        }
    }
    
    func setupGameModel() {
        gameModel = Game2048(dimension: 4, target: 0)
        gameModel.delegate = self
        gameModel.commandQueueSize = kAiCommandQueueSize
    }
    
    func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor

        metrics["padding"] = 5.0
        
        // GameBoardView
        gameBoardView = GameBoardView()
        gameBoardView.backgroundColor = view.backgroundColor
        gameBoardView.gameModel = gameModel
        
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["gameBoardView"] = gameBoardView
        view.addSubview(gameBoardView)
        
        let gameBoardWidth = screenWidth * 0.9
        
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: gameBoardWidth))
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
        // FIXME: On iPhone 4s, layout issues
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: gameBoardView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        
        // ScoreView
        scoreView = ScoreView()
        scoreView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["scoreView"] = scoreView
        view.addSubview(scoreView)
        
        scoreView.titleLabel.text = "SCORE"
        scoreView.numberLabelMaxFontSize = is3_5InchScreen ? 20 : 28
        scoreView.numberLabel.textAlignment = .Right
        scoreView.number = 0
        
        // BestScoreView
        bestScoreView = ScoreView()
        bestScoreView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["bestScoreView"] = bestScoreView
        view.addSubview(bestScoreView)
        
        bestScoreView.titleLabel.text = "BEST"
        bestScoreView.numberLabelMaxFontSize = is3_5InchScreen ? 20 : 28
        bestScoreView.numberLabel.textAlignment = .Right
        bestScoreView.number = 23543 // TODO: Record best score
        
        // TargetView
        targetView = ScoreView()
        targetView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["targetView"] = targetView
        view.addSubview(targetView)
        
        targetView.titleLabel.text = "TARGET"
        targetView.numberLabelMaxFontSize = 38
        targetView.number = 2048
//        targetView.numberLabel.text = "∞"
        
        metrics["targetViewHeight"] = gameBoardWidth / 3.0
        targetView.addConstraint(NSLayoutConstraint(item: targetView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: targetView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0))
        
        // H
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[scoreView]-padding-[targetView]", options: NSLayoutFormatOptions.AlignAllTop, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[bestScoreView]-padding-[targetView]", options: NSLayoutFormatOptions.AlignAllBottom, metrics: metrics, views: views))
        
        // V
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[scoreView]-padding-[bestScoreView(==scoreView)]-padding-[gameBoardView]", options: NSLayoutFormatOptions.AlignAllLeading, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[targetView(targetViewHeight)]-padding-[gameBoardView]", options: NSLayoutFormatOptions.AlignAllTrailing, metrics: metrics, views: views))
        
        view.addConstraint(NSLayoutConstraint(item: targetView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 22))
        
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

extension ViewController {
    func runAI() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            if let nextCommand = self.ai.nextMoveUsingAlphaBetaPruning(self.gameModel.currentGameBoard()) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.queueCommand(nextCommand)
                })
            }
        })
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
//            if let nextCommand = self.aiRandom.nextCommand() {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.queueCommand(nextCommand)
//                })
//            }
//        })
    }
}

// MARK: Command Queue
extension ViewController {
    func queueCommand(command: MoveCommand) {
        logDebug("Called")
        let size = isAiRunning ? kAiCommandQueueSize : kUserCommandQueueSize
        if actionQueue.count >= size || commandQueue.count >= size {
            if actionQueue.count >= size {
                logDebug("ActionQueue is Full")
            }
            
            if commandQueue.count >= size {
                logDebug("CommandQueue is Full")
            }
            return
        }
        logDebug("Enqueue")
        commandQueue.append(command)
        executeCommandQueue()
    }
    
    func executeCommandQueue() {
        logDebug("Called")
        if commandQueue.count > 0 {
            logDebug("Dequeue and Execute")
            let command = commandQueue[0]
            commandQueue.removeAtIndex(0)
            gameModel.playWithCommand(command)
        }
    }
    
    func queueAction(action: ActionTuple) {
        logDebug("Called")
        let size = isAiRunning ? kAiCommandQueueSize : kUserCommandQueueSize
        if actionQueue.count > size {
            logDebug("ActionQueue is Full")
            return
        }
        logDebug("Enqueue")
        actionQueue.append(action)
        executeActionQueue()
    }
    
    func executeActionQueue() {
        logDebug("Called")
        if isAnimating {
            logDebug("is Animating")
            return
        }
        if actionQueue.count > 0 {
            logDebug("Dequeue and Execute")
            let actionTuple = actionQueue[0]
            actionQueue.removeAtIndex(0)
            
            // Update UIs
            self.isAnimating = true
            scoreView.number = actionTuple.score
            gameBoardView.updateWithMoveActions(actionTuple.moveActions, initActions: actionTuple.initActions, completion: {
                self.isAnimating = false
                self.executeActionQueue()
            })
        }
    }
}

// MARK: Game 2048 Delegate
extension ViewController: Game2048Delegate {
    func game2048DidReset(game2048: Game2048) {
        logDebug("Reseted")
    }
    
    func game2048DidStartNewGame(game2048: Game2048) {
        logDebug("Started")
        game2048.printOutGameState()
        isGameEnd = false
        
        isAiRunning = true
    }
    
    func game2048DidUpdate(game2048: Game2048, moveActions: [MoveAction], initActions: [InitAction], score: Int) {
        logDebug("Updated")
//        game2048.printOutGameState()
        runAI()
        queueAction((moveActions, initActions, score))
        
        // Manual
//        scoreView.number = game2048.score
//        gameBoardView.updateWithMoveActions(moveActions, initActions: initActions, completion: {
//            self.isAnimating = false
//            self.executeCommandQueue()
//        })
        
        // AI
//        if !isGameEnd {
////            let nextCommand = ai.nextMoveUsingMonoHeuristic(gameModel.currentGameBoard())
//            
//            let nextCommand = ai.nextMoveUsingAlphaBetaPruning(gameModel.currentGameBoard())
//
//            let nextCommand = ai.nextMoveUsingCombinedStrategy(gameModel.currentGameBoard())
//            
//            scoreView.number = game2048.score
//            gameBoardView.updateWithMoveActions(moveActions, initActions: initActions, completion: {
//                self.isAnimating = false
//                if let nextCommand = nextCommand {
//                    self.queueCommand(nextCommand)
//                }
//                self.executeCommandQueue()
//            })
//        }
        
        // Greedy AI
//        if !isGameEnd {
//            let nextCommand = aiGreedy.nextState()
//            scoreView.number = game2048.score
//            gameBoardView.updateWithMoveActions(moveActions, initActions: initActions, completion: {
//                self.isAnimating = false
//                self.queueCommand(nextCommand)
//                self.executeCommandQueue()
//            })
//        }
        
        // Random AI
//        if !isGameEnd {
//            let nextCommand = aiRandom.nextCommand()
//            scoreView.number = game2048.score
//            gameBoardView.updateWithMoveActions(moveActions, initActions: initActions, completion: {
//                self.isAnimating = false
//                if let nextCommand = nextCommand {
//                    self.queueCommand(nextCommand)
//                }
//                self.executeCommandQueue()
//            })
//        }
    }
    
    func game2048DidEnd(game2048: Game2048) {
        game2048.printOutGameState()
        logDebug("Ended")
        isGameEnd = true
    }
}

// MARK: Others
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
