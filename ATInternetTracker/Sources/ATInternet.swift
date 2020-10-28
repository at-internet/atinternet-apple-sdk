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
//  ATInternet.swift
//  Tracker
//
import Foundation

/// Use this class to manage tracker instances
public class ATInternet: NSObject {
    
    struct Static {
        static var instance: ATInternet?
    }
    
    fileprivate static var __once: () = {
            Static.instance = ATInternet()
        }()
    
    /// Get a Tracker with "defaultTracker" name
    @objc public var defaultTracker: Tracker {
        get {
            return self.tracker("defaultTracker")
        }
    }
    
    /// List of all initialized trackers
    fileprivate var trackers = [String: Tracker]()
    
    /**
    Default initializer
    */
    fileprivate override init() {
        
    }
    
    /// Singleton
    @objc public class var sharedInstance: ATInternet {
        _ = ATInternet.__once
        
        return Static.instance!
    }
    
    
    /// Get a tracker with default configuration
    ///
    /// - Parameter name: the tracker identifier
    /// - Returns: a new tracker or an existing instance
    @objc public func tracker(_ name: String) -> Tracker {
        if(self.trackers.index(forKey: name) != nil) {
            return self.trackers[name]!
        } else {
            let tracker = Tracker(registerNeeded: false)
            registerTracker(name, tracker: tracker)
            return tracker
        }
    }
    
    /// Directory where the database is saved
    #if os(tvOS)
    static var _databaseDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!
    #else
    static var _databaseDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    #endif
    
    /// Custom User-Agent
    @objc fileprivate(set) var _userAgent = "";
    @objc public var userAgent : String {
        get {
            if _userAgent != "" {
                return _userAgent
            }
            if let optDefaultUa = TechnicalContext.defaultUserAgent {
                return optDefaultUa
            }
            return ""
        }
        set {
            _userAgent = newValue
            for (_, t) in trackers {
                t.userAgent = _userAgent
            }
        }
    }
    
    /// Get user agent async
    @objc public func getUserAgentAsync(completionHandler: @escaping ((String) -> Void)) {
        if _userAgent != "" {
            completionHandler(_userAgent)
            return
        }
        TechnicalContext.getUserAgentAsync(completionHandler: completionHandler)
    }
    
    /// Application version
    @objc fileprivate(set) var _applicationVersion = "";
    @objc public var applicationVersion : String {
        get {
            if _applicationVersion != "" {
                return _applicationVersion
            }
            return TechnicalContext.applicationVersion
        }
        set {
            _applicationVersion = newValue
            for (_, t) in trackers {
                t.applicationVersion = _applicationVersion
            }
        }
    };
    
    @objc public class var databaseDirectory: URL {
        get {
            return ATInternet._databaseDirectory
        } set {
            if (Storage.isInitialised) {
                print("[warning] Changing database path when storage is already initialized")
            } else {
                ATInternet._databaseDirectory = newValue
            }
        }
    }
    
    @objc public class var encryptionMode: String {
        get {
            return Crypt.encryptionMode
        } set {
            Crypt.encryptionMode = newValue.lowercased()
        }
    }
    
    /// Disable user identification.
    @objc public class var optOut: Bool {
        get {
            return TechnicalContext.optOut
        } set {
            let optOutOperation = BlockOperation(block: {
                TechnicalContext.optOut = newValue
            })
            
            TrackerQueue.sharedInstance.queue.addOperation(optOutOperation)
        }
    }
    
    /// Prevent offline hits to be sync with icloud
    @objc public static var preventICloudSync = false
    
    /// Get a tracker with custom configuration
    ///
    /// - Parameters:
    ///   - name: the tracker identifier
    ///   - configuration: a custom configuration. See TrackerConfigurationKeys
    /// - Returns: a new tracker or an existing instance
    @objc public func tracker(_ name: String, configuration: [String: String]) -> Tracker {
        if(self.trackers.index(forKey: name) != nil) {
            return self.trackers[name]!
        } else {
            let tracker = Tracker(configuration: configuration, registerNeeded: false)
            registerTracker(name, tracker: tracker)
            return tracker
        }
    }
    
    @objc func registerTracker(_ trackerName: String, tracker: Tracker) {
        if self._applicationVersion != "" {
            tracker.applicationVersion = self._applicationVersion
        }
        if self._userAgent != "" {
            tracker.userAgent = self._userAgent
        }
        self.trackers[trackerName] = tracker
    }
}
