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
    var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    var numberColor: UIColor = UIColor.black {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 5.0
        
        // TitleLabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        views["titleLabel"] = titleLabel
        self.addSubview(titleLabel)
        
        titleLabel.text = "SCORE"
        titleLabel.textColor = borderColor
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 900), for: NSLayoutConstraint.Axis.horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        // NumberLabel
        numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        views["numberLabel"] = numberLabel
        self.addSubview(numberLabel)
        
        numberLabel.text = "0"
        numberLabel.textColor = borderColor
        numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: numberLabelMaxFontSize)
        numberLabel.textAlignment = .center
        // Adjust font size dynamically
        numberLabel.numberOfLines = 1
        numberLabel.adjustsFontSizeToFitWidth = true
        numberLabel.minimumScaleFactor = 12.0 / numberLabel.font.pointSize // Mini font: 12.0
        numberLabel.baselineAdjustment = .alignCenters
        
        numberLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900), for: NSLayoutConstraint.Axis.horizontal)
        numberLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900), for: NSLayoutConstraint.Axis.vertical)
        numberLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        numberLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        metrics["padding"] = padding
        
        // TitleLabel constraints
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]", options: [], metrics: metrics, views: views))
        
        // ScoreLabel constraints
        self.addConstraint(numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[numberLabel]-(padding)-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=8)-[numberLabel]-(>=8)-|", options: [], metrics: metrics, views: views))
    }
}
