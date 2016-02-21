//
// Created by Omar Estrella on 1/23/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

import SnapKit

class ComposeViewController: UIViewController {
    var navigationBar: UINavigationBar!
    let toAddressInput = ComposeAddressInputView()
    let fromAddressInput = ComposeAddressSelectorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar = self.navigationController?.navigationBar

        self.setup()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        self.view.addSubview(fromAddressInput)
        self.view.addSubview(toAddressInput)

        fromAddressInput.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(navigationBar.frame.height + 30)
            make.width.equalTo(self.view)
            make.height.equalTo(20)
        }

        toAddressInput.focus()
        toAddressInput.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(fromAddressInput.snp_bottom).offset(8)
            make.width.equalTo(self.view)
            make.height.equalTo(20)
        }
    }

    @IBAction func didPressCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
