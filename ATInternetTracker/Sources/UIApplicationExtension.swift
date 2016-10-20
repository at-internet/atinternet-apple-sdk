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

extension UIApplication {
    
    /**
     *  Singleton
     */
    struct Static {
        static let token: String = UUID().uuidString
        static let HorizontalSwipeDragMin   = 50.0
        static let VerticalSwipeDragMax     = 50.0
        static let MaxMoveTimeInterval      = 0.7
        static let PinchDragMin             = 1.0
        static let MinimumRotation: CGFloat = 35.0
    }
    
    /**
     Initialize: called once at the runtime
     in swift you have to init the swizzling from this method
     */
    public class func at_swizzle() {
        
        DispatchQueue.once(token: Static.token) {
            do {
                try self.jr_swizzleMethod(#selector(UIApplication.sendEvent(_:)), withMethod: #selector(UIApplication.at_sendEvent(_:)))
                
            } catch {
                NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
            }
        }
    }
    
    /**
     Unswizzle method
     */
    public class func at_unswizzle() {
        DispatchQueue.once(token: Static.token) {
            do {
                try self.jr_swizzleMethod(#selector(UIApplication.at_sendEvent(_:)), withMethod: #selector(UIApplication.sendEvent(_:)))
            } catch {
                NSException(name: NSExceptionName(rawValue: "SwizzleException"), reason: "Impossible to find method to swizzle", userInfo: nil).raise()
            }
        }
    }
    
    /**
     Custom send event method (swizzled)
     
     - parameter event: UIEvent
     */
    func at_sendEvent(_ event: UIEvent) {
        // sometimes we need to wait the end of the event in order
        // to get a correct capture (uiswitch, uislider...)
        if shouldSendNow() {
            queueEvent(event)
            at_sendEvent(event)
        } else {
            at_sendEvent(event)
            queueEvent(event)
        }
    }
    
    /**
     Get the current event type/text/method/...
     and send it to the sender queue
     
     - parameter event: the UIEvent from sendEvent:
     */
    func queueEvent(_ event: UIEvent) {
        let gestureEvent = gestureFromEvent(event)
        
        if let gesture = gestureEvent {
            if !ATInternet.sharedInstance.defaultTracker.debug {
                fillWithScreenshot(gesture)
            }
            
            gesture.viewController = UIViewControllerContext.sharedInstance.currentViewController
            EventManager.sharedInstance.addEvent(GestureOperation(gestureEvent: gesture))
        }
    }
    
    /**
     Takes a screenshot of the current touched view
     
     - parameter gesture: Gesture event
     */
    func fillWithScreenshot(_ gesture: GestureEvent) {
        let optImage = UIApplicationContext.sharedInstance.currentTouchedView?.screenshot()
        if let image = optImage {
            if let b64 = image.toBase64() {
                gesture.view.screenshot = b64.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
            }
        }
    }
    
    /**
     Checks wheter the event must be sent before or after the call of the sendEvent: method
     
     - returns: Bool
     */
    func shouldSendNow() -> Bool {
        let ctx = UIApplicationContext.sharedInstance
        if let view = ctx.currentTouchedView {
            if  view.type == UIApplicationContext.ViewType.button ||
                view.type == UIApplicationContext.ViewType.tableViewCell ||
                view.type == UIApplicationContext.ViewType.textField ||
                view.type == UIApplicationContext.ViewType.navigationBar ||
                view.type == UIApplicationContext.ViewType.backButton ||
                view.type == UIApplicationContext.ViewType.collectionViewCell ||
                view.type == UIApplicationContext.ViewType.unknown
            {
                return true
            }
        }
        return false
    }
    
