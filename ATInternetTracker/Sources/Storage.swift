/*
 This SDK is licensed under the MIT license (MIT)
 Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */





//
//  CoreData.swift
//  Tracker
//

import Foundation
import CoreData

/// Offline hit storage
class Storage {

    static let sharedInstance = Storage()
    
    /// Directory where the database is saved
    let databaseDirectory: URL = {
        #if os(tvOS)
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        #else
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        #endif
        return urls[urls.count - 1]
    }()

    /// Context
    let managedObjectContext: NSManagedObjectContext? = {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }()
    
    /// Data model
    let managedObjectModel: NSManagedObjectModel? = {
        let bundle = Bundle(for: Tracker.self)
        let modelPath = bundle.path(forResource: "Tracker", ofType: "momd")
        let modelURL = URL(fileURLWithPath: modelPath!)
        
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    let persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    // MARK: - Core Data Management
    
    /// Name of the entity
    let entityName = "StoredOfflineHit"
    
    
    /**
     Default initializer
     */
    private init() {
        guard let managedObjectModel = self.managedObjectModel else {
            fatalError()
        }
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        // URL of database
        let url = self.databaseDirectory
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("[warning] Error creating Document folder")
        }
        
        let dbURL = url.appendingPathComponent("Tracker.sqlite")
        
        do {
            try persistentStoreCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
                ])
        } catch _ as NSError {
            deleteOldDB()
            try! persistentStoreCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
                ])
        } catch {
            fatalError()
        }
        managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    func deleteOldDB() {
        let optUrl: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        guard let url = optUrl else {
            return
        }
        
        let db = url.appendingPathComponent("Tracker.sqlite")
        var err: NSError?
        let exists = (db as NSURL).checkResourceIsReachableAndReturnError(&err)
        if exists {
            do{
                try FileManager.default.removeItem(at: db)
            } catch _ {
                print("[warning] failure clean db")
            }
        } else {
            print("[warning] db does not exist but produced an error")
        }
    }
    
    
    /**
     Save changes the data context
     
     - returns: true if the hit was saved successfully
     */
    func saveContext() -> Bool {
        var done = false
        if let moc = self.managedObjectContext {
            moc.performAndWait({
                if(moc.hasChanges) {
                    done = false
                    do {
                        try moc.save()
                        done = true
                    }
                    catch {
                        done = false
                    }
                } else {
                    done = true
                }
            })
            return done
        }
        return false
    }
    
    /**
     Save the main managedObjectContext into the persistent store
     */
    func saveToPersistentStore() {
        if let moc = self.managedObjectContext {
            moc.perform({
                try! moc.save()
            })
        }
    }
    
    /**
     Get a new child context from the singleton context. The parent (main) will be updated automatically not doesn't store it
     into the persistent storage
     
     - returns: a new private context
     */
    func newPrivateContext() -> NSManagedObjectContext {
        let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        privateContext.parent = self.managedObjectContext
        return privateContext
    }
    
    // MARK: - CRUD
    
    /**
     Insert hit in database
     
     :params: hit to be saved
     :params: fixed olt used in case of offline and multihits
     
     - returns: true if hit has been successfully saved
     */
    func insert(_ hit: inout String, mhOlt: String?) -> Bool {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let now = Date()
            var olt: String
            
            if let optMhOlt = mhOlt {
                olt = optMhOlt
            } else {
                olt = String(format: "%f", now.timeIntervalSince1970)
            }
            
            // Format hit before storage (olt, cn)
            hit = buildHitToStore(hit, olt: olt)
            var done = false
            let copyHit = hit
            if(exists(hit) == false) {
                privateContext.performAndWait({
                    let managedHit = NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: privateContext) as! StoredOfflineHit
                    managedHit.hit = copyHit
                    managedHit.date = now
                    managedHit.retry = 0
                    do {
                        try privateContext.save()
                        self.saveToPersistentStore()
                        done = true
                    }
                    catch {
                        done = false
                    }
                })
                return done
            } else {
                return true
            }
        }
        return false
    }
    
    /**
     Set a retry count to an OfflineHit from its NSManagedObjectID
     
     - parameter count:      new retryCount
     - parameter offlineHit: OfflineHit's objectID
     */
    func setRetryCount(_ count: Int, offlineHit: NSManagedObjectID) {
        let privateContext = newPrivateContext()
        privateContext.performAndWait {
            let hit = privateContext.object(with: offlineHit) as! StoredOfflineHit
            hit.retry = NSNumber(value: count)
            try! privateContext.save()
            self.saveToPersistentStore()
        }
    }
    
    /**
     Get retry count of an OfflineHit
     
     - parameter hit: the query string of the hit
     
     - returns: the retryCount of the OfflineHit
     */
    func getRetryCountForHit(_ hit: String) -> Int {
        let offlineHitID = self.getStoredHit(hit)
        guard let hitID = offlineHitID else {
            return -1
        }
        return self.getRetryCount(hitID)
    }
    
    /**
     set a retry count of an OfflineHit
     
     - parameter retryCount: the new retryCount
     - parameter hit:        the query string of the hit
     */
    func setRetryCount(_ retryCount: Int, hit: String) {
        let offlineHitID = self.getStoredHit(hit)
        guard let hitID = offlineHitID else {
            return
        }
        setRetryCount(retryCount, offlineHit: hitID)
    }
    
    /**
     return the retryCount of an OfflineHit
     
     - parameter oid: OfflineHit's objectID
     
     - returns: the retryCount
     */
    func getRetryCount(_ oid: NSManagedObjectID) -> Int {
        var retry = -1
        if let _ = self.managedObjectContext {
            let privateContext = newPrivateContext()
            privateContext.performAndWait {
                let hit = privateContext.object(with: oid) as! StoredOfflineHit
                retry = hit.retry.intValue
            }
        }
        return retry
    }
    
    /**
     Get all hits stored in database
     
     - returns: hits
     */
    func get() -> [Hit] {
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>(entityName: entityName)
            var hits = [Hit]()
            
            let privateContext = newPrivateContext()
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    for object in objects {
                        let hit = Hit()
                        hit.url = object.hit
                        hit.creationDate = object.date
                        hit.retryCount = object.retry
                        hit.isOffline = true
                        
                        hits.append(hit)
                    }
                }
            })
            return hits
        }
        return [Hit]()
    }
    
    /**
     Get all hits stored in database - not used
     
     - returns: hits
     */
    func getStoredHits() -> [StoredOfflineHit] {
        if let moc = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>(entityName: entityName)
            var objects = [StoredOfflineHit]()
            moc.performAndWait({
                if let o = try? moc.fetch(request) {
                    objects = o
                }
            })
            return objects
        }
        return [StoredOfflineHit]()
    }
    
    /**
     Get one hit stored in database - not used
     
     :params: hit to select
     
     - returns: an offline hit
     */
    func get(_ hit: String) -> Hit? {
        if let moc = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>(entityName: entityName)
            
            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter
            
            var hit : Hit?
            moc.performAndWait({
                if let objects = try? moc.fetch(request) {
                    if(objects.count > 0) {
                        hit = Hit()
                        hit!.url = objects.first!.hit
                        hit!.creationDate = objects.first!.date
                        hit!.retryCount = objects.first!.retry
                        hit!.isOffline = true
                    }
                }
            })
            return hit
        }
        
        return nil
    }
    
    /**
     Get one hit stored in database
     
     :params: hit to select
     
     - returns: an offline hit
     */
    func getStoredHit(_ hit: String) -> NSManagedObjectID? {
        if let _ = self.managedObjectContext {
            let privateContext = newPrivateContext()
            let request = NSFetchRequest<StoredOfflineHit>(entityName: entityName)
            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter
            var object : StoredOfflineHit?
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    if(objects.count > 0) {
                        object = objects.first!
                    }
                }
            })
            return object?.objectID
        }
        
        return nil
    }
    
    
    
    /**
     Count number of stored hits
     
     - returns: number of hits stored in database
     */
    func count() -> Int {
        let privateContext = newPrivateContext()
        if let moc = self.managedObjectContext {
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: moc)
            request.includesSubentities = false
            request.includesPropertyValues = false
            
            
            var result = -1
            privateContext.performAndWait({
                do {
                    let count = try privateContext.count(for: request);
                    if(count == NSNotFound) {
                        result = 0
                    } else {
                        result = count
                    }
                } catch {
                    result = -1
                }
            })
            return result
        }
        
        return 0
    }
    
    /**
     Check whether hit already exists in database
     
     - returns: true or false if hit exists
     */
    func exists(_ hit: String) -> Bool {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: privateContext)
            request.includesSubentities = false
            request.includesPropertyValues = false
            
            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter
            
            var exists = false
            privateContext.performAndWait({
                do {
                    let count = try privateContext.count(for: request);
                    exists = (count > 0)
                } catch {
                    exists = false
                }
            })
            
            return exists
        }
        
        return false
    }
    
    /**
     Delete all hits stored in database
     
     - returns: number of deleted hits (-1 if error occured)
     */
    func delete() -> Int {
        if let moc = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: moc)
            request.includesSubentities = false
            request.includesPropertyValues = false
            let privateContext = newPrivateContext()
            var count = -2
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    for object in objects {
                        privateContext.delete(object)
                    }
                    
                    do {
                        try privateContext.save()
                        count = objects.count
                        self.saveToPersistentStore()
                    } catch {
                        count = -1
                    }
                } else {
                    count = 0
                }
            })
            return count
        }
        return -1
    }
    
    /**
     Delete hits stored in database older than number of days passed in parameter
     
     - returns: number of deleted hits (-1 if error occured)
     */
    func delete(_ olderThan: Date) -> Int {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: privateContext)
            request.includesSubentities = false
            request.includesPropertyValues = false
            
            let filter = NSPredicate(format: "date < %@", olderThan as NSDate)
            request.predicate = filter
            
            var count = -2
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    for object in objects {
                        privateContext.delete(object)
                    }
                    do {
                        try privateContext.save()
                        self.saveToPersistentStore()
                        count = objects.count
                    } catch {
                        count = -1
                    }
                    
                } else {
                    count = 0
                }
            })
            return count
        }
        return -1
    }
    
    /**
     Delete one hit from database
     
     - returns: true if deletion was successful
     */
    func delete(_ hit: String) -> Bool {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>()
            request.entity = NSEntityDescription.entity(forEntityName: entityName, in: privateContext)
            request.includesSubentities = false
            request.includesPropertyValues = false
            
            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter
            
            var done = false
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    for object in objects {
                        privateContext.delete(object)
                    }
                    do {
                        try privateContext.save()
                        self.saveToPersistentStore()
                        done = true
                    } catch {
                        done = false
                    }
                } else {
                    done = false
                }
            })
            return done
        }
        return false
    }
    
    /**
     Get the first offline hit
     
     - returns: the first offline hit stored in database (nil if not found)
     */
    func first() -> Hit? {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>(entityName: entityName)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            
            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1
            
            var hit : Hit?
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    if(objects.count > 0) {
                        hit = Hit()
                        hit!.url = objects.first!.hit
                        hit!.creationDate = objects.first!.date
                        hit!.retryCount = objects.first!.retry
                        hit!.isOffline = true
                    }
                }
            })
            return hit
        }
        
        return nil
    }
    
    /**
     Get the last offline hit
     
     - returns: the last offline hit stored in database (nil if not found)
     */
    func last() -> Hit? {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest<StoredOfflineHit>(entityName: entityName)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            
            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1
            
            var hit : Hit?
            privateContext.performAndWait({
                if let objects = try? privateContext.fetch(request) {
                    if(objects.count > 0) {
                        hit = Hit()
                        hit!.url = objects.first!.hit
                        hit!.creationDate = objects.first!.date
                        hit!.retryCount = objects.first!.retry
                        hit!.isOffline = true
                    }
                }
            })
            return hit
        }
        
        return nil
    }
    
    // MARK: - Hit building
    
    /**
     Add the olt parameter to the hit querystring
     
     :params: hit to store
     :params: olt value to add to querystring
     */
    func buildHitToStore(_ hit: String, olt: String) -> String {
        let url = URL(string: hit)
        
        if let optURL = url {
            let urlComponents = optURL.query!.components(separatedBy: "&")
            
            var components = URLComponents()
            components.scheme = optURL.scheme
            components.host = optURL.host
            components.path = optURL.path
            
            var query = ""
            
            var oltAdded = false
            
            for (index,component) in (urlComponents as [String]).enumerated() {
                let pairComponents = component.components(separatedBy: "=")
                
                // Set cn to offline
                if(pairComponents[0] == "cn") {
                    query += "&cn=offline"
                } else {
                    (index > 0) ? (query += "&" + component) : (query += component)
                }
                
                // Add olt variable after na or mh if multihits
                if (!oltAdded) {
                    if(pairComponents[0] == "ts" || pairComponents[0] == "mh") {
                        query += "&olt=" + olt
                        oltAdded = true
                    }
                }
                
            }
            
            components.percentEncodedQuery = query
            
            if let optNewURL = components.url {
                return optNewURL.absoluteString
            } else {
                return hit
            }
        }
        
        return hit
    }
}

/// Stored Offline hit
class StoredOfflineHit: NSManagedObject {
    /// Hit
    @NSManaged var hit: String
    /// Date of creation
    @NSManaged var date: Date
    /// Number of retry that were made to send the hit
    @NSManaged var retry: NSNumber
}
