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
    if params.count > 0 {
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
#if DEBUG
        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: nil)
#else
        log.setup(.Error, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: nil)
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
        } catch {
            log.debug("Couldn't create /tmp/realm for development")
        };
        config.path = "/tmp/realm/db.realm"
        Realm.Configuration.defaultConfiguration = config
#endif

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
