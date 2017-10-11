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



/// Singleton managing the displayed UIViewController events
class UIViewControllerContext {
    
    enum UIViewControllerOrientation: Int {
        case portrait = 1
        case landscape = 2
    }
    
    /// A Stack of UIVIewController displayed
    lazy var activeViewControllers = [UIViewController]()
    
    /// Get the viewController currently displayed
    var currentViewController: UIViewController? {
        return activeViewControllers.last
    }
    
    lazy var currentOrientation: UIViewControllerOrientation = UIViewControllerOrientation.portrait
    var isPeekAndPoped: Bool = false
    var isPeek: Bool = false
        
    
    /// A timestamp representing the time where the last view was loaded
    lazy var viewAppearedTime = Date().timeIntervalSinceNow
    
    /// An array representing "noise" viewcontrollers that are loaded quietly that we want to ignore
    let UIClassToIgnore = [
        NSClassFromString("UICompatibilityInputViewController"),
        NSClassFromString("UIInputWindowController"),
        NSClassFromString("UIKeyboardCandidateGridCollectionViewController"),
        NSClassFromString("UIApplicationRotationFollowingControllerNoTouches"),
        NSClassFromString("UINavigationController"),
        NSClassFromString("MKSmallCalloutViewController"),
        NSClassFromString("UIPageViewController"),
        NSClassFromString("UIApplicationRotationFollowingController"),
        NSClassFromString("_UIRemoteInputViewController")
    ];
    
    /// An array representing "noise" protocols that are loaded quietly that we want to ignore
    let UIProtocolToIgnore = [
        NSProtocolFromString("UIPageViewControllerDelegate"),
        NSProtocolFromString("UIPageViewControllerDataSource"),
    ];
    
    /// Singleton
    static let sharedInstance = UIViewControllerContext()
    
    fileprivate init() { }
}
