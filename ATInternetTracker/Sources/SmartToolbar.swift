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
import AVFoundation

/* localizable texts */
let disconnectedText = NSLocalizedString("DISCONNECTED", tableName: nil, bundle: NSBundle(forClass: Tracker.self), value: "", comment: "content")
let pendingText = NSLocalizedString("PENDING", tableName: nil, bundle: NSBundle(forClass: Tracker.self), value: "", comment: "content")
let connectedText = NSLocalizedString("CONNECTED", tableName: nil, bundle: NSBundle(forClass: Tracker.self), value: "", comment: "content")

/// A movable toolbar to managed the pairing
class SmartToolbar: UIView {
    let refWindow: UIWindow?
    var windowConstraintLeft: NSLayoutConstraint?
    var windowConstraintTop: NSLayoutConstraint?
    var windowConstraintHeight: NSLayoutConstraint?
    var windowConstraintWidth: NSLayoutConstraint?
    var currentPointInWindow: CGPoint = CGPointZero
    var alreadyCalled = false
    var externalBorder = SmartViewIgnored()
    var recorder = SmartViewIgnored()
    var photo = SmartImageViewIgnored()
    var timer = UILabel()
    var nsTimer = NSTimer()
    var connexion = UILabel()
    var hours: Int   = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    
    /* BASE DESIGN */
    var scaling:CGFloat = 1
    var PHOTO_SIZE_WIDTH: CGFloat = 55/2
    var PHOTO_SIZE_HEIGHT: CGFloat = 45/2
    var SEPARATOR_SIZE: CGFloat = 0.5
    var PADDING: CGFloat = 12
    var EXTERNALBORDER_SIZE: CGFloat = 28
    var RECORDER_SIZE: CGFloat = (28/2 + 2)
    var RECORDER_SIZE_MODIFIER: CGFloat = 3
    var RECORDER_SQUARE_MODIFIER: CGFloat = 7.0
    var HEIGHT: CGFloat = 50.0
    var WIDTH: CGFloat = 200.0
    var TEXT_PADDING: CGFloat = 7.0
    
    convenience init() {
        self.init(frame: CGRectZero, scaling: 1.0)
    }
    
    convenience init(scaling: CGFloat) {
        self.init(frame: CGRectZero, scaling: scaling)
    }
    
    
    init(frame: CGRect, scaling: CGFloat) {
        if let window = UIApplication.sharedApplication().keyWindow {
            refWindow = window
        } else {
            refWindow = nil
        }
        super.init(frame: frame)
        self.scaling = scaling
        self.scale(scaling)
        self.buildSubviews()
        self.configureDesign()
    }
    
    override init(frame: CGRect) {
        if let window = UIApplication.sharedApplication().keyWindow {
            refWindow = window
        } else {
            refWindow = nil
        }
        super.init(frame: frame)
        self.scale(self.scaling)
        self.buildSubviews()
        self.configureDesign()
    }
    