    /**
     Gesture detection: this method is called each time an event is detected.
     this method is called several times per moves with different parameters
     (phase state began/moved/ended, number of fingers...)
     
     - parameter event: UIEvent
     
     - returns: GestureEvent detected
     */
    func gestureFromEvent(_ event: UIEvent) -> GestureEvent? {
        guard let touches = event.allTouches else {
            return nil
        }
        
        if event.type == UIEventType.touches {
            let appContext = UIApplicationContext.sharedInstance
            
            guard let touch = touches.first else {
                return nil
            }
            
            if touch.phase == UITouchPhase.began {
                initContext(touches)
                if isDoubleTap(touches) {
                    EventManager.sharedInstance.cancelLastEvent()
                }
            }
            else if touch.phase == UITouchPhase.moved {
                if touches.count == 1 {
                    let currentPos = touch.location(in: nil)
                    let xDelta = fabs(appContext.initialTouchPosition.x - currentPos.x)
                    let yDelta = fabs(appContext.initialTouchPosition.y - currentPos.y)
                    
                    if  isSwipe(xDelta, yDelta: yDelta) {
                        appContext.eventType = Gesture.GestureEventType.swipe
                    }
                    else if isScroll(xDelta, yDelta: yDelta) {
                        appContext.eventType = Gesture.GestureEventType.scroll
                    }
                    else if isTap(xDelta, yDelta: yDelta) {
                       appContext.eventType = Gesture.GestureEventType.tap
                    }
                    else {
                        if #available(iOS 9.0, *) {
                            if touch.force/touch.maximumPossibleForce > 0.5 {
                                appContext.eventType = Gesture.GestureEventType.tap
                            }
                        } else {
                            appContext.eventType = Gesture.GestureEventType.unknown
                        }
                    }
                } else if touches.count == 2 {
                    if isRotation(touches as NSSet) {
                        appContext.eventType = Gesture.GestureEventType.rotate
                    } else {
                        appContext.eventType = Gesture.GestureEventType.pinch
                    }
                }
            }
            else if touch.phase == UITouchPhase.ended {
                if appContext.currentTouchedView == nil {
                    return nil
                }
                
                // sometimes we have unwanted taps or double taps moves after pinch/rotation
                if((appContext.previousEventType == Gesture.GestureEventType.pinch || appContext.previousEventType == Gesture.GestureEventType.rotate || appContext.previousEventType == Gesture.GestureEventType.refresh) && appContext.initalTouchTime! - appContext.previousTouchTime! < 0.1) {

                    return nil
                }
                
                // Remove noise from the toolbar or any SmartTracker events (pairing...)
                if shouldIgnoreView(appContext.currentTouchedView!) {
                    return nil
                }
                
                var gestureEvent: GestureEvent?
                var eventType = appContext.eventType
                var methodName: String?
                
                // get method from action
                let (infoText, infoMethodName, infoClassName, position) = getTouchedViewInfo(appContext.currentTouchedView!)
                let touchedView = getTouchedView(touches)
                var tag: Int = (position != nil) ? position! : 0
                
                if let t = touchedView {
                    if t.tag > 0 {
                        tag = t.tag
                    }
                }
                
                methodName = infoMethodName
                
                /// Try to get a more precise event type by looking at target/action from gesturerecognizers attached to the current view
                if let info = ATGestureRecognizer.getInfo(touches, eventType: Gesture.getEventTypeRawValue(appContext.eventType.rawValue)) {
                    
                    if((info["eventType"]) != nil) {
                        eventType = Gesture.GestureEventType(rawValue: Gesture.getEventTypeIntValue(info["eventType"] as! String))!
                    }
                    
                    if (methodName == nil) || (methodName != nil && methodName!.isEmpty) {
                        methodName = info["action"] as? String
                        
                        if (methodName == nil) || (methodName != nil && methodName!.isEmpty) {
                            methodName = UIApplicationContext.sharedInstance.getDefaultViewMethod(appContext.currentTouchedView)
                            // the object does not respond to anything
                            if methodName == nil {
                                //clearContext()
                                return nil
                            }
                        } else {
                            // Force currentTouchedView with the touched view detected by the OS
                            appContext.currentTouchedView = appContext.initialTouchedView
                        }
                    }
                }
                
                if let segmentedControl = appContext.currentTouchedView as? UISegmentedControl {
                    let segs = segmentedControl.value(forKey: "segments") as! [UIView]
                    appContext.currentTouchedView = segs[position!]
                    tag = (position != nil) ? position! : 0
                }
                
                if UIViewControllerContext.sharedInstance.isPeekAndPoped {
                    methodName = "peekAndPop"
                    UIViewControllerContext.sharedInstance.isPeekAndPoped = false
                }
                
                switch eventType {
                case Gesture.GestureEventType.tap :
                    gestureEvent = logTap(touch, method: methodName)
                case Gesture.GestureEventType.swipe :
                    gestureEvent = logSwipe(touch, method: methodName)
                case Gesture.GestureEventType.pan:
                    gestureEvent = logPan(touch, method: methodName)
                case Gesture.GestureEventType.scroll:
                    gestureEvent = logScroll(touch, method: nil)
                case Gesture.GestureEventType.rotate:
                    gestureEvent = logRotation(methodName)
                case Gesture.GestureEventType.pinch:
                    if(touches.count == 2) {
                        appContext.pinchType = getPinchType(touches)
                    }
                    gestureEvent = logPinch(touch, method: methodName)
                default :
                    gestureEvent = nil
                    break
                }
                
                if let text = infoText {
                    gestureEvent?.view.text = text
                }
                
                if let className = infoClassName {
                    gestureEvent?.view.className = className
                }
                
                gestureEvent?.view.position = tag
                
                clearContext()
                return gestureEvent
            }
        }
        return nil
    }
    
