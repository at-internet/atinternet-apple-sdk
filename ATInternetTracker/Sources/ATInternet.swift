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

/// Makes it easy to manage trackers instances
public class ATInternet: NSObject {
    
    #if os(iOS) && AT_SMART_TRACKER
    /// First tracker that was initialized
    public var defaultTracker: AutoTracker {
        get {
            if(self.trackers == nil) {
                self.trackers = [String: Tracker]()
            }
            
            if(self.trackers.indexForKey("defaultTracker") != nil) {
                return self.trackers["defaultTracker"]! as! AutoTracker
            } else {
                let tracker = AutoTracker()
                self.trackers["defaultTracker"] = tracker
                
                return tracker
            }
        }
    }
    #else
    /// First tracker that was initialized
    public var defaultTracker: Tracker {
        get {
            return self.tracker("defaultTracker")
        }
    }
    #endif
    
    /// List of all initialized trackers
    private var trackers: [String: Tracker]!
    
    /**
    Default initializer
    */
    private override init() {
        
    }
    
    /// Singleton
    public class var sharedInstance: ATInternet {
        struct Static {
            static var instance: ATInternet?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ATInternet()
        }
        
        return Static.instance!
    }
    
    /**
    Method to access or create an instance of a tracker
    - parameter name: name of the tracker
    */
    public func tracker(name: String) -> Tracker {
        if(self.trackers == nil) {
            self.trackers = [String: Tracker]()
        }
        
        if(self.trackers.indexForKey(name) != nil) {
            return self.trackers[name]!
        } else {
            let tracker = Tracker()
            self.trackers[name] = tracker
            
            return tracker
        }
    }
    
    /**
    Method to access or create an instance of a tracker
    - parameter name: name of the tracker
    - parameter configuration: configuration to use for the tracker
    */
    public func tracker(name: String, configuration: [String: String]) -> Tracker {
        if(self.trackers == nil) {
            self.trackers = [String: Tracker]()
        }
        
        if(self.trackers.indexForKey(name) != nil) {
            return self.trackers[name]!
        } else {
            let tracker = Tracker(configuration: configuration)
            
            self.trackers[name] = tracker
            
            return tracker
        }
    }
}
