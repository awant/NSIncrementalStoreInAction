//
//  Person.swift
//  ResultsFetcher
//
//  Created by Admin on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData

class Person: NSManagedObject {
    @NSManaged var firstName: String?
    @NSManaged var secondName: String?
    @NSManaged var job: Job?
    @NSManaged var city: City?
}
