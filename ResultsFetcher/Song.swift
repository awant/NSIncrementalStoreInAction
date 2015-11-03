//
//  Song.swift
//  ResultsFetcher
//
//  Created by Admin on 03.11.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData
import GenericCoreData

class Song: NSManagedObject, CoreDataRepresentable {
    static let entityName = "Song"
}

extension Song {
    
    @NSManaged var name: String?
    @NSManaged var songEng: String?
    @NSManaged var songRus: String?
    @NSManaged var album: Album?
    
}