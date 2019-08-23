// Copyright © 2019 ChouTi. All rights reserved.

import ChouTiUI
import UIKit

class BlackBorderButton: UIButton {
  var title: String = "Button" {
    didSet {
      setTitle(title, for: .normal)
    }
  }

  private var titleLabelMaxFontSize: CGFloat = 22 {
    didSet {
      titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabelMaxFontSize)
    }
  }

  private let disabledColor = UIColor(white: 0.0, alpha: 0.5)

  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        layer.borderColor = UIColor.black.cgColor
      } else {
        layer.borderColor = disabledColor.cgColor
      }
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

    titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: titleLabelMaxFontSize)
    titleLabel?.textAlignment = .center
    titleLabel?.numberOfLines = 1
    titleLabel?.adjustsFontSizeToFitWidth = true
    titleLabel?.minimumScaleFactor = 12.0 / (titleLabel?.font.pointSize ?? 24.0) // Mini font: 12.0
    titleLabel?.baselineAdjustment = .alignCenters

    setTitleColor(UIColor.black, for: .normal)
    setTitleColor(SharedColors.BackgroundColor, for: .highlighted)
    setTitleColor(disabledColor, for: .disabled)

    setBackgroundColor(SharedColors.BackgroundColor, for: .normal)
    setBackgroundColor(UIColor.black, for: .highlighted)
  }
}

extension UIButton {
  func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
    setBackgroundImage(UIImage.imageWithColor(color), for: state)
  }
}
