//
// Created by Omar Estrella on 1/23/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

// swiftlint:disable legacy_constant

import Foundation
import UIKit

import SnapKit

class ComposeViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate {
    var navigationBar: UINavigationBar!
    var toAddressInput: ComposeAddressInputView!
    var fromAddressInput: ComposeAddessFromView!
    var messageBodyInput: ComposeMessageBodyView!

    let accounts = GmailAccount.allAccounts()
    var fromAccount: GmailAccount? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        toAddressInput = ComposeAddressInputView()
        fromAddressInput = ComposeAddessFromView()
        messageBodyInput = ComposeMessageBodyView()

        navigationBar = self.navigationController?.navigationBar
        fromAccount = accounts.first

        self.setup()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setup() {
        self.view.addSubview(fromAddressInput)
        self.view.addSubview(toAddressInput)
        self.view.addSubview(messageBodyInput)

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

        messageBodyInput.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(toAddressInput.snp_bottom).offset(8)
            make.bottom.width.equalTo(self.view)
        }

        self.setupGestures()
        self.attachButtons()
    }

    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleEmailTap:"))
        fromAddressInput.addGestureRecognizer(tapGesture)
    }

    func attachButtons() {
        let leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self,
            action: Selector("didPressCancel:"))
        let rightButton = UIBarButtonItem(title: "Send", style: .Done, target: self,
            action: Selector("didPressSend:"))

        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
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
        let account = accounts[indexPath.row]
        fromAccount = account
        fromAddressInput.setAccount(account)

        self.dismissViewControllerAnimated(false, completion: nil)
    }

    @objc func didPressSend(sender: UIBarButtonItem) {
        fromAccount?.api.sendMessage(to: toAddressInput.addresses, subject: "Subject", message: "Message")
    }

    @IBAction func didPressCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
