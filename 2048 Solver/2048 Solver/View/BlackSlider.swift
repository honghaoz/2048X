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
        self.setMinimumTrackImage(UIImage.imageWithColor(UIColor.blackColor()), forState: .Normal)
        self.setMaximumTrackImage(UIImage.imageWithColor(UIColor.blackColor()), forState: .Normal)
        let thumbImage = UIImage.imageWithBorderRectangle(CGSize(width: 26, height: 26),
                                                          borderWidth: 10.0,
                                                          borderColor: UIColor.blackColor(),
                                                          fillColor: SharedColors.BackgroundColor)
        self.setThumbImage(thumbImage, forState: .Normal)
    }
}
