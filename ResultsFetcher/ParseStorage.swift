//
//  ParseStorage.swift
//  ResultsFetcher
//
//  Created by Roman Marakulin on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import Parse
import Kangaroo

enum FetchError: ErrorType {
    case InvalidFieldOfRecord
}

var fNotificationName: String = "records were obtained"
var fNewObjectsName: String = "new objects"

class ParseStorage : IncrementalStorageProtocol  {
    
    // MARK: IncrementalStorageProtocol
    
    // Return dictionary with format:
    // id: Record (id should be unique)
    // Record is dictionary with format:
    // fieldName: AnyObject
    // if fieldName is relationship
    // AnyObject can be array of ids
    // or just an id
    func fetchRecords<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T:[String:AnyObject]] {
        var fetchedRecords = [T:[String:AnyObject]]()
        
        let query = PFQuery(className: entityName, predicate: predicate)
        let records = try! query.findObjects()
        for record in records {
            var internalRecords = [String : AnyObject]()
            for key in record.allKeys {
                internalRecords[key] = try! self.getRecordOfRecord(record, fromField: key)
            }
            fetchedRecords[record.objectId as! T] = internalRecords
        }
        return fetchedRecords
    }
    
    func saveRecords(dictOfRecords: [(name: String, atributes: [String: AnyObject])]) {
        for (newRecordName, attributes) in dictOfRecords {
            let newRecord = PFObject(className: newRecordName)
            for (attribName, attrib) in attributes {
                newRecord[attribName] = convertToFileIfNeeded(attribName, attrib: attrib)
            }
            try! newRecord.save()
        }
    }
    
    
    // MARK: Notifications in IncrementalStorageProtocol
    var RecordsWereReceivedNotification: String = RecordsWereRecievedFromiCloudNotification
    var newObjectsName: String = nameOfNewObjectsFromiCloud
    
    // MARK: Supporting methods
    
    func convertFile(file: PFFile, _ field: String) -> AnyObject {
        switch field {
        case "image":
            return try! file.getData()
        case "textEng", "textRus":
            return String(data: (try! file.getData()), encoding: NSUTF8StringEncoding)!
        default:
            NSLog("Can't match this file")
            abort()
        }
    }
    
    func convertToFileIfNeeded(recordName: String, attrib: AnyObject?) -> AnyObject? {
        if attrib == nil {
            return nil
        }
        switch recordName {
        case "image":
            return PFFile(data: attrib as! NSData)!
        case "textEng", "textRus":
            return PFFile(data: attrib as! NSData)!
        default:
            //TODO: also we there if recordName is relationship
            return attrib
        }
    }
    
    func getRecordOfRecord(fetchedRerord: PFObject, fromField field: String) throws -> AnyObject {
        guard let rudeRecord = fetchedRerord[field] else {
            throw FetchError.InvalidFieldOfRecord
        }
        
        if let file = rudeRecord as? PFFile {
            return convertFile(file, field)
        } else if let relationship = rudeRecord as? PFRelation {
            let query = relationship.query()
            return (try! query.findObjects().first! as PFObject).objectId!
        } else if let arrayOfRecords = rudeRecord as? [PFObject] {
            let setOfRecords = NSMutableSet()
            for record in arrayOfRecords {
                setOfRecords.addObject(record.objectId!)
            }
            return setOfRecords
        } else {
            return rudeRecord
        }
    }
}
