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

/// ScreenshotEvent - this class handle the screenshot of a screen and the event detected in the screen to display them as *suggested*
class ScreenshotEvent: CustomStringConvertible {
    /// Default method name
    let methodName = "screenshot"
    /// the screen associated
    let screen: Screen
    /// Base64 Screenshot - can be a hardcoded one if we detect that the screenshot is broken
    let screenshot: String?
    /// the suggested events on the screen
    let suggestedEvents: [Any]
    
    /// JSON formatting
    var description: String {
        var jsonObj: [String: Any] = [
            "event": self.methodName,
            "data":[
                "siteID": ATInternet.sharedInstance.defaultTracker.configuration.parameters["site"]!
            ]
        ]
        
        var data = jsonObj["data"] as! [String: Any]
        data.append(self.screen.toJSONObject)
        if screenshot != nil {
            data["screenshot"] = screenshot!
        }
        data["tree"] = self.suggestedEvents
        jsonObj.updateValue(data, forKey: "data")
    
        return jsonObj.toJSON()
    }
    
    /**
     Init a screenshot event
     
     - parameter screen:          the screen to be screened
     - parameter screenshot:      the screenshot associated with the screen
     - parameter suggestedEvents: the suggested events on the screen
     
     - returns: the ScreenshotEvent
     */
    init(screen: Screen, screenshot: String?, suggestedEvents: [Any]) {
        self.screen = screen
        self.screenshot = screenshot
        self.suggestedEvents = suggestedEvents
    }
}
