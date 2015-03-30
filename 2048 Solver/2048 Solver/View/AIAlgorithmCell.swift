//
//  AIAlgorithmCell.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/30/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class AIAlgorithmCell: UITableViewCell {

    var titleLabel: UILabel!
    var selectionControl: BlackSelectionControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    private func setupViews() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel = UILabel()
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(titleLabel)
        
        titleLabel.text = "(Title)"
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.numberOfLines = 1
        
        let cCenterY = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(cCenterY)
        let cLeading = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 8)
        contentView.addConstraint(cLeading)
        
        selectionControl = BlackSelectionControl()
        selectionControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(selectionControl)
        selectionControl.userInteractionEnabled = false
        
        let cWidth = NSLayoutConstraint(item: selectionControl, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.0, constant: 26)
        let cRatio = NSLayoutConstraint(item: selectionControl, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: selectionControl, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0)
        selectionControl.addConstraints([cWidth, cRatio])
        
        let cCenterY1 = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: selectionControl, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        contentView.addConstraint(cCenterY1)
        let cTrailing = NSLayoutConstraint(item: selectionControl, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: -8)
        contentView.addConstraint(cTrailing)
        
        let cHorizontalSpacing = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: selectionControl, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -10)
        contentView.addConstraint(cHorizontalSpacing)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionControl.selected = selected
    }
}
