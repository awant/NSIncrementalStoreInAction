//
//  PersonStorage.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation

struct _Person {
    let firstName: String
    let secondName: String
    let storageID = StorageID()
    init(firstName: String, secondName: String) {
        self.firstName = firstName
        self.secondName = secondName
    }
}

struct StorageID {
    let id = NSUUID().UUIDString
}

class PersonStorage {
    var personCache = NSCache()
    var person = _Person(firstName: "Artemiy", secondName: "Sobolev")
    
    func fetchRecords(entityName: String, newEntityCreator: (String, StorageID) -> AnyObject) -> AnyObject? {
        if entityName == "Person" {
            let person = newEntityCreator("Person", self.person.storageID) as! Person
            return [person]
        }
        return nil
    }
    
    func valuesAndVersion(objectID: StorageID) -> (values: [NSObject : AnyObject], version: UInt64)? {
        return (values:Person.values(person.firstName, secondName: person.secondName), version: 1)
    }
}

private
extension Person {
    class func values(firstName: String, secondName: String) -> [NSObject : AnyObject] {
        return ["firstName" : firstName, "secondName" : secondName]
    }
}