    /**
     function used to determine if a set of touches should be considered as a double tap
     
     - parameter touches: Set of UITouches
     
     - returns: return true if double tap determined
     */
    func isDoubleTap(_ touches: Set<UITouch>) -> Bool {
        return touches.count == 1 && touches.first!.tapCount == 2
    }
    
    /**
     function used to determine if a set of touches should shoudl be considered as a rotation move
     
     - parameter touches: set of current touches - use the context that stores the initial touches
     
     - returns: true if the context thinks a rotation is happening
     */
    func isRotation(_ touches: NSSet) -> Bool {
        let appContext = UIApplicationContext.sharedInstance
        let t = Array(touches)
        let currP1 = (t[0] as AnyObject).location(in: nil)
        let currP2 = (t[1] as AnyObject).location(in: nil)
        appContext.rotationObject?.setCurrentPoints(currP1, p2: currP2)
        if let obj = appContext.rotationObject {
            return obj.isValidRotation()
        } else {
            appContext.rotationObject = Rotator(p1: currP1, p2: currP2)
            return false
        }
    }
    
    /**
     Determines whether the gesture is a Swipe
     
     - parameter xDelta: Delta value between the initial X position and the final position
     - parameter yDelta: Delta value between the initial Y position and the final position
     
     - returns: true if it's detected as a swipe
     */
    func isSwipe(_ xDelta: CGFloat, yDelta: CGFloat) -> Bool {
        let appContext = UIApplicationContext.sharedInstance
        if  Double(xDelta) >= UIApplication.Static.HorizontalSwipeDragMin &&
            Double(yDelta) <= UIApplication.Static.VerticalSwipeDragMax {
                let now = Date().timeIntervalSinceNow
                if now - appContext.initalTouchTime! <= UIApplication.Static.MaxMoveTimeInterval {
                    return true
                }
        }
        return false
    }
    
    func isTap(_ xDelta: CGFloat, yDelta: CGFloat) -> Bool {
        return (xDelta == 0 && yDelta == 0)
    }
    
    /**
     Determines whether the gesture is a Scroll
     
     - parameter xDelta: Delta value between the initial X position and the final position
     - parameter yDelta: Delta value between the initial Y position and the final position
     
     - returns: true if it's a scroll
     */
    func isScroll(_ xDelta: CGFloat, yDelta: CGFloat) -> Bool {
        let appContext = UIApplicationContext.sharedInstance
        
        if  Double(xDelta) <= UIApplication.Static.HorizontalSwipeDragMin &&
            Double(yDelta) >= UIApplication.Static.VerticalSwipeDragMax {
                let now = Date().timeIntervalSinceNow
                if now - appContext.initalTouchTime! <= UIApplication.Static.MaxMoveTimeInterval {
                    return true
                }
        }
        return false
    }
    
