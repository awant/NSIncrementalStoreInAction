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

class CachedParseObjects {
    var fetchedObjects = [String:PFObject]()
    
    func addObject(object: PFObject, withkey key: String) {
        fetchedObjects[key] = object
    }
}

enum FetchError: ErrorType {
    case InvalidFieldOfRecord
}

var fNotificationName: String = "records were obtained"
var fNewObjectsName: String = "new objects"

class ParseStorage : IncrementalStorageProtocol  {
    var receivedObjects: [String: PFObject]?
    var relatedEntitiesNames: [String]?
    var objectsForSave = [String:PFObject]()
    var cache = CachedParseObjects()
    
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
    
    // Return dictionary with format:
    // id: Record (id should be unique)
    // Record is dictionary with format:
    // fieldName: AnyObject
    // if fieldName is relationship
    // AnyObject can be array of ids
    // or just an id
    func fetchRecords<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T:[String:AnyObject]] {
        var fetchedRecords = [T:[String:AnyObject]]()
        
        let records: [PFObject]
        let query = PFQuery(className: entityName)
        records = try! query.findObjects()
        for record in records {
            var internalRecords = [String : AnyObject]()
            for key in record.allKeys {
                internalRecords[key] = try! self.getRecordOfRecord(record, fromField: key)
            }
            fetchedRecords[record.objectId as! T] = internalRecords
        }
        return fetchedRecords
    }
    
    var fetchNotificationName: String = fNotificationName
    var newObjectsName: String = fNewObjectsName
    
//    // TODO:
//    func saveRecord(key: String, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
//        for attrib in dictOfAttribs {
//            objectsForSave[key]![attrib.0] = attrib.1
//        }
//        for (field, relateKeys) in dictOfRelats {
//            if relateKeys.count == 1 {
//                self.objectsForSave[key]![field] = self.objectsForSave[relateKeys.first!]
//            } else {
//                self.objectsForSave[key]![field] = relateKeys.map { (let key) -> PFObject in
//                    return self.objectsForSave[key]!
//                }
//            }
//        }
//        do {
//            try self.objectsForSave[key]!.save()
//        } catch {}
//    }
//    
//    // TODO:
//    func updateRecord(objectForUpdate: AnyObject, key: AnyObject, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
//        print("updateRecord")
//        return
//    }
//    
//    // TODO:
//    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) {
//        return
//    }
    
}
