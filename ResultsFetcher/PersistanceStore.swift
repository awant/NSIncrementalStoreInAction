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
    func fetchRecords(entityName: String, sortDescriptors: [AnyObject]?, newEntityCreator: (String, [AnyObject]?) -> AnyObject) -> AnyObject?
    
    /** 
        Get values and version of object in storage identified by key
    
        :param: key local identifier of object
        :returns: values and version of object
    */
    func valuesAndVersion(key: AnyObject) -> (values: [NSObject : AnyObject], version: UInt64)?
    
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
    
    override func loadMetadata(error: NSErrorPointer) -> Bool {
        // metadata validation goes here - for example we want to check URL or path, check permissions
        self.metadata = [NSStoreUUIDKey : NSProcessInfo().globallyUniqueString,  NSStoreTypeKey : self.dynamicType.type]
        return true
    }
    
    override func newValuesForObjectWithID(objectID: NSManagedObjectID, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> NSIncrementalStoreNode? {
        let identifier: AnyObject = self.referenceObjectForObjectID(objectID)
        if let valuesAndVersion = self.personStorage.valuesAndVersion(identifier) {
            return NSIncrementalStoreNode(objectID: objectID, withValues: valuesAndVersion.values, version: valuesAndVersion.version)
        }
        return nil
    }
    
    override func executeRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        let requestHandler = requestHandlerForType(request.requestType)
        return requestHandler(request, context, error)
    }
    
    func requestHandlerForType(requestType: NSPersistentStoreRequestType) -> (NSPersistentStoreRequest, NSManagedObjectContext, NSErrorPointer) -> AnyObject? {
        switch requestType {
        case .FetchRequestType: return self.executeFetchRequest
        case .SaveRequestType: return self.executeSaveRequest
        case .BatchUpdateRequestType: return self.executeBatchUpdateRequest
        }
    }
    
    override func obtainPermanentIDsForObjects(array: [AnyObject], error: NSErrorPointer) -> [AnyObject]? {
        var permanentIDs = [NSManagedObjectID]()
        for managedObject in array {
            var managedObjectID = (managedObject as! NSManagedObject).objectID
            let objectID = self.newObjectIDForEntity(managedObject.entity, referenceObject: self.personStorage.getKeyOfNewObject())
            permanentIDs.append(objectID)
        }
        return permanentIDs
    }
    
    func executeSaveRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        if let personsForSave = (request as! NSSaveChangesRequest).insertedObjects {
            for newPerson in personsForSave {
                self.personStorage.saveRecord(newPerson as! Person, key: self.referenceObjectForObjectID((newPerson as! NSManagedObject).objectID) as! String)
            }
        }
        if let personsForUpdate = (request as! NSSaveChangesRequest).updatedObjects {
            for updatedPerson in personsForUpdate {
                self.personStorage.updateRecord(updatedPerson as! Person, key: self.referenceObjectForObjectID((updatedPerson as! NSManagedObject).objectID) as! String)
            }
        }
        if let personsForDelete = (request as! NSSaveChangesRequest).deletedObjects {
            for deletedPerson in personsForDelete {
                self.personStorage.deleteRecord(deletedPerson as! Person, key: self.referenceObjectForObjectID((deletedPerson as! NSManagedObject).objectID) as! String)
            }
        }
        return []
    }
    
    func executeBatchUpdateRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        return nil
    }
    
    func executeFetchRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        let sD = (request as! NSFetchRequest).sortDescriptors
        let managedObjectsCreator: (String, [AnyObject]?) -> AnyObject = { (name, keys) in
            let entityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
            if let keys = keys {
                let returningObjects = keys.map {
                    (var key) -> NSManagedObject in
                    var objectID = self.newObjectIDForEntity(entityDescription, referenceObject: key)
                    return context.objectWithID(objectID)
                }
                return returningObjects
            }
            return []
        }
        return self.personStorage.fetchRecords((request as! NSFetchRequest).entityName!, sortDescriptors: sD, newEntityCreator: managedObjectsCreator)
    }
}
