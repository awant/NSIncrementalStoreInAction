//
//  Person+CoreDataProperties.swift
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

extension Person {

    @NSManaged var firstName: String?
    @NSManaged var secondName: String?
    @NSManaged var job: Job?
    @NSManaged var city: City?

}
