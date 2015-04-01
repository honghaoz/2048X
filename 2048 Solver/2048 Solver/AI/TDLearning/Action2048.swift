//
//  Action2048.swift
//  2048game
//
//  Created by yansong li on 2015-03-26.
//  Copyright (c) 2015 yansong li. All rights reserved.
//

import Foundation

enum Action2048 {
    case UP
    case RIGHT
    case DOWN
    case LEFT
    
    static func rawValue(action: Action2048) -> (Int, Int, Int) {
        switch(action) {
        case .UP:
            return (0, 0, -1)
        case .RIGHT:
            return (1, 1, 0)
        case .DOWN:
            return (2, 0, 1)
        case .LEFT:
            return (3, -1, 0)
        default:
            return (-1, -1, -1)
        }
    }
    
    static func randomAction() -> Action2048 {
        var rd =  arc4random_uniform(4)
        
        switch(rd) {
        case 0:
            return .UP
        case 1:
            return .DOWN
        case 2:
            return .RIGHT
        case 3:
            return .LEFT
        default:
            return .UP
        }
    }
    
}