// Copyright © 2019 ChouTi. All rights reserved.

import ChouTi
import Firebase
import UIKit

class GameEndViewController: ConfirmViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "Game Over!"
    cancelButton.title = "Undo"
    okButton.title = "Retry"
  }
}
