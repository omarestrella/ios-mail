//
//  MenuViewController.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/8/15.
//  Copyright © 2015 bitcreative. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController, GmailAuthenticatorDelegate {
    let dataSource = MenuTableViewDataSource()

    var accounts: [GmailAccount] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let accounts = GmailAccount.allAccounts()
        self.accounts = accounts

        dataSource.accounts = accounts

        tableView.dataSource = dataSource
        tableView.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func didLogin(account: GmailAccount) {
        self.accounts.append(account)
        dataSource.accounts.append(account)
        tableView.reloadData()
    }

    func showAuthUI() {
        let authenticator = GmailAuthenticator()
        authenticator.delegate = self
        authenticator.startAuthenticationFlow(context: self)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("segueInbox", sender: indexPath)
        } else if indexPath.section == 1 {
            if indexPath.row == accounts.count {
                self.showAuthUI()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueInbox" {
            if let indexPath = sender as? NSIndexPath {
                if let vc = segue.destinationViewController as? InboxViewController {
                    if indexPath.row > 0 {
                        vc.account = accounts[indexPath.row - 1]
                    }
                }
            }
        }
    }
}

class MenuTableViewDataSource: NSObject, UITableViewDataSource {
    var accounts: [GmailAccount] = []

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("accountCell")
        if indexPath.section == 0 { // accounts
            if indexPath.row == 0 {
                cell?.textLabel?.text = "All Inboxes"
            } else {
                let account = accounts[indexPath.row - 1]
                cell?.textLabel?.text = account.email
            }
        } else if indexPath.section == 1 {
            if indexPath.row == accounts.count {
                cell?.textLabel?.text = "Add Account"
            } else {
                let account = accounts[indexPath.row]
                cell?.textLabel?.text = account.email
            }
        }
        return cell!
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return accounts.count + 1
        case 1:
            return accounts.count + 1
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Inboxes"
        case 1:
            return "Accounts"
        default:
            return "Section"
        }
    }
}
