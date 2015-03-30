//
//  BlackSlider.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/30/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class BlackSlider: UISlider {
    var trackHeight: CGFloat = 5.0
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        let y =  (bounds.height - trackHeight) / 2.0
        return CGRect(x: 0, y: y, width: bounds.width, height: trackHeight)
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
        self.setMinimumTrackImage(UIImage.imageWithColor(UIColor.blackColor()), forState: UIControlState.Normal)
        self.setMaximumTrackImage(UIImage.imageWithColor(UIColor.blackColor()), forState: UIControlState.Normal)
        self.setThumbImage(UIImage.imageWithBorderRectangle(CGSize(width: 26, height: 26), borderWidth: 10.0, borderColor: UIColor.blackColor(), fillColor: SharedColors.BackgroundColor) , forState: UIControlState.Normal)
    }
}
