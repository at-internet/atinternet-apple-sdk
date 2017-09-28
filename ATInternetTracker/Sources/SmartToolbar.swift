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
let disconnectedText = NSLocalizedString("DISCONNECTED", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content")
let pendingText = NSLocalizedString("PENDING", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content")
let connectedText = NSLocalizedString("CONNECTED", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content")

/// A movable toolbar to managed the pairing
class SmartToolbar: UIView {
    let refWindow: UIWindow?
    var windowConstraintLeft: NSLayoutConstraint?
    var windowConstraintTop: NSLayoutConstraint?
    var windowConstraintHeight: NSLayoutConstraint?
    var windowConstraintWidth: NSLayoutConstraint?
    var currentPointInWindow: CGPoint = CGPoint.zero
    var alreadyCalled = false
    var externalBorder = SmartViewIgnored()
    var recorder = SmartViewIgnored()
    var photo = SmartImageViewIgnored()
    var timer = UILabel()
    var nsTimer = Timer()
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
        self.init(frame: CGRect.zero, scaling: 1.0)
    }
    
    convenience init(scaling: CGFloat) {
        self.init(frame: CGRect.zero, scaling: scaling)
    }
    
    
    init(frame: CGRect, scaling: CGFloat) {
        if let window = UIApplication.shared.keyWindow {
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
        if let window = UIApplication.shared.keyWindow {
            refWindow = window
        } else {
            refWindow = nil
        }
        super.init(frame: frame)
        self.scale(self.scaling)
        self.buildSubviews()
        self.configureDesign()
    }
    
    func scale(_ scaling: CGFloat) {
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
    fileprivate func buildSubviews() {
        let imgPhoto = UIImage(named: "flat_photo", in: Bundle(for: Tracker.self), compatibleWith: nil)
        photo = SmartImageViewIgnored(image: imgPhoto)
        photo.isUserInteractionEnabled = true
        self.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .right,
            relatedBy: .equal,
            toItem: self,
            attribute: .right,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 0,
            constant: PHOTO_SIZE_WIDTH))
        self.addConstraint(NSLayoutConstraint(
            item: photo,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 0,
            constant: PHOTO_SIZE_HEIGHT))
        let whiteSeperator = UIView()
        whiteSeperator.backgroundColor = UIColor.white
        whiteSeperator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(whiteSeperator)
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .right,
            relatedBy: .equal,
            toItem: photo,
            attribute: .left,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 0,
            constant: SEPARATOR_SIZE))
        self.addConstraint(NSLayoutConstraint(item: whiteSeperator,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: SEPARATOR_SIZE,
            constant: 0))
        externalBorder = SmartViewIgnored()
        externalBorder.backgroundColor = UIColor.clear
        externalBorder.layer.borderWidth = 2
        externalBorder.layer.borderColor = UIColor.white.cgColor
        externalBorder.translatesAutoresizingMaskIntoConstraints = false
        externalBorder.layer.cornerRadius = EXTERNALBORDER_SIZE/2
        self.addSubview(externalBorder)
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 0,
            constant: EXTERNALBORDER_SIZE))
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 0,
            constant: EXTERNALBORDER_SIZE))
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1,
            constant: PADDING))
        self.addConstraint(NSLayoutConstraint(item: externalBorder,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        
        recorder = SmartViewIgnored()
        externalBorder.addSubview(recorder)
        recorder.layer.cornerRadius = RECORDER_SIZE/2 + RECORDER_SIZE_MODIFIER/2
        recorder.backgroundColor = UIColor.red
        recorder.translatesAutoresizingMaskIntoConstraints = false
        externalBorder.addConstraint(NSLayoutConstraint(item: recorder,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: externalBorder,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        externalBorder.addConstraint(NSLayoutConstraint(item: recorder,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: externalBorder,
            attribute: .centerX,
            multiplier: 1,
            constant: 0))
        let widthConstraint = NSLayoutConstraint(item: recorder,
            attribute: .width,
            relatedBy: .equal,
            toItem: externalBorder,
            attribute: .width,
            multiplier: 0,
            constant: RECORDER_SIZE+RECORDER_SIZE_MODIFIER)
        let heightConstraint = NSLayoutConstraint(item: recorder,
            attribute: .height,
            relatedBy: .equal,
            toItem: externalBorder,
            attribute: .height,
            multiplier: 0,
            constant: RECORDER_SIZE+RECORDER_SIZE_MODIFIER)
        widthConstraint.identifier = "recorder_width"
        externalBorder.addConstraint(widthConstraint)
        heightConstraint.identifier = "recorder_height"
        externalBorder.addConstraint(heightConstraint)
        
        connexion = UILabel()
        connexion.text = disconnectedText
        connexion.textColor = UIColor.white
        connexion.font = UIFont(name: "OpenSans", size: 12*scaling)
        connexion.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(connexion)
        self.addConstraint(NSLayoutConstraint(
            item: connexion,
            attribute: .left,
            relatedBy: .equal,
            toItem: externalBorder,
            attribute: .right,
            multiplier: 1,
            constant: PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: connexion,
            attribute: .right,
            relatedBy: .equal,
            toItem: whiteSeperator,
            attribute: .left,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: connexion,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: -TEXT_PADDING))
        
        timer = UILabel()
        timer.text = "00 : 00 : 00"
        timer.textColor = UIColor.white
        timer.font = UIFont(name: "OpenSans", size: 15*scaling)
        timer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(timer)
        self.addConstraint(NSLayoutConstraint(
            item: timer,
            attribute: .left,
            relatedBy: .equal,
            toItem: externalBorder,
            attribute: .right,
            multiplier: 1,
            constant: PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: timer,
            attribute: .right,
            relatedBy: .equal,
            toItem: whiteSeperator,
            attribute: .left,
            multiplier: 1,
            constant: -PADDING))
        self.addConstraint(NSLayoutConstraint(
            item: timer,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: +TEXT_PADDING))
    }
    
    /**
     We have to reset the view if the user call display() more than once to avoid multiple instance
     */
    fileprivate func reinit() {
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
            , attribute: NSLayoutAttribute.left
            , relatedBy: NSLayoutRelation.equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.left
            , multiplier: 1
            , constant: refWindow!.frame.width/2 - WIDTH/2)
        
        windowConstraintTop = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.top
            , relatedBy: NSLayoutRelation.equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.top
            , multiplier: 1
            , constant: refWindow!.frame.height - HEIGHT - HEIGHT/2)
        
        windowConstraintHeight = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.height
            , relatedBy: NSLayoutRelation.equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.height
            , multiplier: 0
            , constant: HEIGHT)
        
        windowConstraintWidth = NSLayoutConstraint(item: self
            , attribute: NSLayoutAttribute.width
            , relatedBy: NSLayoutRelation.equal
            , toItem: refWindow
            , attribute: NSLayoutAttribute.width
            , multiplier: 0
            , constant: WIDTH)
        
        refWindow?.addConstraints([windowConstraintLeft!, windowConstraintHeight!, windowConstraintTop!, windowConstraintWidth!])
        
    }
    
    /**
     Design stuff
     */
    fileprivate func configureDesign () {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = false;
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
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
        nsTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(SmartToolbar.start(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(nsTimer, forMode: RunLoopMode.commonModes)
    }
    
    /**
     Start the Clock
     */
    @objc func start(_ t: Timer) {
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
    func timerFormatter(_ i: Int) -> String{
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
    func setConnectionText(_ msg: String) {
        connexion.text = msg
    }
    
    /**
     Scale animation
     
     - parameter viewToAnimate: The view to scale
     - parameter onComplete:    Thing to do after the animation
     */
    func onClickAnimation(_ viewToAnimate: UIView, onComplete: @escaping ()->()) {
        UIView.animate(withDuration: 0.1, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }){ Bool in
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
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
    func createColor(_ r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
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
        self.toolbar = SmartToolbar(frame: CGRect.zero, scaling: 1.15)
        toolbar.display()
        self.addRecognizers()
    }
    
    /**
     When we click on the screenshot button
     */
    @objc func onClickScreenshot() {
        screenshotClickSound()
        self.toolbar.onClickAnimation(toolbar.photo, onComplete:{})
        let base64 = UIApplication.shared
            .keyWindow?
            .screenshot([self.toolbar, Debugger.sharedInstance.debugButton])?
            .toBase64()!
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        socket.sendMessage(ScreenshotUpdated(screenshot: base64, screen: Screen()).description)
        screenshotAnimation()
    }
    
    func screenshotClickSound() -> () {
        let path = Bundle(for: Tracker.self).path(forResource: "camera-sound", ofType: "mp3")
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(URL(fileURLWithPath: path!) as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    func screenshotAnimation() -> () {
        let v = UIView(frame: toolbar.refWindow!.frame)
        v.backgroundColor = UIColor.white
        v.alpha = 0.0
        toolbar.refWindow?.addSubview(v)
        UIView.animate(withDuration: 0.2, animations: {
            v.alpha = 0.5
        }){ (Bool) in
            UIView.animate(withDuration: 0.2, animations: {
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
        toolbar.recorder.backgroundColor = UIColor.white
    }
    
    func pendingToDisconnected() {
        toolbar.stopTimer()
        toolbar.setConnectionText(disconnectedText)
        toolbar.recorder.backgroundColor = UIColor.red
    }
    
    func getConstaintFromIdentifier(_ view: UIView, identifier: String) -> NSLayoutConstraint? {
        return view.constraints.filter({$0.identifier == identifier}).first
    }
    
    func pendingToConnected() {
        let widthConstraint = getConstaintFromIdentifier(toolbar.externalBorder, identifier: "recorder_width")
        let heightConstraint = getConstaintFromIdentifier(toolbar.externalBorder, identifier: "recorder_height")
        widthConstraint?.constant = (widthConstraint?.constant)! - toolbar.RECORDER_SQUARE_MODIFIER
        heightConstraint?.constant = (heightConstraint?.constant)! - toolbar.RECORDER_SQUARE_MODIFIER
        
        self.toolbar.recorder.backgroundColor = UIColor.red
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.toolbar.externalBorder.layoutIfNeeded()
        })
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.toolbar.recorder.layer.cornerRadius
        animation.toValue = 3.0
        animation.duration = ANIMATION_DURATION
        self.toolbar.recorder.layer.add(animation, forKey: "cornerRadius")
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
        
        self.toolbar.recorder.backgroundColor = UIColor.red
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            self.toolbar.externalBorder.layoutIfNeeded()
        })
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.toolbar.recorder.layer.cornerRadius
        animation.toValue = self.toolbar.RECORDER_SIZE/2 + self.toolbar.RECORDER_SIZE_MODIFIER/2
        animation.duration = ANIMATION_DURATION
        self.toolbar.recorder.layer.add(animation, forKey: "cornerRadius")
        self.toolbar.recorder.layer.cornerRadius = self.toolbar.RECORDER_SIZE/2 + self.toolbar.RECORDER_SIZE_MODIFIER/2
    }
    
    func rotateIfNeeded() -> () {
        guard let window = toolbar.refWindow else {
            return
        }
        
        if window.frame.contains(toolbar.frame) {
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
    @objc func dragBar(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            let trans = pan.translation(in: toolbar.refWindow)
            translate(trans.x, y: trans.y)
            toolbar.currentPointInWindow = trans
        }
        if pan.state == .changed {
            let trans = pan.translation(in: toolbar.refWindow)
            let delta = Maths.CGPointSub(toolbar.currentPointInWindow, b: trans)
            translate(-delta.x, y: -delta.y)
            toolbar.currentPointInWindow = trans
        }
        if pan.state == .ended {
            var Y = toolbar.windowConstraintTop?.constant
            var X = toolbar.windowConstraintLeft?.constant
            var shoudMove = false // true if bar is moved outside the screen
            if Y! <= CGFloat(10.0) {
                Y = 20.0
                shoudMove = true
            }
            if Y! >= (toolbar.refWindow?.frame.height)!-toolbar.frame.height {
                let windowHeight = toolbar.refWindow!.frame.height
                let selfHeight   = CGFloat(toolbar.frame.height)
                let margin = CGFloat(20)
                Y = windowHeight - selfHeight - margin
                shoudMove = true
            }
            if X! <= CGFloat(0) {
                X = 10
                shoudMove = true
            }
            if X! > (toolbar.refWindow?.frame.width)! - toolbar.frame.width {
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
    fileprivate func translate(_ x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0) { () -> Void in
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
    fileprivate func moveAbs(_ x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.2) { () -> Void in
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
