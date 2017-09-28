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

class App {
    static var token: String? = ATInternet.sharedInstance.defaultTracker.token
    
    var toJSONObject: [String: Any] {
        let s = Screen()
        let jsonObj: [String: Any] = [
            "event":"app",
            "data" :[
                "appIcon": TechnicalContext.applicationIcon ?? emptyIcon(),
                "version": TechnicalContext.applicationVersion.isEmpty ? "1" : TechnicalContext.applicationVersion,
                "device" : TechnicalContext.device.isEmpty ? "x86_64" : TechnicalContext.device,
                "token" : App.token ?? "",
                "package" : TechnicalContext.applicationIdentifier,
                "platform":"ios",
                "title": TechnicalContext.applicationName,
                "width": s.width,
                "height": s.height,
                "scale": s.scale,
                "screenOrientation": s.orientation,
                "siteID": getSiteID(),
                "name": UIDevice.current.name
            ]
        ]
        return jsonObj
    }
    
    var description: String {
        return self.toJSONObject.toJSON()
    }
    
    func getSiteID() -> String {
        guard let siteID = ATInternet.sharedInstance.defaultTracker.configuration.parameters["site"] else {
            assert(false, "siteID must be not empty")
            return ""
        }
        assert(siteID != "", "siteID must be not empty")
        
        return siteID
    }
    
    func emptyIcon() -> String {
        guard
            let img = UIImage(named: "emptyIcon", in: Bundle(for: Tracker.self), compatibleWith: nil),
            let b64 = img.toBase64()
        else { return "" }
        
        return b64.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
    }
    
    init() {}
}
