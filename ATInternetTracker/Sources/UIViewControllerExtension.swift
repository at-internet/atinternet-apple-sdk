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

class Swizzler {
    var _class: AnyClass
    var _sel1: Selector
    var _sel2: Selector
    
    init(_class: AnyClass, _sel1: Selector, _sel2: Selector){
        self._class = _class
        self._sel1 = _sel1
        self._sel2 = _sel2
    }
}

/// extension of UIViewController: used for detecting screen apparitions
extension UIViewController {
    static var swizzlers = [Swizzler]()
    
    /// Return a title for the screen based on the navBar title, uivc title...
    var screenTitle:String {
        var title = self.title;
        
        if (title == nil || title == "") {
            title = self.navigationController?.navigationBar.topItem?.title
        }
        if (title == nil || title == "") {
            title = self.navigationController?.navigationItem.title;
        }
        
        if (title == nil || title == "") {
            title = self.navigationItem.title;
        }
        
        if (title == nil || title == "") {
            title = self.classLabel
        }
        
        return title ?? "";
    }
    
    /// do not use this method unless you know what you are doing. Enable the swizzling for autotracking
    public class func at_swizzle() {
        if self !== UIViewController.self {
            return
        }
        
        do {
            try self.jr_swizzleMethod(#selector(UIViewController.viewWillTransition(to:with:)),
                                      withMethod: #selector(UIViewController.at_viewWillTransitionToSize(_:withTransitionCoordinator:)))
            try self.jr_swizzleMethod(#selector(UIViewController.viewDidAppear(_:)), withMethod: #selector(UIViewController.at_viewDidAppear(_:)))
            try self.jr_swizzleMethod(#selector(UIViewController.viewDidDisappear(_:)), withMethod: #selector(UIViewController.at_viewDidDisappear(_:)))
            try self.jr_swizzleMethod(#selector(UIViewController.viewWillDisappear(_:)), withMethod: #selector(UIViewController.at_viewWillDisappear(_:)))
            try self.jr_swizzleMethod(#selector(UIViewController.viewDidLoad), withMethod: #selector(UIViewController.at_viewDidLoad))
        } catch {
            NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
        }
    }
    
    func at_swizzle_instance(_ name: Selector, name2: Selector, selfClass: AnyClass) {
        if UIViewController.swizzlers.contains(where: {$0._class == selfClass && name.description == $0._sel1.description}) {
            return
        }
        let swizzle = Swizzler(_class: selfClass, _sel1: name, _sel2: name2)
        UIViewController.swizzlers.append(swizzle)
        guard
            let orig = class_getInstanceMethod(selfClass, name),
            let replace = class_getInstanceMethod(selfClass, name2)
        else {
            print("tracker at_swizzle_instance failed")
            return
        }
        method_exchangeImplementations(orig, replace)
    }
    
    @objc func at_previewingContext(_ previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        UIViewControllerContext.sharedInstance.isPeekAndPoped = true
        self.at_previewingContext(previewingContext, commitViewController: viewControllerToCommit)
    }
    
    @objc func at_previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        UIViewControllerContext.sharedInstance.isPeek = true
        return self.at_previewingContext(previewingContext, viewControllerForLocation: location)
    }
    
    @objc func at_viewWillTransitionToSize(_ size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let oldOrientation = UIViewControllerContext.sharedInstance.currentOrientation
        if size.width < size.height {
            if oldOrientation != .portrait {
                UIViewControllerContext.sharedInstance.currentOrientation = .portrait
                EventManager.sharedInstance.addEvent(ScreenRotationOperation(rotationEvent: ScreenRotationEvent(orientation: UIViewControllerContext.sharedInstance.currentOrientation)))
            }
        } else {
            if oldOrientation != .landscape {
                UIViewControllerContext.sharedInstance.currentOrientation = .landscape
                EventManager.sharedInstance.addEvent(ScreenRotationOperation(rotationEvent: ScreenRotationEvent(orientation: UIViewControllerContext.sharedInstance.currentOrientation)))
            }
        }
        
        self.at_viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    @objc func at_viewDidLoad() {
        guard let selfClass: AnyClass = object_getClass(self) else {
            return
        }
        guard let previewProtocol = NSProtocolFromString("UIViewControllerPreviewingDelegate") else {
            return
        }
        if selfClass.conforms(to: previewProtocol){
            var mc:CUnsignedInt = 0
            var mlist = class_copyMethodList(selfClass, &mc);
            for _ in 0...mc {
                if let pointee = mlist?.pointee {
                    let name = method_getName(pointee)
                    mlist = mlist?.successor()
                    if name.description == "previewingContext:commitViewController:" {
                        let s = #selector(UIViewController.at_previewingContext(_:commitViewController:))
                        at_swizzle_instance(name, name2: s, selfClass: selfClass)
                    }
                    if name.description == "previewingContext:viewControllerForLocation:" {
                        let s = #selector(UIViewController.at_previewingContext(_:viewControllerForLocation:))
                        at_swizzle_instance(name, name2: s, selfClass: selfClass)
                    }
                }
            }
        }
        self.at_viewDidLoad()
    }
    
    /// do not use this method unless you know what you are doing. Disable the swizzling for autotracking
    public class func at_unswizzle_instances () {
        for s in swizzlers {
            guard
                let orig = class_getInstanceMethod(s._class, s._sel1),
                let replace = class_getInstanceMethod(s._class, s._sel2)
            else {
                print("Tracker unswizzle failure")
                return
            }
            method_exchangeImplementations(orig, replace)
        }
        swizzlers.removeAll()
    }
    
    /**
     Catching the screen events here
     
     - parameter animated: not related
     */
    @objc func at_viewDidAppear(_ animated: Bool) {
        // reset the screen context
        TechnicalContext.screenName = ""
        TechnicalContext.level2 = 0
        
        if shouldIgnoreViewController() {
            at_viewDidAppear(animated)
            return
        }
        
        let now = Date().timeIntervalSinceNow
        let context = UIViewControllerContext.sharedInstance
        
        context.activeViewControllers.append(self)
        let screenEvent = ScreenEvent(title: self.screenTitle, className: self.classLabel, triggeredBy: nil)
        screenEvent.viewController = self
        
        let operation = ScreenOperation(screenEvent: screenEvent)
        
        if now - context.viewAppearedTime <= 0.1 {
            EventManager.sharedInstance.cancelLastScreenEvent()
        }
        
        context.viewAppearedTime = now
        EventManager.sharedInstance.addEvent(operation)
        
        at_viewDidAppear(animated)
    }
    
    /**
     Check whether a UIViewContoller should be ignored from the Event detection
     we have to ignore some protocol too
     
     - returns: true if the uiviewcontroller must be ignored, false otherwise
     */
    func shouldIgnoreViewController() -> Bool {
        let context = UIViewControllerContext.sharedInstance
        
        for protocolType in context.UIProtocolToIgnore {
            if let type = protocolType {
                if self.conforms(to: type) {
                    return true
                }
            }
        }
        
        for classType in context.UIClassToIgnore {
            if let type = classType {
                if self.isKind(of: type) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /**
     Catches the viewWillDisappear event
     
     - parameter animated: animated
     */
    @objc func at_viewWillDisappear(_ animated: Bool) {
        self.at_viewWillDisappear(animated)
        
        if UIViewControllerContext.sharedInstance.isPeek {
            if let operation = EventManager.sharedInstance.lastEvent() as? GestureOperation {
                let pendingEvent = operation.gestureEvent
                EventManager.sharedInstance.cancelLastEvent()
                pendingEvent.methodName = "Peek:"
                EventManager.sharedInstance.addEvent(GestureOperation(gestureEvent: pendingEvent))
            }
            UIViewControllerContext.sharedInstance.isPeek = false
        }
        
        // User did tap on back button ?
        if self.isMovingFromParentViewController {
            if let operation = EventManager.sharedInstance.lastEvent() as? GestureOperation {
                if operation.gestureEvent.view.className == "UINavigationBar" {
                    let pendingEvent = operation.gestureEvent
                    EventManager.sharedInstance.cancelLastEvent()
                    pendingEvent.methodName = "handleBack:"
                    if pendingEvent.view.text.isEmpty {
                        pendingEvent.view.text = "Back"
                    }
                    
                    EventManager.sharedInstance.addEvent(GestureOperation(gestureEvent: pendingEvent))
                }
            }
        }
    }
    
    /**
     Called when a uiviewcontroller disappeared on the phone
     
     - parameter animated: not related (how the VC is transitioning)
     */
    @objc func at_viewDidDisappear(_ animated: Bool) {
        let context = UIViewControllerContext.sharedInstance
        
        for i in (0 ..< context.activeViewControllers.count).reversed() {
            if self == context.activeViewControllers[i] {
                context.activeViewControllers.remove(at: i)
                break
            }
        }
        
        at_viewDidDisappear(animated)
    }
    
    /**
     return the possible gesture events detected in the current view controller
     those are going to be the "suggested events" feature
     
     - returns: GestureEvent array
     */
    func getControls() -> [GestureEvent] {
        var controls:[UIView] = []
        var events: [GestureEvent] = []
        // 3 steps : ViewController, NavBar, TabBar
        getControlsInView(self.view, allControls: &controls)
        if let navigationController = self.navigationController {
            getControlsInView(navigationController.navigationBar, allControls: &controls)
        }
        if let tabBarController = self.tabBarController {
            getControlsInView(tabBarController.tabBar, allControls: &controls)
        }
        
        let currentScreen = Screen()
        for aView in controls {
            let v = View(view: aView)
            var (text,methodName,className,position) = UIApplication.shared.getTouchedViewInfo(aView)
            let info = ATGestureRecognizer.getInfoFrom(aView, withExpected: Gesture.getEventTypeRawValue(Gesture.GestureEventType.tap.rawValue))
            
            if methodName == nil || (methodName != nil && methodName!.isEmpty) {
                methodName = info?["action"] as? String
                if methodName == nil || (methodName != nil && methodName!.isEmpty) {
                    methodName = UIApplicationContext.sharedInstance.getDefaultViewMethod(aView)
                    // the object does not respond to anything
                    if methodName == nil || (methodName != nil && methodName!.isEmpty) {
                        continue
                    }
                }
            }
            
            let tap = TapEvent(x:-1, y:-1, view: v, direction:"single", currentScreen: currentScreen, methodName: methodName)

            if let _ = className {
                tap.view.className = className!
            }
            if let _ = text {
                tap.view.text = text!
            }
            if let _ = position {
                tap.view.position = position!
            }
            
            // In case of an UISegmentedControl we have to create X events (X=subsegment number)
            if let segmented =  aView as? UISegmentedControl {
                let nb = segmented.numberOfSegments
                let segments = segmented.value(forKey: "segments") as! [UIView]
                for i in 0..<nb {
                    let aTap = TapEvent(x: -1, y: -1, view: View(view: segments[i]), direction: "single", currentScreen: currentScreen, methodName: tap.methodName)
                    aTap.view.position = i
                    aTap.view.text = segmented.titleForSegment(at: i) ?? ""
                    events.append(aTap)
                }
            }
            else if let _ = aView as? UIRefreshControl {
                let refreshControl = RefreshEvent(method: methodName, view: View(view: aView), currentScreen: currentScreen)
                events.append(refreshControl)
            }
            else {
                events.append(tap)
            }
        }
        return events
    }
    
    /**
     Parse the uiview to get all the uicontrols available
     part of the "suggested events" feature
     note: the initial call should pass the current uiwindow as first parameter and a ref to an array as a second parameter
     POSSIBLE KAIZEN => Move to UIViewExtension
     
     - parameter root:        the root uiview to be parsed
     - parameter allControls: the uicontrol array
     */
    func getControlsInView(_ root: UIView, allControls:inout [UIView]) {
        if root is UIControl && !root.isInTableViewCellIgnoreControl {
            allControls.append(root)
        }
        else {
            root.subviews.forEach({getControlsInView($0, allControls: &allControls)})
        }
    }
}
