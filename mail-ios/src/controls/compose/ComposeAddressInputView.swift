//
// Created by Omar Estrella on 1/31/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

import SnapKit

class ComposeAddressInputView: UIView {
    let label: UILabel = UILabel(frame: CGRectZero)
    let textField: UITextField = UITextField(frame: CGRectZero)

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

    func focus() {
        self.textField.becomeFirstResponder()
    }

    private func setup() {
        self.addSubview(label)
        self.addSubview(textField)

        label.text = "To:"
        label.font = UIFont.systemFontOfSize(13)
        label.sizeToFit()
        label.snp_makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(10)
        }

        textField.borderStyle = .None
        textField.font = UIFont.systemFontOfSize(13)
        textField.autocapitalizationType = .None
        textField.snp_makeConstraints { (make) -> Void in
            make.top.bottom.right.equalTo(self)
            make.left.equalTo(label.snp_right).offset(10)
        }
    }
}
