//
//  TileViewType.swift
//  2048X AI
//
//  Created by Honghao Zhang on 8/23/19.
//  Copyright © 2019 Honghao Zhang. All rights reserved.
//

import UIKit

protocol TileViewType: UIView {
  var number: Int { get set }
  var numberLabel: UILabel { get }
  func flashTile(completion: ((Bool) -> Void)?)
}
