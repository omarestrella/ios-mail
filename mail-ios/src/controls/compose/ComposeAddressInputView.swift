//
// Created by Omar Estrella on 1/31/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

// swiftlint:disable legacy_constant

import Foundation
import UIKit

import SnapKit

class ComposeAddressInputView: UIView, UITextFieldDelegate {
    let label = UILabel(frame: CGRectZero)
    let textField = UITextField(frame: CGRectZero)

    var emailCollection: Set<String> = []

    var addresses: [String] {
        get {
            return [""]
        }
    }

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

        let fontSize = CGFloat(14)

        label.text = "To:"
        label.font = UIFont.systemFontOfSize(fontSize)
        label.sizeToFit()
        label.snp_makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(10)
        }

        textField.delegate = self
        textField.keyboardType = .EmailAddress
        textField.borderStyle = .None
        textField.font = UIFont.systemFontOfSize(fontSize)
        textField.autocapitalizationType = .None
        textField.snp_makeConstraints { (make) -> Void in
            make.top.bottom.right.equalTo(self)
            make.left.equalTo(label.snp_right).offset(10)
        }
    }

    // swiftlint:disable line_length
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            if let emails = textField.text?.componentsSeparatedByString(" ") {
                emails.forEach { email in
                    let cleanEmail = email.stringByReplacingOccurrencesOfString(",", withString: "")
                    emailCollection.insert(cleanEmail)
                }
            }

            let strings: [NSAttributedString]? = emailCollection.map { email -> NSAttributedString in
                let newEmail = email
                    .stringByAppendingString(", ")
                let string = NSMutableAttributedString(string: newEmail)
                let color = self.tintColor
                let range = NSRange(location: 0, length: newEmail.characters.count - 2)
                string.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                return string
            }

            let finalString = NSMutableAttributedString(string: "")
            strings?.forEach { finalString.appendAttributedString($0) }

            textField.attributedText = finalString
        }

        return true
    }
    // swiftlint:enable line_length
}
