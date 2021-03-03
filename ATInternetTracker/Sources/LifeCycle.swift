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
//  LifeCycle.swift
//  Tracker
//

import Foundation

/// Life cycle metrics
class LifeCycle: NSObject {
    /// List of lifecycle metrics
    static var parameters = [String: Any]()
    /// App was launched for the first time
    static var firstSession: Bool = false
    /// Indicates whether the app version has changed
    static var appVersionChanged: Bool = false
    // Number of days since last app use
    static var daysSinceLastSession: Int = 0
    /// Check whether lifecycle has already been initialized
    static var isInitialized: Bool = false
    /// Calendar type
    //static var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    static let locale = Locale(identifier: "en_US_POSIX")
    /// SessionId
    static var sessionId: String? = nil
    /// Time during the app is in background
    static var timeInBackground: Date? = nil
    
    /// Lifecycle keys
    enum LifeCycleKey: String, EnumCollection {
        case FirstSession = "ATFirstLaunch"
        case LastSession = "ATLastUse"
        case FirstSessionDate = "ATFirstLaunchDate"
        case SessionCount = "ATLaunchCount"
        case LastApplicationVersion = "ATLastApplicationVersion"
        case ApplicationUpdate = "ATApplicationUpdate"
        case SessionCountSinceUpdate = "ATLaunchCountSinceUpdate"
        case FirstSessionDateV1 = "firstLaunchDate"
        case LastSessionV1 = "lastUseDate"
    }
    
    /**
    Check whether the app has finished launching
    
    :params: a notification
    */
    class func initLifeCycle() {
        let userDefaults = UserDefaults.standard
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyyMMdd"
        let monthFormatter = DateFormatter()
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "yyyyMM"
        let weekFormatter = DateFormatter()
        weekFormatter.locale = locale
        weekFormatter.dateFormat = "yyyyww"
        
        let now = Date()
        var initialized = false
        
        // Not first launch
        if let _ = userDefaults.object(forKey: LifeCycleKey.FirstSession.rawValue) as? Int {
            if ATInternet.optOut {
                return
            }
            LifeCycle.firstSession = false
            
            // Last session
            if let optLastSession = userDefaults.object(forKey: LifeCycleKey.LastSession.rawValue) as? Date {
                LifeCycle.daysSinceLastSession = Tool.daysBetweenDates(optLastSession, toDate: now)
            }
            
            // session count
            if let sessionCount = userDefaults.object(forKey: LifeCycleKey.SessionCount.rawValue) as? Int {
                _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.SessionCount.rawValue, sessionCount + 1))
            }
            
