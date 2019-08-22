// Copyright © 2019 ChouTi. All rights reserved.

import Foundation
func == (lhs: BoardPos, rhs: BoardPos) -> Bool {
  return lhs._row == rhs._row && lhs._column == rhs._column
}

class BoardPos: Equatable {
  fileprivate var _row: Int
  fileprivate var _column: Int

  init(row: Int, col: Int) {
    self._row = row
    self._column = col
  }

  func row() -> Int {
    return _row
  }

  func column() -> Int {
    return _column
  }

  // add two BoardPos
  func add(pos: BoardPos) -> BoardPos {
    return BoardPos(row: _row + pos._row, col: _column + pos._column)
  }
}
