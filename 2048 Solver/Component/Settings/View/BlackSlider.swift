//
//  BlackSlider.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/30/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import UIKit
import ChouTiUI

class BlackSlider: UISlider {
    var trackHeight: CGFloat = 5.0

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
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
        self.setMinimumTrackImage(UIImage.imageWithColor(UIColor.black), for: .normal)
        self.setMaximumTrackImage(UIImage.imageWithColor(UIColor.black), for: .normal)
        let thumbImage = UIImage.imageWithBorderRectangle(size: CGSize(width: 26, height: 26),
                                                          borderWidth: 10.0,
                                                          borderColor: UIColor.black,
                                                          fillColor: SharedColors.BackgroundColor)
        self.setThumbImage(thumbImage, for: .normal)
    }
}

extension UIImage {
    class func imageWithBorderRectangle(size: CGSize, borderWidth: CGFloat, borderColor: UIColor, fillColor: UIColor = UIColor.clear) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: .zero, size: size)

        context?.setFillColor(fillColor.cgColor)
        context?.fill(rect)

        context?.setStrokeColor(borderColor.cgColor)
        context?.setLineWidth(borderWidth)
        context?.stroke(rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return image
    }

}
