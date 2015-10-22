//
//  City.swift
//  ResultsFetcher
//
//  Created by Admin on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData

class City: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var persons: NSMutableSet?
}
