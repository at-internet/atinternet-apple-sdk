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

public class SelfPromotion : OnAppAd {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    
    /// Ad identifier
    public var adId: Int = 0
    /// Ad format
    public var format: String?
    /// Product identifier
    public var productId: String?
    
    // Custom objects to add to self promotion hit
    public lazy var customObjects: CustomObjects = CustomObjects(selfPromotion: self)
    
    /**
    Send self promotion touch hit
    */
    public func sendTouch() {
        self.action = OnAppAdAction.touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send self promotion view hit
    */
    public func sendImpression() {
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
        
        let positions = Tool.findParameterPosition(HitParam.hitType.rawValue, arrays: tracker.buffer.persistentParameters, tracker.buffer.volatileParameters)
        
        if(positions.count > 0) {
            for(_, position) in positions.enumerated() {
                if(position.arrayIndex == 0) {
                    currentType = (tracker.buffer.persistentParameters[position.index] as Param).value()
                } else {
                    currentType = (tracker.buffer.volatileParameters[position.index] as Param).value()
                }
            }
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

public class SelfPromotionImpression: ScreenInfo {
    /// Ad identifier
    public var adId: Int = 0
    /// Ad format
    public var format: String?
    /// Product identifier
    public var productId: String?
    
    public init(adId: Int) {
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

public class SelfPromotionImpressions: NSObject {
    /// Tracker instance
    var tracker: Tracker!
    
    /// Screen instance
    var screen: AbstractScreen
    
    init(screen: AbstractScreen) {
        self.screen = screen
        self.tracker = screen.tracker
    }
    
    /**
     Set a self promotion
     @param adId identifier
     @return the Self Promotion instance
     */
    public func add(_ adId: Int) -> SelfPromotionImpression {
        let selfPromo = SelfPromotionImpression(tracker: self.tracker)
        selfPromo.adId = adId
        
        screen._selfPromotions[selfPromo.id] = selfPromo
        
        return selfPromo
    }
}

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
    
    /**
    Set a self promotion
    - parameter adId: ad identifier
    :returnd: the SelfPromotion instance
    */
    public func add(_ adId: Int) -> SelfPromotion {
        let selfPromotion = SelfPromotion(tracker: self.tracker)
        selfPromotion.adId = adId
        
        self.tracker.businessObjects[selfPromotion.id] = selfPromotion
        
        return selfPromotion
    }
    
    /**
    Send self promotion view hits
    */
    public func sendImpressions() {
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
