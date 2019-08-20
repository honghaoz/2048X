//
//  ConfirmViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTi

class ConfirmViewController: UIViewController {
    
    let titleLabel = UILabel()
    let okButton = BlackBorderButton()
    let cancelButton = BlackBorderButton()
    
    let animator = DropPresentingAnimator()
    
    var okClosure: (() -> ())? = nil
    var cancelClosure: (() -> ())? = nil
    var dismissClosure: (() -> ())? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        animator.animationDuration = 0.75
        animator.allowDragToDismiss = false
        animator.shouldDismissOnTappingOutsideView = true
        animator.presentingViewSize = CGSize(width: ceil(screenWidth * 0.7), height: 120.0)
        animator.overlayViewStyle = .Normal(UIColor(white: 0.0, alpha: 0.7))
        
        modalPresentationStyle = .Custom
        transitioningDelegate = animator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 5.0
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.text = "Ask me something?"
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: is320ScreenWidth ? 22 : 25)
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        
        // OK button
        okButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(okButton)
        okButton.title = "Yes"
        okButton.addTarget(self, action: #selector(ConfirmViewController.okButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        // Cancel button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        cancelButton.title = "No"
        cancelButton.addTarget(self, action: #selector(ConfirmViewController.cancelButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    private func setupConstraints() {
        let views = [
            "titleLabel" : titleLabel,
            "okButton" : okButton,
            "cancelButton" : cancelButton
        ]
        
        let metrics: [String : CGFloat] = [
            "border_width" : -view.layer.borderWidth
        ]
        
        var constraints = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[okButton]-(border_width)-[cancelButton(==okButton)]|", options: [.AlignAllTop, .AlignAllBottom], metrics: metrics, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel][okButton(50)]|", options: [], metrics: metrics, views: views)
        
        NSLayoutConstraint.activateConstraints(constraints)
    }
}

extension ConfirmViewController {
    func okButtonTapped(sender: UIButton) {
        log.debug()
        dismiss(animated: true, completion: nil)
        
        okClosure?()
        dismissClosure?()
    }
    
    func cancelButtonTapped(sender: UIButton) {
        log.debug()
        dismiss(animated: true, completion: nil)
        
        cancelClosure?()
        dismissClosure?()
    }
}

//extension ConfirmViewController: UIViewControllerTransitioningDelegate {
//    // MARK: - UIViewControllerTransitioningDelegate
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        presentingAnimator.presenting = true
//        return presentingAnimator
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        presentingAnimator.presenting = false
//        return presentingAnimator
//    }
//}
