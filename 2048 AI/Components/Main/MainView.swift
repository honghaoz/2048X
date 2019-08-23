//
//  MainView.swift
//  2048X AI
//
//  Created by Honghao Zhang on 8/22/19.
//  Copyright © 2019 Honghao Zhang. All rights reserved.
//

import UIKit

class MainView: UIView {
  let gameModel: Game2048
  var scoreView: ScoreView!
  var bestScoreView: ScoreView!
  var targetView: ScoreView!

  var gameBoardView: GameBoardView!

  var undoButton: BlackBorderButton!
  var hintButton: BlackBorderButton!
  var runAIButton: BlackBorderButton!
  var newGameButton: BlackBorderButton!
  var settingsButton: BlackBorderButton!

  // FIXME: game model is required because the gameboard needs it to
  // initialize the tiles.
  required init(gameModel: Game2048) {
    self.gameModel = gameModel
    super.init(frame: .zero)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func commonInit() {
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    backgroundColor = SharedColors.BackgroundColor

    metrics["padding"] = is3_5InchScreen ? 3.0 : 8.0

    // GameBoardView
    gameBoardView = GameBoardView()
    gameBoardView.backgroundColor = backgroundColor
    gameBoardView.gameModel = gameModel

    gameBoardView.translatesAutoresizingMaskIntoConstraints = false
    views["gameBoardView"] = gameBoardView
    addSubview(gameBoardView)

    // GameBoard Size
    let gameBoardWidth = screenWidth * 0.9
    gameBoardView.constrainTo(width: gameBoardWidth)
    gameBoardView.constrain(.width, equalTo: .height)

    // GameBoard center horizontally
    gameBoardView.constrain(.centerX, toView: self)
    // 3.5 inch Screen has a smaller height, this will be broken
    gameBoardView.constrain(.centerY, toView: self, priority: .init(750))

    // ScoreView
    scoreView = ScoreView()
    scoreView.translatesAutoresizingMaskIntoConstraints = false
    views["scoreView"] = scoreView
    addSubview(scoreView)

    scoreView.titleLabel.text = "SCORE"
    scoreView.numberLabelMaxFontSize = is3_5InchScreen ? 20 : 28
    scoreView.numberLabel.textAlignment = .right
    scoreView.number = 0

    // BestScoreView
    bestScoreView = ScoreView()
    bestScoreView.translatesAutoresizingMaskIntoConstraints = false
    views["bestScoreView"] = bestScoreView
    addSubview(bestScoreView)

    bestScoreView.titleLabel.text = "HIGHEST"
    bestScoreView.numberLabelMaxFontSize = is3_5InchScreen ? 20 : 28
    bestScoreView.numberLabel.textAlignment = .right
    bestScoreView.number = 0

    // TargetView
    targetView = ScoreView()
    targetView.translatesAutoresizingMaskIntoConstraints = false
    views["targetView"] = targetView
    addSubview(targetView)

    targetView.titleLabel.text = "TARGET"
    targetView.numberLabelMaxFontSize = 38
    targetView.number = 2048 // "∞"

    metrics["targetViewHeight"] = is3_5InchScreen ? gameBoardWidth / 3.6 : gameBoardWidth / 3.0
    // TargetView is square
    targetView.constrain(.width, equalTo: .height)

    // New Game Button
    newGameButton = BlackBorderButton()
    newGameButton.translatesAutoresizingMaskIntoConstraints = false
    newGameButton.title = "New Game"
    views["newGameButton"] = newGameButton
    addSubview(newGameButton)

    // Run AI Button
    runAIButton = BlackBorderButton()
    runAIButton.translatesAutoresizingMaskIntoConstraints = false
    runAIButton.title = "Run"
    views["runAIButton"] = runAIButton
    addSubview(runAIButton)

    // Undo Button
    undoButton = BlackBorderButton()
    undoButton.translatesAutoresizingMaskIntoConstraints = false
    undoButton.title = "Undo"
    views["undoButton"] = undoButton
    addSubview(undoButton)

    // Hint Button
    hintButton = BlackBorderButton()
    hintButton.translatesAutoresizingMaskIntoConstraints = false
    hintButton.title = "Hint"
    views["hintButton"] = hintButton
    addSubview(hintButton)

    // Settings Button
    settingsButton = BlackBorderButton()
    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.title = "Settings"
    views["settingsButton"] = settingsButton
    addSubview(settingsButton)

    //        metrics["buttonHeight"] = is3_5InchScreen ? metrics["targetViewHeight"]! / 2.0 : 50.0
    metrics["buttonHeight"] = (metrics["targetViewHeight"]! - metrics["padding"]!) / 2.0

    // H
    NSLayoutConstraint.constraints(withVisualFormat: "H:[targetView]-padding-[scoreView]", options: .alignAllTop, metrics: metrics, views: views).activate()
    NSLayoutConstraint.constraints(withVisualFormat: "H:[targetView]-padding-[bestScoreView]", options: .alignAllBottom, metrics: metrics, views: views).activate()
    NSLayoutConstraint.constraints(withVisualFormat: "H:[undoButton]-padding-[hintButton(==undoButton)]-padding-[runAIButton(==hintButton)]", options: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views).activate()
    NSLayoutConstraint.constraints(withVisualFormat: "H:[newGameButton]-padding-[settingsButton(==newGameButton)]", options: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views).activate()

    // V
    NSLayoutConstraint.constraints(withVisualFormat: "V:[targetView(targetViewHeight)]-padding-[gameBoardView]-padding-[undoButton(buttonHeight)]-padding-[newGameButton(buttonHeight)]", options: .alignAllLeading, metrics: metrics, views: views).activate()
    NSLayoutConstraint.constraints(withVisualFormat: "V:[scoreView]-padding-[bestScoreView(==scoreView)]-padding-[gameBoardView]-padding-[runAIButton(buttonHeight)]-padding-[settingsButton(buttonHeight)]", options: .alignAllTrailing, metrics: metrics, views: views).activate()

    // Target view top spacing >= 22
    targetView.topAnchor.constrain(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 22)
  }
}
