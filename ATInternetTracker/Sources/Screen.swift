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
//  Screen.swift
//  Tracker
//

import Foundation

#if os(iOS) && AT_SMART_TRACKER
import UIKit
#endif


/// Business object type for screen tracking. Used only for specific case.
public class ScreenInfo: BusinessObject {
    
}

/// Abstract business object to manage screen tracking.
public class AbstractScreen: BusinessObject {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    lazy var _customVars: [String: CustomVar] = [String: CustomVar]()
    var _publishers: [String: PublisherImpression] = [String: PublisherImpression]()
    var _selfPromotions: [String: SelfPromotionImpression] = [String: SelfPromotionImpression]()
    
    /// Actions
    @objc public enum ScreenAction: Int {
        /// view actions
        case view = 0
    }
    
    /// Screen name
    @objc public var name: String = ""
    
    /// First chapter
    @objc public var chapter1: String?
    
    /// Second chapter
    @objc public var chapter2: String?
    
    /// Third chapter
    @objc public var chapter3: String?
    
    /// Action
    @objc public var action: ScreenAction = ScreenAction.view
    
    /// Level 2
    @objc public var level2: Int = 0
    
    /// true if the screen is a basket screen
    @objc public var isBasketScreen: Bool = false
    
    /// Get a wrapper for Custom object management
    @objc public lazy var customObjects: CustomObjects = CustomObjects(screen: self)
    
    /// Get a wrapper for CustomVar management
    @objc public lazy var customVars: CustomVars = CustomVars(screen: self)

    /// Attach visited aisle to screen
    @objc public var aisle: Aisle?
    
    /// Attach Custom tree structure to screen
    @objc public var customTreeStructure: CustomTreeStructure?
    
    /// Attach Publisher impression to screen
    @objc public lazy var publishers: PublisherImpressions = PublisherImpressions(screen: self)
    
    /// Attach Publisher impression to screen
    @objc public lazy var selfPromotions: SelfPromotionImpressions = SelfPromotionImpressions(screen: self)
    
    /// Attach Location information to screen
    @objc public var location: Location?
    
    /// Attach Campaign information  to screen
    @objc public var campaign: Campaign?
    
    /// Attach Search result info to screen
    @objc public var internalSearch: InternalSearch?
    
    /// Attach Order information to screen
    @objc public var order: Order?
    
    /// Attach a Cart to screen
    @objc public var cart: Cart? {
        didSet {
            self.isBasketScreen = (cart != nil)
        }
    }
    
    fileprivate func getScreenActionRawValue(_ value: Int) -> String {
        switch value {
        default:
            return "view"
        }
    }

    /// Set parameters in buffer
    override func setEvent() {
        if level2 > 0 {
            _ = self.tracker.setParam(HitParam.level2.rawValue, value: level2)
        }
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setEvent()
        }
        
        for (_, value) in _customVars {
            value.tracker = self.tracker
            value.setEvent()
        }
        
        if let aisle = self.aisle {
            aisle.tracker = self.tracker
            aisle.setEvent()
        }
        
        if let treeStructure = self.customTreeStructure {
            treeStructure.tracker = self.tracker
            treeStructure.setEvent()
        }
        
        for (_, value) in _publishers {
            value.tracker = self.tracker
            value.setEvent()
        }

        for (_, value) in _selfPromotions {
            value.tracker = self.tracker
            value.setEvent()
        }
        
        if let loc = self.location {
            loc.tracker = self.tracker
            loc.setEvent()
        }
        
        if let campaign = self.campaign {
            campaign.tracker = self.tracker
            campaign.setEvent()
        }
        
        if let search = self.internalSearch {
            search.tracker = self.tracker
            search.setEvent()
        }
        
        if let order = self.order {
            order.tracker = self.tracker
            order.setEvent()
        }
        
        if let cart = self.cart {
            if cart.cartId != "" || order != nil {
                cart.tracker = self.tracker
                cart.setEvent()
            }
        }
        
        if (isBasketScreen) {
            _ = tracker.setParam("tp", value: "cart")
        }
    }
    
    /// Send a screen view event
    /// If the screen is generated by AutoTracking, do not call this function in the screenWasDetected delegate, otherwise, the screen will be sent twice.
    @objc public func sendView() {
        self.tracker.dispatcher.dispatch([self])
    }
}

/// Wrapper class for screen tracking
public class Screen: AbstractScreen {
    
    #if os(iOS) && AT_SMART_TRACKER
    
    @objc public var className: String = ""
    fileprivate(set) var title: String = ""
    
