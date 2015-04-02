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

    // MARK: Views
    var scoreView: ScoreView!
    var bestScoreView: ScoreView!
    var targetView: ScoreView!
    
    var gameBoardView: GameBoardView!
    
    var newGameButton: BlackBorderButton!
    var runAIButton: BlackBorderButton!
    var undoButton: BlackBorderButton!
    var hintButton: BlackBorderButton!
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    // MARK: Model
    var dimension: Int = 4
    var gameModel: Game2048!
    /// queue for move command
    var commandQueue = [MoveCommand]()
    /// queue for next command calculate, AI related
    var commandCalculationQueue = NSOperationQueue()
    
    typealias ActionTuple = (moveActions: [MoveAction], initActions: [InitAction], removeActions: [RemoveAction], score: Int)
    /// queue for action (action is for view update)
    var actionQueue = [ActionTuple]()
    
    /// queue size for different mode
    var kUserCommandQueueSize: Int = 2
    var kAiCommandQueueSize: Int = 10
    
    // Game History
    typealias GameState = (stateId: Int, gameBoard: [[Int]], score: Int)
    typealias CommandRecord = (fromStateId: Int, toStateId: Int, command: MoveCommand)
    var gameStateHistory = [GameState]() {
        didSet {
            if gameStateHistory.count > 1 {
                undoButton.enabled = true
            } else {
                undoButton.enabled = false
            }
        }
    }
    var commandHistory = [CommandRecord]()
    
    // MARK: Game status flags
    var isGameEnd: Bool = true {
        didSet {
            isAiRunning = false
        }
    }
    
    var isAnimating: Bool = false
    var isAiRunning: Bool = false {
        didSet {
            if runAIButton != nil {
                runAIButton.title = isAiRunning ? "Stop AI" : "Run AI"
            }
            if isAiRunning {
                runAIforNextStep()
            }
        }
    }
    
    /// Flag: whether user just stopped AI (user pressed Stop AI button), 
    //        this flag will only be true for a short peroid. E.g. when AI is running and user stopped AI, this flag is used for avoiding queue more commands or actions
    var userStoppedAI: Bool = false
    
    // MARK: AI Related
    typealias AITuple = (description: String, function: () -> MoveCommand?)
    var aiChoices = [Int: AITuple]()
    var aiSelectedChoiceIndex: Int = 1
    var ai: AI!
    var aiRandom: AIRandom!
    var aiGreedy: AIGreedy!
    var aiExpectimax: AIExpectimax!
    var TDLAi: TDLGame2048!
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        logLevel = ZHLogLevel.Off
        logLevel = .Info
//        logLevel = .Debug
        
        readData()
        setupGameModel()
        setupViews()
        setupSwipeGestures()
        setupAI()
        otherSetups()
        
        startNewGame()
        
//        let customQ = dispatch_queue_create("com.uw.yansong", DISPATCH_QUEUE_CONCURRENT)
//        dispatch_async(customQ, { () -> Void in
//            var myGame = Game2048ExperimentTDL()
//            myGame.RunMe()
//        })
        
