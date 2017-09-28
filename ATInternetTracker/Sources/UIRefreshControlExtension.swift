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

extension UIRefreshControl {
    /**
     *  Singleton
     */
    struct Static {
        static var token: String = UUID().uuidString
    }
    
    
    /**
     Initialize: called once at the runtime
     in swift you have to init the swizzling from this method
     */
    public class func at_swizzle() {
        if self !== UIRefreshControl.self {
            return
        }
        
        DispatchQueue.once(token: Static.token) {
            guard
            // Get the "- (id)initWithFrame:" method.
            let original = class_getInstanceMethod(self, #selector(UIRefreshControl.init as () -> UIRefreshControl)),
            // Get the "- (id)swizzled_initWithFrame:" method.
            let swizzle = class_getInstanceMethod(self, #selector(UIRefreshControl.at_init))
            else {
                print("Tracker at_swizzle failed")
                return
            }
            // Swap their implementations.
            method_exchangeImplementations(original, swizzle)
            do {
                try self.jr_swizzleMethod(#selector(UIRefreshControl.beginRefreshing), withMethod: #selector(UIRefreshControl.at_beginRefreshing))
                try self.jr_swizzleMethod(#selector(UIView.init(frame:)), withMethod: #selector(UIRefreshControl.at_initWithFrame(_:)))
            } catch {
                NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
            }
        }
    }

    
    /**
 */
    public class func at_unswizzle() {
        if self !== UIRefreshControl.self {
            return
        }
        
        DispatchQueue.once(token: Static.token) {
            guard
            // Get the "- (id)initWithFrame:" method.
            let original = class_getInstanceMethod(self, #selector(UIRefreshControl.init as () -> UIRefreshControl)),
            // Get the "- (id)swizzled_initWithFrame:" method.
            let swizzle = class_getInstanceMethod(self, #selector(UIRefreshControl.at_init))
            else {
                print("at_unswizzle failed")
                return
            }
            // Swap their implementations.
            method_exchangeImplementations(swizzle, original)
            do {
                try self.jr_swizzleMethod(#selector(UIRefreshControl.at_beginRefreshing), withMethod: #selector(UIRefreshControl.beginRefreshing))
                try self.jr_swizzleMethod(#selector(UIRefreshControl.at_initWithFrame(_:)), withMethod: #selector(UIView.init(frame:)))
            } catch {
                NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
            }
        }
    }
    
    @objc func at_init() -> Any {
        self.addTarget(self, action: #selector(UIRefreshControl.at_refresh), for: UIControlEvents.valueChanged)
        return self.at_init()
    }
    
    @objc func at_refresh () {
        let lastOperation = EventManager.sharedInstance.lastEvent() as? GestureOperation
        let appContext = UIApplicationContext.sharedInstance
        
        if let operation = lastOperation {
            if operation.gestureEvent.eventType == Gesture.GestureEventType.scroll  {
                let gesture = operation.gestureEvent as! ScrollEvent
                operation.cancel()
                gesture.view.className = self.classLabel
                gesture.view.path = self.path
                gesture.view.position = -1
                gesture.direction = "down"
                gesture.eventType = Gesture.GestureEventType.refresh
                
                appContext.eventType = Gesture.GestureEventType.refresh
                appContext.initalTouchTime = Date().timeIntervalSinceNow
                
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
        else {
            appContext.eventType = Gesture.GestureEventType.refresh
            appContext.initalTouchTime = Date().timeIntervalSinceNow
            
            let (_,methodName,_,_) = UIApplication.shared.getTouchedViewInfo(self)
            let selfView = View(view: self)
            let currentScreen = Screen()
            let refreshEvent = RefreshEvent(method: methodName, view: selfView, currentScreen: currentScreen)
            EventManager.sharedInstance.addEvent(GestureOperation(gestureEvent: refreshEvent))
        }
        
        clearContext();
    }
    
    func clearContext() {
        let appContext = UIApplicationContext.sharedInstance
        appContext.previousTouchTime = appContext.initalTouchTime
        appContext.previousEventType = appContext.eventType
        appContext.initialTouchPosition = CGPoint.zero
        appContext.initalTouchTime = Date().timeIntervalSinceNow
        appContext.initialPinchDistance = 0
        appContext.rotationObject = nil
        appContext.initialTouchedView = nil
    }

    
    @objc func at_initWithFrame(_ frame: CGRect) {
        self.at_initWithFrame(frame)
    }
    
    @objc func at_beginRefreshing() {
        self.at_beginRefreshing()
    }    
}
