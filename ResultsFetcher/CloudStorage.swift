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
    
    init() {
        let record = CKRecord(recordType: "RecordType")
        publicDB.saveRecord(record) { savedRecord, error in
            // handle errors here
        }
    }
    
//    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
//        let record = CKRecord(recordType: "RecordType")
//        publicDB.saveRecord(record) { savedRecord, error in
//            // handle errors here
//        }
//        
//    }
//    
//    func saveRecord(key: String, dictOfAttribs: [String:AnyObject], dictOfRelats: [String:[String]]) -> AnyObject? {
//        
//    }
}