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

#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

/// Use this class to manage tracker instances
public class ATInternet: NSObject {
    
    struct Static {
        static var instance: ATInternet?
    }
    
    fileprivate static var __once: () = {
            Static.instance = ATInternet()
        }()
    
    #if os(iOS) && AT_SMART_TRACKER
    /// Get an AutoTracker with "defaultTracker" name
    @objc public var defaultTracker: AutoTracker {
        get {
            if(self.trackers == nil) {
                self.trackers = [String: Tracker]()
            }
            
            if(self.trackers.index(forKey: "defaultTracker") != nil) {
                return self.trackers["defaultTracker"]! as! AutoTracker
            } else {
                let tracker = AutoTracker()
                self.trackers["defaultTracker"] = tracker
                
                return tracker
            }
        }
    }
    #else
    /// Get a Tracker with "defaultTracker" name
    @objc public var defaultTracker: Tracker {
        get {
            return self.tracker("defaultTracker")
        }
    }
    #endif
    
    /// List of all initialized trackers
    fileprivate var trackers: [String: Tracker]!
    
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
        if(self.trackers == nil) {
            self.trackers = [String: Tracker]()
        }
        
        if(self.trackers.index(forKey: name) != nil) {
            return self.trackers[name]!
        } else {
            let tracker = Tracker()
            self.trackers[name] = tracker
            
            return tracker
        }
    }
    
    /// Get a tracker with custom configuration
    ///
    /// - Parameters:
    ///   - name: the tracker identifier
    ///   - configuration: a custom configuration. See TrackerConfigurationKeys
    /// - Returns: a new tracker or an existing instance
    @objc public func tracker(_ name: String, configuration: [String: String]) -> Tracker {
        if(self.trackers == nil) {
            self.trackers = [String: Tracker]()
        }
        
        if(self.trackers.index(forKey: name) != nil) {
            return self.trackers[name]!
        } else {
            let tracker = Tracker(configuration: configuration)
            
            self.trackers[name] = tracker
            
            return tracker
        }
    }
}
