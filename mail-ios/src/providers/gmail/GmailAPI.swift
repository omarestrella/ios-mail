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

    func request(path: String, type: Alamofire.Method? = .GET, parameters: [String:AnyObject]? = nil, headers: [String:String]? = nil) -> Promise<JSON> {
        let url = resource(path)
        let authHeader = api.authHeader

        return Promise { fulfill, fail in
            Alamofire.request(type!, url, parameters: parameters, headers: authHeader).response { request, response, data, error in
                log.debug("Made request with: \(type), \(response?.statusCode), \(url), \(parameters), \(authHeader)")
                if response?.statusCode == 401 {
                    self.refreshAccount().then { json -> Void in
                        self.api.setAccessToken(json["access_token"].string!)
                        self.request(path, parameters: parameters, headers: headers).then { fulfill($0) }
                    }
                } else if let _ = error {
                    log.error("Response error: \(error)")
                    fail(error!)
                } else if let _ = data {
                    fulfill(JSON(data: data!))
                }
            }
        }
    }
}

class GmailAPI {
    var _me: JSON?

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

        self.helper = APIHelpers()
        self.helper.api = self

        if let path = NSBundle.mainBundle().pathForResource("gmail", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) {
            self.clientId = dict["CLIENT_ID"] as! String
            self.clientSecret = dict["CLIENT_SECRET"] as! String
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
        let realm = try! Realm()
        try! realm.write {
            account.accessToken = accessToken
        }
    }
}