//        var myGame = Game2048ExperimentTDL()
//        myGame.RunMe()
    }
    
    // MARK: Setups
    func setupGameModel() {
        gameModel = Game2048(dimension: dimension, target: 0)
        gameModel.delegate = self
        gameModel.commandQueueSize = kAiCommandQueueSize
    }
    
    func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor

        metrics["padding"] = is3_5InchScreen ? 5.0 : 8.0
        
        // GameBoardView
        gameBoardView = GameBoardView()
        gameBoardView.backgroundColor = view.backgroundColor
        gameBoardView.gameModel = gameModel
        
        gameBoardView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["gameBoardView"] = gameBoardView
        view.addSubview(gameBoardView)
        
        // GameBoard Size
        let gameBoardWidth = screenWidth * 0.9
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: gameBoardWidth))
        gameBoardView.addConstraint(NSLayoutConstraint(item: gameBoardView, attribute: .Width, relatedBy: .Equal, toItem: gameBoardView, attribute: .Height, multiplier: 1.0, constant: 0.0))
        
        // GameBoard center horizontally
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        let cCenterY = NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: gameBoardView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        // 3.5 inch Screen has a smaller height, this will be broken
        cCenterY.priority = 750
        view.addConstraint(cCenterY)
        
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
        bestScoreView.number = 0
        readBestScore()
        
        // TargetView
        targetView = ScoreView()
        targetView.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["targetView"] = targetView
        view.addSubview(targetView)
        
        targetView.titleLabel.text = "TARGET"
        targetView.numberLabelMaxFontSize = 38
        targetView.number = 2048 // "∞"
        
        metrics["targetViewHeight"] = is3_5InchScreen ? gameBoardWidth / 3.6 : gameBoardWidth / 3.0
        // TargetView is square
        targetView.addConstraint(NSLayoutConstraint(item: targetView, attribute: .Height, relatedBy: .Equal, toItem: targetView, attribute: .Width, multiplier: 1.0, constant: 0.0))
        
        // New Game Button
        newGameButton = BlackBorderButton()
        newGameButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        newGameButton.title = "New Game"
        newGameButton.addTarget(self, action: "newGameButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["newGameButton"] = newGameButton
        view.addSubview(newGameButton)
        
        // Run AI Button
        runAIButton = BlackBorderButton()
        runAIButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        runAIButton.title = "Run AI"
        runAIButton.addTarget(self, action: "runAIButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "runAIButtonLongPressed:")
        runAIButton.addGestureRecognizer(longPressGesture)
        views["runAIButton"] = runAIButton
        view.addSubview(runAIButton)
        
        // Undo Button
        undoButton = BlackBorderButton()
        undoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        undoButton.title = "Undo"
        undoButton.addTarget(self, action: "undoButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["undoButton"] = undoButton
        view.addSubview(undoButton)
        
        // Hint Button
        hintButton = BlackBorderButton()
        hintButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        hintButton.title = "Hint"
        hintButton.addTarget(self, action: "hintButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["hintButton"] = hintButton
        view.addSubview(hintButton)
        
//        metrics["buttonHeight"] = is3_5InchScreen ? metrics["targetViewHeight"]! / 2.0 : 50.0
        metrics["buttonHeight"] = (metrics["targetViewHeight"]! - metrics["padding"]!) / 2.0
        
        // H
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[scoreView]-padding-[targetView]", options: NSLayoutFormatOptions.AlignAllTop, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[bestScoreView]-padding-[targetView]", options: NSLayoutFormatOptions.AlignAllBottom, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[newGameButton]-padding-[runAIButton(==newGameButton)]", options: NSLayoutFormatOptions.AlignAllBottom, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[undoButton]-padding-[hintButton(==undoButton)]", options: NSLayoutFormatOptions.AlignAllBottom, metrics: metrics, views: views))
        
        // V
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[scoreView]-padding-[bestScoreView(==scoreView)]-padding-[gameBoardView]-padding-[newGameButton(buttonHeight)]-padding-[undoButton(buttonHeight)]", options: NSLayoutFormatOptions.AlignAllLeading, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[targetView(targetViewHeight)]-padding-[gameBoardView]-padding-[runAIButton(buttonHeight)]-padding-[hintButton(buttonHeight)]", options: NSLayoutFormatOptions.AlignAllTrailing, metrics: metrics, views: views))
        
        // Target view top spacing >= 22
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
    
    func setupAI() {
        ai = AI.CreateInstance()
        aiRandom = AIRandom(gameModel: gameModel)
        aiGreedy = AIGreedy(gameModel: gameModel)
        aiExpectimax = AIExpectimax(gameModel: gameModel)
        
        
        let AIMiniMaxWithAlphaBetaPruning = AITuple(description: "Minimax Tree with Alpha/Beta Pruning", function: miniMaxWithAlphaBetaPruning)
        aiChoices[0] = AIMiniMaxWithAlphaBetaPruning
        
        let AIMonoHeuristic = AITuple(description: "Mono Heuristic", function: MonoHeuristic)
        aiChoices[1] = AIMonoHeuristic
        
        let AIRandomness = AITuple(description: "Pure Monte Carlo Tree Search", function: randomness)
        aiChoices[2] = AIRandomness
        
        let AIExpectimaxTuple = AITuple(description: "Mono 2", function: expectimax)
        aiChoices[3] = AIExpectimaxTuple
        
        let backgroundReadingQueue = dispatch_queue_create("READING_FILE", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(backgroundReadingQueue, { () -> Void in
            // Do background process
            logInfo("Loading TDLearning file")
            self.TDLAi = TDLGame2048()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Do on main thread
                logInfo("Loading TDLearning file successfully")
                let AITDLearningTuple = AITuple(description: "TDLearning", function: self.TDLearning)
                self.aiChoices[4] = AITDLearningTuple
            })
        })
    }
    
    func otherSetups() {
        // Make sure operation queue is serial
        commandCalculationQueue.maxConcurrentOperationCount = 1
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).mainViewController = self
    }
}

