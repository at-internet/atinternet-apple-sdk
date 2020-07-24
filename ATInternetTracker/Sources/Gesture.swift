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


/// Wrapper class for gesture tracking
public class Gesture: BusinessObject {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    
    /// Enum with differents event type
    ///
    /// - unknown: unknown
    /// - tap: tap
    /// - swipe: swipe
    /// - scroll: scroll
    /// - pinch: pinch
    /// - pan: pan
    /// - rotate: rotate
    /// - refresh: refresh
    @objc public enum GestureEventType: Int {
        /// - unknown: unknown
        case unknown = 0
        /// - tap: tap
        case tap = 1
        /// - swipe: swipe
        case swipe = 2
        /// - scroll: scroll
        case scroll = 3
        /// - pinch: pinch
        case pinch  = 4
        /// - pan: pan
        case pan    = 5
        /// - rotate: rotate
        case rotate = 6
        /// - refresh: refresh
        case refresh = 7
        /// - deviceRotate: deviceRotate
        case deviceRotate = 8
    }

    /// Gesture actions
    ///
    /// - touch: simple gesture
    /// - navigate: navigation gesture
    /// - download: download action
    /// - exit: exit action
    /// - search: internal search action
    @objc public enum GestureAction: Int {
        /// - touch: simple gesture
        case touch = 0
        /// - navigate: navigation gesture
        case navigate = 1
        /// - download: download action
        case download = 2
        /// - exit: exit action
        case exit = 3
        /// - search: internal search action
        case search = 4
    }

    /// Touch name
    @objc public var name: String = ""
    /// First chapter
    @objc public var chapter1: String?
    /// Second chapter
    @objc public var chapter2: String?
    /// Third chapter
    @objc public var chapter3: String?
    /// Level 2
    @objc public var level2: Int {
        get {
            if let l = level2String {
                return Int(l) ?? -1
            }
            return -1
        }
        set {
            if newValue >= 0 {
                level2String = String(newValue)
            } else {
                level2String = nil
            }
        }
    }
    
    @objc public var level2String: String?
    /// Action - See GestureAction
    @objc public var action: GestureAction = GestureAction.touch
    /// Type of touch - See GestureEventType
    @objc internal(set) public lazy var type: GestureEventType = GestureEventType.unknown
    /// Custom objects to add to gesture hit
    @objc public lazy var customObjects: CustomObjects = CustomObjects(gesture: self)
    /// Internal Search
    @objc public var internalSearch: InternalSearch?
    
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
        case 8:
            return "deviceRotate"
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
        case "deviceRotate":
            return 8
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
    override func setParams() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        if let screenName = TechnicalContext.screenName {
            _ = tracker.setParam(HitParam.touchScreen.rawValue, value: screenName, options: encodingOption)
        }
        
        if let level2 = TechnicalContext.level2 {
            _ = tracker.setParam(HitParam.touchLevel2.rawValue, value: level2)
        }
        
        if let l = level2String {
            _ = self.tracker.setParam("s2", value: l)
        }
        
        if let search = self.internalSearch {
            search.tracker = self.tracker
            search.setParams()
        }
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setParams()
        }
        
        
        _ = tracker.setParam("click", value: getActionRawValue(action.rawValue))
            .setParam(HitParam.hitType.rawValue, value: "click")
            .setParam(HitParam.screen.rawValue, value: buildGestureName(), options: encodingOption)
    }
    
    /// Send navigation gesture event
    /// If the gesture is generated by AutoTracking, do not call this function in the gestureWasDetected delegate, otherwise, the gesture will be sent twice.
    @objc public func sendNavigation() {
        self.action = GestureAction.navigate
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send exit gesture event
    /// If the gesture is generated by AutoTracking, do not call this function in the gestureWasDetected delegate, otherwise, the gesture will be sent twice.
    @objc public func sendExit() {
        self.action = GestureAction.exit
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send download gesture event
    /// If the gesture is generated by AutoTracking, do not call this function in the gestureWasDetected delegate, otherwise, the gesture will be sent twice.
    @objc public func sendDownload() {
        self.action = GestureAction.download
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send touch gesture event
    /// If the gesture is generated by AutoTracking, do not call this function in the gestureWasDetected delegate, otherwise, the gesture will be sent twice.
    @objc public func sendTouch() {
        self.action = GestureAction.touch
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send search gesture event
    /// If the gesture is generated by AutoTracking, do not call this function in the gestureWasDetected delegate, otherwise, the gesture will be sent twice.
    @objc public func sendSearch() {
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


/// Wrapper class to manage Gesture instances
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
    
    /// Add a gesture
    ///
    /// - Returns: a new Gesture instance
    @objc public func add() -> Gesture {
        let gesture = Gesture(tracker: tracker)
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /// Add a Gesture with a name
    ///
    /// - Parameter name: Gesture name
    /// - Returns: a new Gesture instance
    @objc public func add(_ name:String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /// Add a gesture with a name and a chapter
    ///
    /// - Parameters:
    ///   - name: Gesture name
    ///   - chapter1: chapter1 label
    /// - Returns: a new Gesture instance
    @objc public func add(_ name: String, chapter1: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /// Add a gesture with a name and chapters
    ///
    /// - Parameters:
    ///   - name: Gesture name
    ///   - chapter1: chapter1 label
    ///   - chapter2: chapter2 label
    /// - Returns: a new Gesture instance
    @objc public func add(_ name: String, chapter1: String, chapter2: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        gesture.chapter2 = chapter2
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
    
    /// Add a gesture with a name and chapters
    ///
    /// - Parameters:
    ///   - name: Gesture name
    ///   - chapter1: chapter1 label
    ///   - chapter2: chapter2 label
    ///   - chapter3: chapter3 label
    /// - Returns: a new Gesture instance
    @objc public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> Gesture {
        let gesture = Gesture(tracker: tracker)
        gesture.name = name
        gesture.chapter1 = chapter1
        gesture.chapter2 = chapter2
        gesture.chapter3 = chapter3
        tracker.businessObjects[gesture.id] = gesture
        
        return gesture
    }
}
