//
//  AppConfig.swift
//  ResultsFetcher
//
//  Created by Admin on 28.10.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import CoreData
import GenericCoreData
import Kangaroo

class AppConfig: CoreDataConfig {
    static func configurationName() -> String {
        return "AppConfig"
    }
    
    class func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("ResultsFetcher", withExtension: "momd")!
    }
    
    class func configurateStoreCoordinator(coordinator: NSPersistentStoreCoordinator) throws {
        let applicationDocumentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        let url = applicationDocumentsDirectory.URLByAppendingPathComponent("ResultsFetcher.sqlite")
        try PersistanceStoreRegistry.register(CloudStorage(), coordinator: coordinator, fileURL: url)
    }
}