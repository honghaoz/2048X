//
//  ScoreView.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    
    var titleLabel: UILabel!
    var numberLabel: UILabel!
    var number: Int = 0 {
        didSet {
            self.numberLabel.text = String(number)
        }
    }
    
    var padding: CGFloat = 12.0
    var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    var numberColor: UIColor = UIColor.blackColor() {
        didSet {
            self.numberLabel.textColor = numberColor
        }
    }
    var numberLabelMaxFontSize: CGFloat = 24 {
        didSet {
            numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: numberLabelMaxFontSize)
        }
    }
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()
    
    // MARK:- Init Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 5.0
        
        // TitleLabel
        titleLabel = UILabel()
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["titleLabel"] = titleLabel
        self.addSubview(titleLabel)
        
        titleLabel.text = "SCORE"
        titleLabel.textColor = borderColor
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 1
        
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        titleLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        titleLabel.setContentHuggingPriority(900, forAxis: UILayoutConstraintAxis.Horizontal)
        titleLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        
        // NumberLabel
        numberLabel = UILabel()
        numberLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        views["numberLabel"] = numberLabel
        self.addSubview(numberLabel)
        
        numberLabel.text = "0"
        numberLabel.textColor = borderColor
        numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: numberLabelMaxFontSize)
        numberLabel.textAlignment = NSTextAlignment.Center
        // Adjust font size dynamically
        numberLabel.numberOfLines = 1
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.minimumScaleFactor = 12.0 / numberLabel.font.pointSize // Mini font: 12.0
        numberLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        
        numberLabel.setContentCompressionResistancePriority(900, forAxis: UILayoutConstraintAxis.Horizontal)
        numberLabel.setContentCompressionResistancePriority(900, forAxis: UILayoutConstraintAxis.Vertical)
        numberLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        numberLabel.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        
        metrics["padding"] = padding
        
        // TitleLabel constraints
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        
        // ScoreLabel constraints
        self.addConstraint(NSLayoutConstraint(item: numberLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[numberLabel]-(padding)-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=8)-[numberLabel]-(>=8)-|", options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    }
}
