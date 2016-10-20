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

public class ScreenInfo: BusinessObject {
    
}

public class AbstractScreen: BusinessObject {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    lazy var _customVars: [String: CustomVar] = [String: CustomVar]()
    var _publishers: [String: PublisherImpression] = [String: PublisherImpression]()
    var _selfPromotions: [String: SelfPromotionImpression] = [String: SelfPromotionImpression]()
    
    /// Actions
    @objc public enum ScreenAction: Int {
        case view = 0
    }
    
    /// Touch name
    public var name: String = ""
    
    /// First chapter
    public var chapter1: String?
    
    /// Second chapter
    public var chapter2: String?
    
    /// Third chapter
    public var chapter3: String?
    
    /// Action
    public var action: ScreenAction = ScreenAction.view
    
    /// Level 2
    public var level2: Int = 0
    
    /// Screen contains cart info
    public var isBasketScreen: Bool = false
    
    /// Custom objects to add to screen hit
    public lazy var customObjects: CustomObjects = CustomObjects(screen: self)
    
    // Custom vars to add to screen hit
    public lazy var customVars: CustomVars = CustomVars(screen: self)

    /// Visited aisle to add to screen hit
    public var aisle: Aisle?
    
    /// Custom tree structure to add to screen hit
    public var customTreeStructure: CustomTreeStructure?
    
    // Publisher impression to add to screen hit
    public lazy var publishers: PublisherImpressions = PublisherImpressions(screen: self)
    
    // Publisher impression to add to screen hit
    public lazy var selfPromotions: SelfPromotionImpressions = SelfPromotionImpressions(screen: self)
    
    // Location information to add to screen hit
    public var location: Location?
    
    // Campaign information to add to screen hit
    public var campaign: Campaign?
    
    // Search result info to add to screen hit
    public var internalSearch: InternalSearch?
    
    // Order information to add to screen hit
    public var order: Order?
    
    // Cart content to add to screen hit
    public var cart: Cart? {
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
    
    /**
    Send a screen view event
    */
    public func sendView() {
        self.tracker.dispatcher.dispatch([self])
    }
}

public class Screen: AbstractScreen {
    
    #if os(iOS) && AT_SMART_TRACKER
    
    public var className: String = ""
    fileprivate(set) var title: String = ""
    
    /// Scale value
    public var scale: Float = 1
    
    /// Screen width
    var width: Int = 0
    
    /// Screen height
    var height: Int = 0
    
    /// Indicates whether the screen is ready to be sent to tracker
    public var isReady: Bool = false
    
    /// JSON description
    public override var description: String {
        return toJSONObject.toJSON()
    }
    
    /// Device width orientation depedant
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

public class DynamicScreen: AbstractScreen {
    
    /// Dynamic screen identifier
    public var screenId: String = ""
    /// Dynamic screen update date
    public var update: Date = Date()
    
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

    
    /**
    Set a screen
    - returns: tracker instance
    */
    public func add() -> Screen {
        let screen = Screen(tracker: tracker)
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - returns: Screen instance
    */
    public func add(_ name:String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - parameter first: chapter
    - returns: Screen instance
    */
    public func add(_ name: String, chapter1: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: Screen instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: Screen instance
    */
    public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> Screen {
        let screen = Screen(tracker: tracker)
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        screen.chapter3 = chapter3
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
}

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
    
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String) instead.")
    public func add(_ screenId: Int, update: Date, name: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    @objc(addScreen:::)
    public func add(_ screenId: String, update: Date, name: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }

    
    /**
    Set a dynamic screen
    - parameter screen: name
    - parameter first: chapter
    - returns: DynamicScreen instance
    */
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String) instead.")
    public func add(_ screenId: Int, update: Date,name: String, chapter1: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    @objc(addScreenWith1Chapter::::)
    public func add(_ screenId: String, update: Date,name: String, chapter1: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = screenId
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    /**
    Set a dynamic screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - returns: DynamicScreen instance
    */
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String) instead.")
    public func add(_ screenId: Int, update: Date,name: String, chapter1: String, chapter2: String) -> DynamicScreen {
        let screen = DynamicScreen(tracker: tracker)
        screen.screenId = String(screenId)
        screen.update = update
        screen.name = name
        screen.chapter1 = chapter1
        screen.chapter2 = chapter2
        tracker.businessObjects[screen.id] = screen
        
        return screen
    }
    
    @objc(addScreenWith2Chapters:::::)
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
    
    /**
    Set a dynamic screen
    - parameter screen: name
    - parameter first: chapter
    - parameter second: chapter
    - parameter third: chapter
    - returns: DynamicScreen instance
    */
    @available(*, deprecated: 2.2.1, message: "Use add(screenId: String, update: NSDate, name: String, chapter1: String, chapter2: String, chapter3: String) instead.")
    public func add(_ screenId: Int, update: Date,name: String, chapter1: String, chapter2: String, chapter3: String) -> DynamicScreen {
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
    
    @objc(addScreenWith3Chapters::::::)
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
