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

class ParseStorage : IncrementalStorageProtocol  {
    var receivedObjects: [String: PFObject]?
    var relatedEntitiesNames: [String]?
    var objectsForSave = [String:PFObject]()
    
    var cache = CachedParseObjects()
    
    
    func fetchRecordIDs<T: Hashable>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        let query = PFQuery(className: entityName)
        do {
            return try query.findObjects().map{ (let record) -> T in
                cache.addObject(record, withkey: record.objectId!)
                return record.objectId! as! T
            }
        } catch { print("Can't find objects") }
        return []
    }

    // TODO: cache for data
    func getReceivedObject(fetchedRecord: PFObject, field: String) -> AnyObject? {
        
        switch field {
        case "image":
            let userImageFile = fetchedRecord[field] as! PFFile
            do {
                return try userImageFile.getData()
            } catch {}
            
        case "textEng", "textRus":
            let text = fetchedRecord[field] as! PFFile
            do {
                return String(data: (try text.getData()), encoding: NSUTF8StringEncoding)
            }
            catch {
                return ""
            }
            
        default:
            return fetchedRecord[field]!
        }
        return nil
    }
    
    func valueAndVersion(key: String, fromField field: String) -> AnyObject? {
        if let fetchedRecord = self.cache.fetchedObjects[key] {
            return getReceivedObject(fetchedRecord, field: field)
        }
        return nil
    }
    
    func getReceivedObjectIDs(fetchedRecord: PFObject, fieldName: String) -> AnyObject {
        
        if let receivedReference = fetchedRecord[fieldName] as? PFRelation {
            let query = receivedReference.query()
            do {
                return (try query!.findObjects().first! as PFObject).objectId!
            } catch { print("Can't find object") }
        } else {
            let receivedReferencesArray = fetchedRecord[fieldName] as! [PFObject]
            return receivedReferencesArray.map { (let reference) -> String in
                return reference.objectId!
            }
        }
        return []
    }
    
    func getKeyOfDestFrom(keyObject: String, to fieldName: String) -> AnyObject {
        if let fetchedRecord = self.cache.fetchedObjects[keyObject] {
            return getReceivedObjectIDs(fetchedRecord, fieldName: fieldName)
        }
        return []
    }
    
    
    // TODO:
    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject {
        let newObject = PFObject(className: entityName)
        do {
            try newObject.save()
        } catch {}
        self.objectsForSave[newObject.objectId!] = newObject
        return newObject.objectId!
    }
    
    // TODO:
    func saveRecord(key: String, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
        for attrib in dictOfAttribs {
            objectsForSave[key]![attrib.0] = attrib.1
        }
        for (field, relateKeys) in dictOfRelats {
            if relateKeys.count == 1 {
                self.objectsForSave[key]![field] = self.objectsForSave[relateKeys.first!]
            } else {
                self.objectsForSave[key]![field] = relateKeys.map { (let key) -> PFObject in
                    return self.objectsForSave[key]!
                }
            }
        }
        do {
            try self.objectsForSave[key]!.save()
        } catch {}
    }
    
    // TODO:
    func updateRecord(objectForUpdate: AnyObject, key: AnyObject, dictOfAttribs: [String : AnyObject], dictOfRelats: [String : [String]]) {
        print("updateRecord")
        return
    }

    // TODO:
    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) {
        return
    }
}






