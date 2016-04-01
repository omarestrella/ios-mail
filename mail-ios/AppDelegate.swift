//
//  AppDelegate.swift
//  mail-ios
//
//  Created by Omar Estrella on 12/7/15.
//  Copyright (c) 2015 bitcreative. All rights reserved.
//


import UIKit

import netfox
import XCGLogger
import RealmSwift

let log = XCGLogger.defaultInstance()

func getParamsForUrl(url: NSURL) -> [String: String] {
    let params = url.query!.componentsSeparatedByString("&")
    var results: [String: String] = [:]
    if !params.isEmpty {
        for param in params {
            let keyValue = param.componentsSeparatedByString("=")
            if keyValue.count > 1 {
                results[keyValue.first!] = keyValue.last!
            }
        }
    }
    return results
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, openURL url: NSURL, options: [String:AnyObject]) -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName("OAuthSwiftCallbackNotificationName",
            object: nil, userInfo: ["OAuthSwiftCallbackNotificationOptionsURLKey": url])
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
                     annotation: AnyObject) -> Bool {
        return true
    }

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
#if DEBUG
        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true,
            writeToFile: nil, fileLogLevel: nil)
#else
        log.setup(.Error, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true,
            writeToFile: nil, fileLogLevel: nil)
#endif

#if DEBUG
        NFX.sharedInstance().start()
#endif

#if DEBUG
        var config = Realm.Configuration()
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath("/tmp/realm",
                withIntermediateDirectories: false,
                attributes: nil)
        } catch let err as NSError {
            log.debug("Couldn't create /tmp/realm for development: \(err)")
        }
        config.path = "/tmp/realm/db.realm"
        Realm.Configuration.defaultConfiguration = config
#endif

        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }
}
