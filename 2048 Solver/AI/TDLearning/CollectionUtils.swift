// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

class CollectionUtils {
  class func flatten(arr: [[[Int]]]) -> [[Int]] {
    var res = [[Int]]()
    for list in arr {
      res += list
    }
    return res
  }
}
