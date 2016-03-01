//
//  ViewController.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/7/15.
//  Copyright (c) 2015 bitcreative. All rights reserved.
//


import UIKit

class InboxViewController: UITableViewController, ThreadCellDelegate {
    var account: GmailAccount?
    var dataSource: InboxDataSource!

    var haveAccount: Bool {
        return self.account != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = InboxDataSource(account: self.account, cellDelegate: self)
        self.tableView.dataSource = self.dataSource

        self.account?.threads(["q": "in:inbox"]).then {
            threads -> Void in
            self.dataSource.threads = threads
            self.tableView.reloadData()
        }
    }

    func removeCell(cell: InboxThreadTableViewCell) {
        let row = self.dataSource.threads.indexOf({
            (thread: GmailThread) in
            return thread.id == cell.thread.id
        })
        let indexPath = NSIndexPath(forRow: row!, inSection: 0)
        let thread = self.dataSource.threads.removeAtIndex(row!)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)

        if cell.dragMarker?.type == .Delete {
            thread.trash()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toComposeViewController" {

        }

        super.prepareForSegue(segue, sender: sender)
    }

}

class InboxDataSource: NSObject, UITableViewDataSource {
    var account: GmailAccount?
    var threads: [GmailThread] = []
    var cellDelegate: ThreadCellDelegate!

    init(account: GmailAccount?, cellDelegate: ThreadCellDelegate) {
        self.account = account
        self.cellDelegate = cellDelegate
    }

    func numberOfSectionsInTableView(_: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: InboxThreadTableViewCell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! InboxThreadTableViewCell
        cell.setupData(self.threads[indexPath.row], delegate: cellDelegate)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
}
