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
        if let mappedID = self.idMapping[objectID],
            let values = self.personStorage.valuesAndVersion(mappedID) {
                return NSIncrementalStoreNode(objectID: objectID, withValues: values.values, version: values.version)
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
        
        return nil
    }
    
    func executeBatchUpdateRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        return nil
    }
    
    func executeFetchRequest(request: NSPersistentStoreRequest, withContext context: NSManagedObjectContext, error: NSErrorPointer) -> AnyObject? {
        let newEntityCreator: (String, StorageID) -> AnyObject = { (name, storageID) in
            let entityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
            let objectID = self.newObjectIDForEntity(entityDescription, referenceObject: storageID.id)
            self.idMapping[objectID] = storageID
            return context.objectWithID(objectID)
        }
        return self.personStorage.fetchRecords((request as! NSFetchRequest).entityName!, newEntityCreator: newEntityCreator)
    }
}
