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


import UIKit
import Foundation

/// Class for sending gesture event to the socket server
class GestureOperation: Operation {
    
    var gestureEvent: GestureEvent
    
    /// refresh the timer tick
    var timerDuration: TimeInterval = 0.2
    
    /// timer to handle the timeout
    var timerTotalDuration: TimeInterval = 0
    
    /// after timeout, the hit is sent
    let TIMEOUT_OPERATION: TimeInterval = 5
    
    /**
     GestureOperation init
     
     - parameter gestureEvent: gestureEvent
     
     - returns: GestureOperation
     */
    init(gestureEvent: GestureEvent) {
        self.gestureEvent = gestureEvent
    }
    
    /**
     Function that is called when the operation runs
     */
    override func main() {
        autoreleasepool {
            
            let tracker: AutoTracker = ATInternet.sharedInstance.defaultTracker
            
            Thread.sleep(forTimeInterval: 0.2)
            if self.isCancelled {
                return
            }
            
            if tracker.enableLiveTagging {
                UIApplicationContext.sharedInstance.previousEventSent = gestureEvent
                ATInternet.sharedInstance.defaultTracker.socketSender!.sendMessage(gestureEvent.description)
            }
            
            if tracker.enableAutoTracking {
               _ =  sendGestureHit(tracker)
            }
        }
    }
    
    /**
     Send a Gesture Hit
     
     - parameter tracker: AutoTracker
     */
    func sendGestureHit(_ tracker: AutoTracker) -> Bool {
        let gesture = tracker.gestures.add()
        let methodName:String = gestureEvent.methodName
        gesture.name = methodName
        
        if methodName == "handleBack:" {
            gesture.action = .navigate
        }
        
        
        gesture.screen = gestureEvent.currentScreen
        gesture.type = gestureEvent.eventType
        gesture.view = gestureEvent.view
        
        // We pause thread in order to wait if next operation is a screen. If a screen operation is added after gesture operation, then it's a navigation event
        Thread.sleep(forTimeInterval: 0.5)
        
        if let _ = EventManager.sharedInstance.lastScreenEvent() as? ScreenOperation  {
            gesture.action = .navigate
        }
        
        let shouldSendHit = mapConfiguration(gesture)
        if shouldSendHit {
            handleDelegate(gesture)
            tracker.dispatcher.dispatch([gesture])
        }
        
        return shouldSendHit
    }
    
    /**
     Manage the delegate interaction: send the gesture to the uiviewcontroller or wait for timeout
     
     - parameter gesture: the gesture
     */
    func handleDelegate(_ gesture: Gesture) {
        if hasDelegate() {
            self.gestureEvent.viewController!.perform(#selector(IAutoTracker.gestureWasDetected(_:)), with: gesture)
            
            if gesture.isReady {
                return
            }
            while(!gesture.isReady) {
                handleTimer(gesture)
            }
        }
    }
    
    /**
     Check if the current viewcontroller has implemented the AutoTracker delegate
     
     - returns: true if delegate implemented
     */
    func hasDelegate() -> Bool {
        var hasDelegate = false
        
        if let viewController = gestureEvent.viewController {
            if viewController.conforms(to: IAutoTracker.self) {
                if viewController.responds(to: #selector(IAutoTracker.gestureWasDetected(_:))) {
                    hasDelegate = true
                }
            }
        }
        return hasDelegate
    }
    
    /**
     Wait until the gesture is ready to be sent or TIMEOUT
     
     - parameter gesture: the gesture to be sent
     */
    func handleTimer(_ gesture: Gesture) {
        Thread.sleep(forTimeInterval: timerDuration)
        timerTotalDuration = timerTotalDuration + timerDuration
        if timerTotalDuration > TIMEOUT_OPERATION {
            gesture.isReady = true
        }
    }
    
    /**
     Map the gesture attributes if a LiveTagging configuration is given
     
     - parameter gesture: the gesture to map
     */
    func mapConfiguration(_ gesture: Gesture) -> Bool {
        waitForConfigurationLoaded()
        
        if let mapping = Configuration.smartSDKMapping {

            let eventType = Gesture.getEventTypeRawValue(gestureEvent.eventType.rawValue)
            let eventKeyBase = eventType+"."+gestureEvent.direction+"."+gestureEvent.methodName
                let position = gesture.view != nil ? "."+String(gesture.view!.position) : ""
            let view = gesture.view != nil ? "."+gesture.view!.className : ""
            let screen = gesture.screen != nil ? "."+gesture.screen!.className : ""

            class Rule {
                var rule: String
                var value: String
                init(rule: String, value: Int) {
                    self.rule = rule
                    self.value = Gesture.getEventTypeRawValue(value)
                }
            }

            let rules = [
                Rule(rule: "ignoreTap", value: Gesture.GestureEventType.tap.rawValue),
            Rule(rule: "ignoreSwipe", value: Gesture.GestureEventType.swipe.rawValue),
            Rule(rule: "ignoreScroll", value: Gesture.GestureEventType.scroll.rawValue),
            Rule(rule: "ignorePinch", value: Gesture.GestureEventType.pinch.rawValue),
            Rule(rule: "ignorePan", value: Gesture.GestureEventType.pan.rawValue),
            Rule(rule: "ignoreRefresh", value: Gesture.GestureEventType.refresh.rawValue),
        ]

            for oKey in rules {
                if let shouldIgnore = mapping["configuration"]["rules"][oKey.rule].bool {
                    if eventType == oKey.value && shouldIgnore {
                        return false
                    }
                }
            }
            
            /* 9 strings generated */
            let one = eventKeyBase + position + view + screen
            let two = eventKeyBase + position + view
            let tree = eventKeyBase + position
            let four = eventKeyBase + position + screen
            let five = eventKeyBase
            let six = eventKeyBase + view
            let seven = eventKeyBase + screen
            let height = eventKeyBase + view + screen
            let events = [one, two, tree, four, five, six, seven, height]
            
            for aKey in events {
                if let shouldIgnore = mapping["configuration"]["events"][aKey]["ignoreElement"].bool {
                    if shouldIgnore {
                        return false
                    }
                }
                if let mappedName = mapping["configuration"]["events"][aKey]["title"].string {
                    gesture.name = mappedName
                    break
                }
            }
        }
        return true
    }
    
    /**
     Wait for the configuration
     */
    func waitForConfigurationLoaded() {
        while(!AutoTracker.isConfigurationLoaded) {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
}