    /**
     Gets the pinch direction
     
     - parameter touches: Touches
     
     - returns: Pinch Direction
     */
    func getPinchType(_ touches: Set<UITouch>) -> UIApplicationContext.PinchDirection {
        let t = Array(touches)
        var pinchType = UIApplicationContext.PinchDirection.Unknown
        let appContext = UIApplicationContext.sharedInstance
        
        let finalDist = Maths.CGPointDist(t[0].location(in: nil), b: t[1].location(in: nil))
        let initialDist = appContext.initialPinchDistance
        
        if  Double(fabs(finalDist - initialDist)) > UIApplication.Static.PinchDragMin &&
            initialDist > 0
        {
            if initialDist < finalDist {
                pinchType = UIApplicationContext.PinchDirection.In
            } else {
                pinchType = UIApplicationContext.PinchDirection.Out
            }
        }
        
        appContext.initialPinchDistance = finalDist
        return pinchType
    }
    
    /**
     Initialize the UIApplicationContext to store value when the touch begins
     
     - parameter touches: touces
     */
    func initContext(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            let appContext = UIApplicationContext.sharedInstance
            appContext.eventType = Gesture.GestureEventType.tap
            appContext.initialTouchPosition = touch.location(in: nil)
            appContext.initalTouchTime = touch.timestamp
            appContext.initialPinchDistance = 0
            let touchedView = getTouchedView(touches)
            appContext.initialTouchedView = touchedView
            let accurateTouchedView = UIApplicationContext.findMostAccurateTouchedView(touchedView)
            if shouldIgnoreView(touchedView) {
                appContext.currentTouchedView = touchedView
            } else {
                appContext.currentTouchedView = accurateTouchedView == nil ? touchedView : accurateTouchedView
            }
            if touches.count == 2 {
                let t = Array(touches)
                appContext.eventType = Gesture.GestureEventType.pinch
                appContext.initialPinchDistance = Maths.CGPointDist(t[0].location(in: nil), b: t[1].location(in: nil))
                appContext.initialTouchPosition = t[0].location(in: nil)
                appContext.rotationObject = Rotator(p1: t[0].location(in: nil), p2: t[1].location(in: nil))
            }
        }
    }
    
    /* check is we should ignore the event */
    func shouldIgnoreView(_ optView: UIView?) -> Bool {
        guard let view = optView else {
            return true
        }
        
        if view is SmartButtonIgnored || view is KLCPopup || view is SmartToolbar || view is SmartImageViewIgnored || view is SmartViewIgnored || view is DebuggerButton || view is DebuggerView {
            return true
        }
        return false
    }
    
    /**
     Restores context with default values
     */
    func clearContext() {
        let appContext = UIApplicationContext.sharedInstance
        appContext.previousTouchTime = appContext.initalTouchTime
        appContext.previousEventType = appContext.eventType
        appContext.initialTouchPosition = CGPoint.zero
        appContext.initalTouchTime = Date().timeIntervalSinceNow
        appContext.initialPinchDistance = 0
        appContext.rotationObject = nil
        appContext.initialTouchedView = nil
    }
    
    /**
     Gets a Tap object
     
     - parameter touch: touch
     
     - returns: TapEvent
     */
    func logTap(_ touch: UITouch, method: String?) -> TapEvent {
        let appContext = UIApplicationContext.sharedInstance
        
        let p = appContext.initialTouchPosition
        let tap = TapEvent(x:Float(p.x), y:Float(p.y), view: View(), direction:touch.tapCount == 1 ? "single" : "double", currentScreen: Screen())
        
        if let methodName = method {
            tap.methodName = methodName
        }
        return tap
    }
    
    /**
     Gets a Swipe object
     
     - parameter touch: touch
     
     - returns: SwipeEvent
     */
    func logSwipe(_ touch: UITouch, method: String?) -> SwipeEvent {
        let appContext = UIApplicationContext.sharedInstance
        let p = touch.location(in: nil)
        let swipe = SwipeEvent(view: View(), direction:appContext.initialTouchPosition.x < p.x ? SwipeEvent.SwipeDirection.Right : SwipeEvent.SwipeDirection.Left, currentScreen: Screen())
        
        if let methodName = method {
            swipe.methodName = methodName
        }

        return swipe
    }
    
    /**
     Gets a Rotation object
     
     - parameter touch: touch
     
     - returns: RotationEvent
     */
    func logRotation(_ method: String?) -> RotationEvent {
        let appContext = UIApplicationContext.sharedInstance
        let finalAngle = appContext.rotationObject?.getCurrentRotation()
        let initialAngle = appContext.rotationObject?.initialRotation
        let rotation = RotationEvent(view: View(), direction:finalAngle!-initialAngle! > 0 ? RotationEvent.RotationDirection.Clockwise : RotationEvent.RotationDirection.CounterClockwise, currentScreen: Screen())
        if let methodName = method {
            rotation.methodName = methodName
        }
        
        return rotation
    }
    
