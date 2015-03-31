//
//  GameEndViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/31/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class GameEndViewController: UIViewController {
    
    var titleLabel: UILabel!
    var undoButton: BlackBorderButton!
    var startButton: BlackBorderButton!
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    let presentingAnimator = PresentingAnimator()
    
    var undoClosure: (() -> ())? = nil
    var startClosure: (() -> ())? = nil
    var dismissClosure: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presentingAnimator.presentingViewSize = CGSize(width: ceil(screenWidth * 0.7), height: 120.0)
    }
    
    private func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor
        view.layer.borderColor = UIColor.blackColor().CGColor
        view.layer.borderWidth = 5.0
        
        // Title Label
        titleLabel = UILabel()
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["titleLabel"] = titleLabel
        view.addSubview(titleLabel)
        
        titleLabel.text = "Game Over!"
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: is320ScreenWidth ? 22 : 25)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        
        // undoButton
        undoButton = BlackBorderButton()
        undoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        undoButton.title = "Undo"
        undoButton.addTarget(self, action: "undoButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["undoButton"] = undoButton
        view.addSubview(undoButton)
        
        // Start a new game button
        startButton = BlackBorderButton()
        startButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        startButton.title = "Try Again"
        startButton.addTarget(self, action: "startButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["startButton"] = startButton
        view.addSubview(startButton)
        
        // Auto Layout
        // H:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[titleLabel]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[undoButton]-(-5)-[startButton(==undoButton)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        // V:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel][undoButton(50)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel][startButton]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
    
    func undoButtonTapped(sender: UIButton) {
        logDebug()
        self.dismissViewControllerAnimated(true, completion: nil)
        undoClosure?()
        dismissClosure?()
    }
    
    func startButtonTapped(sender: UIButton) {
        logDebug()
        self.dismissViewControllerAnimated(true, completion: nil)
        startClosure?()
        dismissClosure?()
    }
}

extension GameEndViewController: UIViewControllerTransitioningDelegate {
    // MARK: - UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingAnimator.presenting = true
        return presentingAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentingAnimator.presenting = false
        return presentingAnimator
    }
}
