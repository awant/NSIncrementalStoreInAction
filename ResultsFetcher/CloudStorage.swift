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

class CashedObjects {
    var fetchedObjects = [String:CKRecord]()
    
    func addObject(object: CKRecord, withkey key: String) {
        fetchedObjects[key] = object
    }
}

class CloudStorage : IncrementalStorageProtocol {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var artistId: CKRecordID!
    var objectsForSave = [String:CKRecord]()
    var objects = [String:CKRecordID]()
    
    var cache = CashedObjects()
    
    func predicateProcessing(basicPredicateInString: String) -> NSPredicate {
        var wordsOfPredicate = basicPredicateInString.componentsSeparatedByString(" ")
        var objectsForPredicate = [CKRecordID]()
        for i in 0...wordsOfPredicate.count-1 {
            if let recordId = self.objects[wordsOfPredicate[i]] {
                objectsForPredicate.append(recordId)
                wordsOfPredicate[i] = "%@"
            }
        }
        return NSPredicate(format: wordsOfPredicate.joinWithSeparator(" "), argumentArray: objectsForPredicate)
    }
    
    func fetchRecordIDs<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        let fetchGroup = dispatch_group_create()
        var arrayOfKeys: [T]?
        
        let validPredicate = predicate ?? NSPredicate(value: true)
        let query = CKQuery(recordType: entityName, predicate: validPredicate)
        query.sortDescriptors = sortDescriptors
        
        dispatch_group_enter(fetchGroup)
        publicDB.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            guard let results = results else {
                return
            }
            if let error = error {
                print("error: \(error)")
                return
            }
            arrayOfKeys = results.map { (let record) -> T in
                self.objects[record.recordID.recordName] = record.recordID
                self.cache.addObject(record, withkey: record.recordID.recordName)
                return record.recordID.recordName as! T
            }
            dispatch_group_leave(fetchGroup)
        }
        dispatch_group_wait(fetchGroup, DISPATCH_TIME_FOREVER)
        return arrayOfKeys!
    }
    
    func getReceivedObject(fetchedRecord: CKRecord, field: String) -> AnyObject? {
        
        switch field {
            case "image":
                let asset = fetchedRecord[field] as! CKAsset
                return NSData(contentsOfURL: asset.fileURL)
            
            case "textEng", "textRus":
                let asset = fetchedRecord[field] as! CKAsset
                do {
                    return try String(contentsOfURL: asset.fileURL)
                }
                catch {
                    return ""
                }
            
            default:
                return fetchedRecord[field]!
        }
    }
    
    func valueAndVersion(key: String, fromField field: String) -> AnyObject? {
        if let fetchedRecord = self.cache.fetchedObjects[key] {
            return getReceivedObject(fetchedRecord, field: field)
        }
        
        var receivedObject: AnyObject?
        let getValuesGroup = dispatch_group_create()
        let recordID = CKRecordID(recordName: key)
        dispatch_group_enter(getValuesGroup)
        publicDB.fetchRecordWithID(recordID) { fetchedRecord, error in
            guard let fetchedRecord = fetchedRecord else {
                print("error in valueAndVersion, error = \(error)")
                return
            }
            self.cache.addObject(fetchedRecord, withkey: fetchedRecord.recordID.recordName)
            receivedObject = self.getReceivedObject(fetchedRecord, field: field)
            dispatch_group_leave(getValuesGroup)
        }
        dispatch_group_wait(getValuesGroup, DISPATCH_TIME_FOREVER)
        return receivedObject
    }
    
    func getReceivedObjectIDs(fetchedRecord: CKRecord, fieldName: String) -> AnyObject {
        if let receivedReference = fetchedRecord[fieldName] as? CKReference {
            self.objects[receivedReference.recordID.recordName] = receivedReference.recordID
            return receivedReference.recordID.recordName
        } else {
            let receivedReferencesArray = fetchedRecord[fieldName] as! [CKReference]
            return receivedReferencesArray.map { (let reference) -> String in
                self.objects[reference.recordID.recordName] = reference.recordID
                return reference.recordID.recordName
            }
        }
    }
    
    func getKeyOfDestFrom(keyObject: String, to fieldName: String) -> AnyObject {
        if let fetchedRecord = self.cache.fetchedObjects[keyObject] {
            getReceivedObjectIDs(fetchedRecord, fieldName: fieldName)
        }
        
        var receivedObjectIDs: AnyObject?
        let relationshipsGroup = dispatch_group_create()
        let recordID = CKRecordID(recordName: keyObject)
        dispatch_group_enter(relationshipsGroup)
        publicDB.fetchRecordWithID(recordID) { fetchedRecord, error in
            guard let fetchedRecord = fetchedRecord else {
                print("error in getKeyOfDestFrom, error = \(error)")
                return
            }
            self.cache.addObject(fetchedRecord, withkey: fetchedRecord.recordID.recordName)
            receivedObjectIDs = self.getReceivedObjectIDs(fetchedRecord, fieldName: fieldName)
            dispatch_group_leave(relationshipsGroup)
        }
        
        dispatch_group_wait(relationshipsGroup, DISPATCH_TIME_FOREVER)
        return receivedObjectIDs!
    }
    
    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
        let newKeyGroup = dispatch_group_create()
        
        var newObjectID: AnyObject?
        
        let newRecord = CKRecord(recordType: entityName)
        dispatch_group_enter(newKeyGroup)
        publicDB.saveRecord(newRecord) { savedRecord, error in
            guard let savedRecord = savedRecord else {
                print("error in getKeyOfNewObjectWithEntityName, error = \(error)")
                return
            }
            newObjectID = savedRecord.recordID.recordName
            self.objectsForSave[savedRecord.recordID.recordName] = savedRecord
            dispatch_group_leave(newKeyGroup)
        }
        dispatch_group_wait(newKeyGroup, DISPATCH_TIME_FOREVER)
        
        return newObjectID!
    }
    func saveRecord(key: String, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
        let saveGroup = dispatch_group_create()
        
        for attrib in dictOfAttribs {
            self.objectsForSave[key]![attrib.0] = attrib.1 as! String
        }
        for (field, relateKeys) in dictOfRelats {
            if relateKeys.count == 1 {
                self.objectsForSave[key]![field] = CKReference(record: self.objectsForSave[relateKeys.first!]!, action: .None)
            } else {
                print("try to save many referencies")
            }
        }
        dispatch_group_enter(saveGroup)
        publicDB.saveRecord(self.objectsForSave[key]!) { savedObject, savedError in
            guard let _ = savedObject else {
                print("error = \(saveGroup)")
                return
            }
            dispatch_group_leave(saveGroup)
        }
        dispatch_group_wait(saveGroup, DISPATCH_TIME_FOREVER)
        return
    }
    
    func updateRecord(objectForUpdate: AnyObject, key: AnyObject, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
        print("updateRecord")
        return
    }
    
    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) {
        return
    }
    
    func subscribeToUpdates() {
        let subscription = CKSubscription(recordType: "Artist", predicate: NSPredicate(format: "TRUEPREDICATE"), options: CKSubscriptionOptions.FiresOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertLocalizationKey = "New artist"
        notificationInfo.shouldBadge = true;
        subscription.notificationInfo = notificationInfo
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveSubscription(subscription, completionHandler: { (subscription, error) in
            if error != nil {
                print("\(error)")
                print("error in subscription")
                return
            }
        })
    }
}


