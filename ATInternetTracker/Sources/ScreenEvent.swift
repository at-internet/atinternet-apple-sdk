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

/// Class that represent a ScreenEvent (screen apparition)
class ScreenEvent: CustomStringConvertible {
    
    lazy var screen: Screen = Screen()
    
    /// The origin method that created this event
    var methodName: String
    
    /// A description of the event on the screen
    var direction: String
    
    /// the general event type
    let type: String = "screen"
    
    /// Event that made the view controller appear
    var triggeredBy: GestureEvent?
    
    /// View controller of the screen
    weak var viewController: UIViewController?
    
    /// JSON representation of the event
    var description: String {
        var jsonObj: [String: Any] = [
            "event": self.methodName,
            "data":[
                "type" : self.type,
                "methodName": self.methodName,
                "direction": self.direction,
                "triggeredBy":self.triggeredBy?.description.toJSONObject() ?? ""
            ]
        ]
        
        var data = jsonObj["data"] as! [String: Any]
        data.append(self.screen.toJSONObject)
        jsonObj.updateValue(data, forKey: "data")
        
        return jsonObj.toJSON()
    }
    
    // Maj s8: suppression de title - on utilise screen.className a la place
    convenience init(title: String, className: String, triggeredBy: GestureEvent?) {
        self.init(title: title, methodName: "viewDidAppear", className: className, direction: "appear", triggeredBy: triggeredBy)
    }
    
    /**
     create a new screen event
     
     - parameter title:      Title of the screen
     - parameter methodName: Name of the method that triggered the new screen event
     - parameter className:  Name of the uiviewcontroller class
     - parameter direction:  Direction of the event (appear)
     
     - returns: A new ScreenEvent object
     */
    init(title: String, methodName: String, className: String, direction: String, triggeredBy: GestureEvent?) {
        self.methodName = methodName
        self.direction = direction
        self.screen.name = title
        self.screen.className = className
        self.triggeredBy = triggeredBy
    }
}
