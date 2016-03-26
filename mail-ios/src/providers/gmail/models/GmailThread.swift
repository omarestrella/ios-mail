//
//  GmailThread.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/8/15.
//  Copyright © 2015 bitcreative. All rights reserved.
//

import Foundation

import PromiseKit
import SwiftyJSON
import Regex

class GmailThread: GmailModel {
    private var api: GmailAPI!

    var data: JSON!

    var id = ""
    var historyId = ""

    var messages: [GmailMessage] {
        if let messageData = data["messages"].array {
            do {
                return try messageData.map { GmailMessage(data: $0, thread: self) }
            } catch {
                return []
            }
        }

        return []
    }

    var snippet: String {
        if let snippet = self.messages.last?.snippet {
            return snippet
        }

        return ""
    }

    var from: String {
        if let from = messages.first?.from {
            let find = from.grep("([\\s\\w]+) <.*>")
            if let match = find.captures.last {
                return match
            }
        }

        return "(Empty)"
    }

    var subject: String {
        if let subject = messages.first?.subject {
            return subject
        }

        return "(Empty)"
    }

    convenience init(data: JSON, api: GmailAPI) {
        self.init()

        self.data = data

        self.id = data["id"].string!
        self.historyId = data["historyId"].string!

        self.api = api

        self.save()
    }

    func trash() -> Promise<JSON> {
        return self.api.trashThread(self).then { json in
            // delete?

            return Promise(json)
        }
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["api", "data"]
    }
}
