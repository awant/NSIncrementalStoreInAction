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
import GenericCoreData
import Kangaroo

import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // With_Parse
        //Parse.enableLocalDatastore()
        Parse.setApplicationId("GqHHo1WXGpbgJlbDc0iwR8IxuVTxIfBbfsdYpT2q",
            clientKey: "UkHwQdTkNNvfL39iE4enM2UETEoVSaMefH5AX5gj")
        // End With_Parse
        
        // Example - Register for push notifications
//        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
//        application.registerUserNotificationSettings(notificationSettings)
//        application.registerForRemoteNotifications()
        //
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        print("didReceiveRemoteNotification")
//        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
//        if cloudKitNotification.notificationType == CKNotificationType.Query {
//            let recordId = (cloudKitNotification as! CKQueryNotification).recordID
//            NSNotificationCenter.defaultCenter().postNotificationName("updateRoot", object: nil)
//        }
    }

    func applicationWillTerminate(application: UIApplication) {
        //CoreDataManager.sharedManager.saveContext()
    }
}



































