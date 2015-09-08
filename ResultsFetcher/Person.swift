//
//  Person.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData

class Person: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var secondName: String

}
