// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

class NTuplesBuilder {
  private var all: [[[Int]]] = [[[Int]]]()
  private var main: [[Int]] = [[Int]]()

  private var numValues: Int
  private var minWeight: Double
  private var maxWeight: Double
  // private var removeSubtuples: Bool

  init(numValues: Int, minWeight: Double, maxWeight: Double) {
    self.maxWeight = maxWeight
    self.minWeight = minWeight
    self.numValues = numValues
    // self.removeSubtuples = removeSubtuples
  }

  func addTuple(locations: [Int]) {
    var sortedLocations = locations
    sortedLocations.sortInPlace { $0 < $1 }

    for sortedTuple in CollectionUtils.flatten(all) {
      if allItemsMatch(sortedTuple, container2: sortedLocations) {
        return
      }
    }

    var tmp = [[Int]]()
    tmp.append(locations)

    all.append(tmp)
    main.append(sortedLocations)
  }

  func buildNTuples() -> NTuples {
    var newMain = [[Int]]()
    newMain += main

    let mainTuples = createNTuplesFromLocations(newMain)
    return NTuples(tuples: mainTuples)
  }

  func createNTuplesFromLocations(newMain: [[Int]]) -> [NTuple] {
    var mainNTuples = [NTuple]()
    for location in newMain {
      mainNTuples.append(NTuple.newWithRandomWeights(numValues, locations: location, minWeight: minWeight, maxWeight: maxWeight))
    }
    return mainNTuples
  }

//
//    func getMainWithoutDuplicates() -> Array<[Int]> {
//        var newMain = Array<[Int]>()
//        var n = main.count
//        for a in 0..<n {
//            var aContainsInB = false
//            for var b = 0; b < n && !aContainsInB; ++b {
//                if (a == b || main[a].count > main[b].count) {
//                    continue;
//                }
//                aContainsInB
//            }
//        }
//    }
}
