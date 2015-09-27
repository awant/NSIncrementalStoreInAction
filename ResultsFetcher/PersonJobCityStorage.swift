//
//  PersonJobStorage.swift
//  ResultsFetcher
//
//  Created by Awant on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
// ObjectID is unique only for a class, but hardly to get duplicated keys (it's not mentioned in docs)
import Parse

class PersonJobCityStorage: IncrementalStorageProtocol {
    enum CodingKeyPerson: String {
        case firstName, secondName, job, city
    }
    enum CodingKeyJob: String {
        case name, persons
    }
    enum CodingKeyCity: String {
        case name, persons
    }
    
    var persons: [String: PFObject]?
    var city: [String: PFObject]?
    var job: [String: PFObject]?
    
    var personForSave: PFObject?
    var jobForSave: PFObject?
    var cityForSave: PFObject?
    
    func fetchRecords(entityName: String, sortDescriptors: [NSSortDescriptor]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject? {
        if entityName == "Person" {
            let personQuery = PFQuery(className: "Person")
            personQuery.includeKey(CodingKeyPerson.job.rawValue)
            personQuery.includeKey(CodingKeyPerson.city.rawValue)
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
                    self.city![person.objectId!] = person[CodingKeyPerson.city.rawValue] as? PFObject
                    self.job![person.objectId!] = person[CodingKeyPerson.job.rawValue] as? PFObject
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
            retDict[CodingKeyPerson.firstName.rawValue] = person[CodingKeyPerson.firstName.rawValue]
            retDict[CodingKeyPerson.secondName.rawValue] = person[CodingKeyPerson.secondName.rawValue]
            return (values: retDict, version: 1)
        }
        retDict["name"] = "Place"
        if let job = self.job![key as! String] {
            //retDict["name"] = job[CodingKeyPerson.firstName.rawValue]
            print("request for values of job")
        }
        if let city = self.city![key as! String] {
            //retDict["name"] = city["firstName"]
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
        if fieldName == CodingKeyPerson.city.rawValue {
            return self.city![keyObject]?.objectId
        }
        if fieldName == CodingKeyPerson.job.rawValue {
            return self.job![keyObject]?.objectId
        }
        print("something else")
        return nil
    }
    
    func saveRecord(objectForSave: AnyObject, key: AnyObject) -> AnyObject? {
        if ((self.personForSave?.objectId)! == key as! String) {
            // And this is because I don't pass relationships
            self.personForSave![CodingKeyPerson.firstName.rawValue] = (objectForSave as! Person).firstName
            self.personForSave![CodingKeyPerson.secondName.rawValue] = (objectForSave as! Person).secondName
            // And this is because I don't pass relationships
            self.personForSave![CodingKeyPerson.job.rawValue] = self.jobForSave
            self.personForSave![CodingKeyPerson.city.rawValue] = self.cityForSave
            do {
                try self.personForSave?.save()
            } catch {}
            return []
        }
        if ((self.jobForSave?.objectId)! == key as! String) {
            
            self.jobForSave![CodingKeyJob.name.rawValue] = (objectForSave as! Job).name
            self.jobForSave![CodingKeyJob.persons.rawValue] = [self.personForSave!]
            do {
                try self.jobForSave?.save()
            } catch {}
            return []
        }
        if ((self.cityForSave?.objectId)! == key as! String) {
            self.cityForSave![CodingKeyCity.name.rawValue] = (objectForSave as! City).name
            self.cityForSave![CodingKeyCity.persons.rawValue] = [self.personForSave!]
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
