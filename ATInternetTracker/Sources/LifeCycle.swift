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
    static var parameters = [String: AnyObject]()
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
    static let locale = NSLocale(localeIdentifier: "en_US_POSIX")
    /// SessionId
    static var sessionId: String? = nil
    /// Time during the app is in background
    static var timeInBackground: NSDate? = nil
    
    /// Lifecycle keys
    enum LifeCycleKey: String {
        case FirstSession = "ATFirstLaunch"
        case LastSession = "ATLastUse"
        case FirstSessionDate = "ATFirstLaunchDate"
        case SessionCount = "ATLaunchCount"
        case LastApplicationVersion = "ATLastApplicationVersion"
        case ApplicationUpdate = "ATApplicationUpdate"
        case SessionCountSinceUpdate = "ATLaunchCountSinceUpdate"
    }
    
    /**
    Check whether the app has finished launching
    
    :params: a notification
    */
    class func initLifeCycle() {
        let userDefaults = NSUserDefaults.standardUserDefaults
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyyMMdd"
        let monthFormatter = NSDateFormatter()
        monthFormatter.locale = locale
        monthFormatter.dateFormat = "yyyyMM"
        let weekFormatter = NSDateFormatter()
        weekFormatter.locale = locale
        weekFormatter.dateFormat = "yyyyww"
        
        let now = NSDate()
        
        // Not first launch
        if let _ = userDefaults().objectForKey(LifeCycleKey.FirstSession.rawValue) as? Int {
            LifeCycle.firstSession = false
            
            // Last session
            if let optLastSession = userDefaults().objectForKey(LifeCycleKey.LastSession.rawValue) as? NSDate {
                LifeCycle.daysSinceLastSession = Tool.daysBetweenDates(optLastSession, toDate: now)
            }
            
            // session count
            if let sessionCount = userDefaults().objectForKey(LifeCycleKey.SessionCount.rawValue) as? Int {
                userDefaults().setInteger(sessionCount + 1, forKey: LifeCycleKey.SessionCount.rawValue)
            }
            
            // Application version changed
            if let appVersion = userDefaults().objectForKey(LifeCycleKey.LastApplicationVersion.rawValue) as? String {
                if(appVersion != TechnicalContext.applicationVersion) {
                    LifeCycle.appVersionChanged = true
                    userDefaults().setObject(now, forKey: LifeCycleKey.ApplicationUpdate.rawValue)
                    userDefaults().setInteger(1, forKey: LifeCycleKey.SessionCountSinceUpdate.rawValue)
                    userDefaults().setObject(TechnicalContext.applicationVersion, forKey: LifeCycleKey.LastApplicationVersion.rawValue)
                } else {
                    LifeCycle.appVersionChanged = false
                    if let sessionCountSinceUpdate = userDefaults().objectForKey(LifeCycleKey.SessionCountSinceUpdate.rawValue) as? Int {
                        userDefaults().setInteger(sessionCountSinceUpdate + 1, forKey: LifeCycleKey.SessionCountSinceUpdate.rawValue)
                    }
                }
            }
            
            userDefaults().setObject(now, forKey: LifeCycleKey.LastSession.rawValue)
            // Save user defaults
            userDefaults().synchronize()
        } else {
            LifeCycle.firstLaunchInit()
        }
        
        LifeCycle.sessionId = NSUUID().UUIDString
        LifeCycle.isInitialized = true
    }
    
    /**
    Init user defaults on first launch
    */
    class func firstLaunchInit() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let now = NSDate()
        self.firstSession = true
        
        // If SDK V1 first launch exists
        if let optFirstLaunchDate = userDefaults.objectForKey("firstLaunchDate") as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "YYYYMMdd"
            let fld = dateFormatter.dateFromString(optFirstLaunchDate)
            
            userDefaults.setObject(fld ?? now, forKey: LifeCycleKey.FirstSessionDate.rawValue)
            userDefaults.setInteger(0, forKey: LifeCycleKey.FirstSession.rawValue)
            
            userDefaults.setObject(nil, forKey: "firstLaunchDate")
            self.firstSession = false
            
        } else {
            userDefaults.setInteger(1, forKey: LifeCycleKey.FirstSession.rawValue)
            
            // First session date
            userDefaults.setObject(now, forKey: LifeCycleKey.FirstSessionDate.rawValue)
        }
        
        // Launch Count update from SDK V1
        if let optSessionCount = userDefaults.objectForKey("ATLaunchCount") as? Int {
            userDefaults.setInteger(optSessionCount + 1, forKey: LifeCycleKey.SessionCount.rawValue)
        } else {
            userDefaults.setInteger(1, forKey: LifeCycleKey.SessionCount.rawValue)
        }
        
        
        // Application version changed
        userDefaults.setObject(TechnicalContext.applicationVersion, forKey: LifeCycleKey.LastApplicationVersion.rawValue)
        
        // Last use update from SDK V1
        if let optLastSessionDate = userDefaults.objectForKey("lastUseDate") as? NSDate  {
            userDefaults.setObject(nil, forKey: "lastUseDate")
            LifeCycle.daysSinceLastSession = Tool.daysBetweenDates(optLastSessionDate, toDate: now)
        }
        userDefaults.setObject(now, forKey: LifeCycleKey.LastSession.rawValue)
        userDefaults.synchronize()
    }
    
    //MARK: - Session
    
    /**
    Called when application goes to background
    should save the timestamp to know if we have to start a new session on the next launch
    
    - parameter notification: notif
    */
    class func applicationDidEnterBackground() {
        LifeCycle.timeInBackground = NSDate()
    }
    
    /**
     Get the default sessionBackground duraion
     
     - parameter parameters: the default parameters
     
     - returns: the background session duration (default: 60)
     */
    class func sessionBackgroundDuration(parameters: Dictionary<String, String>) -> Int {
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
    class func applicationActive(parameters: Dictionary<String, String>) {
        let sessionConfig: Int = sessionBackgroundDuration(parameters)
        
        if !hasAssignedNewSession() {
            if let ts = LifeCycle.timeInBackground {
                let now = NSDate()
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
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if userDefaults.objectForKey(LifeCycleKey.FirstSession.rawValue) == nil {
                LifeCycle.firstLaunchInit()
            }
            
            var fsd = userDefaults.objectForKey(LifeCycleKey.FirstSessionDate.rawValue) as? NSDate
            if fsd == nil {
                fsd = NSDate()
                userDefaults.setObject(fsd, forKey: LifeCycleKey.FirstSessionDate.rawValue)
            }
            
            let firstSessionDate = fsd!
            let now = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "yyyyMMdd"

            // First session: fs
            LifeCycle.parameters["fs"] = (self.firstSession ? 1 : 0)
            
            // First session after update: fsau
            LifeCycle.parameters["fsau"] = (self.appVersionChanged ? 1 : 0)
            
            // session count since update: scsu
            if let sessionCountSinceUpdate = userDefaults.objectForKey(LifeCycleKey.SessionCountSinceUpdate.rawValue) as? Int {
                LifeCycle.parameters["scsu"] = sessionCountSinceUpdate
            }
            
            // session count: sc
            LifeCycle.parameters["sc"] = userDefaults.integerForKey(LifeCycleKey.SessionCount.rawValue)
            
            // First session date: fsd
            LifeCycle.parameters["fsd"] = Int(dateFormatter.stringFromDate(firstSessionDate))
            
            // Days since first session: dsfs
            LifeCycle.parameters["dsfs"] = Tool.daysBetweenDates(firstSessionDate, toDate: now)
            
            // first session date after update & days since update: usd / dsu
            if let applicationUpdate = userDefaults.objectForKey(LifeCycleKey.ApplicationUpdate.rawValue) as? NSDate {
                LifeCycle.parameters["fsdau"] = Int(dateFormatter.stringFromDate(applicationUpdate))
                LifeCycle.parameters["dsu"] = Tool.daysBetweenDates(applicationUpdate, toDate: now)
            }
            
            // Days sinces last session: dsls
            LifeCycle.parameters["dsls"] = self.daysSinceLastSession
            
            // SessionId
            LifeCycle.parameters["sessionId"] = LifeCycle.sessionId
            
            let json = Tool.JSONStringify(["lifecycle": LifeCycle.parameters], prettyPrinted: false)
            
            LifeCycle.parameters.removeAll(keepCapacity: false)
            
            return json
        }
    }
}
