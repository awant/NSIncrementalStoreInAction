//
//  AppDelegate.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Kangaroo

import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("GqHHo1WXGpbgJlbDc0iwR8IxuVTxIfBbfsdYpT2q",
            clientKey: "UkHwQdTkNNvfL39iE4enM2UETEoVSaMefH5AX5gj")
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }

    func applicationWillTerminate(application: UIApplication) {
        //CoreDataManager.sharedManager.saveContext()
    }
}



































