//
// Created by Omar Estrella on 12/7/15.
// Copyright (c) 2015 bitcreative. All rights reserved.
//

import Foundation
import PromiseKit

import RealmSwift

private var _accounts: [GmailAccount] = []

class GmailAccount: GmailModel {
    var api: GmailAPI!
    var authenticator: GmailAuthenticator!

    dynamic var id: String = ""
    dynamic var email: String = ""
    dynamic var name: String = ""
    dynamic var accessToken: String = ""
    dynamic var refreshToken: String = ""

    convenience init(oauth2: GmailOAuth2) {
        self.init()

        if let accessToken = oauth2.accessToken, refreshToken = oauth2.refreshToken {
            self.accessToken = accessToken
            self.refreshToken = refreshToken

            api = GmailAPI(account: self)

            _accounts.append(self)

            self.loadProfile().then { _ -> Void in
                self.save()
            }
        }
    }

    func threads(parameters: [String: String]? = nil) -> Promise<Array<GmailThread>> {
        return api.threads(parameters)
    }

    func loadProfile() -> Promise<GmailAccount> {
        return api.me().then { json in
            do {
                let realm = try Realm()
                try realm.write {
                    self.email = json["emailAddress"].string!
                }
            } catch {
                log.error("Could not save profile email address")
            }

            return Promise(self)
        }
    }

    static func allAccounts() -> [GmailAccount] {
        if !_accounts.isEmpty {
            return _accounts
        }

        var accounts: [GmailAccount] = []
        do {
            let realm = try Realm()
            for account in realm.objects(GmailAccount) {
                accounts.append(account)
                if account.api == nil {
                    account.api = GmailAPI(account: account)
                }
            }
        } catch {
            log.error("Could not read accounts from database")
        }

        _accounts = accounts
        return accounts
    }

    override static func primaryKey() -> String? {
        return "email"
    }

    override static func ignoredProperties() -> [String] {
        return ["api", "authenticator"]
    }
}
