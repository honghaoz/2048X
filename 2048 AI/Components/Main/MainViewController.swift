// Copyright © 2019 ChouTi. All rights reserved.

import ChouTi
import ChouTiUI
import Firebase
import UIKit
// import AVFoundation

class MainViewController: UIViewController {
  // MARK: Views
  var mainView: MainView!

  // MARK: Model

  var dimension: Int = 4
  var gameModel: Game2048!
  /// queue for move command
  var commandQueue = [MoveCommand]()
  /// queue for next command calculate, AI related
  var commandCalculationQueue = OperationQueue()

  typealias ActionTuple = (moveActions: [MoveAction], initActions: [InitAction], removeActions: [RemoveAction], score: Int)
  /// queue for action (action is for view update)
  var actionQueue = [ActionTuple]()

  /// queue size for different mode
  var kUserCommandQueueSize: Int = 2
  var kAiCommandQueueSize: Int = 100

  // Game History
  typealias GameState = (stateId: Int, gameBoard: [[Int]], score: Int)
  typealias CommandRecord = (fromStateId: Int, toStateId: Int, command: MoveCommand)
  var gameStateHistory = [GameState]() {
    didSet {
      if gameStateHistory.count > 1 {
        mainView.undoButton.isEnabled = true
      } else {
        mainView.undoButton.isEnabled = false
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
      if mainView.runAIButton != nil {
        mainView.runAIButton.title = isAiRunning ? "Stop AI" : "Run AI"
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
//    var TDLAi: TDLGame2048!

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Controller Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    readData()
    setupGameModel()

    mainView = MainView(gameModel: gameModel)
    view.addSubview(mainView)
    mainView.translatesAutoresizingMaskIntoConstraints = false
    mainView.constrainTo(edgesOfView: view)

    // Must call this before start game
    // Calling layoutIfNeeded to trigger gameboard view initialization.
    // FIXME: Make this better designed
    mainView.layoutIfNeeded()

    readBestScore()
    setupButtonActions()
    setupSwipeGestures()
    setupAI()

    // Make sure operation queue is serial
    commandCalculationQueue.maxConcurrentOperationCount = 1

    startNewGame()

//        let customQ = dispatch_queue_create("com.uw.yansong", DISPATCH_QUEUE_CONCURRENT)
//        dispatch_async(customQ, { () -> Void in
//            var myGame = Game2048ExperimentTDL()
//            myGame.RunMe()
//        })
  }

  // MARK: Setups

  func setupGameModel() {
    gameModel = Game2048(dimension: dimension, target: 0)
    gameModel.delegate = self
    gameModel.commandQueueSize = kAiCommandQueueSize
  }

  func setupButtonActions() {
    mainView.newGameButton.addTarget(self, action: #selector(newGameButtonTapped(_:)), for: .touchUpInside)
    mainView.runAIButton.addTarget(self, action: #selector(runAIButtonTapped(_:)), for: .touchUpInside)
    mainView.undoButton.addTarget(self, action: #selector(undoButtonTapped(_:)), for: .touchUpInside)
    mainView.hintButton.addTarget(self, action: #selector(hintButtonTapped(_:)), for: .touchUpInside)
    mainView.settingsButton.addTarget(self, action: #selector(settingsButtonTapped(_:)), for: .touchUpInside)
  }

  func setupSwipeGestures() {
    let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(upCommand(_:)))
    upSwipe.numberOfTouchesRequired = 1
    upSwipe.direction = .up
    mainView.gameBoardView.addGestureRecognizer(upSwipe)

    let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(downCommand(_:)))
    downSwipe.numberOfTouchesRequired = 1
    downSwipe.direction = .down
    mainView.gameBoardView.addGestureRecognizer(downSwipe)

    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftCommand(_:)))
    leftSwipe.numberOfTouchesRequired = 1
    leftSwipe.direction = .left
    mainView.gameBoardView.addGestureRecognizer(leftSwipe)

    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightCommand(_:)))
    rightSwipe.numberOfTouchesRequired = 1
    rightSwipe.direction = .right
    mainView.gameBoardView.addGestureRecognizer(rightSwipe)
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

//        let backgroundReadingQueue = dispatch_queue_create("READING_FILE", DISPATCH_QUEUE_CONCURRENT)
//        dispatch_async(backgroundReadingQueue, { () -> Void in
//            // Do background process
//            logInfo("Loading TDLearning file")
//            self.TDLAi = TDLGame2048()
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                // Do on main thread
//                logInfo("Loading TDLearning file successfully")
//                let AITDLearningTuple = AITuple(description: "TDLearning", function: self.TDLearning)
//                self.aiChoices[4] = AITDLearningTuple
//            })
//        })
  }
}

// MARK: Swipe Gestures

extension MainViewController {
  @objc func upCommand(_: UIGestureRecognizer!) {
    precondition(gameModel != nil, "")
    if !isGameEnd, !isAiRunning {
      queueCommand(MoveCommand(direction: MoveDirection.up))
    }
  }

  @objc func downCommand(_: UIGestureRecognizer!) {
    precondition(gameModel != nil, "")
    if !isGameEnd, !isAiRunning {
      queueCommand(MoveCommand(direction: MoveDirection.down))
    }
  }

  @objc func leftCommand(_: UIGestureRecognizer!) {
    precondition(gameModel != nil, "")
    if !isGameEnd, !isAiRunning {
      queueCommand(MoveCommand(direction: MoveDirection.left))
    }
  }

  @objc func rightCommand(_: UIGestureRecognizer!) {
    precondition(gameModel != nil, "")
    if !isGameEnd, !isAiRunning {
      queueCommand(MoveCommand(direction: MoveDirection.right))
    }
  }
}

// MARK: Button Actions

extension MainViewController {
  @objc func newGameButtonTapped(_: AnyObject?) {
    log.debug()

    var aiIsRunningBefore = false
    if isAiRunning {
      aiIsRunningBefore = true
      runAIButtonTapped(nil)
    }

    let newGameVC = NewGameViewController()
    newGameVC.okClosure = {
      self.startNewGame()
    }

    newGameVC.cancelClosure = {
      if aiIsRunningBefore, !self.isAiRunning {
        self.runAIButtonTapped(nil)
      }
    }

    present(newGameVC, animated: true, completion: nil)
  }

  private func startNewGame() {
    gameModel.reset()
    gameModel.start()

    Analytics.logEvent("start_new_game", parameters: nil)
  }

  @objc func runAIButtonTapped(_: UIButton?) {
    log.debug()

    Analytics.logEvent("run_ai", parameters: nil)

    if !isGameEnd {
      isAiRunning = !isAiRunning
      if !isAiRunning {
        userStoppedAI = true
        commandQueue.removeAll(keepingCapacity: false)
        actionQueue.removeAll(keepingCapacity: false)
        log.debug("cancelAllOperations")
        commandCalculationQueue.cancelAllOperations()

        _ = mainView.gameBoardView.currentDisplayingGameBoard()
        // If not animatiing, reset game model immediately
        if !isAnimating {
          resetGameState()
        }
        // else: userSteppedAI will be set to false in action completion block
      }
    }
  }

  private func resetGameState() {
    let currentDisplayingGameBoard = mainView.gameBoardView.currentDisplayingGameBoard()

    // Reset game model from current view state
    log.debug("Reset game model")
    gameModel.resetGameBoardWithIntBoard(currentDisplayingGameBoard, score: mainView.scoreView.number)
    gameModel.printOutGameState()

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
    gameStateHistory.removeSubrange(currentGameStateIndex + 1..<gameStateHistory.count)

    userStoppedAI = false
  }

  @objc func undoButtonTapped(_: UIButton?) {
    Analytics.logEvent("undo", parameters: nil)

    log.debug()
    let count = gameStateHistory.count
    if count <= 1 {
      return
    }
    if isAiRunning || isAnimating || !commandQueue.isEmpty || !actionQueue.isEmpty || commandCalculationQueue.operationCount > 0 {
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
    mainView.gameBoardView.setGameBoardWithBoard(lastState.gameBoard)
    mainView.scoreView.number = lastState.score
    updateTargetScore()
  }

  @objc func hintButtonTapped(_: UIButton) {
    Analytics.logEvent("hint", parameters: nil)

    log.debug()
    if isGameEnd || isAiRunning {
      return
    }
    runAIforNextStep(true)
  }

  @objc func settingsButtonTapped(_: UIButton?) {
    log.debug()
    var aiIsRunningBefore = false
    if isAiRunning {
      aiIsRunningBefore = true
      runAIButtonTapped(nil)
    }

    let dimensionBefore = dimension

    let settingVC = SettingViewController(mainViewController: self)
    settingVC.saveClosure = {
      self.saveData()
    }

    settingVC.dismissClosure = {
      // If dimension is changed, reset game model and game board
      if dimensionBefore != self.dimension {
        self.gameModel = Game2048(dimension: self.dimension, target: 0)
        self.gameModel.delegate = self
        self.gameModel.commandQueueSize = self.kAiCommandQueueSize
        self.mainView.gameBoardView.gameModel = self.gameModel
        self.aiRandom.gameModel = self.gameModel
        self.aiExpectimax.gameModel = self.gameModel

        self.readBestScore()

        self.startNewGame()
        return
      }

      if aiIsRunningBefore, !self.isAiRunning {
        self.runAIButtonTapped(nil)
      }
    }

    present(settingVC, animated: true, completion: nil)
  }
}

// MARK: AI Calculation

extension MainViewController {
  // If ignoreIsAIRunning is true, command calculated will be queued anyway
  func runAIforNextStep(_ ignoreIsAIRunning: Bool = false) {
    if isGameEnd {
      return
    }
    // If dispatched commands + commandToBeDispatched count is greater than size, don't dispacth, otherwise, queue will be overflow
    if (
      (commandCalculationQueue.operationCount + commandQueue.count) >= kAiCommandQueueSize)
      ||
      ((commandCalculationQueue.operationCount + actionQueue.count) >= kAiCommandQueueSize) {
      log.debug("Full, Stop AI")
      return
    }

    log.debug("Add new command calculation")
    commandCalculationQueue.addOperation { () -> Void in
      if let nextCommand = self.aiChoices[self.aiSelectedChoiceIndex]!.function() {
        OperationQueue.main.addOperation { () -> Void in
          if ignoreIsAIRunning || self.isAiRunning {
            self.queueCommand(nextCommand)
          }
        }
      }
    }
  }

  // MARK: Different AI algorithms

  func miniMaxWithAlphaBetaPruning() -> MoveCommand? {
    return ai.nextMoveUsingAlphaBetaPruning(gameModel.currentGameBoard())
  }

  func MonoHeuristic() -> MoveCommand? {
    return ai.nextMoveUsingMonoHeuristic(gameModel.currentGameBoard())
  }

  func randomness() -> MoveCommand? {
    return aiRandom.nextCommand()
  }

  func expectimax() -> MoveCommand? {
    return aiExpectimax.nextCommand()
  }

//    func TDLearning() -> MoveCommand? {
//        return TDLAi.playWithCurrentState(self.gameModel.currentGameBoard())
//    }
}

// MARK: Command Queue

extension MainViewController {
  func queueCommand(_ command: MoveCommand) {
    // If user just stopped AI, stop queueing command
    if userStoppedAI {
      log.debug("user stopped AI")
      log.debug("CommandQueue size: \(commandQueue.count)")
      return
    }
    if queuesAreFull() {
      log.error("Queue are Full")
      log.debug("CommandQueue size: \(commandQueue.count)")
      // If AI is running, shouldn't happen
      if isAiRunning {
        assertionFailure("Queue are Full: should never happen")
      } else {
        // If user is playing game, ignore more commands
        return
      }
    }
    log.debug("Enqueue")
    commandQueue.append(command)
    log.debug("CommandQueue size: \(commandQueue.count)")
    executeCommandQueue()
  }

  func executeCommandQueue() {
    if !commandQueue.isEmpty {
      // If user just stopped AI, don't execute
      // To avoid race condition, when commandQueue.count is > 0 while user tapped stop AI.
      if userStoppedAI {
        log.debug("user stopped AI")
        log.debug("CommandQueue size: \(commandQueue.count)")
        return
      }
      log.debug("Dequeue and Execute")
      let command = commandQueue[0]
//            GameModelHelper.printOutCommand(command, level: .Info)
      commandQueue.remove(at: 0)
      log.debug("CommandQueue size: \(commandQueue.count)")
      gameModel.playWithCommand(command)
    } else {
      log.debug("Queue is empty")
    }
  }

  func queueAction(_ action: ActionTuple) {
    if userStoppedAI {
      log.debug("user stopped AI")
      log.debug("ActionQueue size: \(actionQueue.count)")
      return
    }
    if actionQueueIsFull() {
      log.error("Queue is Full")
      log.debug("ActionQueue size: \(actionQueue.count)")
      if isAiRunning {
        assertionFailure("Queue is Full: should never happen")
      } else {
        return
      }
    }
    log.debug("Enqueue")
    actionQueue.append(action)
    log.debug("ActionQueue size: \(actionQueue.count)")
    executeActionQueue()
  }

  func executeActionQueue() {
    if isAnimating {
      log.debug("is Animating")
      log.debug("ActionQueue size: \(actionQueue.count)")
      return
    }
    if !actionQueue.isEmpty {
      if userStoppedAI {
        log.debug("user stopped AI")
        log.debug("ActionQueue size: \(actionQueue.count)")
        return
      }
      log.debug("Dequeue and Execute")
      let actionTuple = actionQueue[0]
      actionQueue.remove(at: 0)
      log.debug("ActionQueue size: \(actionQueue.count)")

      // If before dequeuing, actionQueue is full, command queue is empty, reactivate AI
      if isAiRunning, actionQueue.count == kAiCommandQueueSize - 1, commandCalculationQueue.operationCount + commandQueue.count == 0 {
        log.debug("Action Queue is available, resume AI")
        runAIforNextStep()
      }

      // Update UIs
      isAnimating = true
      mainView.scoreView.number = actionTuple.score
      if mainView.scoreView.number > mainView.bestScoreView.number {
        mainView.bestScoreView.number = mainView.scoreView.number
        saveBestScore(mainView.bestScoreView.number)
      }

      // If this is remove action, just clear board
      if !actionTuple.removeActions.isEmpty {
        log.debug("Clear board")
        mainView.gameBoardView.removeWithRemoveActions(actionTuple.removeActions, completion: { () -> Void in
          self.isAnimating = false
          self.executeActionQueue()
        })
      } else {
        log.debug("Init/ Move board")
        mainView.gameBoardView.updateWithMoveActions(actionTuple.moveActions, initActions: actionTuple.initActions, completion: {
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
      log.debug("Queue is empty")
      if isGameEnd {
        let gameEndVC = GameEndViewController()
        gameEndVC.cancelClosure = {
          self.undoButtonTapped(nil)
        }
        gameEndVC.okClosure = {
          self.startNewGame()
        }

        present(gameEndVC, animated: true, completion: nil)
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

extension MainViewController: Game2048Delegate {
  func game2048DidReset(_: Game2048, removeActions: [RemoveAction]) {
    log.debug("Reseted")
    isGameEnd = true
    isAiRunning = false
    if !removeActions.isEmpty {
      queueAction(([], [], removeActions, 0))
    }
  }

  func game2048DidStartNewGame(_ game2048: Game2048) {
    log.debug("Started")
    game2048.printOutGameState()
    isGameEnd = false

    // Clean up
    gameStateHistory.removeAll(keepingCapacity: false)
    commandHistory.removeAll(keepingCapacity: false)
  }

  func game2048DidUpdate(_ game2048: Game2048, moveActions: [MoveAction], initActions: [InitAction], score: Int) {
    log.debug("Updated")
    game2048.printOutGameState()

    // Only update view and record state when there's valid action
    if !moveActions.isEmpty || !initActions.isEmpty {
      queueAction((moveActions, initActions, [], score))

      // Record game state
      let newGameState = GameState(stateId: gameStateHistory.count, gameBoard: game2048.currentGameBoard(), score: score)
      gameStateHistory.append(newGameState)
    }

    if isAiRunning {
      runAIforNextStep()
    }
  }

  func game2048DidEnd(_ game2048: Game2048) {
    game2048.printOutGameState()
    log.debug("Ended")
    isGameEnd = true
  }
}

// MARK: Others

extension MainViewController {
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
    let defaults = UserDefaults.standard
    let number = NSNumber(value: aiSelectedChoiceIndex)
    defaults.set(number, forKey: "AIChoice")
  }

  func readAIChoice() {
    let defaults = UserDefaults.standard
    if let choiceNumber = defaults.object(forKey: "AIChoice") as? NSNumber {
      aiSelectedChoiceIndex = choiceNumber.intValue
    }
  }

  func saveDimension() {
    let defaults = UserDefaults.standard
    defaults.set(dimension, forKey: "Dimension")
  }

  func readDimension() {
    let defaults = UserDefaults.standard
    let storedDimension: Int = defaults.integer(forKey: "Dimension")
    if storedDimension > 0 {
      dimension = storedDimension
    }
  }

  func saveAnimationDuration() {
    let defaults = UserDefaults.standard
    let number = NSNumber(value: sharedAnimationDuration)
    defaults.set(number, forKey: "AnimationDuration")
  }

  func readAnimationDuration() {
    let defaults = UserDefaults.standard
    if let durationNumber = defaults.object(forKey: "AnimationDuration") as? NSNumber {
      sharedAnimationDuration = durationNumber.doubleValue
    }
  }

  func saveBestScore(_ score: Int) {
    let defaults = UserDefaults.standard
    defaults.set(score, forKey: String(format: "BestScore_%d", dimension))
  }

  func readBestScore() {
    let defaults = UserDefaults.standard
    mainView.bestScoreView.number = defaults.integer(forKey: String(format: "BestScore_%d", dimension))
  }

  func updateTargetScore() {
    let currentScore = mainView.gameBoardView.currentMaxTileNumber()
    if currentScore < 2048 {
      mainView.targetView.number = 2048
      return
    }

    var i: Double = 11
    while true {
      if Int(pow(Double(2.0), i)) <= currentScore, currentScore < Int(pow(Double(2.0), i + 1)) {
        mainView.targetView.number = Int(pow(Double(2.0), i + 1))
        break
      }
      i += 1
    }
  }
}