    /**
     Gets a Pan object
     
     - parameter touch: touch
     
     - returns: PanEvent
     */
    func logPan(_ touch: UITouch, method: String?) -> PanEvent {
        let appContext = UIApplicationContext.sharedInstance
        let p = touch.location(in: nil)
        var direction = PanEvent.PanDirection.Left
        
        if(appContext.eventType == Gesture.GestureEventType.swipe) {
            direction = appContext.initialTouchPosition.x < p.x ? PanEvent.PanDirection.Right : PanEvent.PanDirection.Left
        } else if(appContext.eventType == Gesture.GestureEventType.scroll) {
            direction = appContext.initialTouchPosition.y < p.y ? PanEvent.PanDirection.Up : PanEvent.PanDirection.Down
        }
        
        let pan = PanEvent(view: View(), direction: direction, currentScreen: Screen())
        
        if let methodName = method {
            pan.methodName = methodName
        }
        
        return pan
    }
    
    /**
     Gets a Scroll object
     
     - parameter touch: touch
     
     - returns: ScrollEvent
     */
    func logScroll(_ touch: UITouch, method: String?) -> ScrollEvent {
        let appContext = UIApplicationContext.sharedInstance
        let p = touch.location(in: nil)
        let optTouchedView = appContext.currentTouchedView
        
        if let touchedView = optTouchedView {
            if(touchedView.isInScrollView) {
                appContext.currentTouchedView = touchedView.parentScrollView!
            }
        }
        
        let scroll = ScrollEvent(view: View(), direction:appContext.initialTouchPosition.y < p.y ? ScrollEvent.ScrollDirection.Up : ScrollEvent.ScrollDirection.Down, currentScreen: Screen())
        
        if let methodName = method {
            scroll.methodName = methodName
        }
        
        return scroll
    }
    
    /**
     Gets a Pinch object
     
     - parameter touch: touch
     
     - returns: PinchEvent
     */
    func logPinch(_ touch: UITouch, method: String?) -> PinchEvent {
        let appContext = UIApplicationContext.sharedInstance
        let pinch = PinchEvent(view: View(), direction:(appContext.pinchType == UIApplicationContext.PinchDirection.In) ? PinchEvent.PinchDirection.In : PinchEvent.PinchDirection.Out , currentScreen: Screen())
        
        if let methodName = method {
            pinch.methodName = methodName
        }

        return pinch
    }
    
    /**
     Get touched view from set
     
     - parameter touches: Set<UITouch>
     
     - returns: UIView?
     */
    func getTouchedView(_ touches: Set<UITouch>) -> UIView? {
        for touch in touches {
            if let view = touch.view {
                
                if(view.isInTableViewCell) {
                    return view.parentTableViewCell!
                } else {
                    return view
                }
            }
        }
        return nil
    }
    
    /**
     get the position of a cell in a collectionViewCell
     
     - returns: the position
     */
    func getIndexPathForCollectionCell() -> NSInteger? {
        let c: UICollectionViewCell? = UIApplicationContext.sharedInstance.currentTouchedView?.parentCollectionViewCell
        if let cell = c {
            let col = self.collectionViewForCell(cell)
            if let collection = col {
                return (collection.indexPath(for: cell) as IndexPath?)?.row
            }
        }
        return nil
    }
    
    /**
     Return the collectionView that belong to the cell (or the opposition ? :p)
     
     - parameter cell: an UICollectionViewCell
     
     - returns: the collectionViewCell
     */
    func collectionViewForCell(_ cell: UICollectionViewCell) -> UICollectionView?{
        var superView = cell.superview
        while superView != nil && !superView!.isKind(of: UICollectionView.self) {
            superView = superView?.superview
        }
        
        return superView as? UICollectionView
    }
    
