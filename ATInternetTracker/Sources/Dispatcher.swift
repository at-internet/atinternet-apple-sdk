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
//  Dispatcher.swift
//  Tracker
//

//#if AT_EXTENSION
//import TrackerExtension
//#else
//import Tracker
//#endif

import Foundation

class Dispatcher: NSObject {
    
    /// Tracker instance
    var tracker: Tracker
    
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Send the built hit
    */
    internal func dispatch(_ businessObjects: [BusinessObject]?) {
        if(businessObjects != nil) {
            for(_, businessObject) in (businessObjects!).enumerated() {
                switch(businessObject) {
                case let screen as AbstractScreen:
                    screen.setEvent()
                
                    var hasOrder: Bool = false
                    
                    for(_, value) in self.tracker.businessObjects {
                        if ((value is ScreenInfo || value is InternalSearch || (value is OnAppAd && (value as! OnAppAd).action == OnAppAd.OnAppAdAction.view) || value is Order) && value.timeStamp <= screen.timeStamp) {

                            if(value is Order) {
                                hasOrder = true
                            }
                            
                            value.setEvent()
                            self.tracker.businessObjects.removeValue(forKey: value.id)
                        }
                    }
                    
                    if(tracker.cart.cartId != "" && ((screen.isBasketScreen) || hasOrder)) {
                        tracker.cart.setEvent()
                    }
                    
                    self.tracker.businessObjects.removeValue(forKey: businessObject.id)
                case let gesture as Gesture:
                    businessObject.setEvent()
                    
                    if(gesture.action == Gesture.GestureAction.search) {
                        for(_, value) in self.tracker.businessObjects {
                            if (value is InternalSearch && value.timeStamp <= businessObject.timeStamp) {
                                value.setEvent()
                                self.tracker.businessObjects.removeValue(forKey: value.id)
                            }
                        }
                    }
                    
                    self.tracker.businessObjects.removeValue(forKey: businessObject.id)
                default:
                    businessObject.setEvent()
                    self.tracker.businessObjects.removeValue(forKey: businessObject.id)
                    break
                }
                
                // If there is some customObjects on the pipeline
                for(_, value) in self.tracker.businessObjects {
                    if(value is CustomObject || value is NuggAd) {
                        if(value.timeStamp <= businessObject.timeStamp) {
                            value.setEvent()
                            self.tracker.businessObjects.removeValue(forKey: value.id)

                        }
                    }
                }
            }
        }
        
        // Saves screen name and level 2 in context if hit type is Screen
        if(Hit.getHitType(self.tracker.buffer.volatileParameters, self.tracker.buffer.persistentParameters) == Hit.HitType.screen) {
            TechnicalContext.screenName = Tool.appendParameterValues(HitParam.screen.rawValue, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters)
            
            let level2 = Int(Tool.appendParameterValues(HitParam.level2.rawValue, volatileParameters: self.tracker.buffer.volatileParameters, persistentParameters: self.tracker.buffer.persistentParameters))
            
            if let optLevel2 = level2 {
                TechnicalContext.level2 = optLevel2
            } else {
                TechnicalContext.level2 = 0
            }
            
            Crash.lastScreen(TechnicalContext.screenName)
        }
        
        // Add life cycle metrics in stc variable
        let appendOptionWithEncoding = ParamOption()
        appendOptionWithEncoding.append = true
        appendOptionWithEncoding.encode = true
        
        _ = self.tracker.setParam(HitParam.json.rawValue, value: LifeCycle.getMetrics(), options: appendOptionWithEncoding)
        
        // Add crash report if available in stc variable
        let report = (Crash.compute() as NSDictionary?) as! [String: Any]?
        if let optReport = report {
            _ = self.tracker.setParam(HitParam.json.rawValue, value: optReport, options: appendOptionWithEncoding)
        }
        
        // Add persistent identified visitor data if required
        let userDefaults = UserDefaults.standard
        
        if let conf = self.tracker.configuration.parameters[IdentifiedVisitorHelperKey.configuration.rawValue] {
            if conf == "true" {
                if let num = userDefaults.object(forKey: IdentifiedVisitorHelperKey.numeric.rawValue) as? String {
                    _ = self.tracker.setParam(HitParam.visitorIdentifierNumeric.rawValue, value: num)
                }
                if let tex = userDefaults.object(forKey: IdentifiedVisitorHelperKey.text.rawValue) as? String {
                    let encodingOption = ParamOption()
                    encodingOption.encode = true
                    _ = self.tracker.setParam(HitParam.visitorIdentifierText.rawValue, value: tex, options:encodingOption)
                }
                if let cat = userDefaults.object(forKey: IdentifiedVisitorHelperKey.category.rawValue) as? String {
                    _ = self.tracker.setParam(HitParam.visitorCategory.rawValue, value: cat)
                }
            }
        }
        
        // Creation of hit builder task to execute in background thread
        let builder = Builder(tracker: self.tracker)
        // Remove all non persistent parameters from buffer
        self.tracker.buffer.volatileParameters.removeAll(keepingCapacity: false)
        // Add hit builder task to queue
        TrackerQueue.sharedInstance.queue.addOperation(builder)
        
        // Set level2 context param back in case level2 id were overriden for one hit
        self.tracker.context.level2 = self.tracker.context.level2
    }
    
}