// MARK: Swipe Gestures
extension ViewController {
    @objc(up:)
    func upCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        if !isGameEnd && !isAiRunning {
            queueCommand(MoveCommand(direction: MoveDirection.Up))
        }
    }
    
    @objc(down:)
    func downCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        if !isGameEnd && !isAiRunning {
            queueCommand(MoveCommand(direction: MoveDirection.Down))
        }
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        if !isGameEnd && !isAiRunning {
            queueCommand(MoveCommand(direction: MoveDirection.Left))
        }
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        precondition(gameModel != nil, "")
        if !isGameEnd && !isAiRunning {
            queueCommand(MoveCommand(direction: MoveDirection.Right))
        }
    }
}

// MARK: Button Actions
extension ViewController {
    func newGameButtonTapped(sender: AnyObject?) {
        logDebug()
        
        var aiIsRunningBefore = false
        if isAiRunning {
            aiIsRunningBefore = true
            runAIButtonTapped(nil)
        }
        
        let confirmVC = ConfirmViewController()
        confirmVC.transitioningDelegate = confirmVC
        confirmVC.modalPresentationStyle = .Custom
        confirmVC.okClosure = {
            self.startNewGame()
        }
        
        confirmVC.cancelClosure = {
            if aiIsRunningBefore && !self.isAiRunning{
                self.runAIButtonTapped(nil)
            }
        }
        
        self.presentViewController(confirmVC, animated: true, completion: nil)
    }
    
    private func startNewGame() {
        self.gameModel.reset()
        self.gameModel.start()
    }
    
    func runAIButtonTapped(sender: UIButton?) {
        logDebug()
        if !isGameEnd {
            isAiRunning = !isAiRunning
            if !isAiRunning {
                userStoppedAI = true
                commandQueue.removeAll(keepCapacity: false)
                actionQueue.removeAll(keepCapacity: false)
                logDebug("cancelAllOperations")
                commandCalculationQueue.cancelAllOperations()
                
                let currentDisplayingGameBoard = self.gameBoardView.currentDisplayingGameBoard()
                // If not animatiing, reset game model immediately
                if !isAnimating {
                    resetGameState()
                }
                // else: userSteppedAI will be set to false in action completion block
            }
        }
    }
    
    private func resetGameState() {
        let currentDisplayingGameBoard = self.gameBoardView.currentDisplayingGameBoard()
        
        // Reset game model from current view state
        logDebug("Reset game model")
        self.gameModel.resetGameBoardWithIntBoard(currentDisplayingGameBoard, score: self.scoreView.number)
        self.gameModel.printOutGameState()
        
        // Reset game state history (roll back)
        let historyCount = gameStateHistory.count
        var currentGameStateIndex = -1
        for i in stride(from: historyCount - 1, to: -1, by: -1) {
            let gameBoard = gameStateHistory[i].gameBoard
            if GameModelHelper.gameBoard(gameBoard, IsEqualTo: currentDisplayingGameBoard) {
                currentGameStateIndex = i
            }
        }
        assert(currentGameStateIndex > -1, "error game state history")
        gameStateHistory.removeRange(currentGameStateIndex + 1 ..< gameStateHistory.count)
        
        self.userStoppedAI = false
    }
    
