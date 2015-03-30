//
//  PresentingAnimator.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool!
    var presentingViewSize: CGSize!
    var animationDuration: NSTimeInterval = 0.8
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromViewController.view
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toViewController.view
        let containerView = transitionContext.containerView()
        
        // Final Frame
        let x = (containerView.bounds.width - presentingViewSize.width) / 2.0
        let y = (containerView.bounds.height - presentingViewSize.height) / 2.0
        let toViewFinalFrame = CGRect(x: x, y: y, width: presentingViewSize.width, height: presentingViewSize.height)
        
        if self.presenting! {
            fromView.tintAdjustmentMode = UIViewTintAdjustmentMode.Dimmed
            fromView.zhAddDimmedOverlayView(animated: true)
            
            // Start Frame
            let toViewStartFrame = CGRect(x: toViewFinalFrame.origin.x, y: -(presentingViewSize.height + 5), width: toViewFinalFrame.width, height: toViewFinalFrame.height)
            toView.frame = toViewStartFrame
            transitionContext.containerView().addSubview(toView)
            
            UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                toView.frame = toViewFinalFrame
                }, completion: { finished -> Void in
                    transitionContext.completeTransition(true)
            })
        } else {
            toView.tintAdjustmentMode = UIViewTintAdjustmentMode.Normal
            toView.zhRemoveDimmedOverlayView(animated: true)
            
            transitionContext.containerView().addSubview(fromView)
            let toViewFinalFrame = CGRect(x: toViewFinalFrame.origin.x, y: screenHeight + presentingViewSize.height + 5, width: toViewFinalFrame.width, height: toViewFinalFrame.height)
            
            UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                fromView.frame = toViewFinalFrame
//                fromView.transform = CGAffineTransformMakeRotation((30.0 * CGFloat(M_PI)) / 180.0)
                }, completion: { finished -> Void in
                    transitionContext.completeTransition(true)
            })
        }
    }
}

extension UIView {
    func zhAddDimmedOverlayView(#animated: Bool, completion: ((Bool) -> ())? = nil) {
        let overlayView = UIView()
        overlayView.frame = self.bounds
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        overlayView.tag = 142301
        
        if !animated {
            self.addSubview(overlayView)
            completion?(true)
            return
        }
        
        overlayView.alpha = 0.0
        self.addSubview(overlayView)
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            overlayView.alpha = 1.0
        }) { (finished) -> Void in
            completion?(finished)
        }
    }
    
    func zhRemoveDimmedOverlayView(#animated: Bool, completion: ((Bool) -> ())? = nil) {
        let overlayView = self.viewWithTag(142301)
        if !animated {
            overlayView?.removeFromSuperview()
            completion?(true)
            return
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            overlayView?.alpha = 0.0
        }) { (finished) -> Void in
            overlayView?.removeFromSuperview()
            completion?(finished)
        }
    }
}