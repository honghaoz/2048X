// Copyright © 2019 ChouTi. All rights reserved.

import UIKit

class AIAlgorithmCell: UITableViewCell {
  let titleLabel = UILabel()
  let selectionControl = BlackSelectionControl()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    backgroundColor = UIColor.clear
    selectionStyle = .none

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(titleLabel)

    titleLabel.text = "(Title)"
    titleLabel.textColor = UIColor.black
    titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    titleLabel.textAlignment = .left
    titleLabel.numberOfLines = 1

    selectionControl.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(selectionControl)
    selectionControl.isUserInteractionEnabled = false
  }

  private func setupConstraints() {
    let constraints = [
      NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: selectionControl, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 26),
      NSLayoutConstraint(item: selectionControl, attribute: .width, relatedBy: .equal, toItem: selectionControl, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: selectionControl, attribute: .centerY, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: selectionControl, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: selectionControl, attribute: .leading, multiplier: 1.0, constant: -10),
    ]

    NSLayoutConstraint.activate(constraints)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    selectionControl.isSelected = selected
  }
}
