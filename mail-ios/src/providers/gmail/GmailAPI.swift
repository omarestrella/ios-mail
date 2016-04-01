//
//  GmailAPI.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/8/15.
//  Copyright © 2015 bitcreative. All rights reserved.
//

import Foundation

import RealmSwift
import PromiseKit
import Alamofire
import SwiftyJSON

struct APIHelpers {
    var api: GmailAPI!

    var baseUrl: NSURL {
        return NSURL(string: "https://www.googleapis.com/gmail/v1/users/")!
    }

    func resource(path: String) -> String {
        let url = NSURL(string: path, relativeToURL: baseUrl)
        return url!.absoluteString
    }

    func refreshAccount() -> Promise<JSON> {
        let clientId = api.clientId
        let refreshToken = api.refreshToken

        let refreshUrl = "https://www.googleapis.com/oauth2/v4/token"
        let authParameters = [
            "client_id": clientId,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token"
        ]

        log.debug("Refresh account with: \(authParameters)")

        return Promise { fulfill, _ in
            Alamofire.request(.POST, refreshUrl, parameters: authParameters).response { _, response, data, error in
                fulfill(JSON(data: data!))
            }
        }
    }

    func request(path: String,
                 type: Alamofire.Method? = .GET,
                 parameters: [String:AnyObject]? = nil,
                 headers: [String:String]? = nil) -> Promise<JSON> {
        let url = resource(path)
        let authHeader = api.authHeader

        return Promise { fulfill, fail in
            Alamofire.request(type!, url, parameters: parameters, headers: authHeader, encoding: .JSON)
                .response { _, resp, data, err in
                    log.debug("Made request with: \(type), \(resp?.statusCode), \(url), \(parameters), \(authHeader)")
                    if resp?.statusCode == 401 {
                        self.refreshAccount().then { json -> Void in
                            self.api.setAccessToken(json["access_token"].string!)
                            self.request(path, parameters: parameters, headers: headers).then { fulfill($0) }
                        }
                    } else if let err = err {
                        log.error("Response error: \(err)")
                        fail(err)
                    } else if let jsonData = data {
                        fulfill(JSON(data: jsonData))
                    }
                }
        }
    }
}

class GmailAPI {
    static var apiInstances: [GmailAPI] = []

    private var _me: JSON?

    var helper: APIHelpers!
    var account: GmailAccount!

    var clientId = ""
    var clientSecret = ""

    var accessToken: String {
        return account.accessToken
    }

    var refreshToken: String {
        return account.refreshToken
    }

    var authHeader: [String:String] {
        return [
            "Authorization": "Bearer \(self.accessToken)"
        ]
    }

    init(account: GmailAccount) {
        self.account = account

        helper = APIHelpers()
        helper.api = self

        GmailAPI.apiInstances.append(self)

        let path = NSBundle.mainBundle().pathForResource("gmail", ofType: "plist")
        if let path = path, dict = NSDictionary(contentsOfFile: path) {
            let storedId = dict["CLIENT_ID"]
            let storedSecret = dict["CLIENT_SECRET"]
            if let storedId = storedId as? String, let storedSecret = storedSecret as? String {
                clientId = storedId as String
                clientSecret = storedSecret as String
            }
        }
    }

    func thread(id: String) -> Promise<GmailThread> {
        let parameters = ["format": "full"]
        return Promise { fulfill, _ in
            helper.request("me/threads/\(id)", parameters: parameters).then { json in
                fulfill(GmailThread(data: json, api: self))
            }
        }
    }

    func messages() -> Promise<[GmailMessage]> {
        return Promise { fulfill, _ in

        }
    }

    func threads(parameters: [String:String]? = [:]) -> Promise<[GmailThread]> {
        return Promise { fulfill, _ in
            helper.request("me/threads", parameters: parameters).then { json -> Void in
                if let threads = json["threads"].array {
                    let promises = threads.map { data in
                        return self.thread(data["id"].string!)
                    }

                    when(promises).then { objs in
                        fulfill(objs)
                    }
                } else {
                    fulfill([])
                }
            }
        }
    }

    func trashThread(thread: GmailThread) -> Promise<JSON> {
        return Promise { fulfill, _ in
            helper.request("me/threads/\(thread.id)", type: .DELETE).then { json -> Void in
                log.debug("\(json)")
                fulfill(json)
            }
        }
    }

    func sendMessage(to to: [String], subject: String, message: String) -> Promise<JSON> {
        return Promise { fulfill, _ in
            let messageData = GmailMessage.buildMessage(from: account.email, to: to,
                subject: subject, message: message)
            let parameters = [
                "raw": messageData
            ]
            helper.request("me/messages/send", parameters: parameters, type: .POST).then { json -> Void in
                log.debug("\(json)")
            }
        }
    }

    func me() -> Promise<JSON> {
        return Promise { fulfill, _ in
            if self._me != nil {
                fulfill(self._me!)
            } else {
                helper.request("me/profile").then { json -> Void in
                    self._me = json
                    fulfill(json)
                }
            }
        }
    }

    func setAccessToken(accessToken: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.account.accessToken = accessToken
            }
        } catch {
            log.error("Could not set accessToken: \(accessToken)")
        }
    }
}