    func runAIButtonLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            logDebug()
            var aiIsRunningBefore = false
            if isAiRunning {
                aiIsRunningBefore = true
                runAIButtonTapped(nil)
            }
            
            var dimensionBefore = dimension
            
            let settingVC = SettingViewController()
            settingVC.transitioningDelegate = settingVC
            settingVC.modalPresentationStyle = .Custom
            settingVC.mainViewController = self
            settingVC.saveClosure = {
                self.saveData()
            }
            
            settingVC.dismissClosure = {
                // If dimension is changed, reset game model and game board
                if dimensionBefore != self.dimension {
                    self.gameModel = Game2048(dimension: self.dimension, target: 0)
                    self.gameModel.delegate = self
                    self.gameModel.commandQueueSize = self.kAiCommandQueueSize
                    self.gameBoardView.gameModel = self.gameModel
                    self.aiRandom.gameModel = self.gameModel
                    self.aiExpectimax.gameModel = self.gameModel
                    
                    self.readBestScore()
                    
                    self.startNewGame()
                    return
                }
                
                if aiIsRunningBefore && !self.isAiRunning {
                    self.runAIButtonTapped(nil)
                }
            }
            
            self.presentViewController(settingVC, animated: true, completion: nil)
        }
    }
    
    func undoButtonTapped(sender: UIButton?) {
        logDebug()
        let count = gameStateHistory.count
        if count <= 1 {
            return
        }
        if isAiRunning || isAnimating || commandQueue.count > 0 || actionQueue.count > 0 || commandCalculationQueue.operationCount > 0 {
            return
        }
        
        if isGameEnd {
            isGameEnd = false
        }
        
        // Last state is current state
        gameStateHistory.removeLast()
        
        // Update last state
        let lastState = gameStateHistory.last!
        gameModel.resetGameBoardWithIntBoard(lastState.gameBoard, score: lastState.score)
        gameBoardView.setGameBoardWithBoard(lastState.gameBoard)
        scoreView.number = lastState.score
        updateTargetScore()
    }
    
    func hintButtonTapped(sender: UIButton) {
        logDebug()
        if isGameEnd || isAiRunning {
            return
        }
        runAIforNextStep(ignoreIsAIRunning: true)
    }
}

// MARK: AI Calculation
extension ViewController {
    // If ignoreIsAIRunning is true, command calculated will be queued anyway
    func runAIforNextStep(ignoreIsAIRunning: Bool = false) {
        if isGameEnd {
            return
        }
        // If dispatched commands + commandToBeDispatched count is greater than size, don't dispacth, otherwise, queue will be overflow
        if (
            (commandCalculationQueue.operationCount + commandQueue.count) >= kAiCommandQueueSize)
            ||
            ((commandCalculationQueue.operationCount + actionQueue.count) >= kAiCommandQueueSize)
        {
            logDebug("Full, Stop AI")
            return
        }

        logDebug("Add new command calculation")
        commandCalculationQueue.addOperationWithBlock { () -> Void in
            if let nextCommand = self.aiChoices[self.aiSelectedChoiceIndex]!.function() {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if ignoreIsAIRunning || self.isAiRunning {
                        self.queueCommand(nextCommand)
                    }
                })
            }
        }
    }
    
    // MARK: Different AI algorithms
    func miniMaxWithAlphaBetaPruning() -> MoveCommand? {
        return ai.nextMoveUsingAlphaBetaPruning(self.gameModel.currentGameBoard())
    }
    
    func MonoHeuristic() -> MoveCommand? {
        return ai.nextMoveUsingMonoHeuristic(self.gameModel.currentGameBoard())
    }
    
    func randomness() -> MoveCommand? {
        return aiRandom.nextCommand()
    }
    
    func expectimax() -> MoveCommand? {
        return aiExpectimax.nextCommand()
    }
    
    func TDLearning() -> MoveCommand? {
        return TDLAi.playWithCurrentState(self.gameModel.currentGameBoard())
    }
}

