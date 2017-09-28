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
//  TVTracking.swift
//  Tracker
//

import Foundation

/// Wrapper class to enable TVTracking partner usage
public class TVTracking: NSObject {
    /// Tracker instance
    var tracker: Tracker
    /// URL of campaign
    var campaignURL: URL!
    /// Visit duration
    var visitDuration: Int
    
    /**
    TVTracking initializer
    - parameter tracker: the tracker instance
    - returns: TVTracking instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
        self.visitDuration = 10
        super.init()
        configure()
    }
    
    func configure() {
        if let optTVTURL = tracker.configuration.parameters["tvtURL"] {
            if(optTVTURL == "") {
                tracker.delegate?.warningDidOccur?("TVTracking URL not set")
            } else {
                let URL = Foundation.URL(string: optTVTURL)
                
                if let optURL = URL {
                    self.campaignURL = optURL
                } else {
                    tracker.delegate?.warningDidOccur?("TVTracking URL is not a valid URL")
                }
            }
        } else {
            tracker.delegate?.warningDidOccur?("TVTracking URL not set")
        }
        
        if let optTVTVisitDuration = tracker.configuration.parameters["tvtVisitDuration"] {
            if let duration = Int(optTVTVisitDuration) {
                self.visitDuration = duration
            }
        }
    }
    
    //MARK: TVT setting
    
    /**
    Enable TV Tracking
    - returns: tracker instance
    */
    @discardableResult
    @objc
    public func set() -> Tracker {
        if ((PluginParam.list(self.tracker)["tvt"]) != nil) {
            let option = ParamOption()
            option.append = true
            option.persistent = true
            option.encode = true
            _ = self.tracker.setParam("tvt", value: true, options: option)
        } else {
            self.tracker.delegate?.warningDidOccur?("TV Tracking not enabled")
        }
        
        return self.tracker
    }
    
    ///  Enable TV Tracking
    ///
    /// - Parameter campaignURL: campaign string url
    /// - Returns: tracker instance
    @discardableResult
    @objc
    public func set(_ campaignURL: String) -> Tracker {
        let URL = Foundation.URL(string: campaignURL)
        
        if let optURL = URL {
            self.campaignURL = optURL
        } else {
            tracker.delegate?.warningDidOccur?("TVTracking URL is not a valid URL")
        }
        
        return set()
    }
    
    /// Enable TV Tracking
    ///
    /// - Parameters:
    ///   - campaignURL: campaign string url
    ///   - visitDuration: visitDuration
    /// - Returns: tracker instance
    @objc public func set(_ campaignURL: String, visitDuration: Int) -> Tracker {
        self.visitDuration = visitDuration
        
        return set(campaignURL)
    }
    
    /**
    Disable TV Tracking
    */
    @objc public func unset() {
        self.tracker.unsetParam("tvt")
        configure()
    }
}
