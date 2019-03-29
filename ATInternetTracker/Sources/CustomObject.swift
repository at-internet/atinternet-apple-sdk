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


/// Wrapper class to inject custom data in you tracking
public class CustomObject: BusinessObject {
    /// custom data as string - json formatted
    @objc public var json: String = "{}"
    /// allow the custom object to persist
    @objc public var persistent = false
    
    @objc(initWithString:)
    init(string: String) {
        super.init()
        
        self.json = string
    }
    
    @objc(initWithDictionary:)
    init(dictionary: [String: Any]) {
        super.init()
        
        self.json = Tool.JSONStringify(dictionary)
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let option = ParamOption()
        option.append = true
        option.encode = true
        option.persistent = self.persistent
        self.tracker.setParam(HitParam.json.rawValue, value: json, options: option)
    }
}


/// Wrapper class to manage custom objects instances
public class CustomObjects: NSObject {
    /// Tracker instance
    var tracker: Tracker!
    
    /// Screen instance
    weak var screen: AbstractScreen!
    
    /// Gesture instance
    weak var gesture: Gesture!
    
    /// Publisher instance
    weak var publisher: Publisher!
    
    /// Self Promotion instance
    weak var selfPromotion: SelfPromotion!
    
    /// Product instance
    weak var product: Product!
    
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
    
    /// Add a custom object
    ///
    /// - Parameter customObject: customObject json string value
    /// - Returns: the custom object instance
    @discardableResult
    @objc(addString:)
    public func add(_ customObject: String) -> CustomObject {
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
    
    /// Add a custom object
    ///
    /// - Parameter customObject: customObject in key-value format
    /// - Returns: the custom object instance
    @discardableResult
    @objc(addDictionary:)
    public func add(_ customObject: [String: Any]) -> CustomObject {
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

    /// Remove a custom object
    ///
    /// - Parameter customObjectId: the custom object identifier
    public func remove(_ customObjectId: String) {
        if(screen != nil) {
            screen!._customObjects.removeValue(forKey: customObjectId)
        } else if(gesture != nil) {
            gesture!._customObjects.removeValue(forKey: customObjectId)
        } else if(publisher != nil) {
            publisher!._customObjects.removeValue(forKey: customObjectId)
        } else if(selfPromotion != nil) {
            selfPromotion!._customObjects.removeValue(forKey: customObjectId)
        } else if(product != nil) {
            product!._customObjects.removeValue(forKey: customObjectId)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is CustomObject && (value as! CustomObject).id == customObjectId) {
                    self.tracker.businessObjects.removeValue(forKey: value.id)
                    break
                }
            }
        }
    }
    
    /// Remove all custom objects
    @objc public func removeAll() {
        if(screen != nil) {
            screen!._customObjects.removeAll(keepingCapacity: false)
        } else if(gesture != nil) {
            gesture!._customObjects.removeAll(keepingCapacity: false)
        } else if(publisher != nil) {
            publisher!._customObjects.removeAll(keepingCapacity: false)
        } else if(selfPromotion != nil) {
            selfPromotion!._customObjects.removeAll(keepingCapacity: false)
        } else if(product != nil) {
            product!._customObjects.removeAll(keepingCapacity: false)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is CustomObject) {
                    self.tracker.businessObjects.removeValue(forKey: value.id)
                }
            }
        }
    }
}
