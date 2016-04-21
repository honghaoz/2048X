//
//  Constant.swift
//  4AM
//
//  Created by Honghao Zhang on 2015-11-15.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Loggerithm

class Global {
	static let log = Loggerithm()
	static let verboseLog = Loggerithm()
	
	#if DEBUG
	static let DEBUG = true
	#else
	static let DEBUG = false
	#endif
}

var log = Global.log
var verboseLog = Global.verboseLog
let DEBUG = Global.DEBUG
