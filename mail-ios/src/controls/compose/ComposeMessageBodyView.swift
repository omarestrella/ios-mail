//
// Created by Omar Estrella
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

class ComposeMessageBodyView: UIView, UITextViewDelegate {
    let textView = UITextView(frame: CGRect.zero)

    convenience init() {
        self.init(frame: CGRect.zero)
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
        self.addSubview(textView)

        let fontSize = CGFloat(14)

        textView.delegate = self
        textView.font = UIFont.systemFontOfSize(fontSize)
        textView.textColor = UIColor.lightGrayColor()
        textView.text = "Message..."
        textView.snp_makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self)
            make.left.right.equalTo(self).offset(10)
        }
    }

    func setPlaceholder() -> Bool {
        if !textView.hasText() {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = "Message..."
            textView.selectedRange = NSRange(location: 0, length: 0)
        }

        return true
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.hasText() && textView.text == "Message..." {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }

        return true
    }

    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return self.setPlaceholder()
    }

    func textViewDidChangeSelection(textView: UITextView) {
        if textView.text == "Message..." {
            textView.selectedRange = NSRange(location: 0, length: 0)
        }
    }

}
