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
class DeviceRotationOperation: Operation {
    
    /// The screen event to be sent
    var rotationEvent: DeviceRotationEvent
    
    /// timer to handle the timeout
    var timerTotalDuration: TimeInterval = 0
    
    /// after timeout, the hit is sent
    let TIMEOUT_OPERATION: TimeInterval = 5
    
    var timerDuration: TimeInterval = 0.2
    
    /**
     RotationOperation init
     
     - parameter rotationEvent: rotationEvent
     
     - returns: RotationOperation
     */
    init(rotationEvent: DeviceRotationEvent) {
        self.rotationEvent = rotationEvent
    }
    
    override func main() {
        autoreleasepool {
            let tracker = ATInternet.sharedInstance.defaultTracker
            
            Thread.sleep(forTimeInterval: 0.2)
            if self.isCancelled {
                return
            }
            
            if tracker.enableAutoTracking {
                sendRotationHit(tracker)
            }
        }
    }
    
    /**
     Send a Gesture Hit
     
     - parameter tracker: AutoTracker
     */
    func sendRotationHit(_ tracker: AutoTracker) {
        let rotationGesture = tracker.gestures.add()
        rotationGesture.name = rotationEvent.methodName
        
        rotationGesture.screen = rotationEvent.currentScreen
        rotationGesture.type = rotationEvent.eventType
        _ = rotationGesture.customObjects.add(["deviceOrientation":tracker.orientation!.rawValue, "interfaceOrientation": UIApplication.shared.statusBarOrientation.rawValue])

        let shouldSendHit = mapConfiguration(rotationGesture)
        if shouldSendHit {
            handleDelegate(rotationGesture)
            tracker.dispatcher.dispatch([rotationGesture])
        }
    }
    
    /**
     Manage the delegate interaction: send the gesture to the uiviewcontroller or wait for timeout
     
     - parameter gesture: the gesture
     */
    func handleDelegate(_ gesture: Gesture) {
        if hasDelegate() {
            self.rotationEvent.viewController!.perform(#selector(IAutoTracker.gestureWasDetected(_:)), with: gesture)
            
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
        
        if let viewController = self.rotationEvent.viewController {
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
            let eventType = Gesture.getEventTypeRawValue(rotationEvent.eventType.rawValue)
            class Rule {
                var rule: String
                var value: String
                init(rule: String, value: Int) {
                    self.rule = rule
                    self.value = Gesture.getEventTypeRawValue(value)
                }
            }
            let rule = Rule(rule: "ignoreRotate", value: Gesture.GestureEventType.rotate.rawValue)
            if let shouldIgnore = mapping["configuration"]["rules"][rule.rule].bool {
                if eventType == rule.value && shouldIgnore {
                    return false
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
