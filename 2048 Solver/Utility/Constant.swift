//
//  Constant.swift
//  4AM
//
//  Created by Honghao Zhang on 2015-11-15.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class Log {
    func debug(_ s: String) {
        print("DEBUG: ", s)
    }

    func verboseLog(_ s: String) {
        print("VERBOSE: ", s)
    }
}

class Global {
  static let log = Log()
  static let verboseLog = Log()

  #if DEBUG
  static let DEBUG = true
  #else
  static let DEBUG = false
  #endif
}

var log = Global.log
var verboseLog = Global.verboseLog
let DEBUG = Global.DEBUG
