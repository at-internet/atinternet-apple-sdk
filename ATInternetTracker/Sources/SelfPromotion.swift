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
//  SelfPromotion
//  Tracker
//

import Foundation


/// manage self promotion tracking
public class SelfPromotion : OnAppAd {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    
    /// Advertising identifier
    @objc public var adId: Int = 0
    /// Advertising format
    @objc public var format: String?
    /// Product identifier
    @objc public var productId: String?
    
    /// Get a wrapper for Custom objects management
    @objc public lazy var customObjects: CustomObjects = CustomObjects(selfPromotion: self)
    
    /**
    Send self promotion touch hit
    */
    @objc public func sendTouch() {
        self.action = OnAppAdAction.touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send self promotion view hit
    */
    @objc public func sendImpression() {
        self.action = OnAppAdAction.view
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        let prefix = "INT"
        let simpleSeparator = "-"
        let doubleSeparator = "||"
        let defaultType = "AT"
        var currentType = ""
        
        var spot = prefix + simpleSeparator + String(adId) + simpleSeparator
        
        if let format = format {
            spot += format + doubleSeparator
        } else {
            spot += doubleSeparator
        }
        
        if let productId = productId {
            spot += productId
        }
        
        if let parameter = tracker.buffer.volatileParameters[HitParam.hitType.rawValue] {
            currentType = parameter.values[0]()
        }
        if let parameter = tracker.buffer.persistentParameters[HitParam.hitType.rawValue] {
            currentType = parameter.values[0]()
        }
        
        if (currentType != "screen" && currentType != defaultType) {
            _ = tracker.setParam(HitParam.hitType.rawValue, value: defaultType)
        }
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        _ = self.tracker.setParam(OnAppAd.getOnAppAddActionRawValue(self.action.rawValue), value: spot, options: option)
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setEvent()
        }
        
        if(action == OnAppAdAction.touch) {
            if(TechnicalContext.screenName != "") {
                let encodingOption = ParamOption()
                encodingOption.encode = true
                _ = tracker.setParam("patc", value: TechnicalContext.screenName, options: encodingOption)
            }
            
            if(TechnicalContext.level2 > 0) {
                _ = tracker.setParam("s2atc", value: TechnicalContext.level2)
            }
        }
    }
}


/// self promotion impression tracking
public class SelfPromotionImpression: ScreenInfo {
    /// Advertising identifier
    @objc public var adId: Int = 0
    /// Advertising format
    @objc public var format: String?
    /// Product identifier
    @objc public var productId: String?
    
    /// Constructor
    ///
    /// - Parameter adId: Advertising identifier
    @objc public init(adId: Int) {
        super.init()
        
        self.adId = adId
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    override func setEvent() {
        let prefix = "INT"
        let simpleSeparator = "-"
        let doubleSeparator = "||"
        
        var spot = prefix + simpleSeparator + String(adId) + simpleSeparator
        
        if let format = format {
            spot += format + doubleSeparator
        } else {
            spot += doubleSeparator
        }
        
        if let productId = productId {
            spot += productId
        }
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        _ = self.tracker.setParam(OnAppAd.getOnAppAddActionRawValue(OnAppAd.OnAppAdAction.view.rawValue), value: spot, options: option)
    }
}


/// Wrapper class to manage Self Promotion Impressions
public class SelfPromotionImpressions: NSObject {
    /// Tracker instance
    var tracker: Tracker!
    
    /// Screen instance
    var screen: AbstractScreen
    
    /// Constructor.
    ///
    /// - Parameter screen: a screen
    init(screen: AbstractScreen) {
        self.screen = screen
        self.tracker = screen.tracker
    }
    
    /// Add a SelfPromotionImpression
    ///
    /// - Parameter adId: Advertiser indentifier
    /// - Returns: the new SelfPromotionImpression
    @objc public func add(_ adId: Int) -> SelfPromotionImpression {
        let selfPromo = SelfPromotionImpression(tracker: self.tracker)
        selfPromo.adId = adId
        
        screen._selfPromotions[selfPromo.id] = selfPromo
        
        return selfPromo
    }
}

/// Wrapper class to manage Self Promotion instances
public class SelfPromotions: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    SelfPromotions initializer
    - parameter tracker: the tracker instance
    - returns: SelfPromotions instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    
    /// Add a SelfPromotion advertising
    ///
    /// - Parameter adId: advertiser identifier
    /// - Returns: the new SelfPromotion instance
    @discardableResult
    @objc
    public func add(_ adId: Int) -> SelfPromotion {
        let selfPromotion = SelfPromotion(tracker: self.tracker)
        selfPromotion.adId = adId
        
        self.tracker.businessObjects[selfPromotion.id] = selfPromotion
        
        return selfPromotion
    }
    
    
    /// Send all impressions
    @objc public func sendImpressions() {
        var impressions = [BusinessObject]()
        
        for(_, object) in self.tracker.businessObjects {
            if let selfPromo = object as? SelfPromotion {
                if(selfPromo.action == OnAppAd.OnAppAdAction.view) {
                    impressions.append(selfPromo)
                }
            }
        }
        
        if(impressions.count > 0) {
            self.tracker.dispatcher.dispatch(impressions)
        }
    }
}
