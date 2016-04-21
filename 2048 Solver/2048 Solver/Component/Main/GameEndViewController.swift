//
//  GameEndViewController.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/31/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import Google
import ChouTi

class GameEndViewController: ConfirmViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Game Over!"
        cancelButton.title = "Undo"
        okButton.title = "Retry"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: "Game End View")
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createScreenView().build() as Dictionary)
    }
}