    /**
     Return the index of a cell in a tableView
     
     - returns: the indexpath.row
     */
    func getIndexPathForTableCell() -> NSInteger? {
        let c: UITableViewCell? = UIApplicationContext.sharedInstance.currentTouchedView?.parentTableViewCell
        if let cell = c {
            let t = self.tableViewForCell(cell)
            if let table = t {
                return (table.indexPath(for: cell) as IndexPath?)?.row
            }
        }
        return nil
    }
    
    /**
     Return the tableView that belong to a tableViewCell
     
     - parameter cell: the cell
     
     - returns: the tableViewCell
     */
    func tableViewForCell(_ cell: UITableViewCell) -> UITableView? {
        var superView = cell.superview
        while superView != nil && !superView!.isKind(of: UITableView.self) {
            superView = superView?.superview
        }
        
        return superView as? UITableView
    }
    
    /**
     Tries to get the text, method and className of the touched view
     
     - parameter object: touched view
     
     - returns: text, method and className
     */
    func getTouchedViewInfo(_ object: Any) -> (text: String?, method: String?, className: String?, position: Int?) {
        var text: String?
        var method: String?
        var className: String?
        var position = -1
        
        if let o = object as? NSObject {
            text = o.accessibilityLabel
        }
        
        if let view = object as? UIView {
            if view.type == UIApplicationContext.ViewType.tableViewCell {
                let cell = view.parentTableViewCell!
                if let textLabel = cell.textLabel {
                    if let cellText = textLabel.textValue {
                        text = cellText
                    }
                }
                className = "UITableViewCell"
                if let index = getIndexPathForTableCell() {
                    position = index
                }
            } else if view.type == UIApplicationContext.ViewType.collectionViewCell {
                let cell = view.parentCollectionViewCell!
                if let cellText = cell.contentView.textValue {
                    text = cellText
                }
                className = "UICollectionViewCell"
                if let index = getIndexPathForCollectionCell() {
                    position = index
                }
                
            } else if view.type == UIApplicationContext.ViewType.backButton {
                text = "handleBack:"
                method = "handleBack:"
            } else if view.type == UIApplicationContext.ViewType.navigationBar {
                text = view.textValue
                className = "UINavigationBar"
            } else if view.type == UIApplicationContext.ViewType.textField  {
                let textField = view as! UITextField
                
                if let fieldText = textField.text {
                    if !fieldText.isEmpty  {
                        text = fieldText
                    } else if let placeHolder = textField.placeholder {
                        if !placeHolder.isEmpty  {
                            text = placeHolder
                        }
                    }
                } else if let placeHolder = textField.placeholder {
                    if !placeHolder.isEmpty  {
                        text = placeHolder
                    }
                }
            } else if view.type == UIApplicationContext.ViewType.button  {
                let button = view as! UIButton
                
                if let title = button.currentTitle {
                    text = title
                } else if let image = button.currentImage {
                    if let title = image.accessibilityLabel {
                        text = title
                    }
                    else if let title = image.accessibilityIdentifier {
                        text = title
                    }
                }
                
                let classType:AnyClass? = NSClassFromString("UINavigationButton")
                if view.isKind(of: classType!) {
                    position = getPositionFromNavigationBar(view)
                }
                
            } else if view.type == UIApplicationContext.ViewType.segmentedControl  {
                let segment = view as! UISegmentedControl
                text = segment.titleForSegment(at: segment.selectedSegmentIndex)
                position = segment.selectedSegmentIndex
                className = "UISegment"
            } else if view.type == UIApplicationContext.ViewType.slider  {
                let slider = view as! UISlider
                
                text = String(slider.value)
            } else if view.type == UIApplicationContext.ViewType.stepper  {
                let stepper = view as! UIStepper
                
                text = String(stepper.value)
            }
        } else if let barButton = object as? UIBarButtonItem {
            let view = barButton.value(forKey: "view") as! UIView
            var barButtonContainer = view.superview
            
            if let title = barButton.title {
                text = title
            }
            
            if let action = barButton.action {
                method = NSStringFromSelector(action)
            }
            
            if barButtonContainer is UIToolbar {
                position = getPositionFromUIToolbarButton(barButton)
            }
        }
        
        if let control = object as? UIControl {
            for target in control.allTargets {
                
                let tar = target as NSObject
                
                if tar.isKind(of: NSClassFromString("UIBarButtonItem")!)  {
                    let barButtonInfo = getTouchedViewInfo(target as! UIBarButtonItem)
                    if let title = barButtonInfo.text {
                        text = title
                    }
                    
                    if let barButtonMethod = barButtonInfo.method {
                        method = barButtonMethod
                    }
                    
                    if let pos = barButtonInfo.position {
                        if position == -1 {
                            position = pos
                        }
                    }
                } else if tar.isKind(of: NSClassFromString("UITabBar")!)  {
                    let tabBar = target as! UITabBar
                    
                    let (idx, title) = getItemFromButton(tabBar, currentButton: object as! UIControl)
                    if let _ = idx {
                        position = idx!
                    }
                    text = title
                    method = "_tabBarItemClicked:"
                    className = "UITabBarController"
                } else {
                    if let actions = control.actions(forTarget: target, forControlEvent: control.allControlEvents) {
                        func getAction(_ actions: [String]) -> String? {
                            return actions.filter({$0 != "at_refresh"}).first
                        }
                        if let action = getAction(actions) {
                            method = action
                        }
                    }
                    // default buttons methods
                    if method == nil {
                        func getMethodFromControlEvents (target: Any?, controlEvent: UIControlEvents) -> String? {
                            if let action = control.actions(forTarget: target, forControlEvent: controlEvent) {
                                if !action.isEmpty {
                                    return action[0]
                                }
                            }
                            return nil
                        }
                        method = getMethodFromControlEvents(target: target, controlEvent: UIControlEvents.touchUpInside) ?? getMethodFromControlEvents(target: target, controlEvent: UIControlEvents.touchDown)
                        
                    }
                }
            }
        }
        
        if position == -1 {
            position = getPositionInSuperView(object)
        }
        
        return (text: text, method: method, className: className, position: position)
    }
    
