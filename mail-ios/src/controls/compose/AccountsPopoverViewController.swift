//
// Created by Omar Estrella
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

class AccountsPopoverViewController: UITableViewController {
    let dataSource = AccountsPopoverDatasource()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        tableView.reloadData()
    }
}

class AccountsPopoverDatasource: NSObject, UITableViewDataSource {
    let accounts = GmailAccount.allAccounts()



    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Accounts"
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let index = indexPath.row
        cell.textLabel?.text = accounts[index].email
        return cell
    }

}
