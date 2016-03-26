//
// Created by Omar Estrella on 12/22/15.
// Copyright (c) 2015 bitcreative. All rights reserved.
//

import Foundation

import OAuthSwift
import SwiftyJSON

class GmailOAuth2: OAuth2Swift {
    private var settings: [String:String] = [:]
    private var credentials: [String:AnyObject]!

    var authorizeContext: UIViewController?
    var onAuthorize: (credentials: [String:AnyObject]) -> Void = { _ in }
    var onFailure: (error: NSError?) -> Void = { _ in }

    var accessToken: String? {
        return credentials["access_token"] as? String
    }

    var refreshToken: String? {
        return credentials["refresh_token"] as? String
    }

    convenience init(settings: [String:String]) {
        let clientId = settings["client_id"]!
        let authorizeUri = settings["authorize_uri"]!
        let tokenUri = settings["token_uri"]!

        self.init(consumerKey: clientId, consumerSecret: "", authorizeUrl: authorizeUri,
            accessTokenUrl: tokenUri, responseType: "code")

        self.settings = settings
    }

    func authorize() {
        if let uri = settings["redirect_uri"], let scope = settings["scope"] {
            if let url = NSURL(string: uri) {
                self.authorize_url_handler = SafariURLHandler(viewController: authorizeContext!)

                self.authorizeWithCallbackURL(url, scope: scope, state: "",
                    success: {
                        credentials, response, parameters in
                        if let json = parameters as? [String:AnyObject] {
                            self.credentials = json
                            self.onAuthorize(credentials: json)
                        } else {
                            let error = NSError(domain: "GmailOauth2#authorize", code: 0, userInfo: nil)
                            self.onFailure(error: error)
                        }
                    },
                    failure: {
                        error in
                        self.onFailure(error: error)
                    })
            }
        }
    }
}