    /**
     Get the position in the index of superview
     KAIZEN : move to UIViewExtension ?
     
     - parameter obj: An object - should be an UIView
     
     - returns: the position in its parent's subviews array
     */
    func getPositionInSuperView(_ obj: Any) -> Int {
        let defaultValue = -1
        guard let view = obj as? UIView else {
            return defaultValue
        }
        
        guard let parent = view.superview else {
            return defaultValue
        }
        
        return zip((0...parent.subviews.count), parent.subviews).filter({$0.1 == view})[0].0
    }
    
    /**
     get the title and the position of a button in a UITabBar
     
     - parameter tabBar:        the TabBar
     - parameter currentButton: the clicked button
     
     - returns: (index, title) tuple
     */
    func getItemFromButton(_ tabBar: UITabBar, currentButton: UIControl) -> (Int?, String?) {
        guard let tabBarItems = tabBar.items else {
            return (nil, nil)
        }
        for (idx, item) in tabBarItems.enumerated() {
            if item.at_hasProperty("view") {
                if currentButton == item.value(forKey: "view") as! UIControl {
                    let text = item.title
                    return (idx, text)
                }
            }
        }
        return (nil,nil)
    }
    
    /**
     get the position of a ToolBarButton in its toolbar.
     Note that the accessible view is a UIBarButtonItem but we test later the UIToolbarButton class
     
     - parameter barButton: the barbutton clicked
     
     - returns: the position
     */
    func getPositionFromUIToolbarButton(_ barButton: UIBarButtonItem) -> Int {
        if let embedView = barButton.value(forKey: "view") as? UIView {
            if let parent = embedView.superview {
                let subs = parent.subviews
                let buttonArray = subs.filter({$0.isKind(of: NSClassFromString("UIToolbarButton")!)})
                return buttonArray.index(of: embedView) ?? -1
            }
        }
        return -1
    }
    
    func getPositionFromNavigationBar(_ view: UIView) -> Int {
        let classType:AnyClass? = NSClassFromString("UINavigationButton")
        if view.isKind(of: classType!) {
            if let navBar = view.superview as? UINavigationBar {
                var navButtons = navBar.subviews.filter({ $0.isKind(of: classType!) })
                navButtons.sort(by: { (button1: UIView, button2: UIView) -> Bool in
                    button1.frame.origin.x < button2.frame.origin.x
                })
                return navButtons.index(of: view) ?? -1
            }
        }
        return -1
    }
}
