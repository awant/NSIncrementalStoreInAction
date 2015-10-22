//
//  CloudStorage.swift
//  ResultsFetcher
//
//  Created by Awant on 20.10.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CloudKit
import Kangaroo

class CloudStorage : IncrementalStorageProtocol {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    
    var objectsForSave = [String:CKRecord]()
    
    func fetchRecords(entityName: String, relatedEntitiesNames: [String]?, sortDescriptors: [NSSortDescriptor]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject? {
        
        var block = true
        var arrayOfKeys: [String]?
        
        let emptyPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: entityName, predicate: emptyPredicate)
        //query.sortDescriptors = sortDescriptors
        
        publicDB.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            guard let results = results else {
                print("results = nil")
                return
            }
            arrayOfKeys = results.map { (let record) -> String in
                return record.recordID.recordName
            }
            block = false
        }
        
        while (block) {}
        return newEntityCreator(entityName, arrayOfKeys)
    }
    
    func valueAndVersion(key: String, fromField field: String) -> AnyObject? {
        
        var block = true
        var receivedObject: AnyObject?
        
        let recordID = CKRecordID(recordName: key)
        publicDB.fetchRecordWithID(recordID) { fetchedRecord, error in
            guard let fetchedRecord = fetchedRecord else {
                print("error in valueAndVersion, error = \(error)")
                return
            }
            receivedObject = fetchedRecord[field]!
            block = false
        }
        while (block) {}
        print("receivedObject = \(receivedObject)")
        return receivedObject
    }
    
    func getKeyOfDestFrom(keyObject: String, to fieldName: String) -> AnyObject? {
        
        var block = true
        var receivedObjectID: AnyObject?
        
        let recordID = CKRecordID(recordName: keyObject)
        publicDB.fetchRecordWithID(recordID) { fetchedRecord, error in
            guard let fetchedRecord = fetchedRecord else {
                print("error in getKeyOfDestFrom, error = \(error)")
                return
            }
            receivedObjectID = (fetchedRecord[fieldName] as! CKReference).recordID.recordName
            block = false
        }
        
        while (block) {}
        print("receivedObjectID = \(receivedObjectID)")
        return receivedObjectID
    }
    
    
    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
        
        var block = true
        var newObjectID: AnyObject?
        
        let newRecord = CKRecord(recordType: entityName)
        publicDB.saveRecord(newRecord) { savedRecord, error in
            guard let savedRecord = savedRecord else {
                print("error in getKeyOfNewObjectWithEntityName, error = \(error)")
                return
            }
            newObjectID = savedRecord.recordID.recordName
            self.objectsForSave[savedRecord.recordID.recordName] = savedRecord
            block = false
        }
        while (block) {}
        
        return newObjectID!
    }
    
    func saveRecord(key: String, dictOfAttribs: [String:AnyObject], dictOfRelats: [String:[String]]) -> AnyObject? {
        
        var block = true
        
        for attrib in dictOfAttribs {
            // TODO: We should be sure that attrib.1 has String type
            self.objectsForSave[key]![attrib.0] = attrib.1 as! String
        }
        for (field, relateKeys) in dictOfRelats {
            if relateKeys.count == 1 {
                self.objectsForSave[key]![field] = CKReference(record: self.objectsForSave[relateKeys.first!]!, action: .None)
            } else {
                print("try to save many referencies")
//                self.objectsForSave[key]![field] = relateKeys.map { (let key) -> PFObject in
//                    // TODO: we should check for existing
//                    return self.objectsForSave[key]!
//                }
            }
        }
        publicDB.saveRecord(self.objectsForSave[key]!) { savedObject, savedError in
            guard let savedObject = savedObject else {
                print("error = \(savedError)")
                return
            }
            block = false
        }
        while (block) {}
        print("record was saved")
        return []
    }
    
    func updateRecord(objectForUpdate: AnyObject, key: AnyObject) -> AnyObject? {
        return nil
    }
    
    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) -> AnyObject? {
        return nil
    }
}


