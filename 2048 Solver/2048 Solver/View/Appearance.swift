//
//  Appearance.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/8/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import UIKit

var sharedAnimationDuration: NSTimeInterval = 0.12

struct SharedFontSize {
    static func tileFontSizeForDimension(dimension: Int) -> Int {
        switch dimension {
        case 0:
            return 150
        case 1:
            return 100
        case 2:
            return 80
        case 3:
            return 50
        case 4:
            return 40
        case 5:
            return 32
        case 6:
            return 28
        case 7:
            return 25
        case 8:
            return 22
        case 9:
            return 18
        case 10:
            return 16
        case 11:
            return 13
        case 12:
            return 11
        default:
            return 10
        }
    }
}

struct SharedColors {
    static let BackgroundColor = UIColor(red: 160.0/255.0, green: 167.0/255.0, blue: 147.0/255.0, alpha: 1.0)
    static func tileBackgrounColorForNumber(number: Int) -> UIColor {
        switch number {
        case 0:
            return UIColor(red:151/255.0, green:158/255.0, blue:139/255.0, alpha:255/255.0)
        case 2:
            return UIColor(red:143/255.0, green:149/255.0, blue:132/255.0, alpha:255/255.0)
        case 4:
            return UIColor(red:128/255.0, green:133/255.0, blue:117/255.0, alpha:255/255.0)
        case 8:
            return UIColor(red:111/255.0, green:116/255.0, blue:102/255.0, alpha:255/255.0)
        case 16:
            return UIColor(red:96/255.0, green:100/255.0, blue:88/255.0, alpha:255/255.0)
        case 32:
            return UIColor(red:87/255.0, green:91/255.0, blue:80/255.0, alpha:255/255.0)
        case 64:
            return UIColor(red:79/255.0, green:83/255.0, blue:73/255.0, alpha:255/255.0)
        case 128:
            return UIColor(red:79/255.0, green:83/255.0, blue:73/255.0, alpha:255/255.0)
        case 256:
            return UIColor(red:64/255.0, green:66/255.0, blue:58/255.0, alpha:255/255.0)
        case 512:
            return UIColor(red:47/255.0, green:49/255.0, blue:43/255.0, alpha:255/255.0)
        case 1024:
            return UIColor(red:40/255.0, green:41/255.0, blue:36/255.0, alpha:255/255.0)
        case 2048:
            return UIColor(red:32/255.0, green:33/255.0, blue:29/255.0, alpha:255/255.0)
        default:
            return UIColor(red:15/255.0, green:16/255.0, blue:14/255.0, alpha:255/255.0)
        }
    }
    
    static func tileLabelTextColorForNumber(number: Int) -> UIColor {
        if number > 100 {
            return SharedColors.BackgroundColor
        } else {
            return UIColor.blackColor()
        }
    }
}
