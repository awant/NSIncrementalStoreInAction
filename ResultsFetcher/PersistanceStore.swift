//
//  PersistanceStore.swift
//  ResultsFetcher
//
//  Created by Artemiy Sobolev on 11.08.15.
//  Copyright (c) 2015 Artemiy Sobolev. All rights reserved.
//

import Foundation
import CoreData



class PersistanceStore: NSIncrementalStore {
    let personStorage = PersonStorage()
    var idMapping = [NSManagedObjectID: StorageID]()
    var cache = [NSManagedObjectID: NSObject]()
    
    override class func initialize() {
        NSPersistentStoreCoordinator.registerStoreClass(self, forStoreType: self.type)
    }
    
    class var type: String {
        return NSStringFromClass(self)
    }
    
    override func loadMetadata(error: NSErrorPointer) -> Bool {
        self.metadata = [NSStoreUUIDKey : NSProcessInfo().globallyUniqueString,  NSStoreTypeKey : self.dynamicType.type]
        return true
    }
    
    override func newValuesForObjectWithID(objectID: NSManagedObjectID, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> NSIncrementalStoreNode? {
        // TODO: We can change it with protocols - (cache[objectID] as! _Person)
        if let valuesAndVersion = (cache[objectID] as! _Person).valuesAndVersion() {
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
    
    func executeSaveRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        // TODO: we can add several objects at the same time
        if let personForSave = (request as! NSSaveChangesRequest).insertedObjects?.first {
            self.personStorage.saveRecord(personForSave as! Person)
        }
        if let personForUpdate = (request as! NSSaveChangesRequest).updatedObjects?.first {
            println("update Records")
        }
        if let personForDelete = (request as! NSSaveChangesRequest).deletedObjects?.first {
            println("delete Records")
            //self.personStorage.deleteRecord(personForDelete as! Person)
        }
        //        let saver: (String) -> AnyObject = { (String) in
        //        }
        return [NSObject]()
    }
    
    func executeBatchUpdateRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        return nil
    }
    
    func executeFetchRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        let newEntityCreator: (String, StorageID, [NSObject]?) -> AnyObject = { (name, storageID, objects) in
            let entityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
            var returningObjects = [AnyObject]()
            if let objects = objects {
                for object in objects {
                    let objectID = self.newObjectIDForEntity(entityDescription, referenceObject: object)
                    returningObjects.append(context.objectWithID(objectID))
                    self.cache[objectID] = object
                    // self.idMapping[objectID] = storageID
                }
            }
            return returningObjects
        }
        return self.personStorage.fetchRecords((request as! NSFetchRequest).entityName!, newEntityCreator: newEntityCreator)
    }
}