// MARK: Command Queue
extension ViewController {
    func queueCommand(command: MoveCommand) {
        // If user just stopped AI, stop queueing command
        if userStoppedAI {
            logDebug("user stopped AI")
            logDebug("CommandQueue size: \(commandQueue.count)")
            return
        }
        if queuesAreFull() {
            logError("Queue are Full")
            logDebug("CommandQueue size: \(commandQueue.count)")
            // If AI is running, shouldn't happen
            if isAiRunning {
                assertionFailure("Queue are Full: should never happen")
            } else {
                // If user is playing game, ignore more commands
                return
            }
        }
        logDebug("Enqueue")
        commandQueue.append(command)
        logDebug("CommandQueue size: \(commandQueue.count)")
        executeCommandQueue()
    }
    
    func executeCommandQueue() {
        if commandQueue.count > 0 {
            // If user just stopped AI, don't execute
            // To avoid race condition, when commandQueue.count is > 0 while user tapped stop AI.
            if userStoppedAI {
                logDebug("user stopped AI")
                logDebug("CommandQueue size: \(commandQueue.count)")
                return
            }
            logDebug("Dequeue and Execute")
            let command = commandQueue[0]
            GameModelHelper.printOutCommand(command, level: .Info)
            commandQueue.removeAtIndex(0)
            logDebug("CommandQueue size: \(commandQueue.count)")
            gameModel.playWithCommand(command)
        } else {
            logDebug("Queue is empty")
        }
    }
    
    func queueAction(action: ActionTuple) {
        if userStoppedAI {
            logDebug("user stopped AI")
            logDebug("ActionQueue size: \(actionQueue.count)")
            return
        }
        if actionQueueIsFull() {
            logError("Queue is Full")
            logDebug("ActionQueue size: \(actionQueue.count)")
            if isAiRunning {
                assertionFailure("Queue is Full: should never happen")
            } else {
                return
            }
        }
        logDebug("Enqueue")
        actionQueue.append(action)
        logDebug("ActionQueue size: \(actionQueue.count)")
        executeActionQueue()
    }
    
