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
    func getKeyOfNewObjectWithEntityName(entityName: String) -> AnyObject
    
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
    
    func getKeyOfDestFrom(keyObject: String , to fieldName: String) -> AnyObject?
}

class PersistanceStore: NSIncrementalStore {
    var cache = [NSManagedObjectID: NSObject]()
    let storage : IncrementalStorageProtocol = PersonJobCityStorage()
    
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
        print("newValuesForObjectWithID, objectID = \(objectID.entity.name)")
        let key: AnyObject = self.referenceObjectForObjectID(objectID)
        let valuesAndVersion = self.storage.valuesAndVersion(key)
        return NSIncrementalStoreNode(objectID: objectID, withValues: valuesAndVersion!.values, version: valuesAndVersion!.version)
    }
    
    override func newValueForRelationship(relationship: NSRelationshipDescription, forObjectWithID objectID: NSManagedObjectID, withContext context: NSManagedObjectContext?) throws -> AnyObject {
        print("newValueForRelationship")
        print("objectID: \(objectID)")
        let key = self.storage.getKeyOfDestFrom(self.referenceObjectForObjectID(objectID) as! String, to: relationship.name)
        let retObjectID = self.newObjectIDForEntity(relationship.destinationEntity!, referenceObject: key!)
        return  retObjectID
    }
    
    override func executeRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext?) throws -> AnyObject {
        let requestHandler = requestHandlerForType(request.requestType)
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
        print("obtainPermanentIDsForObjects")
        var permanentIDs = [NSManagedObjectID]()
        for managedObject in array {
            let objectID = self.newObjectIDForEntity(managedObject.entity, referenceObject: self.storage.getKeyOfNewObjectWithEntityName(managedObject.entity.name!))
            permanentIDs.append(objectID)
        }
        return permanentIDs
    }
    
    func executeSaveRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) -> AnyObject? {
        print("executeSaveRequest")
        if let objectsForSave = (request as! NSSaveChangesRequest).insertedObjects {
            for newObject in objectsForSave {
                // I'm very confused about relationships, but I think the best way is to get their from newObject and pass
                // relationships in format [String: [ObjectID]] to saveRecord
                //
                self.storage.saveRecord(newObject, key: self.referenceObjectForObjectID(newObject.objectID) as! String)
            }
        }
        if let objectsForUpdate = (request as! NSSaveChangesRequest).updatedObjects {
            for updatedObject in objectsForUpdate {
                self.storage.updateRecord(updatedObject, key: self.referenceObjectForObjectID(updatedObject.objectID) as! String)
            }
        }
        if let objectsForDelete = (request as! NSSaveChangesRequest).deletedObjects {
            for deletedObject in objectsForDelete {
                self.storage.deleteRecord(deletedObject, key: self.referenceObjectForObjectID(deletedObject.objectID) as! String)
            }
        }
        return []
    }
    
    func executeBatchUpdateRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) -> AnyObject? {
        return nil
    }
    
    func executeFetchRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext) -> AnyObject? {
        print("executeFetchRequest")
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
        return self.storage.fetchRecords((request as! NSFetchRequest).entityName!, sortDescriptors: sD, newEntityCreator: managedObjectsCreator)
    }
}
