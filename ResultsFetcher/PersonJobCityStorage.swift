//
//  PersonJobStorage.swift
//  ResultsFetcher
//
//  Created by Awant on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import Parse

class PersonJobCityStorage: IncrementalStorageProtocol {
    var persons: [String: PFObject]?
    var city: [String: PFObject]?
    var job: [String: PFObject]?
    
    var personForSave: PFObject?
    var jobForSave: PFObject?
    var cityForSave: PFObject?
    
    func fetchRecords(entityName: String, sortDescriptors: [NSSortDescriptor]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject? {
        if entityName == "Person" {
            let personQuery = PFQuery(className: "Person")
            personQuery.includeKey("job")
            personQuery.includeKey("city")
            var loadedPersons: [PFObject]?
            do {
                loadedPersons = try personQuery.findObjects()
            } catch {}
            var arrayOfKeys: [String]?
            if let lPersons = loadedPersons {
                arrayOfKeys = [String]()
                self.persons = [String: PFObject]()
                self.city = [String: PFObject]()
                self.job = [String: PFObject]()
                for person in lPersons {
                    arrayOfKeys!.append(person.objectId! as String)
                    self.persons![person.objectId!] = person
                    self.city![person.objectId!] = person["city"] as? PFObject
                    self.job![person.objectId!] = person["job"] as? PFObject
                }
            }
            let persons = newEntityCreator("Person", arrayOfKeys)
            return persons
        }
        return nil
    }
    
    func valuesAndVersion(key: AnyObject) -> (values: [String : AnyObject], version: UInt64)? {
        var retDict = [String : AnyObject]()
        if let person = self.persons![key as! String] {
            retDict["firstName"] = person["firstName"]
            retDict["secondName"] = person["secondName"]
            retDict["job"] = NSNull()
            retDict["city"] = NSNull()
        }
        if let job = self.job![key as! String] {
            retDict["name"] = job["firstName"]
            print("request for values of job")
        }
        if let city = self.city![key as! String] {
            retDict["name"] = city["firstName"]
            print("request for values of city")
        }
        return (values: retDict, version: 1)
    }
    
    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
        if entityName == "Person" {
            self.personForSave = PFObject(className: entityName)
            do {
                try self.personForSave?.save()
            } catch {}
            return (self.personForSave?.objectId)!
        }
        if entityName == "Job" {
            self.jobForSave = PFObject(className: entityName)
            do {
                try self.jobForSave?.save()
            } catch {}
            return (self.jobForSave?.objectId)!
        }
        if entityName == "City" {
            self.cityForSave = PFObject(className: entityName)
            do {
                try self.cityForSave?.save()
            } catch {}
            return (self.cityForSave?.objectId)!
        }
        return []
    }
    
    func getKeyOfDestFrom(keyObject: String , to fieldName: String) -> AnyObject? {
        if fieldName == "city" {
            return self.city![keyObject]?.objectId
        }
        if fieldName == "job" {
            return self.job![keyObject]?.objectId
        }
        print("something else")
        return nil
    }

    func saveRecord(objectForSave: AnyObject, key: AnyObject) -> AnyObject? {
        // We don't use NSManagedObject in this and I'll change this in the future
        if ((self.personForSave?.objectId)! == key as! String) {
            // And this is because I don't pass relationships
            self.personForSave!["firstName"] = (objectForSave as! Person).firstName
            self.personForSave!["secondName"] = (objectForSave as! Person).secondName
            // And this is because I don't pass relationships
            self.personForSave!["job"] = self.jobForSave
            self.personForSave!["city"] = self.cityForSave
            do {
                try self.personForSave?.save()
            } catch {}
            return []
        }
        if ((self.jobForSave?.objectId)! == key as! String) {
            
            self.jobForSave!["name"] = (objectForSave as! Job).name
            self.jobForSave!["persons"] = [self.personForSave!]
            do {
                try self.jobForSave?.save()
            } catch {}
            return []
        }
        if ((self.cityForSave?.objectId)! == key as! String) {
            self.cityForSave!["name"] = (objectForSave as! City).name
            self.cityForSave!["persons"] = [self.personForSave!]
            do {
                try self.cityForSave?.save()
            } catch {}
            return []
        }
        return nil
    }
    
    func updateRecord(objectForUpdate: AnyObject, key: AnyObject) -> AnyObject? {
        return nil
    }

    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) -> AnyObject? {
        return nil
    }
}














