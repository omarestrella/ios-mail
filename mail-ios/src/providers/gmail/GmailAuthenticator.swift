//
// Created by Omar Estrella on 12/7/15.
// Copyright (c) 2015 bitcreative. All rights reserved.
//

import Foundation
import UIKit

import RealmSwift
import PromiseKit
import Alamofire

class GmailAuthenticator: NSObject {
    enum NotificationCodes: CustomStringConvertible {
        case LoginSuccess
        case LoginFailure
        case LogoutSuccess

        var description: String {
            switch self {
            case .LoginSuccess:
                return "LoginSuccess"
            case .LoginFailure:
                return "LoginFailure"
            case .LogoutSuccess:
                return "LogoutSuccess"
            }
        }
    }

    var delegate: GmailAuthenticatorDelegate?
    var oauthInstance: GmailOAuth2?

    var account: GmailAccount!

    override init() {
        super.init()

        log.debug("Using Realm path: \(Realm.Configuration.defaultConfiguration.path)")
    }

    func startAuthenticationFlow(context context: UIViewController?) {
        let oauth2 = getOauthInstance()

        oauth2.onAuthorize = { _ in
            let account = GmailAccount(oauth2: oauth2)
            self.account = account
            self.account.authenticator = self

            account.loadProfile().then { _ in
                self.delegate?.didLogin(account)
            }
        }

        oauth2.onFailure = { error in
            if error != nil {
                log.error("\(error)")
            }
        }

        oauth2.authorizeContext = context
        oauth2.authorize()
    }

    func getOauthInstance() -> GmailOAuth2 {
        if let instance = oauthInstance {
            return instance
        }

        var clientId = ""
        var clientSecret = ""
        let path = NSBundle.mainBundle().pathForResource("gmail", ofType: "plist")
        if let path = path, dict = NSDictionary(contentsOfFile: path) {
            let storedId = dict["CLIENT_ID"]
            let storedSecret = dict["CLIENT_SECRET"]
            if let storedId = storedId as? String, let storedSecret = storedSecret as? String {
                clientId = storedId as String
                clientSecret = storedSecret as String
            }
        }

        let settings = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "authorize_uri": "https://accounts.google.com/o/oauth2/v2/auth",
            "token_uri": "https://accounts.google.com/o/oauth2/token",
            "scope": "https://mail.google.com/",
            "redirect_uri": "com.googleusercontent.apps.431060781446-e3fjn4mb5e5ajr4s58drrv2vefnitbj1://"
        ]

        oauthInstance = GmailOAuth2(settings: settings)
        return oauthInstance!
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: GmailAuthenticator.NotificationCodes.LoginSuccess.description,
            object: nil)
    }
}

protocol GmailAuthenticatorDelegate {
    func didLogin(account: GmailAccount)
}
