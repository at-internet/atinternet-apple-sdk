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
//  GPS.swift
//  Tracker
//

import Foundation

/// Wrapper class for gps location tracking
public class Location: ScreenInfo {
    /// latitude
    @objc public var latitude: Double = 0.0
    /// longitude
    @objc public var longitude: Double = 0.0
    
    @objc public init(latitude: Double, longitude: Double) {
        super.init()
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /// Set parameters in buffer
    override func setParams() {
        _ = tracker.setParam(HitParam.gpsLatitude.rawValue, value: String(format: "%.2f", latitude))
        _ = tracker.setParam(HitParam.gpsLongitude.rawValue, value: String(format: "%.2f", longitude))
    }
}

/// /// Wrapper class to manage Locations instances
public class Locations: NSObject {
    /// Tracker instance
    @objc var tracker: Tracker
    
    /**
    Locations initializer
    - parameter tracker: the tracker instance
    - returns: Locations instance
    */
    @objc init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Add a location
    ///
    /// - Parameters:
    ///   - latitude: latitude x
    ///   - longitude: longitude y
    /// - Returns: a new location instance
    @objc public func add(_ latitude: Double, longitude: Double) -> Location {
        let location = Location(tracker: tracker)
        location.latitude = latitude
        location.longitude = longitude
        tracker.businessObjects[location.id] = location
        
        return location
    }
}