    func executeActionQueue() {
        if isAnimating {
            logDebug("is Animating")
            logDebug("ActionQueue size: \(actionQueue.count)")
            return
        }
        if actionQueue.count > 0 {
            if userStoppedAI {
                logDebug("user stopped AI")
                logDebug("ActionQueue size: \(actionQueue.count)")
                return
            }
            logDebug("Dequeue and Execute")
            let actionTuple = actionQueue[0]
            actionQueue.removeAtIndex(0)
            logDebug("ActionQueue size: \(actionQueue.count)")
            
            // If before dequeuing, actionQueue is full, command queue is empty, reactivate AI
            if isAiRunning && (actionQueue.count == kAiCommandQueueSize - 1) && (commandCalculationQueue.operationCount + commandQueue.count == 0) {
                logDebug("Action Queue is available, resume AI")
                runAIforNextStep()
            }
            
            // Update UIs
            self.isAnimating = true
            scoreView.number = actionTuple.score
            if scoreView.number > bestScoreView.number {
                bestScoreView.number = scoreView.number
                saveBestScore(bestScoreView.number)
            }
            
            // If this is remove action, just clear board
            if actionTuple.removeActions.count > 0 {
                logDebug("Clear board")
                gameBoardView.removeWithRemoveActions(actionTuple.removeActions, completion: { () -> () in
                    self.isAnimating = false
                    self.executeActionQueue()
                })
            } else {
                logDebug("Init/ Move board")
                gameBoardView.updateWithMoveActions(actionTuple.moveActions, initActions: actionTuple.initActions, completion: {
                    self.isAnimating = false
                    self.updateTargetScore()
                    
                    // If user has stopped AI, reset game model from current displaying views
                    if self.userStoppedAI {
                        self.resetGameState()
                    }
                    self.executeActionQueue()
                })
            }
        } else {
            logDebug("Queue is empty")
            if isGameEnd {
                let gameEndVC = GameEndViewController()
                gameEndVC.transitioningDelegate = gameEndVC
                gameEndVC.modalPresentationStyle = .Custom
                gameEndVC.undoClosure = {
                    self.undoButtonTapped(nil)
                }
                gameEndVC.startClosure = {
                    self.startNewGame()
                }
                
                self.presentViewController(gameEndVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Queue Helpers
    func queuesAreFull() -> Bool {
        let size = isAiRunning ? kAiCommandQueueSize : kUserCommandQueueSize
        return (actionQueue.count >= size || commandQueue.count >= size)
    }
    
    func commandQueueIsFull() -> Bool {
        let size = isAiRunning ? kAiCommandQueueSize : kUserCommandQueueSize
        return commandQueue.count >= size
    }
    
    func actionQueueIsFull() -> Bool {
        let size = isAiRunning ? kAiCommandQueueSize : kUserCommandQueueSize
        return actionQueue.count >= size
    }
}

// MARK: Game 2048 Delegate
extension ViewController: Game2048Delegate {
    func game2048DidReset(game2048: Game2048, removeActions: [RemoveAction]) {
        logDebug("Reseted")
        isGameEnd = true
        isAiRunning = false
        if removeActions.count > 0 {
            queueAction(([], [], removeActions, 0))
        }
    }
    
    func game2048DidStartNewGame(game2048: Game2048) {
        logDebug("Started")
        game2048.printOutGameState()
        isGameEnd = false
        
        // Clean up
        gameStateHistory.removeAll(keepCapacity: false)
        commandHistory.removeAll(keepCapacity: false)
    }
    
    func game2048DidUpdate(game2048: Game2048, moveActions: [MoveAction], initActions: [InitAction], score: Int) {
        logDebug("Updated")
        game2048.printOutGameState()
        
        // Only update view and record state when there's valid action
        if moveActions.count > 0 || initActions.count > 0 {
            queueAction((moveActions, initActions, [], score))
            
            // Record game state
            let newGameState = GameState(stateId: gameStateHistory.count, gameBoard: game2048.currentGameBoard(), score: score)
            gameStateHistory.append(newGameState)
        }
        
        if isAiRunning {
            runAIforNextStep()
        }
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
    
    func readData() {
        readDimension()
        readAnimationDuration()
        readAIChoice()
    }
    
    func saveData() {
        saveDimension()
        saveAnimationDuration()
        saveAIChoice()
    }
    
    func saveAIChoice() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let number = NSNumber(integer: aiSelectedChoiceIndex)
        defaults.setObject(number, forKey: "AIChoice")
    }
    
    func readAIChoice() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let choiceNumber = defaults.objectForKey("AIChoice") as? NSNumber {
            aiSelectedChoiceIndex = choiceNumber.integerValue
        }
    }
    
    func saveDimension() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(dimension, forKey: "Dimension")
    }
    
    func readDimension() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let storedDimension: Int = defaults.integerForKey("Dimension")
        if storedDimension > 0 {
            dimension = storedDimension
        }
    }
    
    func saveAnimationDuration() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let number = NSNumber(double: sharedAnimationDuration)
        defaults.setObject(number, forKey: "AnimationDuration")
    }
    
    func readAnimationDuration() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let durationNumber = defaults.objectForKey("AnimationDuration") as? NSNumber {
            sharedAnimationDuration = durationNumber.doubleValue
        }
    }
    
    func saveBestScore(score: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(score, forKey: String(format: "BestScore_%d", dimension))
    }
    
    func readBestScore() {
        let defaults = NSUserDefaults.standardUserDefaults()
        bestScoreView.number = defaults.integerForKey(String(format: "BestScore_%d", dimension))
    }
    
    func updateTargetScore() {
        let currentScore = gameBoardView.currentMaxTileNumber()
        if currentScore < 2048 {
            targetView.number = 2048
            return
        }
        
        var i: Double = 11
        while true {
            if Int(pow(Double(2.0), i)) <= currentScore && currentScore < Int(pow(Double(2.0), i + 1)) {
                targetView.number = Int(pow(Double(2.0), i + 1))
                break
            }
            i++
        }
    }
}
