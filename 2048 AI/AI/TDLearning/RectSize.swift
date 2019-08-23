// Copyright © 2019 ChouTi. All rights reserved.

import Foundation

struct RectSize: Equatable {
  let columns: Int
  let rows: Int

  var width: Int {
    return columns
  }

  var height: Int {
    return rows
  }

  init(rows: Int, cols: Int) {
    self.rows = rows
    self.columns = cols
  }

  init(size: Int) {
    self.init(rows: size, cols: size)
  }

  func contains(position: BoardPos) -> Bool {
    return position.row() >= 0 && position.row() < height && position.column() >= 0 && position.column() < width
  }
}

func == (lhs: RectSize, rhs: RectSize) -> Bool {
  if lhs.columns == rhs.columns, lhs.rows == rhs.rows {
    return true
  }
  return false
}
