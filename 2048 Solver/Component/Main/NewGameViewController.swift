// Copyright © 2019 ChouTi. All rights reserved.

import UIKit

class NewGameViewController: ConfirmViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "Start a new game?"
    okButton.title = "Yes"
    cancelButton.title = "No"
  }
}
