//
//  InboxThreadTableViewCell.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/9/15.
//  Copyright © 2015 bitcreative. All rights reserved.
//

import UIKit

class InboxThreadTableViewCell: UITableViewCell {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!

    var delegate: ThreadCellDelegate?

    var dragMarker: InboxThreadDragMarkerView?
    var thread: GmailThread!

    var startingX = CGFloat(0.0)

    func setupData(thread: GmailThread, delegate: ThreadCellDelegate?) {
        self.thread = thread
        self.delegate = delegate

        previewLabel.text = thread.snippet
        fromLabel.text = thread.from
        subjectLabel.text = thread.subject

        let recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }

    func setupCell() {
        contentView.backgroundColor = UIColor.whiteColor()
        startingX = contentView.frame.origin.x
        dragMarker = InboxThreadDragMarkerView(frame: self.frame)
        self.insertSubview(dragMarker!, belowSubview: contentView)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupCell()
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupCell()
    }

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let recognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation = recognizer.translationInView(self)
            return translation.x != 0.0
        }

        return false
    }

    func finishDrag(type: DragType) {
        switch type {
        case .Delete, .Archive:
            self.contentView.frame.origin.x = self.contentView.frame.width
        case .Later:
            self.contentView.frame.origin.x = -self.contentView.frame.width
        default:
            self.contentView.frame.origin.x = self.startingX
        }
    }

    func translateView(position: CGFloat) {
        self.contentView.frame.origin.x = position + startingX
    }

    func resetView() {
        translateView(self.startingX)
        contentView.backgroundColor = UIColor.whiteColor()
        selected = false
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            accessoryType = .None
            selected = false
        }

        if recognizer.state == UIGestureRecognizerState.Changed {
            let translation = recognizer.translationInView(self).x

            translateView(translation + startingX)
            dragMarker?.translateView(translation)
        }

        if recognizer.state == UIGestureRecognizerState.Ended {
            var removeCell = false
            UIView.animateWithDuration(0.1, animations: {
                let type = self.dragMarker?.type
                if type != nil && type != .Other {
                    removeCell = true
                    self.finishDrag(type!)
                } else {
                    self.resetView()
                    self.dragMarker?.resetView()
                }
            }, completion: { _ in
                if removeCell {
                    self.delegate?.removeCell(self)
                } else {
                    self.accessoryType = .DisclosureIndicator
                }
            })
        }
    }
}

protocol ThreadCellDelegate {
    func removeCell(cell: InboxThreadTableViewCell)
}
