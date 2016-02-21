//
// Created by Omar Estrella on 12/28/15.
// Copyright (c) 2015 bitcreative. All rights reserved.
//

import Foundation
import UIKit

struct EmailStateColors {
    static let Red = UIColor(red: 0.941, green: 0.0078, blue: 0.235, alpha: 1.0)
    static let Gray = UIColor(red: 0.913, green: 0.9137,  blue: 0.913, alpha: 1.0)
    static let Green = UIColor(red: 0.396, green: 0.729, blue: 0.281, alpha: 1.0)
    static let Yellow = UIColor(red: 0.949, green: 0.949, blue: 0.435, alpha: 1.0)
}

enum DragType: Int {
    case Archive, Delete, Later, Other

    var color: UIColor {
        switch self {
        case .Archive:
            return EmailStateColors.Green
        case .Delete:
            return EmailStateColors.Red
        case .Later:
            return EmailStateColors.Yellow
        case .Other:
            return EmailStateColors.Gray
        default:
            return EmailStateColors.Gray
        }
    }
}

class InboxThreadDragMarkerView: UIView {
    var type: DragType? = .Other

    var startingX = CGFloat(0.0)

    override init(frame: CGRect) {
        super.init(frame: frame)

        prepare()
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        prepare()
    }

    private func prepare() {
        backgroundColor = UIColor.whiteColor()
    }

    func translateView(translation: CGFloat) {
        let slack = CGFloat(75)

        if translation < -slack {
            // <- Left
            type = .Later
        } else if translation > frame.width / 3.0 {
            // Right ->
            type = .Delete
        } else if translation > slack {
            type = .Archive
        } else {
            type = .Other
        }

        backgroundColor = type?.color
    }

    func resetView() {
        backgroundColor = UIColor.whiteColor()
    }
}
