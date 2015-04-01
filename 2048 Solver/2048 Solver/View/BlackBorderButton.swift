//
//  BlackBorderButton.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/27/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class BlackBorderButton: UIButton {
    
    var title: String = "Button" {
        didSet {
            self.setTitle(title, forState: UIControlState.Normal)
        }
    }
    var titleLabelMaxFontSize: CGFloat = 24 {
        didSet {
            self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabelMaxFontSize)
        }
    }
    
    private let disabledColor = UIColor(white: 0.0, alpha: 0.5)
    
    override var enabled: Bool {
        didSet {
            if enabled {
                self.layer.borderColor = UIColor.blackColor().CGColor
            } else {
                self.layer.borderColor = disabledColor.CGColor
            }
        }
    }
    
    // MARK:- Init Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 5.0
        
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabelMaxFontSize)
        self.titleLabel?.textAlignment = .Center
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 12.0 / self.titleLabel!.font.pointSize // Mini font: 12.0
        self.titleLabel?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.setTitleColor(SharedColors.BackgroundColor, forState: UIControlState.Highlighted)
        self.setTitleColor(disabledColor, forState: UIControlState.Disabled)
        
        self.setBackgroundColor(SharedColors.BackgroundColor, forUIControlState: UIControlState.Normal)
        self.setBackgroundColor(UIColor.blackColor(), forUIControlState: UIControlState.Highlighted)
    }
}
