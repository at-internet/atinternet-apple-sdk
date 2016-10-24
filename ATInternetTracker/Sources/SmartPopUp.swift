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

class SmartPopUp: UIView {
    /// ok / cancel height
    let ButtonHeight:CGFloat = 40.0
    /// my frame
    let selfRect = CGRectMake(20,20,270,120)
    /// cancel button
    var btnCancel:SmartButtonIgnored?
    /// ok button
    var btnOk:SmartButtonIgnored?
    /// descriptive text
    var lblContent: UILabel?
    /// Title
    var lblTitle: UILabel?
    /// Action to perform when click on OK
    var okAction:(()->())?
    /// Action to perform when click on Cancel
    var cancelAction:(()->())?
    
    let margin:CGFloat = 15.0
    
    /* Color Theme */
    func customButtonTextColor() -> UIColor {
        return UIColor(red: 12/255, green: 172/255, blue: 248/255, alpha: 1)
    }
    
    func customTextColor() -> UIColor {
        return UIColor(red: 7/255, green: 34/255, blue: 55/255, alpha: 1)
    }
    func customBackgroundColor() -> UIColor {
        return UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
    }
    
    func customSeparatorColor() -> UIColor {
        return UIColor.grayColor()
    }
    
    init(frame: CGRect, title: String, message: String, okTitle: String) {
        super.init(frame: selfRect)
        self.configure()
        self.addSingleButtonOk(okTitle)
        self.addTitleText(title)
        self.addContentText(message)
        let addSizes = lblTitle!.frame.height + lblContent!.frame.height
        let margin: CGFloat = 15.0
        let globalSize = addSizes + margin*3 + ButtonHeight
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, globalSize)
        self.btnCancel?.frame.origin.y = self.frame.height - ButtonHeight
        self.btnOk?.frame.origin.y = self.frame.height - ButtonHeight
        self.addHorizontalSeparator(globalSize)
    }
    
    init(frame: CGRect, title: String, message: String, okTitle: String, cancelTitle: String) {
        super.init(frame: selfRect)
        self.configure()
        self.addButtonCancel(cancelTitle)
        self.addButtonOk(okTitle)
        self.addTitleText(title)
        self.addContentText(message)
        let addSizes = lblTitle!.frame.height + lblContent!.frame.height
        let margin: CGFloat = 15.0
        let globalSize = addSizes + margin*3 + ButtonHeight
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, globalSize)
        self.btnCancel?.frame.origin.y = self.frame.height - ButtonHeight
        self.btnOk?.frame.origin.y = self.frame.height - ButtonHeight
        self.addVerticalSeparator(globalSize)
        self.addHorizontalSeparator(globalSize)
    }
    
    /**
     general design configurations
     */
    func configure() {
        self.backgroundColor = customBackgroundColor()
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 0.5
    }
    
    /**
     add action to the ok button
     
     - parameter action: the action to perform on touch
     */
    func addOkAction(action: ()->()) {
        okAction = action
    }
    
    /**
     add action to the cancel button
     
     - parameter action: the action to perform on touch
     */
    func addCancelAction(action: ()->()) {
        cancelAction = action
    }
    
    /**
     Add a title to the popup
     */
    func addTitleText(title: String) {
        lblTitle = self.addText(title, f: UIFont.init(name: "Montserrat-Bold", size: 14)!, margin: 20)
        lblTitle!.frame.origin.y = margin
        lblTitle!.frame.origin.x = 20
        self.addSubview(lblTitle!)
        
    }
    
    /**
     add a content text to the popup
     */
    func addContentText(content: String) {
        lblContent = self.addText(content, f: UIFont.init(name: "OpenSans", size: 14)!, margin: 10)
        lblContent!.frame.origin.y = margin*2 + lblTitle!.frame.height
        lblContent!.frame.origin.x = 10
        self.addSubview(lblContent!)
    }
    
    /**
     add the separators
     
     - parameter selfHeight: the computed height of the popup
     */
    func addHorizontalSeparator(selfHeight: CGFloat) {
        let sep2 = UIView(frame: CGRectMake(0, selfHeight-ButtonHeight, selfRect.width,0.5))
        sep2.backgroundColor = customSeparatorColor()
        self.addSubview(sep2)
    }
    
    /**
     add the separators
     
     - parameter selfHeight: the computed height of the popup
     */
    func addVerticalSeparator(selfHeight: CGFloat) {
        let sep = UIView(frame: CGRectMake(selfRect.width/2, selfHeight-ButtonHeight,0.5,ButtonHeight))
        sep.backgroundColor = customSeparatorColor()
        self.addSubview(sep)
    }
    
    
    /**
     add the cancel button
     */
    func addButtonCancel(cancelText: String) {
        btnCancel = SmartButtonIgnored(type: .Custom)
        
        guard let cancel = btnCancel else {
            return
        }
        
        let cancelRect = CGRectMake(0, 0, selfRect.width/2, ButtonHeight)
        cancel.backgroundColor = customBackgroundColor()
        cancel.addTarget(self, action: #selector(SmartPopUp.normal(_:)), forControlEvents: .TouchUpInside)
        cancel.addTarget(self, action: #selector(SmartPopUp.normal(_:)), forControlEvents: .TouchUpOutside)
        cancel.addTarget(self, action: #selector(SmartPopUp.hightlight(_:)), forControlEvents: .TouchDown)
        cancel.setTitle(cancelText, forState: .Normal)
        cancel.setTitleColor(customButtonTextColor(), forState: .Normal)
        cancel.titleLabel?.font = UIFont.init(name: "Montserrat-Regular", size: 14)
        cancel.frame = CGRectMake(0,
            selfRect.height-cancelRect.height,
            cancelRect.width,
            cancelRect.height)
        
        self.addSubview(cancel)
        cancel.layer.cornerRadius = 0.0
        let shapePath = UIBezierPath(roundedRect: cancel.bounds, byRoundingCorners: UIRectCorner.BottomLeft, cornerRadii: CGSizeMake(5, 5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = cancel.bounds
        shapeLayer.path = shapePath.CGPath
        cancel.layer.mask = shapeLayer
    }
    
    /* color of the button in normal state */
    func normal(sender: UIButton) {
        sender.backgroundColor = customBackgroundColor()
    }
    
    /* on click */
    func hightlight(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
        if sender == btnCancel {
            if let action = cancelAction {
                action()
            }
        }
        if sender == btnOk {
            if let action = okAction {
                action()
            }
        }
    }
    
    /**
     add an OK button
     */
    func addButtonOk(okText: String) {
        btnOk = SmartButtonIgnored(type: .Custom)
        
        guard let ok = btnOk else {
            return
        }
        let cancelRect = CGRectMake(0, 0, selfRect.width/2, ButtonHeight)
        ok.backgroundColor = customBackgroundColor()
        ok.setTitle(okText, forState: .Normal)
        ok.setTitleColor(customButtonTextColor(), forState: .Normal)
        ok.addTarget(self, action: #selector(SmartPopUp.normal(_:)), forControlEvents: .TouchUpInside)
        ok.addTarget(self, action: #selector(SmartPopUp.normal(_:)), forControlEvents: .TouchUpOutside)
        ok.addTarget(self, action: #selector(SmartPopUp.hightlight(_:)), forControlEvents: .TouchDown)
        ok.titleLabel?.font = UIFont.init(name: "Montserrat-Regular", size: 14)
        ok.frame = CGRectMake(selfRect.width/2,
            selfRect.height-cancelRect.height,
            cancelRect.width,
            cancelRect.height)
        
        self.addSubview(ok)
        ok.layer.cornerRadius = 0.0
        let shapePath = UIBezierPath(roundedRect: ok.bounds, byRoundingCorners: UIRectCorner.BottomRight, cornerRadii: CGSizeMake(5, 5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = ok.bounds
        shapeLayer.path = shapePath.CGPath
        ok.layer.mask = shapeLayer
    }
    
    /**
     add an OK button
     */
    func addSingleButtonOk(okText: String) {
        btnOk = SmartButtonIgnored(type: .Custom)
        
        guard let ok = btnOk else {
            return
        }
        let cancelRect = CGRectMake(0, 0, selfRect.width/2, ButtonHeight)
        ok.backgroundColor = customBackgroundColor()
        ok.setTitle(okText, forState: .Normal)
        ok.setTitleColor(customButtonTextColor(), forState: .Normal)
        ok.addTarget(self, action: #selector(SmartPopUp.normal(_:)), forControlEvents: .TouchUpInside)
        ok.addTarget(self, action: #selector(SmartPopUp.normal(_:)), forControlEvents: .TouchUpOutside)
        ok.addTarget(self, action: #selector(SmartPopUp.hightlight(_:)), forControlEvents: .TouchDown)
        ok.titleLabel?.font = UIFont.init(name: "Montserrat-Regular", size: 14)
        ok.frame = CGRectMake(0,
                              selfRect.height-cancelRect.height,
                              selfRect.width,
                              ButtonHeight)
        
        self.addSubview(ok)
        ok.layer.cornerRadius = 0.0
        let shapePath = UIBezierPath(roundedRect: ok.bounds, byRoundingCorners: [UIRectCorner.BottomRight, UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(5, 5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = ok.bounds
        shapeLayer.path = shapePath.CGPath
        ok.layer.mask = shapeLayer
    }
    
    /**
     create a text label
     
     - parameter s:      the text
     - parameter f:      the font
     - parameter margin: the left/right margin
     
     - returns: the proper uilabel
     */
    func addText(s: String, f: UIFont, margin: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRectMake(0,0,selfRect.width-margin*2,50))
        label.text = s
        label.backgroundColor = UIColor.clearColor()
        label.font = f
        label.textColor = customTextColor()
        label.textAlignment = .Center
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        
        var y = self.selfRect.height - label.expectedheight()
        y -= CGFloat(ButtonHeight)
        
        label.frame = CGRectMake(0,y,selfRect.width-margin*2,ceil(label.expectedheight()))
        label.backgroundColor = customBackgroundColor()
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