    /// Scale value
    @objc public var scale: Float = 1
    
    /// Screen width
    var width: Int = 0
    
    /// Screen height
    var height: Int = 0
    
    /// JSON description
    public override var description: String {
        return toJSONObject.toJSON()
    }
    
    /// Device width orientation dependent
    public var currentWidth: Int {
        if self.orientation == 1 {
            return min(self.width, self.height)
        }
        else {
            return max(self.height, self.width)
        }
    }
    
    /// Device height orientation dependent
    public var currentHeight: Int {
        if self.orientation == 1 {
            return max(self.width, self.height)
        }
        else {
            return min(self.height, self.width)
        }
    }
    
    /// Device orientation
    var orientation: Int

    var toJSONObject: [String: Any] {
        let jsonObj: [String: Any] = [
            "screen":[
                "title": self.title,
                "className": self.className,
                "scale": self.scale,
                "width" : self.currentWidth,
                "height" : self.currentHeight,
                "app":[
                    "version": TechnicalContext.applicationVersion.isEmpty ? "" : TechnicalContext.applicationVersion,
                    "device" : TechnicalContext.device.isEmpty ? "" : TechnicalContext.device,
                    "token" : App.token ?? "",
                    "package": TechnicalContext.applicationIdentifier,
                    "platform":"ios"
                ],
                "orientation" : self.orientation
            ]
        ]
        return jsonObj
    }
    
    /**
     Screen init
     
     - returns: Screen
     */
    override init() {
        
        let uiScreen = UIScreen.main
        let size = uiScreen.bounds.size
        
        self.className = UIViewControllerContext.sharedInstance.currentViewController?.classLabel ?? ""
        self.title = self.className
        self.scale = Float(uiScreen.scale)
        self.width = Int(size.width)
        //self.orientation = UIViewControllerContext.sharedInstance.currentOrientation.rawValue
        self.height = Int(size.height)
        
        self.orientation = (self.height > self.width) ? 1 : 2
        super.init()
        self.name = UIViewControllerContext.sharedInstance.currentViewController?.screenTitle ?? ""
       
    }
    
    /**
     Screen init
     
     - returns: Screen
     */
    init(fromViewController: UIViewController) {
        let uiScreen = UIScreen.main
        let size = uiScreen.bounds.size
        
        self.className = fromViewController.classLabel
        self.title = self.className
        self.scale = Float(uiScreen.scale)
        self.width = Int(size.width)
        self.orientation = UIViewControllerContext.sharedInstance.currentOrientation.rawValue
        
        self.height = Int(size.height)
        super.init()
        self.name = fromViewController.screenTitle 
    }
    
    override init(tracker: Tracker) {
        self.orientation = UIDeviceOrientation.portrait.rawValue;
        
        super.init(tracker: tracker)
    }
    
    #endif
    
    //MARK: Screen
    /// Set parameters in buffer
    override func setEvent() {
        super.setEvent()
        
        _ = tracker.event.set("screen", action: getScreenActionRawValue(action.rawValue), label: buildScreenName())
    }
    
    //MARK: Screen name building
    func buildScreenName() -> String {
        var screenName = chapter1 == nil ? "" : chapter1! + "::"
        screenName = chapter2 ==  nil ? screenName : screenName + chapter2! + "::"
        screenName = chapter3 ==  nil ? screenName : screenName + chapter3! + "::"
        screenName += name
        
        return screenName
    }
}


/// Wrapper class for dynamic screen tracking
public class DynamicScreen: AbstractScreen {
    
    /// Dynamic screen identifier
    @objc public var screenId: String = ""
    /// Dynamic screen update date
    @objc public var update: Date = Date()
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    /// Set parameters in buffer
    override func setEvent() {
        super.setEvent()
        
        let chapters = buildChapters()
        
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        _ = tracker.setParam("pchap", value: chapters == nil ? "" : chapters!, options:encodingOption)
        
        if(screenId.characters.count > 255){
            screenId = ""
            tracker.delegate?.warningDidOccur?("screenId too long, replaced by empty value")
        }
        
        _ = tracker.setParam("pid", value: screenId)
        
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        dateFormatter.locale = LifeCycle.locale
        
        _ = tracker.setParam("pidt", value: dateFormatter.string(from: update))
        _ = tracker.event.set("screen", action: getScreenActionRawValue(action.rawValue), label: name)
    }
    
