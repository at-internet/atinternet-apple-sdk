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

#if canImport(UIKit)
import UIKit
#endif

#if os(iOS) && !AT_EXTENSION
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
    lazy var applicationWindow: UIWindow? = UIApplication.shared.keyWindow
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
    let hourFormatter = DateFormatter()
    /// Date formatter (dd/MM/yyyy HH:mm:ss)
    let dateHourFormatter = DateFormatter()
    /// Debugger is initialize
    var initialized: Bool = false
    /// Offline storage
    var storage: StorageProtocol!
    let images: [String:String?] = {
        return [
            "atinternet-logo@2x": pathFor(asset: "atinternet-logo@2x"),
            "back64@2x": pathFor(asset: "back64@2x"),
            "database64@2x": pathFor(asset: "database64@2x"),
            "error48@2x": pathFor(asset: "error48@2x"),
            "info48@2x": pathFor(asset: "info48@2x"),
            "refresh64@2x": pathFor(asset: "refresh64@2x"),
            "save48@2x": pathFor(asset: "save48@2x"),
            "sent48@2x": pathFor(asset: "sent48@2x"),
            "smartphone48@2x": pathFor(asset: "smartphone48@2x"),
            "target32@2X": pathFor(asset: "target32@2X"),
            "touch48@2x": pathFor(asset: "touch48@2x"),
            "trash48@2x": pathFor(asset: "trash48@2x"),
            "trash64@2x": pathFor(asset: "trash64@2x"),
            "tv48@2x": pathFor(asset: "tv48@2x"),
            "product48@2x": pathFor(asset: "product48@2x"),
            "audio48@2x": pathFor(asset: "audio48@2x"),
            "video48@2x": pathFor(asset: "video48@2x"),
            "warning48@2x": pathFor(asset: "warning48@2x")
         ]
    }()
    
    
    class var sharedInstance: Debugger {
        _ = Debugger.__once
        
        return Static.instance!
    }
    
    /**
     Add debugger to view controller
     */
    func initDebugger(offlineMode: String) {
        storage = Storage.sharedInstanceOf(offlineMode, forceStorageAccess: true)
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
        
        for(_, window) in self.windows.enumerated() {
            window.window.removeFromSuperview()
        }
        
        self.windows.removeAll(keepingCapacity: false)
    }
    
    /**
     Add an event to the event list
     */
    func addEvent(_ message: String, icon: String) {
        let event = DebuggerEvent()
        event.date = Date()
        event.type = icon
        event.message = message
        
        self.receivedEvents.insert(event, at: 0)
        DispatchQueue.main.sync(execute: {
            self.addEventToList()
        })
        
    }
    
    // MARK: Debug button
    
    /**
     Create debug button
     */
    func createDebugButton() {
        if let logo = images["atinternet-logo@2x"] ?? nil {
            debugButton.setBackgroundImage(UIImage(named: logo), for: UIControl.State())
        }
        debugButton.frame = CGRect(x: 0, y: 0, width: 94, height: 73)
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        debugButton.alpha = 0
        
        applicationWindow!.addSubview(debugButton)
        
        // align atButton from the left
        if(debugButtonPosition == "Right") {
            debugButtonConstraint = NSLayoutConstraint(item: debugButton,
                                                       attribute: NSLayoutConstraint.Attribute.trailing,
                                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                                       toItem: applicationWindow!,
                                                       attribute: NSLayoutConstraint.Attribute.trailing,
                                                       multiplier: 1.0,
                                                       constant: 0)
        } else {
            debugButtonConstraint = NSLayoutConstraint(item: debugButton,
                                                       attribute: NSLayoutConstraint.Attribute.leading,
                                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                                       toItem: applicationWindow!,
                                                       attribute: NSLayoutConstraint.Attribute.leading,
                                                       multiplier: 1.0,
                                                       constant: 0)
        }
        
        applicationWindow!.addConstraint(debugButtonConstraint)
        
        applicationWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[debugButton]-10-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["debugButton": self.debugButton]))
        
        // width constraint
        applicationWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[debugButton(==94)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["debugButton": debugButton]))
        
        // height constraint
        applicationWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[debugButton(==73)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["debugButton": debugButton]))
        
        debugButton.addTarget(self, action: #selector(Debugger.debuggerTouched), for: UIControl.Event.touchUpInside)
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            options: UIView.AnimationOptions.curveLinear,
            animations: {
                self.debugButton.alpha = 1.0;
            },
            completion: nil)
    }
    
    /**
     Debug button was dragged (change postion from left to right ...)
     */
    @objc func debugButtonWasDragged(_ recogniser: UIPanGestureRecognizer) {
        let button = recogniser.view as! DebuggerButton
        let translation = recogniser.translation(in: button)
        
        let velocity = recogniser.velocity(in: button)
        
        if (recogniser.state == UIGestureRecognizer.State.changed)
        {
            button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y)
            recogniser.setTranslation(CGPoint.zero, in: button)
        }
        else if (recogniser.state == UIGestureRecognizer.State.ended)
        {
            if(velocity.x < 0) {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.debugButtonConstraint.constant = (self.applicationWindow!.frame.width - button.frame.width) * -1
                    self.applicationWindow!.layoutIfNeeded()
                    self.applicationWindow!.updateConstraints()
                    }, completion: {
                        finished in
                        self.debugButtonPosition = "Left"
                        self.applicationWindow!.removeConstraint(self.debugButtonConstraint)
                        
                        self.debugButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                            attribute: NSLayoutConstraint.Attribute.leading,
                            relatedBy: NSLayoutConstraint.Relation.equal,
                            toItem: self.applicationWindow!,
                            attribute: NSLayoutConstraint.Attribute.leading,
                            multiplier: 1.0,
                            constant: 0)
                        
                        self.applicationWindow!.addConstraint(self.debugButtonConstraint)
                })
            } else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.debugButtonConstraint.constant = (self.applicationWindow!.frame.width - button.frame.width)
                    self.applicationWindow!.layoutIfNeeded()
                    self.applicationWindow!.updateConstraints()
                    }, completion: {
                        finished in
                        self.debugButtonPosition = "Right"
                        self.applicationWindow!.removeConstraint(self.debugButtonConstraint)
                        
                        self.debugButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                            attribute: NSLayoutConstraint.Attribute.trailing,
                            relatedBy: NSLayoutConstraint.Relation.equal,
                            toItem: self.applicationWindow!,
                            attribute: NSLayoutConstraint.Attribute.trailing,
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
            w.window.isHidden = false
        }
        
        if(self.debuggerShown && !debuggerAnimating) {
            debuggerAnimating = true
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: UIView.AnimationOptions.curveLinear,
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
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: {
                if(self.debuggerShown) {
                    if(self.debugButtonPosition == "Right") {
                        for w in self.windows {
                            w.window.frame = CGRect(x: self.applicationWindow!.frame.width - 47, y: self.applicationWindow!.frame.height - 93, width: 0, height: 0)
                        }
                    } else {
                        for w in self.windows {
                            w.window.frame = CGRect(x: 47, y: self.applicationWindow!.frame.height - 93, width: 0, height: 0)
                        }
                    }
                } else {
                    for w in self.windows {
                        
                        w.window.frame = CGRect(x: 10, y: 30, width: self.applicationWindow!.frame.width - 20, height: self.applicationWindow!.frame.height - 93 - 30)
                    }
                }
            },
            completion: {
                finished in
                
                if(!self.debuggerShown) {
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0.0,
                        options: UIView.AnimationOptions.curveLinear,
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
                        w.window.isHidden = true
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
        if let db = images["database64@2x"] ?? nil {
            offlineButton.setBackgroundImage(UIImage(named: db), for: UIControl.State())
        }
        offlineButton.addTarget(self, action: #selector(Debugger.createOfflineHitsViewer), for: UIControl.Event.touchUpInside)
        
        eventViewer.menu.addSubview(offlineButton)
        
        // width constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[offlineButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        // height constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[offlineButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[offlineButton]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["offlineButton": offlineButton]))
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: offlineButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        windowTitleLabel.text = eventViewer.windowTitle
        windowTitleLabel.textColor = UIColor.white
        windowTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        eventViewer.menu.addSubview(windowTitleLabel)
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: windowTitleLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: windowTitleLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0))
        
        let trashButton = DebuggerButton()
        
        eventViewer.menu.addSubview(trashButton)
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let trash = pathFor(asset: "trash64@2x") {
            trashButton.setBackgroundImage(UIImage(named: trash), for: UIControl.State())
        }
        trashButton.addTarget(self, action: #selector(Debugger.trashEvents), for: UIControl.Event.touchUpInside)
        
        // width constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // height constraint
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[trashButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        eventViewer.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton]-10-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // align messageLabel from the top and bottom
        eventViewer.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventViewer.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        getEventsList(eventViewer)
    }
    
    /**
     Builds offline hits list rows
     */
    func getEventsList(_ eventViewer: (window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String)) {
        
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
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        scrollView.tag = -100
        
        eventViewer.content.addSubview(scrollView)
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .top,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .top,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0))
        
        eventViewer.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: eventViewer.content,
            attribute: .trailing,
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
            eventViewer.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[emptyContentView(==50)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["emptyContentView": emptyContentView]))
            
            eventViewer.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[emptyContentView]-30-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["emptyContentView": emptyContentView]))
            
            // align messageLabel from the top and bottom
            eventViewer.content.addConstraint(NSLayoutConstraint(item: emptyContentView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: eventViewer.content,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            let emptyContentLabel = UILabel()
            emptyContentLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyContentLabel.text = "No event detected"
            emptyContentLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            emptyContentLabel.sizeToFit()
            
            emptyContentView.addSubview(emptyContentLabel)
            
            emptyContentView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: emptyContentView,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            emptyContentView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: emptyContentView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
        } else {
            previousConstraintForEvents = nil
            var previous: DebuggerView?
            for (i,event) in receivedEvents.enumerated() {
                previous = buildEventRow(event, tag: i, scrollView: scrollView, previousRow: previous)
            }
        }
    }
    
    var previousConstraintForEvents: NSLayoutConstraint!
    func buildEventRow(_ event: DebuggerEvent, tag: Int, scrollView: UIScrollView, previousRow: DebuggerView?) -> DebuggerView {
        let rowView = DebuggerView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        rowView.isUserInteractionEnabled = true
        rowView.tag = tag
        rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Debugger.eventRowSelected(_:))))
        
        scrollView.insertSubview(rowView, at: 0)
        
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[rowView]-0-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
        
        if previousConstraintForEvents != nil {
            scrollView.removeConstraint(previousConstraintForEvents)
        }
        
        previousConstraintForEvents = NSLayoutConstraint(item: rowView,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: scrollView,
                                                         attribute: .top,
                                                         multiplier: 1.0,
                                                         constant: 0)
        scrollView.addConstraint(previousConstraintForEvents)
        
        
        if(tag == 0) {
            scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
            
            scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0))
        } else {
            if let previous = previousRow {
                scrollView.addConstraint(NSLayoutConstraint(item: previous,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .bottom,
                    multiplier: 1.0,
                    constant: 0))
            }
        }
        
        if(tag % 2 == 0) {
            rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        } else {
            rowView.backgroundColor = UIColor.white
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
        iconView.image = UIImage(named: event.type, in: Bundle(for: Tracker.self), compatibleWith: nil)
        
        rowView.addConstraint(NSLayoutConstraint(item: iconView,
            attribute: .left,
            relatedBy: .equal,
            toItem: rowView,
            attribute: .left,
            multiplier: 1.0,
            constant: 5))
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: iconView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: rowView,
            attribute: .centerY,
            multiplier: 1.0,
            constant: -1))
        
        // width constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[iconView(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["iconView": iconView]))
        
        // height constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[iconView(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["iconView": iconView]))
        /******* END ICON ********/
        
        /******* DATE ********/
        dateLabel.text = hourFormatter.string(from: event.date)
        dateLabel.sizeToFit();
        dateLabel.textColor = UIColor.black
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
            attribute: .left,
            relatedBy: .equal,
            toItem: iconView,
            attribute: .right,
            multiplier: 1.0,
            constant: 5))
        
        rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: rowView,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        /******* END DATE ********/
        
        /******* HIT ********/
        messageLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        messageLabel.baselineAdjustment = UIBaselineAdjustment.none
        messageLabel.text = event.message
        messageLabel.textColor = UIColor.black
        
        rowView.addConstraint(NSLayoutConstraint(item: messageLabel,
            attribute: .left,
            relatedBy: .equal,
            toItem: dateLabel,
            attribute: .right,
            multiplier: 1.0,
            constant: 10))
        
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[messageLabel]-12-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["messageLabel": messageLabel]))
        
        /******* END HIT ********/
        
        /******* HIT TYPE ********/
        let URL = Foundation.URL(string: event.message)
        
        if let optURL = URL {
            hitTypeView.isHidden = false
            
            let hit = Hit(url: optURL.absoluteString)
            var image: String? = nil
            switch(hit.getHitType()) {
            case Hit.HitType.touch:
                image = images["touch48@2x"] ?? nil
            case Hit.HitType.adTracking:
                image = images["tv48@2x"] ?? nil
            case Hit.HitType.audio:
                image = images["audio48@2x"] ?? nil
            case Hit.HitType.video:
                image = images["video48@2x"] ?? nil
            case Hit.HitType.productDisplay:
                image = images["product48@2x"] ?? nil
            default:
                image = images["smartphone48@2x"] ?? nil
            }
            if let img = image {
                hitTypeView.image = UIImage(named: img)
            }
        } else {
            hitTypeView.isHidden = true
        }
        
        rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
            attribute: .left,
            relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
            toItem: messageLabel,
            attribute: .right,
            multiplier: 1.0,
            constant: 10))
        
        // align iconView from the top and bottom
        rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: rowView,
            attribute: .centerY,
            multiplier: 1.0,
            constant: -1))
        
        // width constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hitTypeView(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        // height constraint
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[hitTypeView(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
        rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hitTypeView]-5-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
        
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
        
        _ = buildEventRow(self.receivedEvents[0], tag: self.receivedEvents.count - 1, scrollView: scrollview, previousRow: scrollview.viewWithTag(self.receivedEvents.count - 2) as! DebuggerView?)
    }
    
    /**
     event list row selected
     */
    @objc func eventRowSelected(_ recogniser: UIPanGestureRecognizer) {
        self.windows[0].content.isHidden = true
        
        if let row = recogniser.view {
            let window = createEventDetailView(receivedEvents[(receivedEvents.count - 1) - row.tag].message)
            
            hidePreviousWindowMenuButtons(window)
        }
    }
    
    /**
     Delete received events
     */
    @objc func trashEvents() {
        self.receivedEvents.removeAll(keepingCapacity: false)
        updateEventList()
    }
    
    //MARK: Event detail
    
    /**
     Create event detail window
     
     - parameter hit: or message to display
     */
    func createEventDetailView(_ hit: String) -> DebuggerView {
        var eventDetail: (window: DebuggerView, content: DebuggerView, menu: DebuggerTopBar, windowTitle: String) = self.createWindow("Hit Detail")
        eventDetail.window.alpha = 0.0;
        eventDetail.window.isHidden = false
        eventDetail.content.alpha = 1.0
        eventDetail.menu.alpha = 1.0
        
        let backButton = DebuggerButton()
        
        eventDetail.menu.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let back = images["back64@2x"] ?? nil {
            backButton.setBackgroundImage(UIImage(named: back), for: UIControl.State())
        }
        backButton.tag = self.windows.count - 1
        backButton.addTarget(self, action: #selector(Debugger.backButtonWasTouched(_:)), for: UIControl.Event.touchUpInside)
        
        // width constraint
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // height constraint
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[backButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        eventDetail.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[backButton]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // align messageLabel from the top and bottom
        eventDetail.menu.addConstraint(NSLayoutConstraint(item: backButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: eventDetail.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        eventDetail.content.addSubview(scrollView)
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .top,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .top,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0))
        
        eventDetail.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: eventDetail.content,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0))
        
        let URL = Foundation.URL(string: hit)
        
        if let optURL = URL {
            eventDetail.windowTitle = "Hit detail"
            windowTitleLabel.text = eventDetail.windowTitle
            
            var urlComponents: [(key: String, value: String)] = []
            
            let sslComponent: (key: String, value: String) = (key: "ssl", value: optURL.scheme == "http" ? "Off" : "On")
            urlComponents.append(sslComponent)
            
            let logComponent: (key: String, value: String) = (key: "log", value: optURL.host!)
            urlComponents.append(logComponent)
            
            let queryStringComponents = optURL.query!.components(separatedBy: "&")
            
            for (_,component) in (queryStringComponents as [String]).enumerated() {
                let pairComponents = component.components(separatedBy: "=")
                
                urlComponents.append((key: pairComponents[0], value: pairComponents[1].percentDecodedString))
            }
            
            var i: Int = 0
            var previousRow: DebuggerView!
            
            for(key, value) in urlComponents {
                let rowView = DebuggerView()
                rowView.translatesAutoresizingMaskIntoConstraints = false
                
                scrollView.addSubview(rowView)
                
                scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[rowView]-0-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
                
                if(i == 0) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 0))
                    
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .centerX,
                        multiplier: 1.0,
                        constant: 0))
                } else {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: previousRow,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                if(i % 2 == 0) {
                    rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                } else {
                    rowView.backgroundColor = UIColor.white
                }
                
                if(i == urlComponents.count - 1) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                let variableLabel = UILabel()
                variableLabel.translatesAutoresizingMaskIntoConstraints = false
                variableLabel.text = key
                variableLabel.textColor = UIColor.black
                variableLabel.textAlignment = NSTextAlignment.right
                variableLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                
                rowView.addSubview(variableLabel)
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[variableLabel(==100)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["variableLabel": variableLabel]))
                
                rowView.addConstraint(NSLayoutConstraint(item: variableLabel,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .top,
                    multiplier: 1.0,
                    constant: 12))
                
                rowView.addConstraint(NSLayoutConstraint(item: rowView,
                    attribute: .bottom,
                    relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
                    toItem: variableLabel,
                    attribute: .bottom,
                    multiplier: 1.0,
                    constant: 12))
                
                rowView.addConstraint(NSLayoutConstraint(item: variableLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .left,
                    multiplier: 1.0,
                    constant: 0))
                
                let columnSeparator = DebuggerView()
                columnSeparator.translatesAutoresizingMaskIntoConstraints = false
                columnSeparator.backgroundColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
                
                rowView.addSubview(columnSeparator)
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[columnSeparator(==1)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["columnSeparator": columnSeparator]))
                
                rowView.addConstraint(NSLayoutConstraint(item: columnSeparator,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: variableLabel,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[columnSeparator]-0-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["columnSeparator": columnSeparator]))
                
                let valueLabel = UILabel()
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                
                if let optValue: Any = value.toJSONObject() {
                    if(key == "stc") {
                        valueLabel.text = Tool.JSONStringify(optValue, prettyPrinted: true)
                    } else {
                        valueLabel.text = value
                    }
                } else {
                    valueLabel.text = value
                }
                valueLabel.textColor = UIColor.black
                valueLabel.textAlignment = NSTextAlignment.left
                valueLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                valueLabel.numberOfLines = 0
                
                rowView.addSubview(valueLabel)
                
                rowView.addConstraint(NSLayoutConstraint(item: valueLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: columnSeparator,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraint(NSLayoutConstraint(item: valueLabel,
                    attribute: .right,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[valueLabel]-12-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["valueLabel": valueLabel]))
                
                previousRow = rowView
                
                i += 1
            }
        } else {
            eventDetail.windowTitle = "Event detail"
            windowTitleLabel.text = eventDetail.windowTitle
            
            let eventMessageLabel = UILabel()
            eventMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            eventMessageLabel.text = hit
            eventMessageLabel.textColor = UIColor.black
            eventMessageLabel.textAlignment = NSTextAlignment.left
            eventMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            eventMessageLabel.numberOfLines = 0
            
            scrollView.addSubview(eventMessageLabel)
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .leading,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .leading,
                multiplier: 1.0,
                constant: 10))
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .trailing,
                multiplier: 1.0,
                constant: 10))
            
            scrollView.addConstraint(NSLayoutConstraint(item: eventMessageLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
            
            scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[eventMessageLabel]-10-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["eventMessageLabel": eventMessageLabel]))
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
        offlineHits.window.isHidden = false
        offlineHits.content.alpha = 1.0
        offlineHits.menu.alpha = 1.0
        
        windowTitleLabel.text = offlineHits.windowTitle
        
        let backButton = DebuggerButton()
        
        offlineHits.menu.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        if let back = images["back64@2x"] ?? nil {
            backButton.setBackgroundImage(UIImage(named: back), for: UIControl.State())
        }
        backButton.tag = self.windows.count - 1
        backButton.addTarget(self, action: #selector(Debugger.backButtonWasTouched(_:)), for: UIControl.Event.touchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[backButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[backButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[backButton]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["backButton": backButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: backButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: offlineHits.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        let trashButton = UIButton()
        
        offlineHits.menu.addSubview(trashButton)
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let trash = images["trash64@2x"] ?? nil {
            trashButton.setBackgroundImage(UIImage(named: trash), for: UIControl.State())
        }
        trashButton.addTarget(self, action: #selector(Debugger.trashOfflineHits), for: UIControl.Event.touchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[trashButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[trashButton]-10-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["trashButton": trashButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: offlineHits.menu,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0))
        
        let refreshButton = DebuggerButton()
        
        offlineHits.menu.addSubview(refreshButton)
        
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let refresh = images["refresh64@2x"] ?? nil {
            refreshButton.setBackgroundImage(UIImage(named: refresh), for: UIControl.State())
        }
        refreshButton.addTarget(self, action: #selector(Debugger.refreshOfflineHits), for: UIControl.Event.touchUpInside)
        
        // width constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[refreshButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["refreshButton": refreshButton]))
        
        // height constraint
        offlineHits.menu.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[refreshButton(==32)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["refreshButton": refreshButton]))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: trashButton,
            attribute: .leading,
            relatedBy: .equal,
            toItem: refreshButton,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 10))
        
        // align messageLabel from the top and bottom
        offlineHits.menu.addConstraint(NSLayoutConstraint(item: refreshButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: offlineHits.menu,
            attribute: .centerY,
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
    func getOfflineHitsList(_ offlineHits: (window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String)) {
        
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
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        offlineHits.content.addSubview(scrollView)
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .top,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .top,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0))
        
        offlineHits.content.addConstraint(NSLayoutConstraint(item: scrollView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: offlineHits.content,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0))
        
        var previousRow: DebuggerView!
        hits = storage.get()
        hits = hits.sorted(by: sortOfflineHits)
        
        if(hits.count == 0) {
            let noOfflineHitsView = DebuggerView()
            noOfflineHitsView.tag = -2
            noOfflineHitsView.translatesAutoresizingMaskIntoConstraints = false
            noOfflineHitsView.layer.cornerRadius = 4.0
            noOfflineHitsView.backgroundColor = UIColor(red: 139/255.0, green: 139/255.0, blue: 139/255.0, alpha: 1)
            
            offlineHits.content.addSubview(noOfflineHitsView)
            
            // height constraint
            offlineHits.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[noOfflineHitsView(==50)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["noOfflineHitsView": noOfflineHitsView]))
            
            offlineHits.content.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[noOfflineHitsView]-30-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["noOfflineHitsView": noOfflineHitsView]))
            
            // align messageLabel from the top and bottom
            offlineHits.content.addConstraint(NSLayoutConstraint(item: noOfflineHitsView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: offlineHits.content,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            let emptyContentLabel = UILabel()
            emptyContentLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyContentLabel.text = "No stored hit"
            emptyContentLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            emptyContentLabel.sizeToFit()
            
            noOfflineHitsView.addSubview(emptyContentLabel)
            
            noOfflineHitsView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: noOfflineHitsView,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0))
            
            noOfflineHitsView.addConstraint(NSLayoutConstraint(item: emptyContentLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: noOfflineHitsView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0))
        } else {
            for(i, hit) in hits.enumerated() {
                let rowView = DebuggerView()
                rowView.translatesAutoresizingMaskIntoConstraints = false
                rowView.isUserInteractionEnabled = true
                rowView.tag = i
                rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Debugger.offlineHitRowSelected(_:))))
                
                scrollView.addSubview(rowView)
                
                scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[rowView]-0-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["rowView": rowView]))
                
                if(i == 0) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 0))
                    
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .centerX,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .centerX,
                        multiplier: 1.0,
                        constant: 0))
                } else {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: previousRow,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0))
                }
                
                if(i % 2 == 0) {
                    rowView.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
                } else {
                    rowView.backgroundColor = UIColor.white
                }
                
                if(i == hits.count - 1) {
                    scrollView.addConstraint(NSLayoutConstraint(item: rowView,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: scrollView,
                        attribute: .bottom,
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
                dateLabel.text = dateHourFormatter.string(from: hit.creationDate as Date)
                dateLabel.textColor = UIColor.black
                dateLabel.sizeToFit();
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .left,
                    multiplier: 1.0,
                    constant: 5))
                
                rowView.addConstraint(NSLayoutConstraint(item: dateLabel,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: 0))
                /******* END DATE ********/
                
                /******* HIT ********/
                messageLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                messageLabel.baselineAdjustment = UIBaselineAdjustment.none
                messageLabel.text = hit.url
                messageLabel.textColor = UIColor.black
                
                rowView.addConstraint(NSLayoutConstraint(item: messageLabel,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: dateLabel,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[messageLabel]-12-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["messageLabel": messageLabel]))
                
                /******* END HIT ********/
                
                /******* HIT TYPE ********/
                var image: String? = nil
                switch(hit.getHitType()) {
                case Hit.HitType.touch:
                    image = images["touch48@2x"] ?? nil
                case Hit.HitType.adTracking:
                    image = images["tv48@2x"] ?? nil
                case Hit.HitType.audio:
                    image = images["audio48@2x"] ?? nil
                case Hit.HitType.video:
                    image = images["video48@2x"] ?? nil
                case Hit.HitType.productDisplay:
                    image = images["product48@2x"] ?? nil
                default:
                    image = images["smartphone48@2x"] ?? nil
                }
                if let img = image {
                    hitTypeView.image = UIImage(named: img)
                }
                
                rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                    attribute: .left,
                    relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
                    toItem: messageLabel,
                    attribute: .right,
                    multiplier: 1.0,
                    constant: 10))
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: hitTypeView,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: -1))
                
                // width constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[hitTypeView(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
                
                // height constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[hitTypeView(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["hitTypeView": hitTypeView]))
                
                /******* DELETE BUTTON ********/
                if let trash = images["trash48@2x"] ?? nil {
                    deleteButton.setBackgroundImage(UIImage(named: trash), for: UIControl.State())
                }
                deleteButton.tag = i
                deleteButton.addTarget(self, action: #selector(Debugger.deleteOfflineHit(_:)), for: UIControl.Event.touchUpInside)
                
                rowView.addConstraint(NSLayoutConstraint(item: deleteButton,
                    attribute: .leading,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: hitTypeView,
                    attribute: .trailing,
                    multiplier: 1.0,
                    constant: 10))
                
                // align iconView from the top and bottom
                rowView.addConstraint(NSLayoutConstraint(item: deleteButton,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: rowView,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: -1))
                
                // width constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[deleteButton(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                // height constraint
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[deleteButton(==24)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                rowView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[deleteButton]-5-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:["deleteButton": deleteButton]))
                
                previousRow = rowView
            }
        }
    }
    
    /**
     Offline hit list row selected
     */
    @objc func offlineHitRowSelected(_ recogniser: UIPanGestureRecognizer) {
        self.windows[1].content.isHidden = true
        
        if let row = recogniser.view {
            let window = createEventDetailView(hits[row.tag].url)
            
            hidePreviousWindowMenuButtons(window)
        }
    }
    
    /**
     Delete offline hit
     */
    @objc func deleteOfflineHit(_ sender: UIButton) {
        _ = storage.delete(hits[sender.tag].id)
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    /**
     Delete all offline hits
     */
    @objc func trashOfflineHits() {
        _ = storage.delete()
        
        getOfflineHitsList(self.windows[self.windows.count - 1])
    }
    
    //MARK: Window management
    
    /**
     Create a new window
     */
    func createWindow(_ windowTitle: String) -> (window:DebuggerView, content:DebuggerView, menu: DebuggerTopBar, windowTitle: String) {
        let window = DebuggerView()
        if(windows.count == 0) {
            window.backgroundColor = UIColor.white
            window.layer.shadowOffset = CGSize(width: 1, height: 1)
            window.layer.shadowRadius = 4.0
            window.layer.shadowColor = UIColor.black.cgColor
            window.layer.shadowOpacity = 0.2
        } else {
            window.backgroundColor = UIColor.clear
        }
        
        window.frame = CGRect(x: self.applicationWindow!.frame.width - 47, y: self.applicationWindow!.frame.height - 93, width: 0, height: 0)
        window.layer.borderColor = UIColor(red:211/255.0, green:215/255.0, blue:220/255.0, alpha:1.0).cgColor
        window.layer.borderWidth = 1.0
        window.layer.cornerRadius = 4.0
        
        window.translatesAutoresizingMaskIntoConstraints = false
        window.isHidden = true
        
        let windowId = "window" + String(self.windows.count)
        
        self.applicationWindow!.addSubview(window)
        
        if(windows.count == 0) {
            self.applicationWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[" + windowId + "]-10-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[windowId: window]))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutConstraint.Attribute.top,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: self.applicationWindow!,
                attribute: NSLayoutConstraint.Attribute.top,
                multiplier: 1.0,
                constant: 30))
            
            let popupVsButtonConstraint = NSLayoutConstraint(item: self.debugButton,
                                                             attribute: .top,
                                                             relatedBy: .equal,
                                                             toItem: window,
                                                             attribute: .bottom,
                                                             multiplier: 1.0,
                                                             constant: 10.0)
            
            self.applicationWindow!.addConstraint(popupVsButtonConstraint)
        } else {
            self.applicationWindow!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[" + windowId + "]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[windowId: window]))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutConstraint.Attribute.top,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: self.applicationWindow!,
                attribute: NSLayoutConstraint.Attribute.top,
                multiplier: 1.0,
                constant: 30))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: .equal,
                toItem: windows[0].window,
                attribute: NSLayoutConstraint.Attribute.width,
                multiplier: 1.0,
                constant: 0.0))
            
            self.applicationWindow!.addConstraint(NSLayoutConstraint(item: window,
                attribute: NSLayoutConstraint.Attribute.height,
                relatedBy: .equal,
                toItem: windows[0].window,
                attribute: NSLayoutConstraint.Attribute.height,
                multiplier: 1.0,
                constant: 0.0))
        }
        
        let menu = DebuggerTopBar()
        menu.alpha = 0.0;
        if(windows.count == 0) {
            menu.backgroundColor = UIColor(red: 7/255.0, green: 39/255, blue: 80/255, alpha: 1.0)
        } else {
            menu.backgroundColor = UIColor.clear
        }
        
        window.addSubview(menu)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        let menuId = "menu" + String(self.windows.count)
        
        // align topBar from the left and right
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[" + menuId + "]-0-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[menuId : menu]))
        
        // align topBar from the top
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[" + menuId + "]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[menuId: menu]))
        
        // height constraint
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[" + menuId + "(==60)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[menuId: menu]))
        
        let contentId = "content" + String(self.windows.count)
        
        let content = DebuggerView()
        content.frame = window.frame;
        content.backgroundColor = UIColor.white
        content.alpha = 0.0;
        content.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(content)
        
        // align eventLogContent from the left and right
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[" + contentId + "]-0-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[contentId: content]))
        
        // align eventLogContent from the top and bottom@
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[" + contentId + "]-3-|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views:[contentId: content]))
        
        window.addConstraint(NSLayoutConstraint(item: content,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: .equal,
            toItem: menu,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1.0,
            constant: 0.0))
        
        let tuple: (window: DebuggerView, content: DebuggerView, menu: DebuggerTopBar, windowTitle: String) = (window: window, content: content, menu: menu, windowTitle: windowTitle)
        
        windows.append(tuple)
        
        return tuple
    }
    
    /**
     Back button pressed
     */
    @objc func backButtonWasTouched(_ sender:DebuggerButton) {
        for(_, view) in self.windows[sender.tag - 1].menu.subviews.enumerated() {
            if let button = view as? DebuggerButton {
                button.isHidden = false
            }
        }
        
        windowTitleLabel.text = self.windows[sender.tag - 1].windowTitle
        self.windows[sender.tag - 1].content.isHidden = false
        
        windows[sender.tag].window.removeFromSuperview()
        self.windows.remove(at: sender.tag)
    }
    
    /**
     Hide menu buttons from previous window
     
     - parameter window: where buttons need to be hidden
     */
    fileprivate func hidePreviousWindowMenuButtons(_ window: DebuggerView) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIView.AnimationOptions.curveLinear,
            animations: {
                for(_, view) in self.windows[self.windows.count - 2].menu.subviews.enumerated() {
                    if let button = view as? UIButton {
                        button.isHidden = true
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
    func sortOfflineHits(_ hit1: Hit, hit2: Hit) -> Bool {
        return hit1.creationDate.timeIntervalSince1970 > hit2.creationDate.timeIntervalSince1970
    }
}

/**
Event class
*/
class DebuggerEvent: NSObject {
    /// Date of event
    var date: Date
    /// Event message
    var message: String
    /// Type of event
    var type: String
    
    override init() {
        date = Date()
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
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: 4, height: 4))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
#endif
