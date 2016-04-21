//
//  AIAlgorithmCell.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/30/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class AIAlgorithmCell: UITableViewCell {

    let titleLabel = UILabel()
    let selectionControl = BlackSelectionControl()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        titleLabel.text = "(Title)"
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.textAlignment = .Left
        titleLabel.numberOfLines = 1
        
        selectionControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionControl)
        selectionControl.userInteractionEnabled = false
    }
    
    private func setupConstraints() {
        let constraints = [
            NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: selectionControl, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 26),
            NSLayoutConstraint(item: selectionControl, attribute: .Width, relatedBy: .Equal, toItem: selectionControl, attribute: .Height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: selectionControl, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: selectionControl, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .LessThanOrEqual, toItem: selectionControl, attribute: .Leading, multiplier: 1.0, constant: -10)
        ]
        
        NSLayoutConstraint.activateConstraints(constraints)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionControl.selected = selected
    }
}
