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

#if canImport(TrackerObjc)
import TrackerObjc
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
    
    var commpleteScreenLabel: String = ""
    
    /// Actions
    @objc public enum ScreenAction: Int {
        /// view actions
        case view = 0
    }
    
    var _name: String = ""
    var _chapter1: String?
    var _chapter2: String?
    var _chapter3: String?
    var _level2: String?
    
    /// Action
    @objc public var action: ScreenAction = ScreenAction.view
    
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
    override func setParams() {
        if let l = _level2 {
            _ = self.tracker.setParam(HitParam.level2.rawValue, value: l)
        }
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setParams()
        }
        
        for (_, value) in _customVars {
            value.tracker = self.tracker
            value.setParams()
        }
        
        if let aisle = self.aisle {
            aisle.tracker = self.tracker
            aisle.setParams()
        }
        
        if let treeStructure = self.customTreeStructure {
            treeStructure.tracker = self.tracker
            treeStructure.setParams()
        }
        
        let sortedPublishers = _publishers.sorted {
            a, b in return a.value.timeStamp < b.value.timeStamp
        }
        
        for (_, value) in sortedPublishers {
            value.tracker = self.tracker
            value.setParams()
        }

        let sortedSelfPromotions = _selfPromotions.sorted {
            a, b in return a.value.timeStamp < b.value.timeStamp
        }
        
        for (_, value) in sortedSelfPromotions {
            value.tracker = self.tracker
            value.setParams()
        }
        
        if let loc = self.location {
            loc.tracker = self.tracker
            loc.setParams()
        }
        
        if let campaign = self.campaign {
            campaign.tracker = self.tracker
            campaign.setParams()
        }
        
        if let search = self.internalSearch {
            search.tracker = self.tracker
            search.setParams()
        }
        
        if let order = self.order {
            order.tracker = self.tracker
            order.setParams()
        }
        
        if let cart = self.cart {
            cart.tracker = self.tracker
            cart.setParams()
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
    
    //MARK: Screen name building
    func buildCompleteLabel() -> String {
        var screenName = _chapter1 == nil ? "" : _chapter1! + "::"
        screenName = _chapter2 ==  nil ? screenName : screenName + _chapter2! + "::"
        screenName = _chapter3 ==  nil ? screenName : screenName + _chapter3! + "::"
        screenName += _name
        
        return screenName
    }
    
    func updateContext() {
        commpleteScreenLabel = buildCompleteLabel()
        TechnicalContext.screenName = commpleteScreenLabel
        Crash.lastScreen(commpleteScreenLabel)
    }
}

/// Wrapper class for screen tracking
public class Screen: AbstractScreen {
    /// Screen name
    @objc public var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
            updateContext()
        }
    }
    /// First chapter
    @objc public var chapter1: String? {
        get {
            return _chapter1
        }
        set {
            _chapter1 = newValue
            updateContext()
        }
    }
    /// Second chapter
    @objc public var chapter2: String? {
        get {
            return _chapter2
        }
        set {
            _chapter2 = newValue
            updateContext()
        }
    }
    /// Third chapter
    @objc public var chapter3: String? {
        get {
            return _chapter3
        }
        set {
            _chapter3 = newValue
            updateContext()
        }
    }
    
    /// Level 2
    @objc public var level2: Int {
        get {
            if let l = level2String {
                return Int(l) ?? -1
            }
            return -1
        }
        set {
            if newValue >= 0 {
                _level2 = String(newValue)
                TechnicalContext.isLevel2Int = true
            } else {
                _level2 = nil
                TechnicalContext.isLevel2Int = false
            }
            TechnicalContext.level2 = _level2
        }
    }
    
    @objc public var level2String: String? {
        get {
            return _level2
        }
        set {
            _level2 = newValue
            TechnicalContext.isLevel2Int = false
            TechnicalContext.level2 = newValue
        }
    }
    
    //MARK: Screen
    /// Set parameters in buffer
    override func setParams() {
        super.setParams()
        let encodingOption = ParamOption()
        encodingOption.encode = true
        _ = self.tracker.setParam(HitParam.screen.rawValue, value: commpleteScreenLabel, options: encodingOption)
    }
}


/// Wrapper class for dynamic screen tracking
public class DynamicScreen: AbstractScreen {
    /// Screen name
    @objc public var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    /// First chapter
    @objc public var chapter1: String? {
        get {
            return _chapter1
        }
        set {
            _chapter1 = newValue
        }
    }
    /// Second chapter
    @objc public var chapter2: String? {
        get {
            return _chapter2
        }
        set {
            _chapter2 = newValue
        }
    }
    /// Third chapter
    @objc public var chapter3: String? {
        get {
            return _chapter3
        }
        set {
            _chapter3 = newValue
        }
    }
    
    /// Level 2
    @objc public var level2: Int {
        get {
            if let l = level2String {
                return Int(l) ?? -1
            }
            return -1
        }
        set {
            if newValue >= 0 {
                _level2 = String(newValue)
                TechnicalContext.isLevel2Int = true
            } else {
                _level2 = nil
                TechnicalContext.isLevel2Int = false
            }
            TechnicalContext.level2 = _level2
        }
    }
    
    @objc public var level2String: String? {
        get {
            return _level2
        }
        set {
            _level2 = newValue
            TechnicalContext.isLevel2Int = false
            TechnicalContext.level2 = newValue
        }
    }
    
    /// Dynamic screen identifier
    @objc public var screenId: String = ""
    /// Dynamic screen update date
    @objc public var update: Date = Date()
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    //MARK: Chapters building
    func buildDynamicScreenChapters() -> String {
        var chapters = _chapter1
        chapters = chapters == nil ? _chapter2 : chapters! + (_chapter2 == nil ? "" : "::" + _chapter2!)
        chapters = chapters == nil ? _chapter3 : chapters! + (_chapter3 == nil ? "" : "::" + _chapter3!)
        return chapters ?? ""
    }
    
    /// Set parameters in buffer
    override func setParams() {
        super.setParams()
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        if(screenId.count > 255){
            screenId = ""
            tracker.delegate?.warningDidOccur?("screenId too long, replaced by empty value")
        }
        
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        dateFormatter.locale = LifeCycle.locale
        
        _ = tracker.setParam("pid", value: screenId)
            .setParam("pchap", value: buildDynamicScreenChapters(), options:encodingOption)
            .setParam("pidt", value: dateFormatter.string(from: update))
            .setParam(HitParam.screen.rawValue, value: _name, options:encodingOption)
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
