//
// Created by Omar Estrella on 1/31/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

// swiftlint:disable legacy_constant

import Foundation
import UIKit

class ComposeAddessFromView: UIView {
    let fromLabel = UILabel(frame: CGRectZero)
    let emailSelectionView = ComposeEmailSelectionView()

    convenience init() {
        self.init(frame: CGRectZero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    private func setup() {
        self.addSubview(fromLabel)
        self.addSubview(emailSelectionView)

        let fontSize = CGFloat(14)

        fromLabel.text = "From:"
        fromLabel.font = UIFont.systemFontOfSize(fontSize)
        fromLabel.sizeToFit()
        fromLabel.snp_makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(10)
        }

        emailSelectionView.snp_makeConstraints { (make) -> Void in
            make.top.bottom.right.equalTo(self)
            make.left.equalTo(fromLabel.snp_right).offset(10)
        }
    }

    func setAccount(account: GmailAccount) {
        emailSelectionView.setAccount(account)
    }
}
