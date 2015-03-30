//
//  SettingViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/29/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    var mainContainerView: UIView!
    var animationDurationLabel: UILabel!
    var animationDurationNumberLabel: UILabel!
    var animationDurationNumberUnderscoreView: UIView!
    var animationDurationUnitLabel: UILabel!
    
    var animationDurationSlider: UISlider!
    
    var saveButton: BlackBorderButton!
    var cancelButton: BlackBorderButton!
    
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    let presentingAnimator = PresentingAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presentingAnimator.presentingViewSize = CGSize(width: ceil(screenWidth * 0.7), height: 120.0)
    }
    
    private func setupViews() {
        view.backgroundColor = SharedColors.BackgroundColor
        view.layer.borderColor = UIColor.blackColor().CGColor
        view.layer.borderWidth = 5.0
    }
}
