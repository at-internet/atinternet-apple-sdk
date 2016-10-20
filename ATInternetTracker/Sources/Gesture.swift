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
//  Touch.swift
//  Tracker
//

import Foundation

public class Gesture: BusinessObject {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    
    /**
     Enum with differents event type
     
     - Unknown: unknown event
     - Tap:     tap event
     */
    @objc public enum GestureEventType: Int {
        case unknown = 0
        case tap = 1
        case swipe = 2
        case scroll = 3
        case pinch  = 4
        case pan    = 5
        case rotate = 6
        case refresh = 7
    }
    
    /// Gesture actions
    @objc public enum GestureAction: Int {
        case touch = 0
        case navigate = 1
        case download = 2
        case exit = 3
        case search = 4
    }

    /// Touch name
    public var name: String = ""
    /// First chapter
    public var chapter1: String?
    /// Second chapter
    public var chapter2: String?
    /// Third chapter
    public var chapter3: String?
    /// Level 2
    public var level2: Int = 0
    /// Action
    public var action: GestureAction = GestureAction.touch
    /// Type of touch
    internal(set) public lazy var type: GestureEventType = GestureEventType.unknown
    /// Screen information on which the gesture has been done
    internal(set) public weak var screen: Screen?
    /// Custom objects to add to gesture hit
    public lazy var customObjects: CustomObjects = CustomObjects(gesture: self)
    
    #if os(iOS) && AT_SMART_TRACKER
    // View information which was touched by the user
    internal(set) public weak var view: View?
    /// Indicates whether the gesture is ready to be sent to tracker
    public var isReady: Bool = false
    #endif
    
    internal class func getEventTypeRawValue(_ value: Int) -> String {
        switch value {
        case 1:
            return "tap"
        case 2:
            return "swipe"
        case 3:
            return "scroll"
        case 4:
            return "pinch"
        case 5:
            return "pan"
        case 6:
            return "rotate"
        case 7:
            return "refresh"
        default:
            return "unknown"
        }
    }
    
    internal class func getEventTypeIntValue(_ value: String) -> Int {
        switch value {
        case "tap":
            return 1
        case "swipe":
            return 2
        case "scroll":
            return 3
        case "pinch":
            return 4
        case "pan":
            return 5
        case "rotate":
            return 6
        case "refresh":
            return 7
        default:
            return 0
        }
    }
    
    fileprivate func getActionRawValue(_ value: Int) -> String {
        switch(value) {
        case 0:
            return "A"
        case 1:
            return "N"
        case 2:
            return "T"
        case 3:
            return "S"
        case 4:
            return "IS"
        default:
            return "A"
        }
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        if(TechnicalContext.screenName != "") {
            let encodingOption = ParamOption()
            encodingOption.encode = true
            _ = tracker.setParam(HitParam.touchScreen.rawValue, value: TechnicalContext.screenName, options: encodingOption)
        }
        
        if(TechnicalContext.level2 > 0) {
            _ = tracker.setParam(HitParam.touchLevel2.rawValue, value: TechnicalContext.level2)
        }
        
        if level2 > 0 {
            _ = self.tracker.setParam("s2", value: level2)
        }
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setEvent()
        }
        
        _ = tracker.setParam("click", value: getActionRawValue(action.rawValue))
        _ = tracker.event.set("click", action: getActionRawValue(action.rawValue), label: buildGestureName())
    }
    
    /**
    Send navigation gesture hit
    */
    public func sendNavigation() {
        self.action = GestureAction.navigate
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send exit gesture hit
    */
    public func sendExit() {
        self.action = GestureAction.exit
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send download gesture hit
    */
    public func sendDownload() {
        self.action = GestureAction.download
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send touch gesture hit
    */

    public func sendTouch() {
        self.action = GestureAction.touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send search gesture hit
    */
    public func sendSearch() {
        self.action = GestureAction.search
        self.tracker.dispatcher.dispatch([self])
    }
       
       
    //MARK: Touch name building
    func buildGestureName() -> String {
        var touchName = chapter1 == nil ? "" : chapter1! + "::"
        touchName = chapter2 ==  nil ? touchName : touchName + chapter2! + "::"
        touchName = chapter3 ==  nil ? touchName : touchName + chapter3! + "::"
        touchName += name
        
        return touchName
    }
}

public class Gestures: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Gestures initializer
    - parameter tracker: the tracker instance
    - returns: Gestures instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Set a gesture
    - returns: gesture instance
    */
    public func add() -> Gesture {
        let gesture = Gesture(tracker: tracker)
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - returns: gesture instance
    */
    public func add(_ name:String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - parameter first: chapter
    - returns: gesture instance
    */
    public func add(_ name: String, chapter1: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: gesture instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        gesture.chapter2 = chapter2
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /**
    Set a gesture
    - parameter touch: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: gesture instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        gesture.chapter2 = chapter2
        gesture.chapter3 = chapter3
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
}
