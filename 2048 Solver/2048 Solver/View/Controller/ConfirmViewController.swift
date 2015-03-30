//
//  ConfirmViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class ConfirmViewController: UIViewController {

    var titleLabel: UILabel!
    var okButton: BlackBorderButton!
    var cancelButton: BlackBorderButton!
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    let presentingAnimator = PresentingAnimator()
    
    var okClosure: (() -> ())? = nil
    var cancelClosure: (() -> ())? = nil
    
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
        
        titleLabel.text = "Start a new game?"
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: is320ScreenWidth ? 22 : 25)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 0
        
        // OK button
        okButton = BlackBorderButton()
        okButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        okButton.title = "Yes"
        okButton.addTarget(self, action: "okButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["okButton"] = okButton
        view.addSubview(okButton)
        
        // Cancel button
        cancelButton = BlackBorderButton()
        cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        cancelButton.title = "No"
        cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        views["cancelButton"] = cancelButton
        view.addSubview(cancelButton)
        
        // Auto Layout
        // H:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[titleLabel]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[okButton]-(-5)-[cancelButton(==okButton)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        // V:
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel][okButton(50)]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel][cancelButton]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
    
    func okButtonTapped(sender: UIButton) {
        logDebug()
        self.dismissViewControllerAnimated(true, completion: nil)
        okClosure?()
    }
    
    func cancelButtonTapped(sender: UIButton) {
        logDebug()
        self.dismissViewControllerAnimated(true, completion: nil)
        cancelClosure?()
    }
}

extension ConfirmViewController: UIViewControllerTransitioningDelegate {
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