//
//  PersistanceStore.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData

protocol IncrementalStorageProtocol {
    
    /**
        Returns objects from storage. [AnyObject]? is array of keys of objects in storage. Return persons getting from newEntityCreator
    
        :param: entityName the Name of entity to create
        :param: sortDescriptors how can we want to sort objects
        :param: newEntityCreator function, which get (entityName, local keys of objects) for create
        :returns: objects from storage (empty for a while)
    */
    func fetchRecords(entityName: String, sortDescriptors: [NSSortDescriptor]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject?
    
    /** 
        Get values and version of object in storage identified by key
    
        :param: key local identifier of object
        :returns: values and version of object
    */
    func valuesAndVersion(key: AnyObject) -> (values: [String : AnyObject], version: UInt64)?
    
    /** 
        Create new empty object in storage and return key of it
    
        :returns: key of new object
    */
    func getKeyOfNewObject() -> AnyObject
    
    /** 
        Save record in storage and return nil if can't
        
        :param: objectForSave representation of object in storage
        :param: key local identifier of object
        :returns: nil, if can't save
    */
    func saveRecord(objectForSave: AnyObject, key: AnyObject) -> AnyObject?
    
    /** 
        Update record in storage and return nil if can't
    
        :param: objectForUpdate representation of object in storage
        :param: key local identifier of object
        :returns: nil, if can't update
    */
    func updateRecord(objectForUpdate: AnyObject, key: AnyObject) -> AnyObject?
    
    /** 
        Delete record in storage and return nil if can't
    
        :param: objectForDelete representation of object in storage
        :param: key local identifier of object
        :returns: nil, if can't delete
    */
    func deleteRecord(objectForDelete: AnyObject, key: AnyObject) -> AnyObject?
}

class PersistanceStore: NSIncrementalStore {
    let personStorage = PersonStorage()
    var cache = [NSManagedObjectID: NSObject]()
    
    override class func initialize() {
        NSPersistentStoreCoordinator.registerStoreClass(self, forStoreType: self.type)
    }
    
    class var type: String {
        return NSStringFromClass(self)
    }
    
    override func loadMetadata() throws {
        self.metadata = [NSStoreUUIDKey : NSProcessInfo().globallyUniqueString,  NSStoreTypeKey : self.dynamicType.type]
    }
    
    override func newValuesForObjectWithID(objectID: NSManagedObjectID, withContext context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
        let identifier: AnyObject = self.referenceObjectForObjectID(objectID)
        let valuesAndVersion = self.personStorage.valuesAndVersion(identifier)
        return NSIncrementalStoreNode(objectID: objectID, withValues: valuesAndVersion!.values, version: valuesAndVersion!.version)
    }
    
    override func executeRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext?) throws -> AnyObject {
        let requestHandler = requestHandlerForType(request.requestType)
//        guard let requestHandler = requestHandlerForType(request.requestType) else {
//        }
        return requestHandler!(request, context!)!
    }
    
    func requestHandlerForType(requestType: NSPersistentStoreRequestType) -> ((NSPersistentStoreRequest, NSManagedObjectContext) -> AnyObject?)? {
        switch requestType {
        case .FetchRequestType: return self.executeFetchRequest
        case .SaveRequestType: return self.executeSaveRequest
        case .BatchUpdateRequestType: return self.executeBatchUpdateRequest
        default: return nil
        }
    }
    
    override func obtainPermanentIDsForObjects(array: [NSManagedObject]) throws -> [NSManagedObjectID] {
        var permanentIDs = [NSManagedObjectID]()
        for managedObject in array {
            let objectID = self.newObjectIDForEntity(managedObject.entity, referenceObject: self.personStorage.getKeyOfNewObject())
            permanentIDs.append(objectID)
        }
        return permanentIDs
    }
    
    func executeSaveRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) -> AnyObject? {
        if let personsForSave = (request as! NSSaveChangesRequest).insertedObjects {
            for newPerson in personsForSave {
                self.personStorage.saveRecord(newPerson as! Person, key: self.referenceObjectForObjectID(newPerson.objectID) as! String)
            }
        }
        if let personsForUpdate = (request as! NSSaveChangesRequest).updatedObjects {
            for updatedPerson in personsForUpdate {
                self.personStorage.updateRecord(updatedPerson as! Person, key: self.referenceObjectForObjectID(updatedPerson.objectID) as! String)
            }
        }
        if let personsForDelete = (request as! NSSaveChangesRequest).deletedObjects {
            for deletedPerson in personsForDelete {
                self.personStorage.deleteRecord(deletedPerson as! Person, key: self.referenceObjectForObjectID(deletedPerson.objectID) as! String)
            }
        }
        return []
    }
    
    func executeBatchUpdateRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) -> AnyObject? {
        return nil
    }
    
    func executeFetchRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) -> AnyObject? {
        let sD = (request as! NSFetchRequest).sortDescriptors
        let managedObjectsCreator: (String, [AnyObject]?) -> AnyObject = { (name, keys) in
            let entityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
            if let keys = keys {
                let returningObjects = keys.map {
                    (let key) -> NSManagedObject in
                    let objectID = self.newObjectIDForEntity(entityDescription, referenceObject: key)
                    return context.objectWithID(objectID)
                }
                return returningObjects
            }
            return []
        }
        return self.personStorage.fetchRecords((request as! NSFetchRequest).entityName!, sortDescriptors: sD, newEntityCreator: managedObjectsCreator)
    }
}
