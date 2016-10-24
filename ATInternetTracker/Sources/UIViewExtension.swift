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

extension UIView {
        
    /// Text of the UIView
    var textValue: String? {
        let properties = ["currentTitle", "title", "text"]
        for p in properties {
            let cp = class_getProperty(object_getClass(self), p)
            if cp != nil {
                if let title = self.valueForKey(p) {
                    return title as? String
                }
            }
        }
        return nil
    }
    
    /// Path of the view in the window hierarchy
    var path: String {
        var path = self.classLabel
        var parentView: UIView? = self.superview;
        
        while(parentView != nil) {
            path = parentView!.classLabel + "/" + path
            
            parentView = parentView?.superview;
        }
        
        return path
    }
    
    /// Checks whether the view is inside a UICollectionViewCell
    var isInCollectionViewCell: Bool {
        return parentCollectionViewCell != nil
    }
    
    /// Checks whether the view is inside a UITableViewCell
    var isInTableViewCell: Bool {
        return parentTableViewCell != nil
    }
    
    /// get the parent UICollectionViewCell if exists
    var parentCollectionViewCell: UICollectionViewCell? {
        if self is UIControl || hasActiveGestureRecognizer {
            return nil
        } else {
            var parentView: UIView? = self;
            
            while(parentView != nil) {
                if(parentView is UICollectionViewCell) {
                    return (parentView as! UICollectionViewCell);
                }
                
                parentView = parentView?.superview;
            }
            
            return nil;
        }
    }
    
    /// Gets the parent UITableViewCell if exists
    var parentTableViewCell: UITableViewCell? {
        if self is UIControl || hasActiveGestureRecognizer {
            return nil
        } else {
            var parentView: UIView? = self;
            
            while(parentView != nil) {
                if(parentView is UITableViewCell) {
                    return (parentView as! UITableViewCell);
                }
                
                parentView = parentView?.superview;
            }
            
            return nil;
        }
    }
    
    /// Checks whether the view is inside a UITableViewCell
    var isInTableViewCellIgnoreControl: Bool {
        return parentTableViewCellIgnoreControl != nil
    }
    
    var parentTableViewCellIgnoreControl: UITableViewCell? {
        if hasActiveGestureRecognizer {
            return nil
        } else {
            var parentView: UIView? = self;
            
            while(parentView != nil) {
                if(parentView is UITableViewCell) {
                    return (parentView as! UITableViewCell);
                }
                
                parentView = parentView?.superview;
            }
            
            return nil;
        }
    }
    
     /// Indicates whether a gesture recognizer has been triggered
    var hasActiveGestureRecognizer: Bool {
        if let recognizers = self.gestureRecognizers {
            for recognizer in recognizers {
                if(recognizer.state == UIGestureRecognizerState.Changed || (recognizer is UITapGestureRecognizer && recognizer.state == UIGestureRecognizerState.Possible))
                {
                    return true;
                }
            }
        }
        
        return false
    }
    
    /// Checks whether the view is inside a UIScrollView
    var isInScrollView: Bool {
        return parentScrollView != nil
    }
    
    /// Gets the parent UIScrollView if exists
    var parentScrollView: UIScrollView? {
        var parentView: UIView? = self;
        
        while(parentView != nil) {
            if(parentView is UIScrollView) {
                return (parentView as! UIScrollView);
            }
            
            parentView = parentView?.superview;
        }
        
        return nil;
    }
    
    /// Gets the type of UIView
    var type: UIApplicationContext.ViewType {
        if self.isInTableViewCell {
            return UIApplicationContext.ViewType.TableViewCell
        } else if self.isInCollectionViewCell {
            return UIApplicationContext.ViewType.CollectionViewCell
        }
        else if(self.isKindOfClass(NSClassFromString("_UINavigationBarBackIndicatorView")!)) {
            return UIApplicationContext.ViewType.BackButton
        } else if(self.isKindOfClass(NSClassFromString("UITabBarButton")!)) {
            return UIApplicationContext.ViewType.TabBarButton
        } else if(self.isKindOfClass(NSClassFromString("UISegmentedControl")!)) {
            return UIApplicationContext.ViewType.SegmentedControl
        } else if(self.isKindOfClass(NSClassFromString("UISlider")!)) {
            return UIApplicationContext.ViewType.Slider
        } else if(self.isKindOfClass(NSClassFromString("UITextField")!)) {
            return UIApplicationContext.ViewType.TextField
        } else if(self.isKindOfClass(NSClassFromString("UIStepper")!)) {
            return UIApplicationContext.ViewType.Stepper
        } else if(self.isKindOfClass(NSClassFromString("UIButton")!)) {
            return UIApplicationContext.ViewType.Button
        } else if(self.isKindOfClass(NSClassFromString("UISwitch")!)) {
            return UIApplicationContext.ViewType.Switch
        } else if(self.isKindOfClass(NSClassFromString("UINavigationBar")!)) {
            return UIApplicationContext.ViewType.NavigationBar
        } else if(self.isKindOfClass(NSClassFromString("UIPageControl")!)) {
            return UIApplicationContext.ViewType.PageControl
        } else if(self.isKindOfClass(NSClassFromString("UIDatePicker")!)) {
            return UIApplicationContext.ViewType.DatePicker
        } else {
            return UIApplicationContext.ViewType.Unkwown
        }
    }
    
    /**
     Finds the text in UIView 
     If there is no text, try to find one in children
     
     - parameter p: Touch point
     
     - returns: Text
     */
    func findText(p:CGPoint) -> String? {
        if let text = self.textValue {
            return text
        }
        return rFindText(self, p: p, info: [:])["title"]
    }
    
    /**
     Recursive funtion used to find text in UIView hierarchy
     
     - parameter view: Touched view
     - parameter p:    Touch point
     - parameter info: Dictionary containing view info
     
     - returns: Dictionary containing UIView text
     */
    func rFindText(view: UIView, p: CGPoint, info: [String: String]) -> [String: String] {
        var info = info
        var title:String?
        for subview in view.subviews {
            let frame = subview.superview?.convertRect(subview.frame, toView: view.window?.rootViewController?.view)
            title = subview.textValue
            if title != nil && CGRectContainsPoint(frame!, p) {
                info["title"] = title
            } else {
                info = rFindText(subview, p: p, info: info)
                if info["title"] != nil && CGRectContainsPoint(frame!, p) {
                    return info
                }
            }
        }
        return info
    }
    
    /**
     screenshot function: Take a screenshot
     - returns: the self UIImage representation
     */
    func screenshot (ignoreViews: [UIView]? = nil) -> UIImage? {
        let visibleViews = ignoreViews?.filter({!$0.hidden})
        visibleViews?.forEach({ (v: UIView) in
            v.hidden = true
        })
        
        let optWindow = UIApplication.sharedApplication().keyWindow
        var optImage: UIImage?
        
        if let window = optWindow {
            if !CGRectEqualToRect(window.frame, CGRectZero) {
                UIGraphicsBeginImageContextWithOptions(window.bounds.size, true, window.screen.scale)
                if !window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: true) {
                    window.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                }
                optImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
        
        // if the view is not the current UIWindows, crop the screenshot to match the size of the view
        if self != optWindow {
            optImage = optImage?.crop(self.convertRect(self.bounds, toView: nil))
        }
        
        visibleViews?.forEach({ (v: UIView) in
            v.hidden = false
        })
        
        return optImage
    }
}