            // Application version changed
            if let appVersion = userDefaults.object(forKey: LifeCycleKey.LastApplicationVersion.rawValue) as? String {
                if(appVersion != TechnicalContext.applicationVersion) {
                    LifeCycle.appVersionChanged = true
                    _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.ApplicationUpdate.rawValue, now), (LifeCycleKey.SessionCountSinceUpdate.rawValue, 1), (LifeCycleKey.LastApplicationVersion.rawValue, TechnicalContext.applicationVersion))
                } else {
                    LifeCycle.appVersionChanged = false
                    if let sessionCountSinceUpdate = userDefaults.object(forKey: LifeCycleKey.SessionCountSinceUpdate.rawValue) as? Int {
                        _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.SessionCountSinceUpdate.rawValue, sessionCountSinceUpdate + 1))
                    }
                }
            }
            
            initialized = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.LastSession.rawValue, now))
        } else {
            initialized = LifeCycle.firstLaunchInit()
        }
        
        LifeCycle.sessionId = UUID().uuidString
        LifeCycle.isInitialized = initialized
    }
    
    /**
    Init user defaults on first launch
    */
    class func firstLaunchInit() -> Bool {
        let userDefaults = UserDefaults.standard
        let now = Date()
        self.firstSession = true
        
        // If SDK V1 first launch exists
        if let optFirstLaunchDate = userDefaults.object(forKey: LifeCycleKey.FirstSessionDateV1.rawValue) as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "YYYYMMdd"
            let fld = dateFormatter.date(from: optFirstLaunchDate)
            
            _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.FirstSessionDate.rawValue, fld ?? now), (LifeCycleKey.FirstSession.rawValue, 0))
            userDefaults.removeObject(forKey: LifeCycleKey.FirstSessionDateV1.rawValue)
            
            self.firstSession = false
            
        } else {
            _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.FirstSessionDate.rawValue, now), (LifeCycleKey.FirstSession.rawValue, 1))
        }
        
        // Launch Count update from SDK V1
        if let optSessionCount = userDefaults.object(forKey: LifeCycleKey.SessionCount.rawValue) as? Int {
            _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.SessionCount.rawValue, optSessionCount + 1))
        } else {
            _ = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.SessionCount.rawValue, 1))
        }
        
        // Last use update from SDK V1
        if let optLastSessionDate = userDefaults.object(forKey: LifeCycleKey.LastSessionV1.rawValue) as? Date  {
            userDefaults.removeObject(forKey: LifeCycleKey.LastSessionV1.rawValue)
            LifeCycle.daysSinceLastSession = Tool.daysBetweenDates(optLastSessionDate, toDate: now)
        }
        let initialized = Privacy.storeData(Privacy.StorageFeature.lifecycle, pairs: (LifeCycleKey.LastApplicationVersion.rawValue, TechnicalContext.applicationVersion), (LifeCycleKey.LastSession.rawValue, now))
        userDefaults.synchronize()
        return initialized
    }
    
    //MARK: - Session
    
    /**
    Called when application goes to background
    should save the timestamp to know if we have to start a new session on the next launch
    
    - parameter notification: notif
    */
    class func applicationDidEnterBackground() {
        LifeCycle.timeInBackground = Date()
    }
    
    /**
     Get the default sessionBackground duration
     
     - parameter parameters: the default parameters
     
     - returns: the background session duration (default: 60)
     */
    class func sessionBackgroundDuration(_ parameters: Dictionary<String, String>) -> Int {
        guard let sessionBackgroundDuration = parameters["sessionBackgroundDuration"] else {
            return 60
        }
        
        guard let sessionConfig = Int(sessionBackgroundDuration) else {
            return 60
        }
        
        if sessionConfig < 0 {
            return 60
        }
        
        return sessionConfig
    }
    
    /**
     Called when app is active
     Should create a new SessionId if necessary and update lifecycles data
     */
    class func applicationActive(_ parameters: Dictionary<String, String>) {
        let sessionConfig: Int = sessionBackgroundDuration(parameters)
        
        if !hasAssignedNewSession() {
            if let ts = LifeCycle.timeInBackground {
                let now = Date()
                // do we need a new session after background ?
                if Tool.secondsBetweenDates(ts, toDate: now) > sessionConfig {
                    LifeCycle.initLifeCycle()
                }
                LifeCycle.timeInBackground = nil
            }
        }
    }
    
    /**
     Create a new session if current SessionId is nil
     
     - returns: True if a new session has been created false otherwise
     */
    class func hasAssignedNewSession() -> Bool {
        if let _ = LifeCycle.sessionId {
            return false
        } else {
            LifeCycle.initLifeCycle()
            return true
        }
    }
    
    /**
    Get all lifecycle metrics in a JSON format
    
    - returns: a closure that will return a JSON
    */
    static func getMetrics() -> (() -> String) {
        return {
            let userDefaults = UserDefaults.standard
            
            if userDefaults.object(forKey: LifeCycleKey.FirstSession.rawValue) == nil {
                _ = LifeCycle.firstLaunchInit()
            }
            
            var fsd = userDefaults.object(forKey: LifeCycleKey.FirstSessionDate.rawValue) as? Date
            if fsd == nil {
                fsd = Date()
            }
            
            let firstSessionDate = fsd!
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "yyyyMMdd"

            // First session: fs
            LifeCycle.parameters["fs"] = (self.firstSession ? 1 : 0)
            
            // First session after update: fsau
            LifeCycle.parameters["fsau"] = (self.appVersionChanged ? 1 : 0)
            
            // session count since update: scsu
            if let sessionCountSinceUpdate = userDefaults.object(forKey: LifeCycleKey.SessionCountSinceUpdate.rawValue) as? Int {
                LifeCycle.parameters["scsu"] = sessionCountSinceUpdate
            }
            
            // session count: sc
            LifeCycle.parameters["sc"] = userDefaults.integer(forKey: LifeCycleKey.SessionCount.rawValue)
            
            // First session date: fsd
            LifeCycle.parameters["fsd"] = Int(dateFormatter.string(from: firstSessionDate))
            
            // Days since first session: dsfs
            LifeCycle.parameters["dsfs"] = Tool.daysBetweenDates(firstSessionDate, toDate: now)
            
            // first session date after update & days since update: usd / dsu
            if let applicationUpdate = userDefaults.object(forKey: LifeCycleKey.ApplicationUpdate.rawValue) as? Date {
                LifeCycle.parameters["fsdau"] = Int(dateFormatter.string(from: applicationUpdate))
                LifeCycle.parameters["dsu"] = Tool.daysBetweenDates(applicationUpdate, toDate: now)
            }
            
            // Days sinces last session: dsls
            LifeCycle.parameters["dsls"] = self.daysSinceLastSession
            
            // SessionId
            LifeCycle.parameters["sessionId"] = LifeCycle.sessionId
            
            let json = Tool.JSONStringify(["lifecycle": LifeCycle.parameters], prettyPrinted: false)
            
            LifeCycle.parameters.removeAll(keepingCapacity: false)
            
            return json
        }
    }
    
    static func getMetricsMap() -> [String : Any] {
        var map = [String : Any]()
        let userDefaults = UserDefaults.standard
        
        let firstSessionDate = userDefaults.object(forKey: LifeCycleKey.FirstSessionDate.rawValue) as? Date ?? Date()
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyyMMdd"
        
        // First session: fs
        map["fs"] = (self.firstSession ? 1 : 0)
        
        // First session after update: fsau
        map["fsau"] = (self.appVersionChanged ? 1 : 0)
        
        // session count since update: scsu
        if let sessionCountSinceUpdate = userDefaults.object(forKey: LifeCycleKey.SessionCountSinceUpdate.rawValue) as? Int {
            map["scsu"] = sessionCountSinceUpdate
        }
        
        // session count: sc
        map["sc"] = userDefaults.integer(forKey: LifeCycleKey.SessionCount.rawValue)
        
        // First session date: fsd
        map["fsd"] = Int(dateFormatter.string(from: firstSessionDate))
        
        // Days since first session: dsfs
        map["dsfs"] = Tool.daysBetweenDates(firstSessionDate, toDate: now)
        
        // first session date after update & days since update: usd / dsu
        if let applicationUpdate = userDefaults.object(forKey: LifeCycleKey.ApplicationUpdate.rawValue) as? Date {
            map["fsdau"] = Int(dateFormatter.string(from: applicationUpdate))
            map["dsu"] = Tool.daysBetweenDates(applicationUpdate, toDate: now)
        }
        
        // Days sinces last session: dsls
        map["dsls"] = self.daysSinceLastSession
        
        // SessionId
        map["sessionId"] = LifeCycle.sessionId
        
        return map
    }
}
