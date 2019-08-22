// Copyright © 2019 ChouTi. All rights reserved.

import UIKit

class BlackSelectionControl: UIControl {
  private let selectionDotView = UIView()

  override var bounds: CGRect {
    didSet {
      updateSelectionDotView()
    }
  }

  // MARK: - Init Methods

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  private func commonInit() {
    setupViews()
  }

  private func setupViews() {
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 5.0

    selectionDotView.backgroundColor = UIColor.black
    updateSelectionDotView()

    addSubview(selectionDotView)
  }

  func updateSelectionDotView() {
    selectionDotView.frame = frameForSelectionDotView()
  }

  func frameForSelectionDotView() -> CGRect {
    let width = bounds.width * 0.4
    let height = bounds.height * 0.4
    let x = (bounds.width - width) / 2.0
    let y = (bounds.height - height) / 2.0
    return CGRect(x: x, y: y, width: width, height: height)
  }

  override var isHighlighted: Bool {
    didSet {
      selectionDotView.alpha = isHighlighted ? 1.0 : 0.0
    }
  }

  override var isSelected: Bool {
    didSet {
      selectionDotView.alpha = isSelected ? 1.0 : 0.0
    }
  }
}
