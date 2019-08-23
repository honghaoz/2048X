// Copyright © 2019 ChouTi. All rights reserved.

import UIKit

class TileView: UIView, TileViewType {
  var number: Int = 0 {
    didSet {
      if number <= 0 {
        numberLabel.text = ""
        layer.borderColor = UIColor.clear.cgColor
      } else {
        numberLabel.text = String(number)
        layer.borderColor = borderColor.cgColor
      }
      tileBackgroundColor = SharedColors.tileBackgrounColorForNumber(number)
      tileNumberColor = SharedColors.tileLabelTextColorForNumber(number)
    }
  }

  let numberLabel = UILabel()

  private var padding: CGFloat = 5.0

  private var borderColor: UIColor = UIColor.black {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }

  private var tileNumberColor: UIColor = UIColor.black {
    didSet {
      numberLabel.textColor = tileNumberColor
    }
  }

  private var tileBackgroundColor: UIColor = UIColor.clear {
    didSet {
      backgroundColor = tileBackgroundColor
    }
  }

  // MARK: - Init Methods

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }

  private func setupViews() {
    var views = [String: UIView]()
    var metrics = [String: CGFloat]()

    layer.borderColor = borderColor.cgColor
    layer.borderWidth = 3.0

    numberLabel.translatesAutoresizingMaskIntoConstraints = false
    numberLabel.numberOfLines = 1
    numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
    numberLabel.minimumScaleFactor = 12.0 / numberLabel.font.pointSize
    numberLabel.adjustsFontSizeToFitWidth = true
    numberLabel.textAlignment = .center
    numberLabel.baselineAdjustment = .alignCenters

    numberLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900), for: NSLayoutConstraint.Axis.horizontal)
    numberLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 900), for: NSLayoutConstraint.Axis.vertical)
    numberLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    numberLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)

    views["numberLabel"] = numberLabel
    addSubview(numberLabel)

    metrics["padding"] = padding

    addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
    addConstraint(NSLayoutConstraint(item: numberLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=padding)-[numberLabel]-(>=padding)-|", options: [], metrics: metrics, views: views))
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=padding)-[numberLabel]-(>=padding)-|", options: [], metrics: metrics, views: views))
  }

  func flashTile(completion: ((Bool) -> Void)? = nil) {
//    numberLabel.textColor = self.backgroundColor
//    UIView.transition(with: numberLabel, duration: sharedAnimationDuration * 2, options: .transitionCrossDissolve, animations: { () -> Void in
//      self.numberLabel?.text = String(self.number)
//      self.numberLabel.textColor = UIColor.black
//    }, completion: nil)

    // Black flash tile
    backgroundColor = UIColor.black
    UIView.animate(withDuration: sharedAnimationDuration * 2, animations: { () -> Void in
      self.backgroundColor = self.tileBackgroundColor
    }, completion: { (finished) -> Void in
      completion?(finished)
    })
  }
}
