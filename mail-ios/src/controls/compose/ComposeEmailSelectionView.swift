//
// Created by Omar Estrella on 2/21/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

class ComposeEmailSelectionView: UIView {
    var currentAccount: GmailAccount? = nil

    let emailLabel = UILabel(frame: CGRectZero)

    var accounts: [GmailAccount] {
        return GmailAccount.allAccounts()
    }

    convenience init() {
        self.init(frame: CGRectZero)

        self.currentAccount = accounts.first

        self.setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func handleEmailTap(sender: UITapGestureRecognizer) {
        log.debug("Tapped!")
    }

    private func setup() {
        self.addSubview(emailLabel)

        let fontSize = CGFloat(14)

        emailLabel.text = self.currentAccount?.email
        emailLabel.font = UIFont.systemFontOfSize(fontSize)
        emailLabel.textColor = self.tintColor
        emailLabel.snp_makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(self)
        }

        self.setupGestures()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleEmailTap:"))
        self.addGestureRecognizer(tapGesture)
    }
}
