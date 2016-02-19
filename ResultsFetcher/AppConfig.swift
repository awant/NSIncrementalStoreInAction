//
//  AppConfig.swift
//  ResultsFetcher
//
//  Created by Admin on 28.10.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import CoreData
import Kangaroo

class AppConfig: CoreDataConfig {
    static func configurationName() -> String {
        return "AppConfig"
    }
    
    class func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("ResultsFetcher", withExtension: "momd")!
    }
    
    class func configurateStoreCoordinator(coordinator: NSPersistentStoreCoordinator) throws {
        // try PersistanceStoreRegistry.register(CloudStorage(), coordinator: coordinator)
        try PersistanceStoreRegistry.register(ParseStorage(), coordinator: coordinator, cacheState: .LocalCache)
    }
}