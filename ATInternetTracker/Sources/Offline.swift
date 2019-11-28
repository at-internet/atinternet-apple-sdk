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
//  Offline.swift
//  Tracker
//

import Foundation

/// Class to manage offline hits stored
public class Offline: NSObject {
    /// Tracker instance
    var tracker: Tracker
    var offlineMode: String
    
    /**
    Offline initializer
    - parameter tracker: the tracker instance
    - returns: Offline instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
        self.offlineMode = tracker.configuration.parameters["storage"] ?? "never"
    }
    
    /// Send all hits stored
    @objc public func dispatch() {
        Sender.sendOfflineHits(self.tracker, forceSendOfflineHits: true, async: true)
    }
    
    /// Get all offline hits stored in database
    ///
    /// - Returns: collection of offline hits
    @objc public func get() -> [Hit] {
        return Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true).get()
    }
    
    /// Get the number of offline hits stored in database
    ///
    /// - Returns: number of offline hits
    @objc public func count() -> Int {
        return Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true).count()
    }

    /// Delete all offline hits stored in database
    ///
    /// - Returns: number of deleted hits (-1 if an error occured)
    @objc public func delete() -> Int {
        return Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true).delete()
    }

    /// Delete offline hits older than the number of days passed in parameter
    ///
    /// - Parameter olderThan: Number of days of offline hits to keep in database
    /// - Returns: number of deleted hits (-1 if an error occured)
    @objc(deleteOlderThanInt:)
    public func delete(_ olderThan: Int) -> Int {
        let storage = Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true)
        
        let now = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -olderThan
        
        let past = Calendar.current.date(byAdding: dateComponent, to: now)
        
        return storage.delete(past!)
    }
    
    /// Delete offline hits older than the date passed in parameter
    ///
    /// - Parameter olderThan: Date from which the hits will be deleted
    /// - Returns: number of deleted hits (-1 if an error occured)
    @objc(deleteOlderThanDate:)
    public func delete(_ olderThan: Date) -> Int {
        return Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true).delete(olderThan)
    }
    
    /// Get the first hit stored in database
    ///
    /// - Returns: the oldest hit
    @objc public func oldest() -> Hit? {
        return Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true).first()
    }
    
    /// Get the latest hit stored in database
    ///
    /// - Returns: the latest hit
    @objc public func latest() -> Hit? {
        return Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true).last()
    }
}