    func scale(scaling: CGFloat) {
        PHOTO_SIZE_WIDTH *= scaling
        PHOTO_SIZE_HEIGHT *= scaling
        SEPARATOR_SIZE *= scaling
        PADDING *= scaling
        EXTERNALBORDER_SIZE *= scaling
        RECORDER_SIZE *= scaling
        RECORDER_SIZE_MODIFIER *= scaling
        RECORDER_SQUARE_MODIFIER *= scaling
        HEIGHT *= scaling
        WIDTH *= scaling
        TEXT_PADDING *= scaling
    }
    
    
    /**
     Build all the subviews with contraints
     */
    private func buildSubviews() {
        let imgPhoto = UIImage(named: "flat_photo", inBundle: NSBundle(forClass: Tracker.self), compatibleWithTraitCollection: nil)
        photo = SmartImageViewIgnored(image: imgPhoto)
        photo.userInteractionEnabled = true
        self.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Right,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Width,
            multiplier: 0,
            constant: PHOTO_SIZE_WIDTH))
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Height,
            multiplier: 0,
            constant: PHOTO_SIZE_HEIGHT))
        let whiteSeperator = UIView()
        whiteSeperator.backgroundColor = UIColor.whiteColor()
        whiteSeperator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(whiteSeperator)
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: photo,
            attribute: .Left,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Width,
            multiplier: 0,
            constant: SEPARATOR_SIZE))
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Height,
            multiplier: SEPARATOR_SIZE,
            constant: 0))
        externalBorder = SmartViewIgnored()
        externalBorder.backgroundColor = UIColor.clearColor()
        externalBorder.layer.borderWidth = 2
        externalBorder.layer.borderColor = UIColor.whiteColor().CGColor
        externalBorder.translatesAutoresizingMaskIntoConstraints = false
        externalBorder.layer.cornerRadius = EXTERNALBORDER_SIZE/2
        self.addSubview(externalBorder)
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Height,
            multiplier: 0,
            constant: EXTERNALBORDER_SIZE))
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Width,
            multiplier: 0,
            constant: EXTERNALBORDER_SIZE))
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Left,
            multiplier: 1,
            constant: PADDING))
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0))
        
        recorder = SmartViewIgnored()
        externalBorder.addSubview(recorder)
        recorder.layer.cornerRadius = RECORDER_SIZE/2 + RECORDER_SIZE_MODIFIER/2
        recorder.backgroundColor = UIColor.redColor()
        recorder.translatesAutoresizingMaskIntoConstraints = false
        externalBorder.addConstraint(NSLayoutConstraint(item: recorder,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: externalBorder,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0))
        externalBorder.addConstraint(NSLayoutConstraint(item: recorder,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: externalBorder,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0))
        let widthConstraint = NSLayoutConstraint(item: recorder,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: externalBorder,
            attribute: .Width,
            multiplier: 0,
            constant: RECORDER_SIZE+RECORDER_SIZE_MODIFIER)
        let heightConstraint = NSLayoutConstraint(item: recorder,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: externalBorder,
            attribute: .Height,
            multiplier: 0,
            constant: RECORDER_SIZE+RECORDER_SIZE_MODIFIER)
        widthConstraint.identifier = "recorder_width"
        externalBorder.addConstraint(widthConstraint)
        heightConstraint.identifier = "recorder_height"
        externalBorder.addConstraint(heightConstraint)
        
        connexion = UILabel()
        connexion.text = disconnectedText
        connexion.textColor = UIColor.whiteColor()
        connexion.font = UIFont.init(name: "OpenSans", size: 12*scaling)
        connexion.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(connexion)
        self.addConstraint(NSLayoutConstraint(
            item: connexion,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: externalBorder,
            attribute: .Right,
            multiplier: 1,
            constant: PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: connexion,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: whiteSeperator,
            attribute: .Left,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: connexion,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: -TEXT_PADDING))
        
        timer = UILabel()
        timer.text = "00 : 00 : 00"
        timer.textColor = UIColor.whiteColor()
        timer.font = UIFont.init(name: "OpenSans", size: 15*scaling)
        timer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(timer)
        self.addConstraint(NSLayoutConstraint(
            item: timer,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: externalBorder,
            attribute: .Right,
            multiplier: 1,
            constant: PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: timer,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: whiteSeperator,
            attribute: .Left,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: timer,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: +TEXT_PADDING))
    }
    
    /**
     We have to reset the view if the user call display() more than once to avoid multiple instance
     */
    private func reinit() {
        self.removeFromSuperview()
        refWindow?.removeConstraints([windowConstraintLeft!, windowConstraintHeight!, windowConstraintTop!, windowConstraintWidth!])
    }
    
    /**
     Display the view on the screen
     */
    
    func display() {
        if alreadyCalled {
            reinit()
        }
        alreadyCalled = true
        refWindow?.addSubview(self)
        windowConstraintLeft = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.Left
            , relatedBy: NSLayoutRelation.Equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.Left
            , multiplier: 1
            , constant: refWindow!.frame.width/2 - WIDTH/2)
        
        windowConstraintTop = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.Top
            , relatedBy: NSLayoutRelation.Equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.Top
            , multiplier: 1
            , constant: refWindow!.frame.height - HEIGHT - HEIGHT/2)
        
        windowConstraintHeight = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.Height
            , relatedBy: NSLayoutRelation.Equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.Height
            , multiplier: 0
            , constant: HEIGHT)
        
        windowConstraintWidth = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.Width
            , relatedBy: NSLayoutRelation.Equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.Width
            , multiplier: 0
            , constant: WIDTH)
        
        refWindow?.addConstraints([windowConstraintLeft!, windowConstraintHeight!, windowConstraintTop!, windowConstraintWidth!])
        
    }
    
    /**
     Design stuff
     */
    private func configureDesign () {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = false;
        self.layer.shadowOffset = CGSizeMake(1, 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = 4
        self.backgroundColor = createColor(7,g:34,b:55)
    }
    
    /**
     Stop the Clock
     */
    func stopTimer() {
        nsTimer.invalidate()
        hours = 0
        minutes = 0
        seconds = 0
        timer.text = "\(timerFormatter(hours)) : \(timerFormatter(minutes)) : \(timerFormatter(seconds))"
    }
    
    /**
     Start the timer that triggers the clock
     */
    func startTimer() {
        nsTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(SmartToolbar.start(_:)), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(nsTimer, forMode: NSRunLoopCommonModes)
    }
    
    /**
     Start the Clock
     */
    func start(t: NSTimer) {
        seconds += 1
        if seconds == 59 {
            seconds = 0
            minutes += 1
        }
        if minutes == 59 {
            minutes = 0
            if hours < 23 {
                hours += 1
            }
        }
        timer.text = "\(timerFormatter(hours)) : \(timerFormatter(minutes)) : \(timerFormatter(seconds))"
    }
    
    /**
     Format an Int to a string for the clock
     
     - parameter i: an int
     
     - returns: an int on 2 digits
     */
    func timerFormatter(i: Int) -> String{
        if i < 10 {
            return "0\(i)"
        } else {
            return "\(i)"
        }
    }
    
    /**
     Set the text to display on the toolbar
     
     - parameter msg: the text
     */
    func setConnectionText(msg: String) {
        connexion.text = msg
    }
    
    /**
     Scale animation
     
     - parameter viewToAnimate: The view to scale
     - parameter onComplete:    Thing to do after the animation
     */
    func onClickAnimation(viewToAnimate: UIView, onComplete: ()->()) {
        UIView.animateWithDuration(0.1, animations: {
            viewToAnimate.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }){ Bool in
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                viewToAnimate.transform = CGAffineTransformMakeScale(1, 1)
            }) { Bool in onComplete() }
        }
    }
    
    /**
     Helper to create a color
     
     - parameter r: 0-255
     - parameter g: 0-255
     - parameter b: 0-255
     
     - returns: The RGB UIColor
     */
    func createColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SmartToolBarController {
    let ANIMATION_DURATION = 0.3
    
    let toolbar: SmartToolbar
    let socket: SocketSender
    let networkManager: LiveNetworkManager
    
    init(socket: SocketSender, networkManager: LiveNetworkManager) {
        self.networkManager = networkManager
        self.socket = socket
        self.toolbar = SmartToolbar(frame: CGRectZero, scaling: 1.15)
        toolbar.display()
        self.addRecognizers()
    }
    
    /**
     When we click on the screenshot button
     */
    @objc func onClickScreenshot() {
        screenshotClickSound()
        self.toolbar.onClickAnimation(toolbar.photo, onComplete:{})
        let base64 = UIApplication.sharedApplication()
            .keyWindow?
            .screenshot([self.toolbar, Debugger.sharedInstance.debugButton])?
            .toBase64()!
            .stringByReplacingOccurrencesOfString("\n", withString: "")
            .stringByReplacingOccurrencesOfString("\r", withString: "")
        socket.sendMessage(ScreenshotUpdated(screenshot: base64, screen: Screen()).description)
        screenshotAnimation()
    }
    
    func screenshotClickSound() -> () {
        let path = NSBundle(forClass: Tracker.self).pathForResource("camera-sound", ofType: "mp3")
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: path!) as CFURLRef, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    func screenshotAnimation() -> () {
        let v = UIView(frame: toolbar.refWindow!.frame)
        v.backgroundColor = UIColor.whiteColor()
        v.alpha = 0.0
        toolbar.refWindow?.addSubview(v)
        UIView.animateWithDuration(0.2, animations: {
            v.alpha = 0.5
        }){ (Bool) in
            UIView.animateWithDuration(0.2, animations: {
                v.alpha = 0
            }){ (Bool) in
                v.removeFromSuperview()
            }
        }
    }
    
    
    /**
     When we click on record : change the state and perform events according to the state
     */
    @objc func onClickRecord() {
        if networkManager.networkStatus == .Disconnected {
            networkManager.deviceAskedForLive()
        }
        else if networkManager.networkStatus == .Connected {
            networkManager.deviceStoppedLive()
        } else if networkManager.networkStatus == .Pending {
            networkManager.deviceAbortedLiveRequest()
        }
    }
    
    func disconnectedToPending() {
        toolbar.setConnectionText(pendingText)
        toolbar.recorder.backgroundColor = UIColor.whiteColor()
    }
    
    func pendingToDisconnected() {
        toolbar.stopTimer()
        toolbar.setConnectionText(disconnectedText)
        toolbar.recorder.backgroundColor = UIColor.redColor()
    }
    
    func getConstaintFromIdentifier(view: UIView, identifier: String) -> NSLayoutConstraint? {
        return view.constraints.filter({$0.identifier == identifier}).first
    }
    
    func pendingToConnected() {
        let widthConstraint = getConstaintFromIdentifier(toolbar.externalBorder, identifier: "recorder_width")
        let heightConstraint = getConstaintFromIdentifier(toolbar.externalBorder, identifier: "recorder_height")
        widthConstraint?.constant = (widthConstraint?.constant)! - toolbar.RECORDER_SQUARE_MODIFIER
        heightConstraint?.constant = (heightConstraint?.constant)! - toolbar.RECORDER_SQUARE_MODIFIER
        
        self.toolbar.recorder.backgroundColor = UIColor.redColor()
        UIView.animateWithDuration(ANIMATION_DURATION, animations: {
            self.toolbar.externalBorder.layoutIfNeeded()
        })
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.toolbar.recorder.layer.cornerRadius
        animation.toValue = 3.0
        animation.duration = ANIMATION_DURATION
        self.toolbar.recorder.layer.addAnimation(animation, forKey: "cornerRadius")
        self.toolbar.recorder.layer.cornerRadius = 3.0
        
        toolbar.setConnectionText(connectedText)
        toolbar.startTimer()
    }
    
    func connectedToDisconnected() {
        toolbar.stopTimer()
        toolbar.setConnectionText(disconnectedText)

        let widthConstraint = getConstaintFromIdentifier(toolbar.externalBorder, identifier: "recorder_width")
        let heightConstraint = getConstaintFromIdentifier(toolbar.externalBorder, identifier: "recorder_height")
        widthConstraint?.constant = (widthConstraint?.constant)! + toolbar.RECORDER_SQUARE_MODIFIER
        heightConstraint?.constant = (heightConstraint?.constant)! + toolbar.RECORDER_SQUARE_MODIFIER
        
        self.toolbar.recorder.backgroundColor = UIColor.redColor()
        UIView.animateWithDuration(ANIMATION_DURATION, animations: {
            self.toolbar.externalBorder.layoutIfNeeded()
        })
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.toolbar.recorder.layer.cornerRadius
        animation.toValue = self.toolbar.RECORDER_SIZE/2 + self.toolbar.RECORDER_SIZE_MODIFIER/2
        animation.duration = ANIMATION_DURATION
        self.toolbar.recorder.layer.addAnimation(animation, forKey: "cornerRadius")
        self.toolbar.recorder.layer.cornerRadius = self.toolbar.RECORDER_SIZE/2 + self.toolbar.RECORDER_SIZE_MODIFIER/2
    }
    
    func rotateIfNeeded() -> () {
        guard let window = toolbar.refWindow else {
            return
        }
        
        if CGRectContainsRect(window.frame, toolbar.frame) {
            return
        }
        
        let (cx,cy) = (toolbar.center.x, toolbar.center.y)
        let (old_width, old_height) = (window.frame.height, window.frame.width)
        let (new_width, new_heigth) = (window.frame.width, window.frame.height)
        let (new_cx, new_cy) = (new_width*cx/old_width, new_heigth*cy/old_height)
        self.moveAbs(new_cx-toolbar.frame.width/2, y: new_cy-toolbar.frame.height/2)
    }
    
    
    
    /**
     Called when the toolbar is dragged - move it accordingly
     if the toolbar is out of the screen, create a little bump effect
     
     - parameter pan: the pangesture - X/Y are translated values, not absolute
     */
    @objc func dragBar(pan: UIPanGestureRecognizer) {
        if pan.state == .Began {
            let trans = pan.translationInView(toolbar.refWindow)
            translate(trans.x, y: trans.y)
            toolbar.currentPointInWindow = trans
        }
        if pan.state == .Changed {
            let trans = pan.translationInView(toolbar.refWindow)
            let delta = Maths.CGPointSub(toolbar.currentPointInWindow, b: trans)
            translate(-delta.x, y: -delta.y)
            toolbar.currentPointInWindow = trans
        }
        if pan.state == .Ended {
            var Y = toolbar.windowConstraintTop?.constant
            var X = toolbar.windowConstraintLeft?.constant
            var shoudMove = false // true if bar is moved outside the screen
            if Y <= 10 {
                Y = 20
                shoudMove = true
            }
            if Y >= (toolbar.refWindow?.frame.height)!-toolbar.frame.height {
                let windowHeight = toolbar.refWindow!.frame.height
                let selfHeight   = CGFloat(toolbar.frame.height)
                let margin = CGFloat(20)
                Y = windowHeight - selfHeight - margin
                shoudMove = true
            }
            if X <= 0 {
                X = 10
                shoudMove = true
            }
            if X > (toolbar.refWindow?.frame.width)! - toolbar.frame.width {
                let windowWidth = toolbar.refWindow!.frame.width
                let selfWidth   = CGFloat(toolbar.frame.width)
                X = windowWidth-selfWidth
                shoudMove = true
            }
            if shoudMove {
                moveAbs(X!, y: Y!)
            }
        }
    }
    
    /**
     Translate the toolbar (self)
     
     - parameter x: x
     - parameter y: y
     */
    private func translate(x: CGFloat, y: CGFloat) {
        UIView.animateWithDuration(0) { () -> Void in
            self.toolbar.windowConstraintTop?.constant += y
            self.toolbar.windowConstraintLeft?.constant += x
            self.toolbar.refWindow?.layoutIfNeeded()
        }
    }
    
    /**
     Move the toolbar (self)
     
     - parameter x: X
     - parameter y: Y
     */
    private func moveAbs(x: CGFloat, y: CGFloat) {
        UIView.animateWithDuration(0.2) { () -> Void in
            self.toolbar.windowConstraintTop?.constant = y
            self.toolbar.windowConstraintLeft?.constant = x
            self.toolbar.refWindow?.layoutIfNeeded()
        }
    }
    
    func addRecognizers() {
        toolbar.externalBorder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SmartToolBarController.onClickRecord)))
        toolbar.photo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SmartToolBarController.onClickScreenshot)))
        let reconizer = UIPanGestureRecognizer(target: self, action: #selector(SmartToolBarController.dragBar(_:)))
        self.toolbar.addGestureRecognizer(reconizer)
    }
}
