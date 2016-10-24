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
//  CustomObject.swift
//  Tracker
//

import Foundation

public class CustomObject: BusinessObject {
    /// JSON 
    public var json: String = "{}"
    
    @objc(initWithString:)
    init(string: String) {
        super.init()
        
        self.json = string
    }
    
    @objc(initWithDictionary:)
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        self.json = Tool.JSONStringify(dictionary)
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        let option = ParamOption()
        option.append = true
        option.encode = true
        
        self.tracker.setParam(HitParam.JSON.rawValue, value: json, options: option)
    }
}

public class CustomObjects: NSObject {
    /// Tracker instance
    var tracker: Tracker!
    
    /// Screen instance
    var screen: AbstractScreen!
    
    /// Gesture instance
    var gesture: Gesture!
    
    /// Publisher instance
    var publisher: Publisher!
    
    /// Self Promotion instance
    var selfPromotion: SelfPromotion!
    
    /// Product instance
    var product: Product!
    
    /**
    CustomObjects initializer
    - parameter tracker: the tracker instance
    - returns: CustomObjects instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    init(screen: AbstractScreen) {
        self.screen = screen
        self.tracker = screen.tracker
    }
    
    init(gesture: Gesture) {
        self.gesture = gesture
        self.tracker = gesture.tracker
    }
    
    init(publisher: Publisher) {
        self.publisher = publisher
        self.tracker = publisher.tracker
    }
    
    init(selfPromotion: SelfPromotion) {
        self.selfPromotion = selfPromotion
        self.tracker = selfPromotion.tracker
    }
    
    init(product: Product) {
        self.product = product
        self.tracker = product.tracker
    }
    
    /**
    Add tagging data for custom object
    - parameter customObject: serialized custom object
    @- returns: the CustomObjects instance
    */
    @objc(addString:)
    public func add(customObject: String) -> CustomObject {
        let customObj = CustomObject(string: customObject)
        customObj.tracker = self.tracker
        
        if screen != nil {
            screen!._customObjects[customObj.id] = customObj
        } else if gesture != nil {
            gesture!._customObjects[customObj.id] = customObj
        } else if publisher != nil {
            publisher!._customObjects[customObj.id] = customObj
        } else if selfPromotion != nil {
            selfPromotion!._customObjects[customObj.id] = customObj
        } else if product != nil {
            product!._customObjects[customObj.id] = customObj
        } else {
            self.tracker.businessObjects[customObj.id] = customObj
        }
        return customObj
    }
    
    /**
    Add tagging data for custom object
    - parameter customObject: not serialized custom object
    - returns: the CustomObjects instance
    */
    @objc(addDictionary:)
    public func add(customObject: [String: AnyObject]) -> CustomObject {
        let customObj = CustomObject(dictionary: customObject)
        customObj.tracker = tracker
        
        if screen != nil {
            screen!._customObjects[customObj.id] = customObj
        } else if gesture != nil {
            gesture!._customObjects[customObj.id] = customObj
        } else if publisher != nil {
            publisher!._customObjects[customObj.id] = customObj
        } else if selfPromotion != nil {
            selfPromotion!._customObjects[customObj.id] = customObj
        } else if product != nil {
            product!._customObjects[customObj.id] = customObj
        } else {
            self.tracker.businessObjects[customObj.id] = customObj
        }
        
        return customObj
    }
    
    /**
     Remove a custom object
     - parameter customObjectId: the custom object identifier
     */
    public func remove(customObjectId: String) {
        if(screen != nil) {
            screen!._customObjects.removeValueForKey(customObjectId)
        } else if(gesture != nil) {
            gesture!._customObjects.removeValueForKey(customObjectId)
        } else if(publisher != nil) {
            publisher!._customObjects.removeValueForKey(customObjectId)
        } else if(selfPromotion != nil) {
            selfPromotion!._customObjects.removeValueForKey(customObjectId)
        } else if(product != nil) {
            product!._customObjects.removeValueForKey(customObjectId)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is CustomObject && (value as! CustomObject).id == customObjectId) {
                    self.tracker.businessObjects.removeValueForKey(value.id)
                    break
                }
            }
        }
    }
    
    /**
     Remove all the products
     */
    public func removeAll() {
        if(screen != nil) {
            screen!._customObjects.removeAll(keepCapacity: false)
        } else if(gesture != nil) {
            gesture!._customObjects.removeAll(keepCapacity: false)
        } else if(publisher != nil) {
            publisher!._customObjects.removeAll(keepCapacity: false)
        } else if(selfPromotion != nil) {
            selfPromotion!._customObjects.removeAll(keepCapacity: false)
        } else if(product != nil) {
            product!._customObjects.removeAll(keepCapacity: false)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is CustomObject) {
                    self.tracker.businessObjects.removeValueForKey(value.id)
                }
            }
        }
    }
}
