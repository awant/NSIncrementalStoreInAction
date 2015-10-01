//
//  City+CoreDataProperties.swift
//  ResultsFetcher
//
//  Created by Admin on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension City {

    @NSManaged var name: String?
    @NSManaged var persons: NSMutableSet?

}
