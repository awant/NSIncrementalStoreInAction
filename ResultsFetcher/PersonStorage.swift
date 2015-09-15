//
//  PersonStorage.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation

let homeDirectory = NSFileManager.homeDirectory().stringByAppendingPathComponent("persons")

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
    
    override var description: String {
        return "\(firstName) \(secondName)"
    }
}

protocol IncrementalStorageProtocol {
    /** [AnyObject]? is array of keys of objects in storage. Return persons getting from newEntityCreator */
    func fetchRecords(entityName: String, sortDescriptors: [AnyObject]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject?
    /** Get values and version of object with this key */
    func valuesAndVersion(key: AnyObject) -> (values: [NSObject : AnyObject], version: UInt64)?
    /** Create new empty object and return key of it */
    func getKeyOfNewObject() -> AnyObject
    /** Save record in storage and return nil if can't */
    func saveRecord(personForSave: Person, key: AnyObject) -> AnyObject?
    /** Update record in storage and return nil if can't */
    func updateRecord(personForUpdate: Person, key: AnyObject) -> AnyObject?
    /** Delete record in storage and return nil if can't */
    func deleteRecord(personForDelete: Person, key: AnyObject) -> AnyObject?
}

class PersonStorage: IncrementalStorageProtocol {
    
    var cachePersons = [String: _Person]()
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
    
    func fetchRecords(entityName: String, sortDescriptors: [AnyObject]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject? {
        persons = NSKeyedUnarchiver.unarchiveObjectWithFile(homeDirectory) as? [_Person]
        if entityName == "Person" {
            if let persons = self.persons, let sD = sortDescriptors {
                self.persons = (persons as NSArray).sortedArrayUsingDescriptors(sD) as? [_Person]
            }
            let persons = newEntityCreator("Person", arrayOfKeys()) as! [_Person]
            return persons
        }
        return nil
    }
    
    func valuesAndVersion(key: AnyObject) -> (values: [NSObject : AnyObject], version: UInt64)? {
        if let persons = self.persons {
            for person in persons {
                if person.identifier.id == key as! String {
                    return person.valuesAndVersion()
                }
            }
            return nil
        }
        return nil
    }
    
    func getKeyOfNewObject() -> AnyObject {
        var newPerson = _Person(firstName: "", secondName: "")
        cachePersons[newPerson.identifier.id] = newPerson
        return newPerson.identifier.id
    }
    
    func saveRecord(personForSave: Person, key: AnyObject) -> AnyObject? {
        if self.persons == nil {
            self.persons = [_Person]()
        }
        if let personInCache = self.cachePersons[key as! String] {
            personInCache.firstName = personForSave.firstName
            personInCache.secondName = personForSave.secondName
            self.persons!.append(personInCache)
            if (!NSKeyedArchiver.archiveRootObject(persons!, toFile: homeDirectory)) {
                return nil
            }
            cachePersons.removeValueForKey(key as! String)
            return []
        }
        return nil
    }
    
    func updateRecord(personForUpdate: Person, key: AnyObject) -> AnyObject? {
        if self.persons == nil {
            return nil
        }
        for person in self.persons! {
            if person.identifier.id == key as! String {
                person.firstName = personForUpdate.firstName
                person.secondName = personForUpdate.secondName
                if (!NSKeyedArchiver.archiveRootObject(persons!, toFile: homeDirectory)) {
                    return nil
                }
                return []
            }
        }
        return nil
    }
    
    func deleteRecord(personForDelete: Person, key: AnyObject) -> AnyObject? {
        if self.persons == nil {
            return nil
        }
        var i = 0
        for person in self.persons! {
            if person.identifier.id == key as! String {
                self.persons!.removeAtIndex(i)
                if (!NSKeyedArchiver.archiveRootObject(persons!, toFile: homeDirectory)) {
                    return nil
                }
                return []
            }
            i++
        }
        return nil
    }
}

extension NSFileManager {
    class func homeDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    }
}
