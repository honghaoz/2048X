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
            setTitle(title, forState: .Normal)
        }
    }
    
    var titleLabelMaxFontSize: CGFloat = 24 {
        didSet {
            titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabelMaxFontSize)
        }
    }
    
    private let disabledColor = UIColor(white: 0.0, alpha: 0.5)
    
    override var enabled: Bool {
        didSet {
            if enabled {
                layer.borderColor = UIColor.blackColor().CGColor
            } else {
                layer.borderColor = disabledColor.CGColor
            }
        }
    }
    
    // MARK:- Init Methods    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
    }
    
    private func setupViews() {
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 5.0
        
        titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabelMaxFontSize)
        titleLabel?.textAlignment = .Center
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 12.0 / (titleLabel?.font.pointSize ?? 24.0) // Mini font: 12.0
        titleLabel?.baselineAdjustment = .AlignCenters
        
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(SharedColors.BackgroundColor, forState: .Highlighted)
        setTitleColor(disabledColor, forState: .Disabled)
        
        setBackgroundColor(SharedColors.BackgroundColor, forUIControlState: .Normal)
        setBackgroundColor(UIColor.blackColor(), forUIControlState: .Highlighted)
    }
}
