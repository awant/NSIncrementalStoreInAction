//
//  Album.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData
import GenericCoreData

class Album: NSManagedObject, CoreDataRepresentable {
    static let entityName = "Album"
}

extension Album {
    
    @NSManaged var name: String?
    @NSManaged var artist: Artist?
    @NSManaged var songs: NSSet?
    
}