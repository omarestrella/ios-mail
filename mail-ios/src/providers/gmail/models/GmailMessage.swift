//
//  GmailMessage.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/9/15.
//  Copyright © 2015 bitcreative. All rights reserved.
//

import Foundation

import SwiftyJSON

class GmailMessage: GmailModel {
    var data: JSON!

    dynamic var id = ""
    dynamic var threadId = ""
    dynamic var thread: GmailThread?

    var snippet: String? {
        return data?["snippet"].string
    }

    var message: String {
        let parts = data?["payload"]["parts"].array
        if parts?.count > 0 {
            if let messageBody: String = parts?.last?["body"]["data"].string {
                let base64Message = messageBody
                    .stringByReplacingOccurrencesOfString("-", withString: "+")
                    .stringByReplacingOccurrencesOfString("_", withString: "/");
                let data = NSData(base64EncodedString: base64Message, options: NSDataBase64DecodingOptions(rawValue: 0))
                return String(data: data!, encoding: NSUTF8StringEncoding)!
            }
        }

        return ""
    }

    var from: String {
        if let from = findHeader("From") {
            return from
        }

        return ""
    }

    var subject: String {
        if let subject = findHeader("Subject") {
            return subject
        }

        return ""
    }

    convenience init(data: JSON, thread: GmailThread) {
        self.init()

        self.data = data
        self.thread = thread

        id = data["id"].string!
        threadId = data["threadId"].string!

        self.save()
    }

    func findHeader(name: String) -> String? {
        if let headers = data?["payload"]["headers"].array {
            if let idx = headers.indexOf({ (h: JSON) in h["name"].string! == name }) {
                return headers[idx]["value"].string
            }
        }

        return ""
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["data"]
    }
}
