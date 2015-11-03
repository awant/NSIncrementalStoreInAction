//
//  Artist.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData
import GenericCoreData

class Artist: NSManagedObject, CoreDataRepresentable {
    static let entityName = "Artist"
}

extension Artist {
    
    @NSManaged var name: String?
    @NSManaged var albums: NSSet?
    
}