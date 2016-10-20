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

/// Factory making a different class in charge of handling different events
class SocketEventFactory {
    class func create(_ eventName: String, liveManager: LiveNetworkManager, messageData: JSON?) -> SocketEvent {
        switch eventName {
        // triggered after viewDidAppear
        case SmartSocketEvent.Screenshot.rawValue:
            return SEScreenshot(liveManager: liveManager, messageData: messageData)
        // interface requesting a live session
        case SmartSocketEvent.InterfaceAskedForLive.rawValue:
            return SEInterfaceAskedForLive(liveManager: liveManager, messageData: messageData)
        // device decline live (loop from self due to the dispatch broadcast)
        case SmartSocketEvent.InterfaceRefusedLive.rawValue:
            return SEInterfaceRefusedLive(liveManager: liveManager)
        // device ready to go live
        case SmartSocketEvent.InterfaceAcceptedLive.rawValue:
            return SEInterfaceAcceptedLive(liveManager: liveManager)
        // interface request a screenshot from current view
        case SmartSocketEvent.InterfaceAskedForScreenshot.rawValue:
            return SEInterfaceAskedForScreenshot(liveManager: liveManager)
        // interface ends live sessions
        case SmartSocketEvent.InterfaceStoppedLive.rawValue:
            return SEInterfaceStoppedLive(liveManager: liveManager)
        case SmartSocketEvent.InterfaceAbortedLiveRequest.rawValue:
            return SEInterfaceAbortedLiveRequest(liveManager: liveManager)
        default:
            return SocketEvent(liveManager: liveManager)
        }
    }
}

/// Handle all the incoming messages from the websocket
class SocketEvent {
    let liveManager: LiveNetworkManager
    let messageData: JSON?
    
    init(liveManager: LiveNetworkManager, messageData: JSON? = nil) {
        self.liveManager = liveManager
        self.messageData = messageData
    }
    
    func process() {}
    
    /// delay
    ///
    /// - parameter delay:   a delay before executing the closure
    /// - parameter closure: a closure to execute after a delay
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

/// Wait a bit then send a screenshot with screen information and suggested events
class SEScreenshot: SocketEvent {
    func makeJSONArray(_ values: [Any]) -> [Any] {
        if let events = values as? [GestureEvent] {
            return events.map( {$0.description.toJSONObject()!} )
        }
        return []
    }
    
    func isRequestedVCCurrentVC(requestedVC: String?) -> (isCurrent: Bool, foundVC: UIViewController?) {
        if let rvc = requestedVC {
            if let currentViewController = UIViewControllerContext.sharedInstance.currentViewController {
                if currentViewController.classLabel == rvc {
                    return (isCurrent: true, foundVC: currentViewController)
                } else {
                    for viewController in UIViewControllerContext.sharedInstance.activeViewControllers.reversed() {
                        if viewController.classLabel == rvc {
                            return (isCurrent: false, foundVC: viewController)
                        }
                    }
                }
            }
        }
        
        return (isCurrent: false, foundVC: nil)
    }
    
    override func process() {
        
        var controls: [Any] = []
        
        let requestedViewControllerName = messageData?["screen"]["className"].string
        
        // We check whether the uiviewcontroller is still available for screenshot or we try to find it in the navigation stack
        let vc = isRequestedVCCurrentVC(requestedVC: requestedViewControllerName)
        
        if vc.isCurrent {
            controls = self.makeJSONArray(vc.foundVC!.getControls())
        }

        delay(0.5) {
            let screen: Screen
            
            let vc = self.isRequestedVCCurrentVC(requestedVC: requestedViewControllerName)
            
            if vc.isCurrent {
                screen = Screen()
                
                var toIgnore = [UIView]()
                if let toolbar = self.liveManager.toolbar?.toolbar {
                    toIgnore.append(toolbar)
                }
                if let popup = self.liveManager.currentPopupDisplayed {
                    toIgnore.append(popup)
                }
                toIgnore.append(Debugger.sharedInstance.debugButton)
                
                let base64 = UIApplication.shared
                    .keyWindow?
                    .screenshot(toIgnore)?
                    .toBase64()!
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "\r", with: "")
                
                //assert(base64 != nil)
                
                let screenshotEvent = ScreenshotEvent(screen: screen,
                                                      screenshot: base64,
                                                      suggestedEvents: controls)
                
                self.liveManager.sender?.sendMessage(screenshotEvent.description)
            } else {
                
                if let foundVC = vc.foundVC {
                    screen = Screen(fromViewController: foundVC)
                    
                    let screenshotEvent = ScreenshotEvent(screen: screen,
                                                          screenshot: nil,
                                                          suggestedEvents: [])
                    
                    self.liveManager.sender?.sendMessage(screenshotEvent.description)
                }
            }
        }
    }
}
    
/// The BO is asking for a live - display a popup to the user
class SEInterfaceAskedForLive: SocketEvent {
    override func process() {
        let currentVersion = TechnicalContext.applicationVersion.isEmpty ? "" : TechnicalContext.applicationVersion
        if self.messageData != nil && self.messageData!["version"].string != nil && self.messageData!["version"].string != currentVersion {
            liveManager.sender?.sendMessageForce(DeviceVersion().description)
            return
        }
        self.liveManager.interfaceAskedForLive()
    }
}

/// Live Tagging canceled
class SEInterfaceRefusedLive: SocketEvent {
    override func process() {
        self.liveManager.interfaceRefusedLive()
    }
}

/// Live Tagging started
class SEInterfaceAcceptedLive: SocketEvent {
    override func process() {
        self.liveManager.interfaceAcceptedLive()
    }
}

/// BO is requesting a screenshot
class SEInterfaceAskedForScreenshot: SocketEvent {
    override func process() {
        if self.liveManager.networkStatus == .Connected {
            var toIgnore = [UIView]()
            if let toolbar = self.liveManager.toolbar?.toolbar {
                toIgnore.append(toolbar)
            }
            if let popup = self.liveManager.currentPopupDisplayed {
                toIgnore.append(popup)
            }
            toIgnore.append(Debugger.sharedInstance.debugButton)
            
            let base64 = UIApplication.shared
                .keyWindow?
                .screenshot(toIgnore)?
                .toBase64()!
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
            let currentScreen = Screen()
            self.liveManager.sender?.sendMessage(ScreenshotUpdated(screenshot: base64, screen: currentScreen).description)
        }
    }
}

/// Live tagging is canceled
class SEInterfaceStoppedLive: SocketEvent {
    override func process() {
        self.liveManager.interfaceStoppedLive()
    }
}

class SEInterfaceAbortedLiveRequest: SocketEvent {
    override func process() {
        self.liveManager.interfaceAbortedLiveRequest()
    }
}
