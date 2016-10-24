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
    let databaseDirectory: NSURL = {
        #if os(tvOS)
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        #else
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        #endif
        return urls[urls.count - 1]
    }()

    /// Context
    let managedObjectContext: NSManagedObjectContext? = {
        return NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    }()
    
    /// Data model
    let managedObjectModel: NSManagedObjectModel = {
        let bundle = NSBundle(forClass: Tracker.self)
        let modelPath = bundle.pathForResource("Tracker", ofType: "momd")
        let modelURL = NSURL(fileURLWithPath: modelPath!)
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    let persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    // MARK: - Core Data Management
    
    /// Name of the entity
    let entityName = "StoredOfflineHit"


    /**
     Default initializer
     */
    private init() {
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        // URL of database
        let url = self.databaseDirectory
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("[warning] Error creating Document folder")
        }
        
        let dbURL = url.URLByAppendingPathComponent("Tracker.sqlite")

        do {
            try persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
            ])
        } catch _ as NSError {
            deleteOldDB()
            try! persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
                ])
        } catch {
            fatalError()
        }
        managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    func deleteOldDB() {
        let optUrl: NSURL? = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        guard let url = optUrl else {
            return
        }
        
        let db = url.URLByAppendingPathComponent("Tracker.sqlite")
        var err: NSError?
        let exists = db!.checkResourceIsReachableAndReturnError(&err)
        if exists {
            do{
                try NSFileManager.defaultManager().removeItemAtURL(db!)
            } catch _ {
                print("[warning] failure clean db")
            }
        } else {
            print("[warning] db does not exist bu produce an error")
        }
    }
    

    /**
     Save changes the data context

     - returns: true if the hit was saved successfully
     */
    func saveContext() -> Bool {
        var done = false
        if let moc = self.managedObjectContext {
            moc.performBlockAndWait({
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
            moc.performBlock({
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
        let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        privateContext.parentContext = self.managedObjectContext
        return privateContext
    }

    // MARK: - CRUD

    /**
     Insert hit in database

     :params: hit to be saved
     :params: fixed olt used in case of offline and multihits

     - returns: true if hit has been successfully saved
     */
    func insert( inout hit: String, mhOlt: String?) -> Bool {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let now = NSDate()
            var olt: String

            if let optMhOlt = mhOlt {
                olt = optMhOlt
            } else {
                olt = String(format: "%f", now.timeIntervalSince1970)
            }

            // Format hit before storage (olt, cn)
            hit = buildHitToStore(hit, olt: olt)
            var done = false
            if(exists(hit) == false) {
                privateContext.performBlockAndWait({
                    let managedHit = NSEntityDescription.insertNewObjectForEntityForName(self.entityName, inManagedObjectContext: privateContext) as! StoredOfflineHit
                    managedHit.hit = hit
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
    func setRetryCount(count: Int, offlineHit: NSManagedObjectID) {
        let privateContext = newPrivateContext()
        privateContext.performBlockAndWait {
            let hit = privateContext.objectWithID(offlineHit) as! StoredOfflineHit
            hit.retry = NSNumber(integer: count)
            try! privateContext.save()
            self.saveToPersistentStore()
        }
    }

    /**
     Get retry count of an OfflineHit
     
     - parameter hit: the query string of the hit
     
     - returns: the retryCount of the OfflineHit
     */
    func getRetryCountForHit(hit: String) -> Int {
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
    func setRetryCount(retryCount: Int, hit: String) {
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
    func getRetryCount(oid: NSManagedObjectID) -> Int {
        var retry = -1
        if let _ = self.managedObjectContext {
            let privateContext = newPrivateContext()
            privateContext.performBlockAndWait {
                let hit = privateContext.objectWithID(oid) as! StoredOfflineHit
                retry = hit.retry.integerValue
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
            let request = NSFetchRequest(entityName: entityName)
            var hits = [Hit]()

        let privateContext = newPrivateContext()
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as! [StoredOfflineHit] {
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
            let request = NSFetchRequest(entityName: entityName)
            var objects = [StoredOfflineHit]()
            moc.performBlockAndWait({
                if let o = try? moc.executeFetchRequest(request) as! [StoredOfflineHit] {
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
    func get(hit: String) -> Hit? {
        if let moc = self.managedObjectContext {
            let request = NSFetchRequest(entityName: entityName)

            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter

            var hit : Hit?
            moc.performBlockAndWait({
                if let objects = try? moc.executeFetchRequest(request) as! [StoredOfflineHit] {
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
    func getStoredHit(hit: String) -> NSManagedObjectID? {
        if let _ = self.managedObjectContext {
            let privateContext = newPrivateContext()
            let request = NSFetchRequest(entityName: entityName)
            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter
            var object : StoredOfflineHit?
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as! [StoredOfflineHit] {
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
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)
            request.includesSubentities = false
            request.includesPropertyValues = false

            var result = -1
            privateContext.performBlockAndWait({
                do {
                    let count = try privateContext.countForFetchRequest(request);
                    if(count == NSNotFound) {
                        result = 0
                    } else {
                        result = count
                    }

                } catch let error as NSError {
                    print(error.localizedDescription)
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
    func exists(hit: String) -> Bool {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: privateContext)
            request.includesSubentities = false
            request.includesPropertyValues = false

            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter

            var exists = false
            privateContext.performBlockAndWait({
                do {
                    let count = try privateContext.countForFetchRequest(request);
                     exists = (count > 0)
                } catch let error as NSError {
                    print(error.localizedDescription)
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
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)
            request.includesSubentities = false
            request.includesPropertyValues = false
            let privateContext = newPrivateContext()
            var count = -2
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as! [StoredOfflineHit] {
                    for object in objects {
                        privateContext.deleteObject(object)
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
    func delete(olderThan: NSDate) -> Int {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: privateContext)
            request.includesSubentities = false
            request.includesPropertyValues = false

            let filter = NSPredicate(format: "date < %@", olderThan)
            request.predicate = filter

            var count = -2
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as! [StoredOfflineHit] {
                    for object in objects {
                        privateContext.deleteObject(object)
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
    func delete(hit: String) -> Bool {
        let privateContext = newPrivateContext()
        if let _ = self.managedObjectContext {
            let request = NSFetchRequest()
            request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: privateContext)
            request.includesSubentities = false
            request.includesPropertyValues = false

            let filter = NSPredicate(format: "hit == %@", hit);
            request.predicate = filter

            var done = false
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as! [StoredOfflineHit] {
                    for object in objects {
                        privateContext.deleteObject(object)
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
            let request = NSFetchRequest(entityName: entityName)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)

            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1

            var hit : Hit?
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as![StoredOfflineHit] {
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
            let request = NSFetchRequest(entityName: entityName)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)

            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit = 1

            var hit : Hit?
            privateContext.performBlockAndWait({
                if let objects = try? privateContext.executeFetchRequest(request) as! [StoredOfflineHit] {
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
    func buildHitToStore(hit: String, olt: String) -> String {
        let url = NSURL(string: hit)

        if let optURL = url {
            let urlComponents = optURL.query!.componentsSeparatedByString("&")

            let components = NSURLComponents()
            components.scheme = optURL.scheme
            components.host = optURL.host
            components.path = optURL.path

            var query = ""

            var oltAdded = false

            for (index,component) in (urlComponents as [String]).enumerate() {
                let pairComponents = component.componentsSeparatedByString("=")

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

            if let optNewURL = components.URL {
                return optNewURL.absoluteString!
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
    @NSManaged var date: NSDate
    /// Number of retry that were made to send the hit
    @NSManaged var retry: NSNumber
}
