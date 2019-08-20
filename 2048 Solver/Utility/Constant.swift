//
//  Constant.swift
//  4AM
//
//  Created by Honghao Zhang on 2015-11-15.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

class Log {
    func debug(_ s: String = "") {
        print("DEBUG: ", s)
    }

    func verbose(_ s: String = "") {
        print("VERBOSE: ", s)
    }

    func error(_ s: String = "") {
        print("ERROR: ", s)
    }
}

class Global {
  static let log = Log()
  static let verbose = Log()
  static let error = Log()

  #if DEBUG
  static let DEBUG = true
  #else
  static let DEBUG = false
  #endif
}

var log = Global.log
var verboseLog = Global.verbose
var error = Global.error

let DEBUG = Global.DEBUG


// MARK: - Device Related
var isIOS7: Bool = !isIOS8
let isIOS8: Bool = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1

var screenWidth: CGFloat { return UIScreen.main.bounds.size.width }
var screenHeight: CGFloat { return UIScreen.main.bounds.size.height }

var screenSize: CGSize { return UIScreen.main.bounds.size }
var screenBounds: CGRect { return UIScreen.main.bounds }

var isIpad: Bool { return UIDevice.current.userInterfaceIdiom == .pad }

var is3_5InchScreen: Bool { return screenHeight ~= 480.0 }
var is4InchScreen: Bool { return screenHeight ~= 568.0 }
var isIphone6: Bool { return screenHeight ~= 667.0 }
var isIphone6Plus: Bool { return screenHeight ~= 736.0 }

var is320ScreenWidth: Bool { return screenWidth ~= 320.0 }
