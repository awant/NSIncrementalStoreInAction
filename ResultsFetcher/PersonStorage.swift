//
//  PersonStorage.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation

// I don't know, why StorageID is needed
struct StorageID {
    let id = NSUUID().UUIDString
}

let homeDirectory = NSFileManager.homeDirectory().stringByAppendingPathComponent("persons")

class _Person: NSObject, NSCoding {
    private struct CodingKey {
        static let fName = "firstName"
        static let sName = "secondName"
    }
    
    var firstName: String
    var secondName: String
    
    init(firstName: String, secondName: String) {
        self.firstName = firstName
        self.secondName = secondName
    }
    
    required init(coder aDecoder: NSCoder) {
        self.firstName = aDecoder.decodeObjectForKey(CodingKey.fName) as! String
        self.secondName = aDecoder.decodeObjectForKey(CodingKey.sName) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.firstName, forKey: CodingKey.fName)
        aCoder.encodeObject(self.secondName, forKey: CodingKey.sName)
    }
    
    func valuesAndVersion() -> (values: [NSObject : AnyObject], version: UInt64)? {
        return (values:[CodingKey.fName : firstName, CodingKey.sName : secondName], version: 1)
    }
}

class PersonStorage {
    var persons = NSKeyedUnarchiver.unarchiveObjectWithFile(homeDirectory) as? [_Person]
    let storageID = StorageID()
    
    func fetchRecords(entityName: String, newEntityCreator: (String, StorageID, [NSObject]?) -> AnyObject) -> AnyObject? {
        if entityName == "Person" {
            let persons = newEntityCreator("Person", self.storageID, self.persons) as! [_Person]
            return persons
        }
        return nil
    }
    
    func saveRecord(personForSave: Person) {
        if self.persons == nil {
            self.persons = [_Person]()
        }
        self.persons!.append(_Person(firstName: personForSave.firstName, secondName: personForSave.secondName))
        NSKeyedArchiver.archiveRootObject(persons!, toFile: homeDirectory)
    }
}

extension NSFileManager {
    class func homeDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    }
}

//private
//extension Person {
//    class func values(firstName: String, secondName: String) -> [NSObject : AnyObject] {
//        return ["firstName" : firstName, "secondName" : secondName]
//    }
//}