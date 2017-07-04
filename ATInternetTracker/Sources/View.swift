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

/// Class representing the view that was touched by a user
public class View: NSObject {
    
    /// The subclass name of the touched UIView
    public var className: String
    
    /// X coordinates
    public var x: Float
    
    /// Y coordinates
    public var y: Float
    
    /// View width
    public var width: Float
    
    /// View height
    public var height: Float
    
    /// Text in view
    public var text: String
    
    /// Visibility of the view 
    public var visible: Bool
    
    /// position of the element in a list, tabbar...
    public var position:Int = -1
    
    /// Screenshot encoded in base64
    lazy var screenshot: String = ""
    
    /// Path to the view
    lazy var path: String = ""
    
    /// JSON description
    public override var description: String {
        return toJSONObject.toJSON()
    }
    
    var toJSONObject: [String: Any] {
        let jsonObj: [String: Any] = [
            "view":[
                "className": self.className,
                "x": self.x,
                "y": self.y,
                "width": self.width,
                "height": self.height,
                "text": self.text,
                "path": self.path,
                "screenshot": self.screenshot,
                "visible": self.visible,
                "position": self.position
            ]
        ]
        return jsonObj
    }
    
    /**
     Default init
     */
    override convenience init() {
        self.init(view: UIApplicationContext.sharedInstance.currentTouchedView)
    }
    
    /**
     Init with a uiview
     - parameter view: the uiview that going to be associated with the View
     */
    init(view: UIView?) {
        if let v = view {
            self.className = v.classLabel
            let newFrame = v.convert(v.bounds, to: nil)
            self.x = Float(newFrame.origin.x)
            self.y = Float(newFrame.origin.y)
            self.width = Float(newFrame.width)
            self.height = Float(newFrame.height)
            self.text = v.findText(UIApplicationContext.sharedInstance.initialTouchPosition) ?? ""
            self.visible = (v.isHidden || v.alpha == 0)
            super.init()
            self.path = v.path
        } else {
            self.className = ""
            self.x = 0
            self.y = 0
            self.width = 0
            self.height = 0
            self.text = ""
            self.visible = true
            super.init()
        }
    }
}
