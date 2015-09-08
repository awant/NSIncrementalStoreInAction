//
//  AppDelegate.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        
//        let sleepOperation = NSBlockOperation {
//            sleep(5)
//        }
//        
//        let saveOperation = NSBlockOperation {
//            CoreDataManager.sharedManager.testInsertion()
//        }
//        
//        saveOperation.addDependency(sleepOperation)
//        NSOperationQueue().addOperation(sleepOperation)
//        NSOperationQueue.mainQueue().addOperation(saveOperation)
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataManager.sharedManager.saveContext()
    }
}