    //MARK: Chapters building
    func buildChapters() -> String? {
        var value: String?
        
        if let optChapter1 = chapter1 {
            value = optChapter1
        }
        
        if let optChapter2 = chapter2 {
            if(value == nil) {
                value = optChapter2
            } else {
                value! += "::" + optChapter2
            }
        }
        
        if let optChapter3 = chapter3 {
            if(value == nil) {
                value = optChapter3
            } else {
                value! += "::" + optChapter3
            }
        }
        
        return value
    }
}


/// Wrapper class to manage Screen instances
public class Screens: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Screens initializer
    - parameter tracker: the tracker instance
    - returns: Screens instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    @objc(addWithScreen:)
    internal func add(_ screen: Screen) -> Screen {
        screen.tracker = tracker
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new screen
    ///
    /// - Returns: the Screen instance
    @objc public func add() -> Screen {
        let screen = Screen(tracker: tracker)
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Screen
    ///
    /// - Parameter name: the screen name
    /// - Returns: the Screen instance
    @objc public func add(_ name:String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Screen
    ///
    /// - Parameters:
    ///   - name: the screen name
    ///   - chapter1: screen first chapter
    /// - Returns: the Screen instance
    @objc public func add(_ name: String, chapter1: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Screen
    ///
    /// - Parameters:
    ///   - name: the screen name
    ///   - chapter1: screen first chapter
    ///   - chapter2: screen second chapter
    /// - Returns: the Screen instance
    @objc public func add(_ name: String, chapter1: String, chapter2: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Screen
    ///
    /// - Parameters:
    ///   - name: the screen name
    ///   - chapter1: screen first chapter
    ///   - chapter2: screen second chapter
    ///   - chapter3: screen third chapter
    /// - Returns: the Screen instance
    @objc public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
}


/// Wrapper class to manage Screen instances
public class DynamicScreens: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    DynamicScreens initializer
    - parameter tracker: the tracker instance
    - returns: DynamicScreens instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    
    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    /// - Returns: the Dynamic Screen instance
    /// - Deprecated: Use add(screenId: String, update: NSDate, name: String) instead.
    @available(*, deprecated, message: "Use add(screenId: String, update: NSDate, name: String) instead (> 2.2.1). ")
    @objc public func add(_ screenId: Int, update: Date, name: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    /// - Returns: the Dynamic Screen instance
    @objc(addScreen:update:name:)
    public func add(_ screenId: String, update: Date, name: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }

    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    ///   - chapter1: screen first chapter
    /// - Returns: the Dynamic Screen instance
    /// - Deprecated: Use add(screenId: String, update: NSDate, name: String, chapter1: String) instead.
    @available(*, deprecated, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String) instead (> 2.2.1).")
    @objc public func add(_ screenId: Int, update: Date,name: String, chapter1: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    
    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    ///   - chapter1: screen first chapter
    /// - Returns: the Dynamic Screen instance
    @objc(addScreenWith1Chapter:update:name:chapter1:)
    public func add(_ screenId: String, update: Date,name: String, chapter1: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    ///   - chapter1: screen first chapter
    ///   - chapter2: screen second chapter
    /// - Returns: the Dynamic Screen instance
    /// - Deprecated: Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String) instead.
    @available(*, deprecated, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String) instead (> 2.2.1).")
    @objc public func add(_ screenId: Int, update: Date,name: String, chapter1: String, chapter2: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    ///   - chapter1: screen first chapter
    ///   - chapter2: screen second chapter
    /// - Returns: the Dynamic Screen instance
    @objc(addScreenWith2Chapters:update:name:chapter1:chapter2:)
    public func add(_ screenId: String, update: Date,name: String, chapter1: String, chapter2: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }

    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    ///   - chapter1: screen first chapter
    ///   - chapter2: screen second chapter
    ///   - chapter3: screen third chapter
    /// - Returns: the Dynamic Screen instance
    /// - Deprecated: Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String, chapter3: String) instead.
    @available(*, deprecated, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String, chapter3: String) instead (> 2.2.1).")
    @objc public func add(_ screenId: Int, update: Date,name: String, chapter1: String, chapter2: String, chapter3: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /// Add a new Dynamic Screen
    ///
    /// - Parameters:
    ///   - screenId: dynamic screen identifier
    ///   - update: dynamic screen update date
    ///   - name: dynamic screen name
    ///   - chapter1: screen first chapter
    ///   - chapter2: screen second chapter
    ///   - chapter3: screen third chapter
    /// - Returns: the Dynamic Screen instance
    @objc(addScreenWith3Chapters:update:name:chapter1:chapter2:chapter3:)
    public func add(_ screenId: String, update: Date,name: String, chapter1: String, chapter2: String, chapter3: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
}
