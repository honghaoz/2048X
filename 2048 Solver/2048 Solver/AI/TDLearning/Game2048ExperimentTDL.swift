//
//  Game2048ExperimentTDL.swift
//  2048 Solver
//
//  Created by yansong li on 2015-03-31.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

class Game2048ExperimentTDL {
    func RunMe() {
        println("Run Me")
        
        var tdlGame2048 = TDLGame2048()
        
        
        var path = "NTuples.archieves"
        var vFunction:NTuples
        
        if let archived = tdlGame2048.currentNTuples {
            vFunction = archived
        } else {
            var lines = NTuplesAllStraightFactory(tupleLength: 4, boardSize: State2048.METRIC.BOARD_SIZE, numValues: 15, minWeight: 0, maxWeight: 0).createRandomIndividual()
            
            var squares = NTuplesAllRectanglesFactory(rectSize: RectSize(size: 2), boardSize: State2048.METRIC.BOARD_SIZE, numValue: 15, minWeight: 0, maxWeight: 0).createRandomIndividual()
            
            // Question1, vFunction is passed by value not reference
            vFunction = lines.add(squares)
        }
        
        
        for i in 1..<100000 {
            println("Start a NEW ONE ---------\(i)")
            tdlGame2048.TDAfterstateLearn(vFunction, explorationRate: 0.001, learningRate: 0.01)
            println("Finish this ONE ---------\(i)")
            if (i % 501 == 0) {
                vFunction.saveNTuplesForPath(path)
                evaluatePerformance(tdlGame2048, vFunctions: vFunction, numEpisodes: 10, e: i)
            }
        }
    }
    
    func evaluatePerformance(game:TDLGame2048, vFunctions:NTuples, numEpisodes:Int, e:Int) {
        var performance = 0
        var ratio = 0
        var maxTile = 0
        
        for i in 0..<numEpisodes {
            var res = game.playByAfterstates(vFunctions)
            
            performance += res.score()
            
            if res.maxTile() >= 2048 {
                ratio += 1
            }
            if res.maxTile() > maxTile {
                maxTile = res.maxTile()
            }
            println("This time we got \(res.maxTile())")
        }
        var eF = e.format("5")
        var sF = (Double(performance)/Double(numEpisodes)).format("6")
        var rF = (Double(ratio)/Double(numEpisodes)).format("6")
        println("After \(eF) games: avg score = \(sF), avg ratio = \(rF), maxtile = \(maxTile)")
    }
    
}
