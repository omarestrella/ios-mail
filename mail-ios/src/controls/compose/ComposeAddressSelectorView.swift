//
// Created by Omar Estrella on 1/31/16.
// Copyright (c) 2016 bitcreative. All rights reserved.
//

import Foundation
import UIKit

class ComposeAddressSelectorView: UIView {
    let label: UILabel = UILabel(frame: CGRectZero)

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
        self.addSubview(label)

        label.text = "From:"
        label.font = UIFont.systemFontOfSize(13)
        label.sizeToFit()
        label.snp_makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).offset(10)
        }
    }
}
