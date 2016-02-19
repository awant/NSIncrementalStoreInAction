//
//  ParseStorage.swift
//  ResultsFetcher
//
//  Created by Awant on 23.09.15.
//  Copyright © 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
// ObjectID is unique only for a class, but hardly to get duplicated keys (it's not mentioned in docs)
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
    
    // NEW API ==============================================================================================
    
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
            return setOfRecords // arrayOfRecords.map{ $0.objectId! }
        } else {
            return rudeRecord
        }
    }
    
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
    
    // END OF NEW API =======================================================================================
    
    // Return dictionary with format:
    // id: Record (id should be unique)
    // Record is dictionary with format:
    // fieldName: AnyObject
    // if fieldName is relationship
    // AnyObject can be array of ids
    // or just an id

    
//    func fetchRecords<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T:[String:AnyObject]] {
//        
//        var fetchedRecords = [T:[String:AnyObject]]()
//        
//        let records: [PFObject]
//        let query = PFQuery(className: entityName)
//        records = try! query.findObjects()
//        for record in records {
//            var internalRecords = [String: AnyObject]()
//            for key in record.allKeys {
//                internalRecords[key] = try! self.getRecordOfRecord(record, fromField: key)
//            }
//            fetchedRecords[record.objectId as! T] = internalRecords
//        }
//        return fetchedRecords
//    }
    
//    func asyncFetchRecords<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completionHandler: (fetchedRecords: [T:[String:AnyObject]]) -> Void) {
//        
//        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            let fetchedRecords: [T:[String:AnyObject]] = self.fetchRecords(entityName, predicate: predicate, sortDescriptors: sortDescriptors)
//            dispatch_async(dispatch_get_main_queue()) {
//                completionHandler(fetchedRecords: fetchedRecords)
//            }
//        }
//    }
    
    // =========================================================================================================
    
//    func getReceivedObject(fetchedRecord: PFObject, field: String) -> AnyObject? {
//        
//        switch field {
//        case "image":
//            let userImageFile = fetchedRecord[field] as! PFFile
//            do {
//                return try userImageFile.getData()
//            } catch {}
//            
//        case "textEng", "textRus":
//            let text = fetchedRecord[field] as! PFFile
//            do {
//                return String(data: (try text.getData()), encoding: NSUTF8StringEncoding)
//            }
//            catch {
//                return ""
//            }
//            
//        default:
//            return fetchedRecord[field]!
//        }
//        return nil
//    }
    
//    func predicateProcessing(basicPredicateInString: String) -> NSPredicate {
//        var wordsOfPredicate = basicPredicateInString.componentsSeparatedByString(" ")
//        
//        for i in 0...wordsOfPredicate.count-1 {
//            if let recordObject = self.cache.fetchedObjects[wordsOfPredicate[i]] {
//                let recordName = recordObject["name"] as! String
//                wordsOfPredicate[i-2] = "keyWord"
//                wordsOfPredicate[i] = "'" + recordName + "'"
//                return NSPredicate(format: wordsOfPredicate.joinWithSeparator(" "))
//            }
//        }
//        return NSPredicate(format: "FALSEPREDICATE")
//    }
    
//    func fetchRecordIDs<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
//        print("fetch from Parse")
//        
//        if let predicate = predicate {
//            if predicate.predicateFormat == NSPredicate(format: "FALSEPREDICATE").predicateFormat {
//                return []
//            }
//        }
//        
//        let query = PFQuery(className: entityName, predicate: predicate)
//        do {
//            return try query.findObjects().map{ (let record) -> T in
//                cache.addObject(record, withkey: record.objectId!)
//                return record.objectId! as! T
//            }
//        } catch { print("Can't find objects") }
//        return []
//    }
//    
//
//    
//    func valueAndVersion(key: String, fromField field: String) -> AnyObject? {
//        if let fetchedRecord = self.cache.fetchedObjects[key] {
//            return getReceivedObject(fetchedRecord, field: field)
//        }
//        return nil
//    }
//    
//    func getReceivedObjectIDs(fetchedRecord: PFObject, fieldName: String) -> AnyObject {
//        
//        if let receivedReference = fetchedRecord[fieldName] as? PFRelation {
//            let query = receivedReference.query()
//            do {
//                return (try query.findObjects().first! as PFObject).objectId!
//            } catch { print("Can't find object") }
//        } else {
//            let receivedReferencesArray = fetchedRecord[fieldName] as! [PFObject]
//            return receivedReferencesArray.map { (let reference) -> String in
//                return reference.objectId!
//            }
//        }
//        return []
//    }
//    
//    func getKeyOfDestFrom(keyObject: String, to fieldName: String) -> AnyObject {
//        if let fetchedRecord = self.cache.fetchedObjects[keyObject] {
//            return getReceivedObjectIDs(fetchedRecord, fieldName: fieldName)
//        }
//        return []
//    }
//    
//    
//    // TODO:
//    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
//        let newObject = PFObject(className: entityName)
//        do {
//            try newObject.save()
//        } catch {}
//        self.objectsForSave[newObject.objectId!] = newObject
//        return newObject.objectId!
//    }
//    
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














































