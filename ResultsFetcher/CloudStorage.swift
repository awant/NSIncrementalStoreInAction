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

class CloudStorage {
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    
    var objectsForSave = [String:CKRecord]()
    
    init() {
        getKeyOfNewObjectWithEntityName("RecordType")
    }
    
    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
        var block = true
        var returnedValue = ""
        let record = CKRecord(recordType: entityName)
        publicDB.saveRecord(record) { savedRecord, error in
            guard let savedRecord = savedRecord else {
                print("error = \(error)")
                return
            }
            self.objectsForSave[savedRecord.recordID.recordName] = savedRecord
            returnedValue = savedRecord.recordID.recordName
            block = false
        }
        while (block) {}
        print("returnedValue = \(returnedValue)")
        return returnedValue
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


