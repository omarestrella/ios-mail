//
// Created by Omar Estrella on 1/23/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

import SnapKit

class ComposeViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate {
    var navigationBar: UINavigationBar!
    let toAddressInput = ComposeAddressInputView()
    let fromAddressInput = ComposeAddessFromView()

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

        self.setupGestures()
    }

    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleEmailTap:"))
        fromAddressInput.addGestureRecognizer(tapGesture)
    }

    func handleEmailTap(sender: UITapGestureRecognizer) {
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(false, completion: nil)
        }

        let width = self.view.frame.width * 0.75
        let height = self.view.frame.height * 0.5

        let accountsController = AccountsPopoverViewController()
        accountsController.tableView.delegate = self
        accountsController.modalPresentationStyle = .Popover
        accountsController.preferredContentSize = CGSize(width: width, height: height)

        if let popController = accountsController.popoverPresentationController as UIPopoverPresentationController? {
            popController.delegate = self
            popController.permittedArrowDirections = UIPopoverArrowDirection.Any
            popController.sourceView = fromAddressInput

            let pos = CGFloat(-height + fromAddressInput.frame.height + 10)
            popController.sourceRect = CGRect(x: 0, y: pos, width: width, height: height)
        }

        self.presentViewController(accountsController, animated: false, completion: nil)
    }

    // swiftlint:disable line_length
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController,
                                                            traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
    // swiftlint:enable line_length

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }


    @IBAction func didPressCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
