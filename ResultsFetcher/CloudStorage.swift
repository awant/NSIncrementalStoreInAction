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

var fNotificationNameiCloud: String = "records were obtained"
var fNewObjectsNameiCloud: String = "new objects"

class CachediCloudObjects {
    var fetchedObjects = [String:CKRecord]()
    
    func addObject(object: CKRecord, withkey key: String) {
        fetchedObjects[key] = object
    }
}

class CloudStorage: IncrementalStorageProtocol {
    
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    
    func fetchRecords<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T:[String:AnyObject]] {
        var fetchedRecords = [T : [String : AnyObject]]()
        
        let query = CKQuery(recordType: entityName, predicate: (predicate != nil ? predicate! : NSPredicate(value: true)))
        query.sortDescriptors = sortDescriptors
        
        let fetchGroup = dispatch_group_create()
        dispatch_group_enter(fetchGroup)
        publicDB.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
            guard let records = records else {
                return
            }
            if let error = error {
                print("error: \(error)")
                return
            }
            for record in records {
                var internalRecords = [String : AnyObject]()
                for key in record.allKeys() {
                    internalRecords[key] = try! self.getRecordOfRecord(record, fromField: key)
                }
                fetchedRecords[record.recordID.recordName as! T] = internalRecords
            }
            dispatch_group_leave(fetchGroup)
        }
        dispatch_group_wait(fetchGroup, DISPATCH_TIME_FOREVER)
        
        return fetchedRecords
    }
    
    func getRecordOfRecord(fetchedRerord: CKRecord, fromField field: String) throws -> AnyObject {
        guard let rudeRecord = fetchedRerord[field] else {
            throw FetchError.InvalidFieldOfRecord
        }
        
        if let file = rudeRecord as? CKAsset {
            return convertFile(file, field)
        } else if let relationship = rudeRecord as? CKReference {
            return relationship.recordID.recordName
        } else if let arrayOfRecords = rudeRecord as? [CKReference] {
            let setOfRecords = NSMutableSet()
            for record in arrayOfRecords {
                setOfRecords.addObject(record.recordID.recordName)
            }
            return setOfRecords
        } else {
            return rudeRecord
        }
    }
    
    func convertFile(file: CKAsset, _ field: String) -> AnyObject {
        switch field {
        case "image":
            return NSData(contentsOfURL: file.fileURL)!
        case "textEng", "textRus":
            return try! String(contentsOfURL: file.fileURL)
        default:
            NSLog("Can't match this file")
            abort()
        }
    }
    
    
    // For notifications about fetching from remote cloud
    var fetchNotificationName: String = fNotificationNameiCloud
    var newObjectsName: String = fNewObjectsNameiCloud
    
}



