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
//  Publisher.swift
//  Tracker
//

import Foundation

/// Wrapper class for Publisher (ads) tracking
public class Publisher : OnAppAd {
    
    var fromScreen = false
    
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    
    /// Campaign identifier
    @objc public var campaignId: String = ""
    
    /// Creation
    @objc public var creation: String?
    
    /// Variant
    @objc public var variant: String?
    
    /// Format
    @objc public var format: String?
    
    /// General placement
    @objc public var generalPlacement: String?
    
    /// Detailed placement
    @objc public var detailedPlacement: String?
    
    /// Advertiser identifier
    @objc public var advertiserId: String?
    
    /// URL
    @objc public var url: String?
    
    // Custom objects to add to publisher hit
    @objc public lazy var customObjects: CustomObjects = CustomObjects(publisher: self)
    
    /// Send publisher touch hit
    @objc public func sendTouch() {
        self.action = OnAppAdAction.touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send publisher view hit
    */
    @objc public func sendImpression() {
        self.action = OnAppAdAction.view
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let prefix = "PUB"
        let separator = "-"
        
        var spot = prefix + separator + campaignId + separator
        
        if let creation = creation {
            spot += creation + separator
        } else {
            spot += separator
        }
        
        if let variant = variant {
            spot += variant + separator
        } else {
            spot += separator
        }
        
        if let format = format {
            spot += format + separator
        } else {
            spot += separator
        }
        
        if let generalPlacement = generalPlacement {
            spot += generalPlacement + separator
        } else {
            spot += separator
        }
        
        if let detailedPlacement = detailedPlacement {
            spot += detailedPlacement + separator
        } else {
            spot += separator
        }
        
        if let advertiserId = advertiserId {
            spot += advertiserId + separator
        } else {
            spot += separator
        }
        
        if let url = url {
            spot += url
        }
        
        if (!self.fromScreen) {
            self.tracker.setParam(HitParam.hitType.rawValue, value: "AT")
        }
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        _ = self.tracker.setParam(OnAppAd.getOnAppAddActionRawValue(self.action.rawValue), value: spot, options: option)
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setParams()
        }
        
        if(action == OnAppAdAction.touch) {
            if let screenName = TechnicalContext.screenName {
                let encodingOption = ParamOption()
                encodingOption.encode = true
                _ = tracker.setParam("patc", value: screenName, options: encodingOption)
            }
            
            if let level2 = TechnicalContext.level2 {
                _ = tracker.setParam("s2atc", value: level2)
            }
        }
    }
}

/// Wrapper class for publisher impression tracking. They are attached to a Screen
public class PublisherImpression: Publisher {
    /// Create a PublisherImpression with a campaignId
    ///
    /// - Parameter campaignId: campaign identifier
    @available(*, deprecated, message: "useless constructor")
    @objc public init(campaignId: String) {
        super.init()
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
        self.action = OnAppAdAction.view
        self.fromScreen = true
    }
    
    @objc public override func sendImpression() {
        /// Do nothing
        self.tracker?.delegate?.warningDidOccur?("This method is overrided to do nothing")
    }
    
    @objc public override func sendTouch() {
        /// Do nothing
        self.tracker?.delegate?.warningDidOccur?("This method is overrided to do nothing")
    }
}

/// Wrapper class to manage PublisherImpressions instances
@objc public class PublisherImpressions: NSObject {
    /// Tracker instance
    var tracker: Tracker!
    
    /// Screen instance
    weak var screen: AbstractScreen!
    
    init(screen: AbstractScreen) {
        self.screen = screen
        self.tracker = screen.tracker
    }
    
    /// Add a publisher
    ///
    /// - Parameter campaignId: campaign identifier
    /// - Returns: the new publisher instance
    @discardableResult
    @objc
    public func add(_ campaignId: String) -> PublisherImpression {
        let publisherDetail = PublisherImpression(tracker: self.tracker)
        publisherDetail.campaignId = campaignId
        
        screen._publishers[publisherDetail.id] = publisherDetail
        
        return publisherDetail
    }
}

/// Wrapper class to manage Publisher instances
public class Publishers: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Publishers initializer
    - parameter tracker: the tracker instance
    - returns: Publishers instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Add a publisher
    ///
    /// - Parameter campaignId: campaign identifier
    /// - Returns: the new Publisher instance
    @discardableResult
    @objc
    public func add(_ campaignId: String) -> Publisher {
        let publisherDetail = Publisher(tracker: self.tracker)
        publisherDetail.campaignId = campaignId
        
        self.tracker.businessObjects[publisherDetail.id] = publisherDetail
        
        return publisherDetail
    }
    
    /**
    Send publisher views hits
    */
    @objc public func sendImpressions() {
        var impressions = [BusinessObject]()
        
        for(_, object) in self.tracker.businessObjects {
            if let pub = object as? Publisher {
                if(pub.action == OnAppAd.OnAppAdAction.view) {
                    impressions.append(pub)
                }
            }
        }
        
        let sortedImpressions = impressions.sorted {
            a, b in return a.timeStamp < b.timeStamp
        }
        
        if(sortedImpressions.count > 0) {
            self.tracker.dispatcher.dispatch(sortedImpressions)
        }
    }
}
