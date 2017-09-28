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


import Foundation
import UIKit

extension UISwitch {
    /**
     *  Singleton
     */
    struct Static {
        static var token: String = UUID().uuidString
    }
    
    /**
     UISwitch init
     
     - returns: UISwitch
     */
    public class func at_swizzle() {
        if self !== UISwitch.self {
            return
        }
        
        DispatchQueue.once(token: Static.token) {
            do {
                try self.jr_swizzleMethod(#selector(UIResponder.touchesEnded), withMethod: #selector(UISwitch.at_touchesEnded(_:withEvent:)))
            } catch {
                NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
            }
        }
    }
    
    /**
     Unswizzle
     */
    public class func at_unswizzle() {
        if self !== UISwitch.self {
            return
        }
        
        DispatchQueue.once(token: Static.token) {
            do {
                try self.jr_swizzleMethod(#selector(UISwitch.at_touchesEnded(_:withEvent:)), withMethod: #selector(UIResponder.touchesEnded))
            } catch {
                NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
            }
        }
    }
    
    /**
     Catches the touchesEnded event
     
     - parameter touches: touches
     - parameter event:   event
     */
    @objc func at_touchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent) {
        let _ = UIApplicationContext.sharedInstance
        let touch = touches.first
        let touchPoint = touch?.location(in: nil)
        let lastOperation = EventManager.sharedInstance.lastEvent() as? GestureOperation
        
        at_touchesEnded(touches, withEvent: event)
        
        if let operation = lastOperation {
            if operation.gestureEvent.eventType == Gesture.GestureEventType.tap {
                if let touchLocation = touchPoint {
                    let gesture = operation.gestureEvent as! TapEvent
                    if gesture.x == Float(touchLocation.x) && gesture.y == Float(touchLocation.y) {
                        operation.cancel()
                    }
                    
                    gesture.view.text = self.isOn ? "On" : "Off"
                    gesture.view.className = self.classLabel
                    gesture.view.path = self.path
                    gesture.methodName = "setOn:"
                    
                    if let screenshot = self.screenshot() {
                        if let b64 = screenshot.toBase64() {
                            gesture.view.screenshot = b64.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
                        }
                    }
                    
                    let (_,mehodName,_,_) = UIApplication.shared.getTouchedViewInfo(self)
                    if let method = mehodName {
                        gesture.methodName = method
                    }
                    EventManager.sharedInstance.addEvent(GestureOperation(gestureEvent: gesture))
                }
            }
        }
    }
}
