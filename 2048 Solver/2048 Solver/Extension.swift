//
//  Extension.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/17/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import UIKit

var screenWidth: CGFloat { return UIScreen.mainScreen().bounds.size.width }
var screenHeight: CGFloat { return UIScreen.mainScreen().bounds.size.height }

var screenSize: CGSize { return UIScreen.mainScreen().bounds.size }
var screenBounds: CGRect { return UIScreen.mainScreen().bounds }

var isIpad: Bool { return UIDevice.currentDevice().userInterfaceIdiom == .Pad }

var is3_5InchScreen: Bool { return screenHeight ~= 480.0 }
var is4InchScreen: Bool { return screenHeight ~= 568.0 }
var isIphone6: Bool { return screenHeight ~= 667.0 }
var isIphone6Plus: Bool { return screenHeight ~= 736.0 }
var is320ScreenWidth: Bool { return screenWidth ~= 320.0 }

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func imageWithBorderRectangle(size: CGSize, borderWidth: CGFloat, borderColor: UIColor, fillColor: UIColor = UIColor.clearColor()) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: CGPointZero, size: size)
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextFillRect(context, rect)
        
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        CGContextSetLineWidth(context, borderWidth)
        CGContextStrokeRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(UIImage.imageWithColor(color), forState: state)
    }
}