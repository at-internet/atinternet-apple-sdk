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

/// Context for swizzling of UIApplication class
class UIApplicationContext {
    /// An array representing "noise" UIView that we want to ignore
    let UIViewToIgnore = [
        SmartButtonIgnored.self,
        KLCPopup.self,
        SmartToolbar.self,
        SmartImageViewIgnored.self,
    ];
    
    /**
     Enum of pinch direction
     
     - In:      Pinch In
     - Out:     Pinch Out
     - Unknown: Pinch detected but not yet identified
     */
    enum PinchDirection: String {
        case In = "in"
        case Out = "out"
        case Unknown = "?"
    }
    
    /**
     Enum of view types
     
     - Unkwown:          Default type
     - TableViewCell:    TableViewCell
     - BackButton:       BackButton
     - TabBarButton:     TabBarButton
     - SegmentedControl: SegmentedControl
     - Slider:           Slider
     - TextField:        TextField
     - Stepper:          Stepper
     - Button:           Button
     - Switch:           Switch
     - NavigationBar:    NavigationBar
     - PageControl:      PageControl
     - DatePicker:       DatePicker
     */
    enum ViewType: String {
        case Unkwown = "UIView"
        case TableViewCell = "UITableViewCell"
        case CollectionViewCell = "UICollectionViewCell"
        case BackButton = "UINavigationBarBackIndicatorView"
        case TabBarButton = "UITabBarButton"
        case SegmentedControl = "UISegmentedControl"
        case Slider = "UISlider"
        case TextField = "UITextField"
        case Stepper = "UIStepper"
        case Button = "UIButton"
        case Switch = "UISwitch"
        case NavigationBar = "UINavigationBar"
        case PageControl = "UIPageControl"
        case DatePicker = "UIDatePicker"
    }
    
    /// Property to keep event type
    lazy var eventType: Gesture.GestureEventType = Gesture.GestureEventType.Unknown
    
    /// Property to keep current touched view in app
    weak var currentTouchedView : UIView? = nil
    
    /// View that was touched when the gesture begin
    weak var initialTouchedView: UIView? = nil
    
    /// Touch position
    lazy var initialTouchPosition: CGPoint = CGPointZero
    
    /// Time of touch
    var initalTouchTime: NSTimeInterval?
    
    /// Distance between two fingers
    lazy var initialPinchDistance: CGFloat = 0.0
    
    var rotationObject: Rotator?
    
    /// Pinch direction
    lazy var pinchType = PinchDirection.Unknown
    
    /// Time of previous touch
    var previousTouchTime: NSTimeInterval?
    
    /// Previous event type - not always sent
    lazy var previousEventType: Gesture.GestureEventType = Gesture.GestureEventType.Unknown
    
    /// Previous event - that was SENT
    lazy var previousEventSent: GestureEvent? = nil
    
    /// Singleton
    static let sharedInstance = UIApplicationContext()
    
    private init() { }
    
    /**
     Return the default methodName for a view
     
     - returns: a default string that represent the default action on this view
     */
    func getDefaultViewMethod(currentView: UIView?) -> String? {
        guard let currentView = currentView else {
            return "handleTap:"
        }
        switch currentView.type {
        case UIApplicationContext.ViewType.Unkwown:
            return nil
        case UIApplicationContext.ViewType.TableViewCell:
            return "handleTap:"
        case UIApplicationContext.ViewType.CollectionViewCell:
            return "handleTap:"
        case UIApplicationContext.ViewType.BackButton:
            return "handleBack:"
        case UIApplicationContext.ViewType.TabBarButton:
            return "_tabBarItemClicked:"
        case UIApplicationContext.ViewType.SegmentedControl:
            return nil
        case UIApplicationContext.ViewType.Slider:
            return nil
        case UIApplicationContext.ViewType.TextField:
            return "handleFocus:"
        case UIApplicationContext.ViewType.Stepper:
            return nil
        case UIApplicationContext.ViewType.Button:
            return nil
        case UIApplicationContext.ViewType.Switch:
            return "setOn:"
        case UIApplicationContext.ViewType.NavigationBar:
            return "handleTap:"
        case UIApplicationContext.ViewType.PageControl:
            return nil
        case UIApplicationContext.ViewType.DatePicker:
            return "handleTap:"
        }
    }
    
    class func findMostAccurateTouchedView(view: UIView?) -> UIView? {
        var accurateView: UIView?
        
        if let touchedView = view {
            if UIApplicationContext.sharedInstance.initialTouchPosition != CGPointZero {
                let frame = touchedView.superview?.convertRect(touchedView.frame, toView: nil)
                
                if CGRectContainsPoint(frame!, UIApplicationContext.sharedInstance.initialTouchPosition) {
                    accurateView = touchedView
                    
                    if accurateView! is UIControl || accurateView?.type != UIApplicationContext.ViewType.Unkwown {
                        return accurateView
                    } else {
                        for subview in touchedView.subviews {
                            let accView = findMostAccurateTouchedView(subview)
                            
                            if(accView != nil) {
                                accurateView = accView
                            }
                        }
                    }
                } else {
                    accurateView = nil
                }
            }
        }
        
        return accurateView;
    }
}
