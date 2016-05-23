//
//  AppDelegate.swift
//  Spotlight
//
//  Created by Dan Ionescu on 12/04/16.
//  Copyright © 2016 Alt Tab. All rights reserved.
//

import UIKit
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            let uniqueIdentifier = userActivity.userInfo? [CSSearchableItemActivityIdentifier] as? String

            // Find and open the item specified by uniqueIdentifer.
            showArticleWithUniqueIdentifier(uniqueIdentifier);
        }


        return true
    }

    func showArticleWithUniqueIdentifier(uniqueIdentifier: String?) {
        guard let uniqueIdentifier = uniqueIdentifier else {
            return
        }

        let articlesViewController = (window?.rootViewController as! UINavigationController).viewControllers[0] as! ArticlesTableViewController

        articlesViewController.showArticleWithUniqueIdentifier(uniqueIdentifier);
    }
}

