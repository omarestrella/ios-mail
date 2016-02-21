//
// Created by Omar Estrella on 12/7/15.
// Copyright (c) 2015 bitcreative. All rights reserved.
//

import Foundation
import UIKit

import RealmSwift
import PromiseKit
import Alamofire

struct AuthenticationCodes {
    let LoginSuccess: String = "LoginSuccess"
    let LoginFailure: String = "LoginFailure"
    let LogoutSuccess: String = "LogoutSuccess"
}

class GmailAuthenticator: NSObject {
    static let NotificationCodes = AuthenticationCodes()

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
        if oauthInstance != nil {
            return oauthInstance!
        }

        var clientId = ""
        var clientSecret = ""
        if let path = NSBundle.mainBundle().pathForResource("gmail", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) {
            clientId = dict["CLIENT_ID"] as! String
            clientSecret = dict["CLIENT_SECRET"] as! String
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
            name: GmailAuthenticator.NotificationCodes.LoginSuccess,
            object: nil)
    }
}

protocol GmailAuthenticatorDelegate {
    func didLogin(account: GmailAccount)
}
