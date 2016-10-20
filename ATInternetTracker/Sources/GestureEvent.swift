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

/// Class that represent a gesture event. concrete subclass should be used to represent specific events
class GestureEvent {
    
    /// View contains the gesture
    lazy var view: View = View()
    
    /// Default method name in case we can't find the name of the method
    var defaultMethodName: String
    
    /// Method called by the touched UIView
    var _methodName: String?
    var methodName: String {
        get {
            return _methodName ?? defaultMethodName
        }
        set {
            self.title = newValue
            _methodName = newValue
        }
    }
    
    // Alias
    var title: String?
    
    /// A description of the gesture
    var direction: String
    
    /// current screen
    lazy var currentScreen: Screen = Screen()
    
    /// Event Type
    lazy var eventType: Gesture.GestureEventType = Gesture.GestureEventType.unknown
    
    
    /// View controller of the screen
    weak var viewController: UIViewController?
    
    /// Default description
    var description: String {
        return ""
    }
    
    /**
     Create a new Gesture Event
     
     - parameter type:          EventType enumeration
     - parameter methodName:    Method that triggered the gesture event
     - parameter viewClassName: 
     - parameter direction:
     - parameter currentScreen:
     
     - returns: a gesture event
     */
    init(type: Gesture.GestureEventType, methodName: String?, view: View, direction: String, currentScreen: Screen) {
        self.defaultMethodName = ""
        self._methodName = methodName
        self.title = methodName
        self.direction = direction
        self.currentScreen = currentScreen
        self.view = view
        self.eventType = type
    }
}
