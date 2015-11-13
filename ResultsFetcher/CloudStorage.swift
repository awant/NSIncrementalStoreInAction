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
    var artistId: CKRecordID!
    var objectsForSave = [String:CKRecord]()
    var objects = [String:CKRecordID]()
    
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
        print("fetchRecordIDs")
        
        let fetchGroup = dispatch_group_create()
        var arrayOfKeys: [T]?
        
        var validPredicate = predicate
        if predicate == nil {
            validPredicate = NSPredicate(value: true)
        }
        let query = CKQuery(recordType: entityName, predicate: validPredicate!)
        query.sortDescriptors = sortDescriptors
        
        dispatch_group_enter(fetchGroup)
        publicDB.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            guard let results = results else {
                print("results = nil")
                return
            }
            
            arrayOfKeys = results.map { (let record) -> T in
                self.objects[record.recordID.recordName] = record.recordID
                return record.recordID.recordName as! T
            }
            dispatch_group_leave(fetchGroup)
        }
        dispatch_group_wait(fetchGroup, DISPATCH_TIME_FOREVER)
        return arrayOfKeys!
    }
    
    func valueAndVersion(key: String, fromField field: String) -> AnyObject? {
        let getValuesGroup = dispatch_group_create()
        
        var receivedObject: AnyObject?
        let recordID = CKRecordID(recordName: key)
        dispatch_group_enter(getValuesGroup)
        publicDB.fetchRecordWithID(recordID) { fetchedRecord, error in
            guard let fetchedRecord = fetchedRecord else {
                print("error in valueAndVersion, error = \(error)")
                return
            }
            if (field == "image") {
                let asset = fetchedRecord[field] as! CKAsset
                receivedObject = NSData(contentsOfURL: asset.fileURL)
            } else if (field == "textEng") || (field == "textRus") {
                let asset = fetchedRecord[field] as! CKAsset
                do {
                    receivedObject = try String(contentsOfURL: asset.fileURL)
                }
                catch {
                    receivedObject = ""
                }
            } else {
                receivedObject = fetchedRecord[field]!
            }
            dispatch_group_leave(getValuesGroup)
        }
        dispatch_group_wait(getValuesGroup, DISPATCH_TIME_FOREVER)
        return receivedObject
    }
    
    func getKeyOfDestFrom(keyObject: String, to fieldName: String) -> AnyObject {
        let relationshipsGroup = dispatch_group_create()
        
        var receivedObjectIDs: AnyObject?
        let recordID = CKRecordID(recordName: keyObject)
        dispatch_group_enter(relationshipsGroup)
        publicDB.fetchRecordWithID(recordID) { fetchedRecord, error in
            guard let fetchedRecord = fetchedRecord else {
                print("error in getKeyOfDestFrom, error = \(error)")
                return
            }
            if let receivedReference = fetchedRecord[fieldName] as? CKReference {
                self.objects[receivedReference.recordID.recordName] = receivedReference.recordID
                receivedObjectIDs = receivedReference.recordID.recordName
            } else {
                let receivedReferencesArray = fetchedRecord[fieldName] as! [CKReference]
                receivedObjectIDs = receivedReferencesArray.map { (let reference) -> String in
                    self.objects[reference.recordID.recordName] = reference.recordID
                    return reference.recordID.recordName
                }
            }
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
        dispatch_group_enter(saveGroup)
        publicDB.saveRecord(self.objectsForSave[key]!) { savedObject, savedError in
            guard let _ = savedObject else {
                print("error = \(saveGroup)")
                return
            }
            dispatch_group_leave(saveGroup)
        }
        dispatch_group_wait(saveGroup, DISPATCH_TIME_FOREVER)
        print("record was saved")
        return
    }
    
    func updateRecord(objectForUpdate: AnyObject, key: AnyObject, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
        print("updateRecord")
        return
    }
    
    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) {
        print("deleteRecord")
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


