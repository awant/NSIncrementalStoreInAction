//
//  Song.swift
//  ResultsFetcher
//
//  Created by Admin on 10.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData
import GenericCoreData

class Song: NSManagedObject, CoreDataRepresentable {
    static let entityName = "Song"
}
