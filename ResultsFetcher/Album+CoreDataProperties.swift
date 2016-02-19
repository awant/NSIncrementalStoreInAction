//
//  Album+CoreDataProperties.swift
//  ResultsFetcher
//
//  Created by Admin on 10.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Album {

    @NSManaged var name: String?
    @NSManaged var image: NSData?
    @NSManaged var artist: Artist?
    @NSManaged var songs: NSSet?
}
