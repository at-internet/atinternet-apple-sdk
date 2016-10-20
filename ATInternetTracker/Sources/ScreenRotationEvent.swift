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

/// Object used for manage screen rotation events. Note that face up and face down are ignored at runtime
class ScreenRotationEvent {
    /// Method called by the touched UIView
    lazy var methodName = "rotate"
    
    /// A description of the gesture
    var orientation: UIViewControllerContext.UIViewControllerOrientation
    
    /// current screen
    lazy var currentScreen: Screen = Screen()
    
    /// the general event type
    let type: String = "screen"
    
    /// JSON description
    var description: String {
        var jsonObj: [String: Any] = [
            "event": "screenRotation",
            "data":[
                "name": self.currentScreen.name,
                "type" : self.type,
                "className": self.currentScreen.className,
                "methodName": self.methodName,
                "direction": self.orientation.rawValue,
                "triggeredBy": ""
            ]
        ]
        
        var data = jsonObj["data"] as! [String: Any]
        data.append(self.currentScreen.toJSONObject)
        jsonObj.updateValue(data, forKey: "data")

        return jsonObj.toJSON()
    }

    /**
     RotationEvent init
     
     - parameter orientation: device orientation
     
     - returns: RotationEvent
     */
    init(orientation: UIViewControllerContext.UIViewControllerOrientation) {
        self.orientation = orientation
    }
}
