//
//  AppDelegate.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
// With_Parse
// In Addition, there are dependencies in building (Additional Frameworks)
import Parse
import Bolts
// End With_Parse
import Kangaroo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // With_Parse
        Parse.enableLocalDatastore()
        Parse.setApplicationId("GqHHo1WXGpbgJlbDc0iwR8IxuVTxIfBbfsdYpT2q",
            clientKey: "UkHwQdTkNNvfL39iE4enM2UETEoVSaMefH5AX5gj")
        // End With_Parse
        // CoreDataManager.sharedManager.storage = PersonJobCityParseStorage()
        CoreDataManager.sharedManager.storage = CloudStorage()
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataManager.sharedManager.saveContext()
    }
}