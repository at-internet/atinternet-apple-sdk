//
//  EventFactory.swift
//  ATInternetTracker
//
//  Created by Théo Damaville on 07/02/2017.
//
//

import Foundation

class EventFactory {
    public func createEvent(eventType: Gesture.GestureEventType, touch: UITouch, method: String?) -> GestureEvent? {
        switch eventType {
        case .tap:
            return self.logTap(touch, method: method)
        case .swipe:
            return self.logSwipe(touch, method: method)
        case .pan:
            return self.logPan(touch, method: method)
        case .scroll:
            return self.logScroll(touch, method: method)
        case .rotate:
            return self.logRotation(method)
        case .pinch:
            return self.logPinch(touch, method: method)
        default:
            return nil
        }
    }

    /**
     Gets a Tap object
     
     - parameter touch: touch
     
     - returns: TapEvent
     */
    func logTap(_ touch: UITouch, method: String?) -> TapEvent {
        let appContext = UIApplicationContext.sharedInstance
        
        let p = appContext.initialTouchPosition
        let tap = TapEvent(x:Float(p.x),
                           y:Float(p.y),
                           view: View(),
                           direction:touch.tapCount == 1 ? "single" : "double",
                           currentScreen: Screen(),
                           methodName: method)
        
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
        let swipe = SwipeEvent(view: View(),
                               direction:appContext.initialTouchPosition.x < p.x ? SwipeEvent.SwipeDirection.Right : SwipeEvent.SwipeDirection.Left,
                               currentScreen: Screen(),
                               methodName: method)
        
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
        let rotation = RotationEvent(view: View(),
                                     direction:finalAngle!-initialAngle! > 0 ? RotationEvent.RotationDirection.Clockwise : RotationEvent.RotationDirection.CounterClockwise,
                                     currentScreen: Screen(),
                                     methodName: method)
        
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
        
        let pan = PanEvent(view: View(),
                           direction: direction,
                           currentScreen: Screen(),
                           methodName: method)
        
        
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
        
        let scroll = ScrollEvent(view: View(),
                                 direction:appContext.initialTouchPosition.y < p.y ? ScrollEvent.ScrollDirection.Up : ScrollEvent.ScrollDirection.Down,
                                 currentScreen: Screen(),
                                 methodName: method)
        
        return scroll
    }
    
    /**
     Gets a Pinch object
     
     - parameter touch: touch
     
     - returns: PinchEvent
     */
    func logPinch(_ touch: UITouch, method: String?) -> PinchEvent {
        let appContext = UIApplicationContext.sharedInstance
        let pinch = PinchEvent(view: View(),
                               direction:(appContext.pinchType == UIApplicationContext.PinchDirection.In) ? PinchEvent.PinchDirection.In : PinchEvent.PinchDirection.Out ,
                               currentScreen: Screen(),
                               methodName: method)
        
        return pinch
    }
}
