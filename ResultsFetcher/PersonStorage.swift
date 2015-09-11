//
//  PersonStorage.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation

let homeDirectory = NSFileManager.homeDirectory().stringByAppendingPathComponent("persons")

struct StorageID {
    let id = NSUUID().UUIDString
}

struct StorageObjectID {
    let id = NSUUID().UUIDString
}

class _Person: NSObject, NSCoding {
    enum CodingKey: String {
        case fName = "firstName"
        case sName = "secondName"
    }
    let identifier = StorageObjectID()
    
    var firstName: String
    var secondName: String
    
    init(firstName: String, secondName: String) {
        self.firstName = firstName
        self.secondName = secondName
    }
    
    required init(coder aDecoder: NSCoder) {
        self.firstName = aDecoder.decodeObjectForKey(CodingKey.fName.rawValue) as! String
        self.secondName = aDecoder.decodeObjectForKey(CodingKey.sName.rawValue) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.firstName, forKey: CodingKey.fName.rawValue)
        aCoder.encodeObject(self.secondName, forKey: CodingKey.sName.rawValue)
    }
    
    func valuesAndVersion() -> (values: [NSObject : AnyObject], version: UInt64)? {
        return (values:[CodingKey.fName.rawValue : firstName, CodingKey.sName.rawValue : secondName], version: 1)
    }
}

class PersonStorage {
    
    var cachePersons = [_Person]()
    var persons: [_Person]?
    
    // It can be written in one line
    func arrayOfKeys() -> [AnyObject]? {
        if let persons = self.persons {
            var keys = [AnyObject]()
            for person in persons {
                keys.append(person.identifier.id)
            }
            return keys
        }
        return nil
    }
    
    // For protocol
    func fetchRecords(entityName: String, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject? {
        persons = NSKeyedUnarchiver.unarchiveObjectWithFile(homeDirectory) as? [_Person]
        if entityName == "Person" {
            let persons = newEntityCreator("Person", arrayOfKeys()) as! [_Person]
            return persons
        }
        return nil
    }
    
    // It can be written better
    func valuesAndVersion(id: String) -> (values: [NSObject : AnyObject], version: UInt64)? {
        if let persons = self.persons {
            for person in persons {
                if person.identifier.id == id {
                    return person.valuesAndVersion()
                }
            }
            return nil
        }
        return nil
    }
    
    func keyOfNewObject() -> AnyObject {
        var newPerson = _Person(firstName: "", secondName: "")
        cachePersons.append(newPerson)
        return newPerson.identifier.id
    }
    
    func saveRecord(personForSave: Person, key: String) {
        if self.persons == nil {
            self.persons = [_Person]()
        }
        for personInCache in cachePersons {
            if personInCache.identifier.id == key {
                personInCache.firstName = personForSave.firstName
                personInCache.secondName = personForSave.secondName
                self.persons?.append(personInCache)
                // It doesn't work with several persons
                cachePersons = [_Person]()
                break
            }
        }
        NSKeyedArchiver.archiveRootObject(persons!, toFile: homeDirectory)
    }
}

extension NSFileManager {
    class func homeDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    }
}
