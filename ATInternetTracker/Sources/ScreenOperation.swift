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


import UIKit
import Foundation

/// Class for sending screen event to socket server
class ScreenOperation: Operation {
    
    /// The screen event to be sent
    var screenEvent: ScreenEvent
    
    /**
     ScreenOperation init
     
     - parameter screenEvent: ScreenEvent
     
     - returns: ScreenOperation
     */
    init(screenEvent: ScreenEvent) {
        self.screenEvent = screenEvent
    }

    /**
     function called when the operation runs
     */
    override func main() {
        autoreleasepool {
            let tracker = ATInternet.sharedInstance.defaultTracker
            
            //TODO: sendBuffer
            screenEvent.triggeredBy = UIApplicationContext.sharedInstance.previousEventSent
            
            // Wait a little in order to make this operation cancellable
            Thread.sleep(forTimeInterval: 0.2)
            
            if self.isCancelled {
                return
            }
            
            if(tracker.enableLiveTagging) {
                tracker.socketSender!.sendMessage(screenEvent.description)
            }
            
            if (tracker.enableAutoTracking) {
                if !sendScreenHit(tracker) {
                    tracker.delegate?.warningDidOccur?("hit ignored")
                }
            }
        }
    }
    
    /**
     Send a Screen hit
     
     - parameter tracker: AutoTracker
     */
    func sendScreenHit(_ tracker: AutoTracker) -> Bool {
        let screen = tracker.screens.add(screenEvent.screen)
        let shouldSend = mapConfiguration(screen)
        if shouldSend {
            handleDelegate(screen)
            tracker.buffer.addAutoTrackingContextVariable()
            screen.sendView()
        }
        return shouldSend
    }
    
    /**
     Map the screen with custom information to add
     
     - parameter screen: the screen
     */
    func mapConfiguration(_ screen: Screen) -> Bool {
        waitForConfigurationLoaded()
        
        if let mapping = Configuration.smartSDKMapping {
            if let shouldIgnore = mapping["configuration"]["screens"][screen.className]["ignoreElement"].bool {
                if shouldIgnore {
                    return false
                }
            }
            if let mappedName = mapping["configuration"]["screens"][screen.className]["title"].string {
                screen.name = mappedName
            }
        }
        return true
    }
    
    /**
     Wait for the configuration to be loaded
     */
    func waitForConfigurationLoaded() {
        while(!AutoTracker.isConfigurationLoaded) {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    /**
     Wait for the screen to be ready or until timeout
     
     - parameter screen: the screen
     */
    func handleDelegate(_ screen: Screen) {
        var screen = screen
        
        if hasDelegate() {
            if let s = screenEvent.viewController!.perform(#selector(IAutoTracker.screenWasDetected(_:)), with: screen).takeUnretainedValue() as? Screen {
                screen = s
            } else {
                ATInternet.sharedInstance.defaultTracker.delegate?.warningDidOccur?("The delegate has not returned a screen; \(screen.title) will not be modified.")
            }
        }
    }
    
    /**
     Do the viewcontroller has a AutoTracker Delegate ?
     
     - returns: yes if so
     */
    func hasDelegate() -> Bool {
        var hasDelegate = false
        if let viewController = screenEvent.viewController {
            if viewController.conforms(to: IAutoTracker.self) {
                if viewController.responds(to: #selector(IAutoTracker.screenWasDetected(_:))) {
                    hasDelegate = true
                }
            }
        }
        return hasDelegate
    }
    
}
