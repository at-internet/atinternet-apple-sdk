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


//
//  Debug.swift
//  Tracker
//

import UIKit

class DebuggerButton: UIButton {}
class DebuggerView: UIView {}

internal class Debugger: NSObject {
    
    struct Static {
        static var instance: Debugger?
        static var token: Int = 0
    }
    
    private static var __once: () = {
        Static.instance = Debugger()
    }()
    
    
    /// Application window
    lazy var applicationWindow: UIWindow? = UIApplication.sharedApplication().keyWindow
    /// Debug button
    lazy var debugButton: DebuggerButton = DebuggerButton()
    /// Debug button position
    var debugButtonPosition: String = "Right"
    /// List of all created windows
    lazy var windows: [(window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String)] = []
    /// Window title
    lazy var windowTitleLabel = UILabel()
    /// List of offline hits
    lazy var hits: [Hit] = []
    /// Gesture recogniser for debug button
    var gestureRecogniser: UIPanGestureRecognizer!
    /// Debug button constraint (for animation)
    var debugButtonConstraint: NSLayoutConstraint!
    /// List of received events
    var receivedEvents: [DebuggerEvent] = []
    /// Is debugger visible or not
    var debuggerShown:Bool = false
    /// Is debugger animating
    var debuggerAnimating: Bool = false
    /// Date formatter (HH:mm:ss)
    let hourFormatter = NSDateFormatter()
    /// Date formatter (dd/MM/yyyy HH:mm:ss)
    let dateHourFormatter = NSDateFormatter()
    /// Offline storage
    let storage = Storage.sharedInstance
    /// Debugger is initialize
    var initialized: Bool = false
    
    class var sharedInstance: Debugger {
        struct Static {
            static var instance: Debugger?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Debugger()
        }
        
        return Static.instance!
    }
    
