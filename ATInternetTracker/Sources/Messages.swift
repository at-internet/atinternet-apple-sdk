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

/// Mostly static messages for the websocket

/// Device ask for a live
class DeviceAskingForLive {
    var description: String {
        let askForLive: NSMutableDictionary = [
            "event": "DeviceAskedForLive",
            "data": App().toJSONObject["data"]!
        ]
        return askForLive.toJSON()
    }
}

/// Device refuse a live
class DeviceRefusedLive {
    var description: String {
        let deviceRefusedLive: NSMutableDictionary = [
            "event": "DeviceRefusedLive",
            "data": [
                "token": ATInternet.sharedInstance.defaultTracker.token ?? "0"
            ]
        ]
        return deviceRefusedLive.toJSON()
    }
}

/// Device abort a live
class DeviceAbortedLiveRequest {
    var description: String {
        let deviceAbortedLiveRequest: NSMutableDictionary = [
            "event": "DeviceAbortedLiveRequest",
            "data": [
                "token": ATInternet.sharedInstance.defaultTracker.token ?? "0"
            ]
        ]
        return deviceAbortedLiveRequest.toJSON()
    }
}

/// Device stop a live
class DeviceStoppedLive {
    var description: String {
        let deviceStoppedLive: NSMutableDictionary = [
            "event": "DeviceStoppedLive",
            "data": [
                "token": ATInternet.sharedInstance.defaultTracker.token ?? "0"
            ]
        ]
        return deviceStoppedLive.toJSON()
    }
}

/// Device accept the live
class DeviceAcceptedLive {
    var description: String {
        let deviceAcceptedLive: NSMutableDictionary = [
            "event": "DeviceAcceptedLive",
            "data": [
                "token": ATInternet.sharedInstance.defaultTracker.token ?? "0"
            ]
        ]
        return deviceAcceptedLive.toJSON()
    }
}

/// Send a fresh screenshot for the current screen
class ScreenshotUpdated {
    let screenshot:String
    let currentScreen: Screen
    
    init(screenshot: String?, screen: Screen) {
        //assert(screenshot != nil)
        self.screenshot = screenshot ?? ""
        self.currentScreen = screen
    }
    
    var description: String {
        let refreshScreenshot: NSMutableDictionary = [
            "event": "ScreenshotUpdated",
            "data": [
                "screenshot":self.screenshot,
                "siteID": ATInternet.sharedInstance.defaultTracker.configuration.parameters["site"]!
            ]
        ]
        let data = refreshScreenshot.objectForKey("data")?.mutableCopy() as! NSMutableDictionary
        data.addEntriesFromDictionary(self.currentScreen.description.toJSONObject() as! [NSObject: AnyObject])
        refreshScreenshot.setValue(data, forKey: "data")
        return refreshScreenshot.toJSON()
    }
}

/// Device sends its version
class DeviceVersion {
    var description: String {
        let deviceVersion: NSMutableDictionary = [
            "event": "DeviceVersion",
            "data": App().toJSONObject["data"]!
        ]
        return deviceVersion.toJSON()
    }
}

/// Device sends its data
class DeviceTokenAlreadyUsed {
    var description: String {
        let deviceTokenAlreadyUsed: NSMutableDictionary = [
            "event": "DeviceTokenAlreadyUsed",
            "data": App().toJSONObject["data"]!
        ]
        return deviceTokenAlreadyUsed.toJSON()
    }
}

