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

    var emailCollection: [String] = []

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
        textField.spellCheckingType = .No
        textField.autocapitalizationType = .None
        textField.returnKeyType = .Next
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
                    let cleanEmail = email
                        .stringByReplacingOccurrencesOfString(",", withString: "")
                        .stringByReplacingOccurrencesOfString(" ", withString: "")
                    if !cleanEmail.characters.isEmpty && !emailCollection.contains(cleanEmail) {
                        emailCollection.append(cleanEmail)
                    }
                }
            }

            let strings = self.getAttributedStrings()
            let finalString = NSMutableAttributedString(string: "")
            strings.forEach { str in
                finalString.appendAttributedString(str)
                finalString.appendAttributedString(NSAttributedString(string: ", "))
            }

            textField.attributedText = finalString

            return false
        } else if string.isEmpty && range.length == 1 {
            // deleting characters
            log.debug("\(emailCollection)")
            log.debug("\(range)")

            if let lastEmail: String = emailCollection.maxElement() {
                if let stringRange = textField.text?.rangeOfString(lastEmail.stringByAppendingString(", ")) {
                    guard let startIndex = textField.text?.startIndex else { return true }
                    let length = startIndex.distanceTo(stringRange.endIndex)
                    let location = startIndex.distanceTo(stringRange.startIndex)

                    let start = textField.positionFromPosition(textField.beginningOfDocument,
                        offset: location)
                    let end = textField.positionFromPosition(textField.beginningOfDocument,
                        offset: length)

                    if let start = start, end = end {
                        textField.selectedTextRange = textField.textRangeFromPosition(start, toPosition: end)
                        return false
                    }
                }
            }
        } else if string.isEmpty {
            emailCollection.removeLast()
            log.debug("Removed email, \(emailCollection)")
        }

        return true
    }
    // swiftlint:enable line_length

    func getAttributedStrings() -> [NSAttributedString] {
        let strings: [NSAttributedString]? = emailCollection.map { email -> NSAttributedString in
            let string = NSMutableAttributedString(string: email)
            let color = self.tintColor
            let range = NSRange(location: 0, length: email.characters.count)
            string.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            return string
        }

        if let strings = strings {
            return strings
        }

        return []
    }
}