    /**
     Add debugger to view controller
     */
    func initDebugger() {
        
        if !initialized {
            hourFormatter.dateFormat = "HH':'mm':'ss"
            hourFormatter.locale = LifeCycle.locale
            dateHourFormatter.dateFormat = "dd'/'MM'/'YYYY' 'HH':'mm':'ss"
            dateHourFormatter.locale = LifeCycle.locale
            self.initialized = true
            
            createDebugButton()
            createEventViewer()
            
            gestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(Debugger.debugButtonWasDragged(_:)))
            debugButton.addGestureRecognizer(gestureRecogniser)
            
            
            applicationWindow!.bringSubviewToFront(debugButton)
        }
    }
    
    /**
     Remove debugger from view controller
     */
    func deinitDebugger() {
        self.initialized = false
        debuggerShown = false
        debuggerAnimating = false
        
        debugButton.removeFromSuperview()
        
        for(_, window) in self.windows.enumerate() {
            window.window.removeFromSuperview()
        }
        
        self.windows.removeAll(keepCapacity: false)
    }
    
    /**
     Add an event to the event list
     */
    func addEvent(message: String, icon: String) {
        let event = DebuggerEvent()
        event.date = NSDate()
        event.type = icon
        event.message = message
        
        self.receivedEvents.insert(event, atIndex: 0)
        dispatch_sync(dispatch_get_main_queue(), {
            self.addEventToList()
        })
        
    }
    
    // MARK: Debug button
    
    /**
     Create debug button
     */
    func createDebugButton() {
        debugButton.setBackgroundImage(UIImage(named: "atinternet-logo", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        debugButton.frame = CGRectMake(0, 0, 94, 73)
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        debugButton.alpha = 0
        
        applicationWindow!.addSubview(debugButton)
        
        // align atButton from the left
        if(debugButtonPosition == "Right") {
            debugButtonConstraint = NSLayoutConstraint(item: debugButton,
                                                       attribute: NSLayoutAttribute.Trailing,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: applicationWindow!,
                                                       attribute: NSLayoutAttribute.Trailing,
                                                       multiplier: 1.0,
                                                       constant: 0)
        } else {
            debugButtonConstraint = NSLayoutConstraint(item: debugButton,
                                                       attribute: NSLayoutAttribute.Leading,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: applicationWindow!,
                                                       attribute: NSLayoutAttribute.Leading,
                                                       multiplier: 1.0,
                                                       constant: 0)
        }
        
        applicationWindow!.addConstraint(debugButtonConstraint)
        
        applicationWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[debugButton]-10-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["debugButton": self.debugButton]))
        
        // width constraint
        applicationWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[debugButton(==94)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["debugButton": debugButton]))
        
        // height constraint
        applicationWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[debugButton(==73)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["debugButton": debugButton]))
        
        debugButton.addTarget(self, action: #selector(Debugger.debuggerTouched), forControlEvents: UIControlEvents.TouchUpInside)
        
        UIView.animateWithDuration(
            0.4,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                self.debugButton.alpha = 1.0;
            },
            completion: nil)
    }
    
    /**
     Debug button was dragged (change postion from left to right ...)
     */
    @objc func debugButtonWasDragged(recogniser: UIPanGestureRecognizer) {
        let button = recogniser.view as! DebuggerButton
        let translation = recogniser.translationInView(button)
        
        let velocity = recogniser.velocityInView(button)
        
        if (recogniser.state == UIGestureRecognizerState.Changed)
        {
            button.center = CGPointMake(button.center.x + translation.x, button.center.y)
            recogniser.setTranslation(CGPointZero, inView: button)
        }
        else if (recogniser.state == UIGestureRecognizerState.Ended)
        {
            if(velocity.x < 0) {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.debugButtonConstraint.constant = (self.applicationWindow!.frame.width - button.frame.width) * -1
                    self.applicationWindow!.layoutIfNeeded()
                    self.applicationWindow!.updateConstraints()
                    }, completion: {
                        finished in
                        self.debugButtonPosition = "Left"
                        self.applicationWindow!.removeConstraint(self.debugButtonConstraint)
                        
                        self.debugButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                            attribute: NSLayoutAttribute.Leading,
                            relatedBy: NSLayoutRelation.Equal,
                            toItem: self.applicationWindow!,
                            attribute: NSLayoutAttribute.Leading,
                            multiplier: 1.0,
                            constant: 0)
                        
                        self.applicationWindow!.addConstraint(self.debugButtonConstraint)
                })
            } else {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.debugButtonConstraint.constant = (self.applicationWindow!.frame.width - button.frame.width)
                    self.applicationWindow!.layoutIfNeeded()
                    self.applicationWindow!.updateConstraints()
                    }, completion: {
                        finished in
                        self.debugButtonPosition = "Right"
                        self.applicationWindow!.removeConstraint(self.debugButtonConstraint)
                        
                        self.debugButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                            attribute: NSLayoutAttribute.Trailing,
                            relatedBy: NSLayoutRelation.Equal,
                            toItem: self.applicationWindow!,
                            attribute: NSLayoutAttribute.Trailing,
                            multiplier: 1.0,
                            constant: 0)
                        
                        self.applicationWindow!.addConstraint(self.debugButtonConstraint)
                })
            }
        }
    }
    
    /**
     Debug button was touched
     */
    @objc func debuggerTouched() {
        for w in self.windows {
            w.window.hidden = false
        }
        
        if(self.debuggerShown && !debuggerAnimating) {
            debuggerAnimating = true
            
            UIView.animateWithDuration(
                0.2,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    for w in self.windows {
                        w.content.alpha = 0.0
                        w.menu.alpha = 0.0
                    }
                },
                completion: {
                    finished in
                    self.animateEventLog()
            })
        } else {
            debuggerAnimating = true
            
            animateEventLog()
        }
    }
    
    /**
     Animate window (show or hide)
     */
    func animateEventLog() {
        UIView.animateWithDuration(
            0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                if(self.debuggerShown) {
                    if(self.debugButtonPosition == "Right") {
                        for w in self.windows {
                            w.window.frame = CGRectMake(self.applicationWindow!.frame.width - 47, self.applicationWindow!.frame.height - 93, 0, 0)
                        }
                    } else {
                        for w in self.windows {
                            w.window.frame = CGRectMake(47, self.applicationWindow!.frame.height - 93, 0, 0)
                        }
                    }
                } else {
                    for w in self.windows {
                        
                        w.window.frame = CGRectMake(10, 30, self.applicationWindow!.frame.width - 20, self.applicationWindow!.frame.height - 93 - 30)
                    }
                }
            },
            completion: {
                finished in
                
                if(!self.debuggerShown) {
                    UIView.animateWithDuration(
                        0.2,
                        delay: 0.0,
                        options: UIViewAnimationOptions.CurveLinear,
                        animations: {
                            for w in self.windows {
                                w.content.alpha = 1.0
                                w.menu.alpha = 1.0
                            }
                        },
                        completion: nil)
                    
                    self.applicationWindow!.bringSubviewToFront(self.windows[self.windows.count - 1].window)
                } else {
                    for w in self.windows {
                        w.window.hidden = true
                    }
                }
                
                self.debuggerShown = !self.debuggerShown
                self.debuggerAnimating = false
        })
    }
    
    //MARK: Event viewer
    
    /**
     Create event viewer window
     */
    func createEventViewer() {
        let eventViewer: (window: DebuggerView, content: DebuggerView, menu: DebuggerTopBar, windowTitle: String) = self.createWindow("Event viewer")
        
        let offlineButton = DebuggerButton()
        offlineButton.translatesAutoresizingMaskIntoConstraints = false
        offlineButton.setBackgroundImage(UIImage(named: "database64", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        offlineButton.addTarget(self, action: #selector(Debugger.createOfflineHitsViewer), forControlEvents: UIControlEvents.TouchUpInside)
        
        eventViewer.menu.addSubview(offlineButton)
        
        // width constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[offlineButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        // height constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[offlineButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-14-[offlineButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: offlineButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: eventViewer.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        windowTitleLabel.text = eventViewer.windowTitle
        windowTitleLabel.textColor = UIColor.whiteColor()
        windowTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        eventViewer.menu.addSubview(windowTitleLabel)
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: windowTitleLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: eventViewer.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: windowTitleLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: eventViewer.menu,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0))
        
        let trashButton = DebuggerButton()
        
        eventViewer.menu.addSubview(trashButton)
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        trashButton.setBackgroundImage(UIImage(named: "trash64", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        trashButton.addTarget(self, action: #selector(Debugger.trashEvents), forControlEvents: UIControlEvents.TouchUpInside)
        
        // width constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // height constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[trashButton]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: eventViewer.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        getEventsList(eventViewer)
    }
    
    /**
     Builds offline hits list rows
     */
    func getEventsList(eventViewer: (window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String)) {
        
        let scrollViews = eventViewer.content.subviews.filter({ return $0 is UIScrollView }) as! [UIScrollView]
        let emptyEventList = eventViewer.content.subviews.filter() {
            if($0.tag == -2) {
                return true
            } else {
                return false
            }
        }
        
        if(scrollViews.count > 0) {
            for row in scrollViews[0].subviews {
                row.tag = 9999999
                row.removeFromSuperview()
            }
            
            scrollViews[0].removeFromSuperview()
        }
        
        if(emptyEventList.count > 0) {
            emptyEventList[0].removeFromSuperview()
        }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.scrollEnabled = true
        scrollView.userInteractionEnabled = true
        scrollView.tag = -100
        
        eventViewer.content.addSubview(scrollView)
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: eventViewer.content,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: eventViewer.content,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: eventViewer.content,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: eventViewer.content,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0))
        
        if(receivedEvents.count == 0) {
            let emptyContentView = DebuggerView()
            emptyContentView.tag = -2
            emptyContentView.translatesAutoresizingMaskIntoConstraints = false
            emptyContentView.layer.cornerRadius = 4.0
            emptyContentView.backgroundColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1)
            
            eventViewer.content.addSubview(emptyContentView)
            
            // height constraint
            eventViewer.content.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[emptyContentView(==50)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["emptyContentView": emptyContentView]))
            
            eventViewer.content.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[emptyContentView]-30-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["emptyContentView": emptyContentView]))
            
            // align messageLabel from the top and bottom
            eventViewer.content.addConstraint(NSLayoutConstraint(item: emptyContentView,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: eventViewer.content,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0))
            
            let emptyContentLabel = UILabel()
            emptyContentLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyContentLabel.text = "No event detected"
            emptyContentLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            emptyContentLabel.sizeToFit()
            
            emptyContentView.addSubview(emptyContentLabel)
            
            emptyContentView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: emptyContentView,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0))
            
            emptyContentView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: emptyContentView,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0))
        } else {
            previousConstraintForEvents = nil
            var previous: DebuggerView?
            for (i,event) in receivedEvents.enumerate() {
                previous = buildEventRow(event, tag: i, scrollView: scrollView, previousRow: previous)
            }
        }
    }
    
    var previousConstraintForEvents: NSLayoutConstraint!
    func buildEventRow(event: DebuggerEvent, tag: Int, scrollView: UIScrollView, previousRow: DebuggerView?) -> DebuggerView {
        let rowView = DebuggerView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.userInteractionEnabled = true
        rowView.tag = tag
        rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Debugger.eventRowSelected(_:))))
        
        scrollView.insertSubview(rowView, atIndex: 0)
        
        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[rowView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
        
        if previousConstraintForEvents != nil {
            scrollView.removeConstraint(previousConstraintForEvents)
        }
        
        previousConstraintForEvents = NSLayoutConstraint(item: rowView,
                                                         attribute: .Top,
                                                         relatedBy: .Equal,
                                                         toItem: scrollView,
                                                         attribute: .Top,
                                                         multiplier: 1.0,
                                                         constant: 0)
        scrollView.addConstraint(previousConstraintForEvents)
        
        
        if(tag == 0) {
            scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: scrollView,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0))
            
            scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: scrollView,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0))
        } else {
            if let previous = previousRow {
                scrollView.addConstraint(NSLayoutConstraint(item: previous,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .Bottom,
                    multiplier: 1.0,
                    constant: 0))
            }
        }
        
        if(tag % 2 == 0) {
            rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        } else {
            rowView.backgroundColor = UIColor.whiteColor()
        }
        
        let iconView = UIImageView()
        let dateLabel = UILabel()
        let messageLabel = UILabel()
        let hitTypeView = UIImageView()
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        hitTypeView.translatesAutoresizingMaskIntoConstraints = false
        
        rowView.addSubview(iconView)
        rowView.addSubview(dateLabel)
        rowView.addSubview(messageLabel)
        rowView.addSubview(hitTypeView)
        
        /******* ICON ********/
        iconView.image = UIImage(named: event.type, inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
        
        rowView.addConstraint(NSLayoutConstraint(item: iconView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: rowView,
            attribute: .Left,
            multiplier: 1.0,
            constant: 5))
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: iconView,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: rowView,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: -1))
        
        // width constraint
        rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[iconView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["iconView": iconView]))
        
        // height constraint
        rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[iconView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["iconView": iconView]))
        /******* END ICON ********/
        
        /******* DATE ********/
        dateLabel.text = hourFormatter.stringFromDate(event.date)
        dateLabel.sizeToFit();
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: iconView,
            attribute: .Right,
            multiplier: 1.0,
            constant: 5))
        
        rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: rowView,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        /******* END DATE ********/
        
        /******* HIT ********/
        messageLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        messageLabel.baselineAdjustment = UIBaselineAdjustment.None
        messageLabel.text = event.message
        
        rowView.addConstraint(NSLayoutConstraint(item: messageLabel,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: dateLabel,
            attribute: .Right,
            multiplier: 1.0,
            constant: 10))
        
        rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[messageLabel]-12-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["messageLabel": messageLabel]))
        
        /******* END HIT ********/
        
        /******* HIT TYPE ********/
        let URL = NSURL(string: event.message)
        
        if let optURL = URL {
            hitTypeView.hidden = false
            
            let hit = Hit(url: optURL.absoluteString!)
            
            switch(hit.getHitType()) {
            case Hit.HitType.Touch:
                hitTypeView.image = UIImage(named: "touch48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
            case Hit.HitType.AdTracking:
                hitTypeView.image = UIImage(named: "tv48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
            case Hit.HitType.Audio:
                hitTypeView.image = UIImage(named: "audio48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
            case Hit.HitType.Video:
                hitTypeView.image = UIImage(named: "video48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
            case Hit.HitType.ProductDisplay:
                hitTypeView.image = UIImage(named: "product48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
            default:
                hitTypeView.image = UIImage(named: "smartphone48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
            }
        } else {
            hitTypeView.hidden = true
        }
        
        rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
            attribute: .Left,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: messageLabel,
            attribute: .Right,
            multiplier: 1.0,
            constant: 10))
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: rowView,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: -1))
        
        // width constraint
        rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        // height constraint
        rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[hitTypeView]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        return rowView
    }
    
    /**
     Reload event list
     */
    func updateEventList() {
        getEventsList(self.windows[0])
    }
    
    @objc func addEventToList() {
        let window = self.windows[0]
        
        window.content.viewWithTag(-2)?.removeFromSuperview()
        
        let scrollview = window.content.viewWithTag(-100) as! UIScrollView
        
        buildEventRow(self.receivedEvents[0], tag: self.receivedEvents.count - 1, scrollView: scrollview, previousRow: scrollview.viewWithTag(self.receivedEvents.count - 2) as! DebuggerView?)
    }
    
    /**
     event list row selected
     */
    @objc func eventRowSelected(recogniser: UIPanGestureRecognizer) {
        self.windows[0].content.hidden = true
        
        if let row = recogniser.view {
            let window = createEventDetailView(receivedEvents[(receivedEvents.count - 1) - row.tag].message)
            
            hidePreviousWindowMenuButtons(window)
        }
    }
    
    /**
     Delete received events
     */
    @objc func trashEvents() {
        self.receivedEvents.removeAll(keepCapacity: false)
        updateEventList()
    }
    
    //MARK: Event detail
    
    /**
     Create event detail window
     
     - parameter hit: or message to display
     */
    func createEventDetailView(hit: String) -> DebuggerView {
        var eventDetail: (window: DebuggerView, content: DebuggerView, menu: DebuggerTopBar, windowTitle: String) = self.createWindow("Hit Detail")

        eventDetail.window.alpha = 0.0;
        eventDetail.window.hidden = false
        eventDetail.content.alpha = 1.0
        eventDetail.menu.alpha = 1.0
        
        let backButton = DebuggerButton()
        
        eventDetail.menu.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setBackgroundImage(UIImage(named: "back64", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        backButton.tag = self.windows.count - 1
        backButton.addTarget(self, action: #selector(Debugger.backButtonWasTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // width constraint
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // height constraint
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-14-[backButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // align messageLabel from the top and bottom
        eventDetail.menu.addConstraint(NSLayoutConstraint(item: backButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: eventDetail.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.scrollEnabled = true
        scrollView.userInteractionEnabled = true
        
        eventDetail.content.addSubview(scrollView)
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: eventDetail.content,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: eventDetail.content,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: eventDetail.content,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: eventDetail.content,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0))
        
        let URL = NSURL(string: hit)
        
        if let optURL = URL {
            eventDetail.windowTitle = "Hit detail"
            windowTitleLabel.text = eventDetail.windowTitle
            
            var urlComponents: [(key: String, value: String)] = []
            
            let sslComponent: (key: String, value: String) = (key: "ssl", value: optURL.scheme == "http" ? "Off" : "On")
            urlComponents.append(sslComponent)
            
            let logComponent: (key: String, value: String) = (key: "log", value: optURL.host!)
            urlComponents.append(logComponent)
            
            let queryStringComponents = optURL.query!.componentsSeparatedByString("&")
            
            for (_,component) in (queryStringComponents as [String]).enumerate() {
                let pairComponents = component.componentsSeparatedByString("=")
                
                urlComponents.append((key: pairComponents[0], value: pairComponents[1].percentDecodedString))
            }
            
            var i: Int = 0
            var previousRow: DebuggerView!
            
            for(key, value) in urlComponents {
                let rowView = DebuggerView()
                rowView.translatesAutoresizingMaskIntoConstraints = false
                
                scrollView.addSubview(rowView)
                
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[rowView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
                
                if(i == 0) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: scrollView,
                        attribute: .Top,
                        multiplier: 1.0,
                        constant: 0))
                    
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .CenterX,
                        relatedBy: .Equal,
                        toItem: scrollView,
                        attribute: .CenterX,
                        multiplier: 1.0,
                        constant: 0))
                } else {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: previousRow,
                        attribute: .Bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                if(i % 2 == 0) {
                    rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                } else {
                    rowView.backgroundColor = UIColor.whiteColor()
                }
                
                if(i == urlComponents.count - 1) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .Bottom,
                        relatedBy: .Equal,
                        toItem: scrollView,
                        attribute: .Bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                let variableLabel = UILabel()
                variableLabel.translatesAutoresizingMaskIntoConstraints = false
                variableLabel.text = key
                variableLabel.textAlignment = NSTextAlignment.Right
                variableLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                
                rowView.addSubview(variableLabel)
                
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[variableLabel(==100)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["variableLabel": variableLabel]))
                
                rowView.addConstraint(NSLayoutConstraint(item: variableLabel,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .Top,
                    multiplier: 1.0,
                    constant: 12))
                
                rowView.addConstraint(NSLayoutConstraint(item: rowView,
                    attribute: .Bottom,
                    relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                    toItem: variableLabel,
                    attribute: .Bottom,
                    multiplier: 1.0,
                    constant: 12))
                
                rowView.addConstraint(NSLayoutConstraint(item: variableLabel,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .Left,
                    multiplier: 1.0,
                    constant: 0))
                
                let columnSeparator = DebuggerView()
                columnSeparator.translatesAutoresizingMaskIntoConstraints = false
                columnSeparator.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
                
                rowView.addSubview(columnSeparator)
                
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[columnSeparator(==1)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["columnSeparator": columnSeparator]))
                
                rowView.addConstraint(NSLayoutConstraint(item: columnSeparator,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: variableLabel,
                    attribute: .Right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[columnSeparator]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["columnSeparator": columnSeparator]))
                
                let valueLabel = UILabel()
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                
                if let optValue: AnyObject = value.toJSONObject() {
                    if(key == "stc") {
                        valueLabel.text = Tool.JSONStringify(optValue, prettyPrinted: true)
                    } else {
                        valueLabel.text = value
                    }
                } else {
                    valueLabel.text = value
                }
                
                valueLabel.textAlignment = NSTextAlignment.Left
                valueLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                valueLabel.numberOfLines = 0
                
                rowView.addSubview(valueLabel)
                
                rowView.addConstraint(NSLayoutConstraint(item: valueLabel,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: columnSeparator,
                    attribute: .Right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraint(NSLayoutConstraint(item: valueLabel,
                    attribute: .Right,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .Right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[valueLabel]-12-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["valueLabel": valueLabel]))
                
                previousRow = rowView
                
                i += 1
            }
        } else {
            eventDetail.windowTitle = "Event detail"
            windowTitleLabel.text = eventDetail.windowTitle
            
            let eventMessageLabel = UILabel()
            eventMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            eventMessageLabel.text = hit
            
            eventMessageLabel.textAlignment = NSTextAlignment.Left
            eventMessageLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            eventMessageLabel.numberOfLines = 0
            
            scrollView.addSubview(eventMessageLabel)
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: scrollView,
                attribute: .Leading,
                multiplier: 1.0,
                constant: 10))
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: scrollView,
                attribute: .Trailing,
                multiplier: 1.0,
                constant: 10))
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: scrollView,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0))
            
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[eventMessageLabel]-10-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["eventMessageLabel": eventMessageLabel]))
        }
        
        return eventDetail.window
    }
    
    //MARK: Offline hits
    
    /**
     Create offline hits window
     */
    @objc func createOfflineHitsViewer() {
        let offlineHits: (window: DebuggerView, content: DebuggerView, menu: DebuggerTopBar, windowTitle: String) = self.createWindow("Offline Hits")
        offlineHits.window.alpha = 0.0;
        offlineHits.window.hidden = false
        offlineHits.content.alpha = 1.0
        offlineHits.menu.alpha = 1.0
        
        windowTitleLabel.text = offlineHits.windowTitle
        
        let backButton = DebuggerButton()
        
        offlineHits.menu.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setBackgroundImage(UIImage(named: "back64", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        backButton.tag = self.windows.count - 1
        backButton.addTarget(self, action: #selector(Debugger.backButtonWasTouched(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[backButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-14-[backButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: backButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: offlineHits.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        let trashButton = UIButton()
        
        offlineHits.menu.addSubview(trashButton)
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        trashButton.setBackgroundImage(UIImage(named: "trash64", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        trashButton.addTarget(self, action: #selector(Debugger.trashOfflineHits), forControlEvents: UIControlEvents.TouchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[trashButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[trashButton]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: offlineHits.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        let refreshButton = DebuggerButton()
        
        offlineHits.menu.addSubview(refreshButton)
        
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        refreshButton.setBackgroundImage(UIImage(named: "refresh64", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: #selector(Debugger.refreshOfflineHits), forControlEvents: UIControlEvents.TouchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[refreshButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["refreshButton": refreshButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[refreshButton(==32)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["refreshButton": refreshButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: refreshButton,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 10))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: refreshButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: offlineHits.menu,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0))
        
        getOfflineHitsList(offlineHits)
        
        hidePreviousWindowMenuButtons(offlineHits.window)
    }
    
    /**
     Refresh offline hits list
     */
    @objc func refreshOfflineHits() {
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    /**
     Builds offline hits list rows
     */
    func getOfflineHitsList(offlineHits: (window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String)) {

        let scrollViews = offlineHits.content.subviews.filter({ return $0 is UIScrollView }) as! [UIScrollView]
        let emptyOfflineHitsView = offlineHits.content.subviews.filter() {
            if($0.tag == -2) {
                return true
            } else {
                return false
            }
        }
        
        if(scrollViews.count > 0) {
            scrollViews[0].removeFromSuperview()
        }
        
        if(emptyOfflineHitsView.count > 0) {
            emptyOfflineHitsView[0].removeFromSuperview()
        }
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.scrollEnabled = true
        scrollView.userInteractionEnabled = true
        
        offlineHits.content.addSubview(scrollView)
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: offlineHits.content,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: offlineHits.content,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: offlineHits.content,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: offlineHits.content,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0))
        
        var previousRow: DebuggerView!
        hits = storage.get()
        hits = hits.sort(sortOfflineHits)
        
        if(hits.count == 0) {
            let noOfflineHitsView = DebuggerView()
            noOfflineHitsView.tag = -2
            noOfflineHitsView.translatesAutoresizingMaskIntoConstraints = false
            noOfflineHitsView.layer.cornerRadius = 4.0
            noOfflineHitsView.backgroundColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1)
            
            offlineHits.content.addSubview(noOfflineHitsView)
            
            // height constraint
            offlineHits.content.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[noOfflineHitsView(==50)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["noOfflineHitsView": noOfflineHitsView]))
            
            offlineHits.content.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[noOfflineHitsView]-30-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["noOfflineHitsView": noOfflineHitsView]))
            
            // align messageLabel from the top and bottom
            offlineHits.content.addConstraint(NSLayoutConstraint(item: noOfflineHitsView,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: offlineHits.content,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0))
            
            let emptyContentLabel = UILabel()
            emptyContentLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyContentLabel.text = "No stored hit"
            emptyContentLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            emptyContentLabel.sizeToFit()
            
            noOfflineHitsView.addSubview(emptyContentLabel)
            
            noOfflineHitsView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: noOfflineHitsView,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0))
            
            noOfflineHitsView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: noOfflineHitsView,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0))
        } else {
            for(i, hit) in hits.enumerate() {
                let rowView = DebuggerView()
                rowView.translatesAutoresizingMaskIntoConstraints = false
                rowView.userInteractionEnabled = true
                rowView.tag = i
                rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Debugger.offlineHitRowSelected(_:))))
                
                scrollView.addSubview(rowView)
                
                scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[rowView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
                
                if(i == 0) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: scrollView,
                        attribute: .Top,
                        multiplier: 1.0,
                        constant: 0))
                    
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .CenterX,
                        relatedBy: .Equal,
                        toItem: scrollView,
                        attribute: .CenterX,
                        multiplier: 1.0,
                        constant: 0))
                } else {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: previousRow,
                        attribute: .Bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                if(i % 2 == 0) {
                    rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                } else {
                    rowView.backgroundColor = UIColor.whiteColor()
                }
                
                if(i == hits.count - 1) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .Bottom,
                        relatedBy: .Equal,
                        toItem: scrollView,
                        attribute: .Bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                let dateLabel = UILabel()
                let messageLabel = UILabel()
                let hitTypeView = UIImageView()
                let deleteButton = DebuggerButton()
                
                dateLabel.translatesAutoresizingMaskIntoConstraints = false
                messageLabel.translatesAutoresizingMaskIntoConstraints = false
                hitTypeView.translatesAutoresizingMaskIntoConstraints = false
                deleteButton.translatesAutoresizingMaskIntoConstraints = false
                
                rowView.addSubview(dateLabel)
                rowView.addSubview(messageLabel)
                rowView.addSubview(hitTypeView)
                rowView.addSubview(deleteButton)
                
                /******* DATE ********/
                dateLabel.text = dateHourFormatter.stringFromDate(hit.creationDate)
                dateLabel.sizeToFit();
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .Left,
                    multiplier: 1.0,
                    constant: 5))
                
                rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .CenterY,
                    multiplier: 1.0,
                    constant: 0))
                /******* END DATE ********/
                
                /******* HIT ********/
                messageLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                messageLabel.baselineAdjustment = UIBaselineAdjustment.None
                messageLabel.text = hit.url
                
                rowView.addConstraint(NSLayoutConstraint(item: messageLabel,
                    attribute: .Left,
                    relatedBy: .Equal,
                    toItem: dateLabel,
                    attribute: .Right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[messageLabel]-12-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["messageLabel": messageLabel]))
                
                /******* END HIT ********/
                
                /******* HIT TYPE ********/
                switch(hit.getHitType()) {
                case Hit.HitType.Touch:
                    hitTypeView.image = UIImage(named: "touch48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
                case Hit.HitType.AdTracking:
                    hitTypeView.image = UIImage(named: "tv48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
                case Hit.HitType.Audio:
                    hitTypeView.image = UIImage(named: "audio48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
                case Hit.HitType.Video:
                    hitTypeView.image = UIImage(named: "video48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
                case Hit.HitType.ProductDisplay:
                    hitTypeView.image = UIImage(named: "product48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
                default:
                    hitTypeView.image = UIImage(named: "smartphone48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
                }
                
                rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                    attribute: .Left,
                    relatedBy: NSLayoutRelation.GreaterThanOrEqual,
                    toItem: messageLabel,
                    attribute: .Right,
                    multiplier: 1.0,
                    constant: 10))
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .CenterY,
                    multiplier: 1.0,
                    constant: -1))
                
                // width constraint
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
                
                // height constraint
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[hitTypeView(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
                
                /******* DELETE BUTTON ********/
                
                deleteButton.setBackgroundImage(UIImage(named: "trash48", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                deleteButton.tag = i
                deleteButton.addTarget(self, action: #selector(Debugger.deleteOfflineHit(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                rowView.addConstraint(NSLayoutConstraint(item: deleteButton,
                    attribute: .Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: hitTypeView,
                    attribute: .Trailing,
                    multiplier: 1.0,
                    constant: 10))
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: deleteButton,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: rowView,
                    attribute: .CenterY,
                    multiplier: 1.0,
                    constant: -1))
                
                // width constraint
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[deleteButton(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                // height constraint
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[deleteButton(==24)]", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                rowView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[deleteButton]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                previousRow = rowView
            }
        }
    }
    
    /**
     Offline hit list row selected
     */
    @objc func offlineHitRowSelected(recogniser: UIPanGestureRecognizer) {
        self.windows[1].content.hidden = true
        
        if let row = recogniser.view {
            let window = createEventDetailView(hits[row.tag].url)
            
            hidePreviousWindowMenuButtons(window)
        }
    }
    
    /**
     Delete offline hit
     */
    @objc func deleteOfflineHit(sender: UIButton) {
        //let storage = Storage(concurrencyType: .MainQueueConcurrencyType)
        storage.delete(hits[sender.tag].url)
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    /**
     Delete all offline hits
     */
    @objc func trashOfflineHits() {
        storage.delete()
        
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    //MARK: Window management
    
    /**
     Create a new window
     */
    func createWindow(windowTitle: String) -> (window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String) {

        let window = DebuggerView()
        if(windows.count == 0) {
            window.backgroundColor = UIColor.whiteColor()
            window.layer.shadowOffset = CGSizeMake(1, 1)
            window.layer.shadowRadius = 4.0
            window.layer.shadowColor = UIColor.blackColor().CGColor
            window.layer.shadowOpacity = 0.2
        } else {
            window.backgroundColor = UIColor.clearColor()
        }
        
        window.frame = CGRectMake(self.applicationWindow!.frame.width - 47, self.applicationWindow!.frame.height - 93, 0, 0)
        window.layer.borderColor = UIColor(red:211/255.0, green:215/255.0, blue:220/255.0, alpha:1.0).CGColor
        window.layer.borderWidth = 1.0
        window.layer.cornerRadius = 4.0
        
        window.translatesAutoresizingMaskIntoConstraints = false
        window.hidden = true
        
        let windowId = "window" + String(self.windows.count)
        
        self.applicationWindow!.addSubview(window)
        
        if(windows.count == 0) {
            self.applicationWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[" + windowId + "]-10-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[windowId: window]))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.applicationWindow!,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0,
                constant: 30))
            
            let popupVsButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                                                             attribute: .Top,
                                                             relatedBy: .Equal,
                                                             toItem: window,
                                                             attribute: .Bottom,
                                                             multiplier: 1.0,
                                                             constant: 10.0)
            
            self.applicationWindow!.addConstraint(popupVsButtonConstraint)
        } else {
            self.applicationWindow!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[" + windowId + "]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[windowId: window]))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.applicationWindow!,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0,
                constant: 30))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.Width,
                relatedBy: .Equal,
                toItem: windows[0].window,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 0.0))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutAttribute.Height,
                relatedBy: .Equal,
                toItem: windows[0].window,
                attribute: NSLayoutAttribute.Height,
                multiplier: 1.0,
                constant: 0.0))
        }
        
        let menu = DebuggerTopBar()
        menu.alpha = 0.0;
        if(windows.count == 0) {
            menu.backgroundColor = UIColor(red: 7/255.0, green: 39/255, blue: 80/255, alpha: 1.0)
        } else {
            menu.backgroundColor = UIColor.clearColor()
        }
        
        window.addSubview(menu)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        let menuId = "menu" + String(self.windows.count)
        
        // align topBar from the left and right
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[" + menuId + "]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[menuId : menu]))
        
        // align topBar from the top
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[" + menuId + "]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[menuId: menu]))
        
        // height constraint
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[" + menuId + "(==60)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[menuId: menu]))
        
        let contentId = "content" + String(self.windows.count)
        
        let content = DebuggerView()
        content.frame = window.frame;
        content.backgroundColor = UIColor.whiteColor()
        content.alpha = 0.0;
        content.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(content)
        
        // align eventLogContent from the left and right
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[" + contentId + "]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[contentId: content]))
        
        // align eventLogContent from the top and bottom@
        window.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[" + contentId + "]-3-|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views:[contentId: content]))
        
        window.addConstraint(NSLayoutConstraint(item: content,
            attribute: NSLayoutAttribute.Top,
            relatedBy: .Equal,
            toItem: menu,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: 0.0))
        
        let tuple: (window: DebuggerView, content: DebuggerView, menu: DebuggerTopBar, windowTitle: String) = (window: window, content: content, menu: menu, windowTitle: windowTitle)

        windows.append(tuple)
        
        return tuple
    }
    
    /**
     Back button pressed
     */
    @objc func backButtonWasTouched(sender:DebuggerButton) {
        for(_, view) in self.windows[sender.tag - 1].menu.subviews.enumerate() {
            if let button = view as? DebuggerButton {
                button.hidden = false
            }
        }
        
        windowTitleLabel.text = self.windows[sender.tag - 1].windowTitle
        self.windows[sender.tag - 1].content.hidden = false
        
        windows[sender.tag].window.removeFromSuperview()
        self.windows.removeAtIndex(sender.tag)
    }
    
    /**
     Hide menu buttons from previous window
     
     - parameter window: where buttons need to be hidden
     */
    private func hidePreviousWindowMenuButtons(window: DebuggerView) {
        UIView.animateWithDuration(
            0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                for(_, view) in self.windows[self.windows.count - 2].menu.subviews.enumerate() {
                    if let button = view as? UIButton {
                        button.hidden = true
                    }
                }
                
                window.alpha = 1.0;
            },
            completion: nil
        )
    }
    
    /**
     Sort hit by date from most recent to oldest
     
     - parameter first: hit to compare
     - parameter second: hit
     
     */
    func sortOfflineHits(hit1: Hit, hit2: Hit) -> Bool {
        return hit1.creationDate.timeIntervalSince1970 > hit2.creationDate.timeIntervalSince1970
    }
}

/**
Event class
*/
public class DebuggerEvent: NSObject {
    /// Date of event
    var date: NSDate
    /// Event message
    var message: String
    /// Type of event
    var type: String
    
    override init() {
        date = NSDate()
        message = ""
        type = "sent48"
    }
}

/**
 Rounded corner for debugger menu
 */
class DebuggerTopBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.TopRight], cornerRadii: CGSizeMake(4, 4))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        self.layer.mask = maskLayer
    }
}
