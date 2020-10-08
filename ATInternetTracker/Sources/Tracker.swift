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
//  Tracker.swift
//  Tracker
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Build or send status of the hit
///
/// - failed: failed
/// - success: success
@objc public enum HitStatus: Int {
    /// failed
    case failed = 0
    /// success
    case success = 1
}

/// Standard parameters added in the Hit querystring
///
/// - screen: screen
/// - level2: level2
/// - json: json
/// - userID: userID
/// - hitType: hitType
/// - action: action
/// - touch: touch
/// - touchScreen: touchScreen
/// - touchLevel2: touchLevel2
/// - visitorIdentifierNumeric: visitorIdentifierNumeric
/// - visitorIdentifierText: visitorIdentifierText
/// - visitorCategory: visitorCategory
/// - backgroundMode: backgroundMode
/// - onAppAdsTouch: onAppAdsTouch
/// - onAppAdsImpression: onAppAdsImpression
/// - gpsLatitude: gpsLatitude
/// - gpsLongitude: gpsLongitude
/// - referrer: referrer
public enum HitParam: String {
    /// screen (p)
    case screen = "p"
    /// level (s2)
    case level2 = "s2"
    /// json (stc)
    case json = "stc"
    /// userID (idclient)
    case userID = "idclient"
    /// hitype (type)
    case hitType = "type"
    /// action (action)
    case action = "action"
    /// touch (click)
    case touch = "click"
    /// touchScreen (pclick)
    case touchScreen = "pclick"
    /// touchLevel2 (s2click)
    case touchLevel2 = "s2click"
    /// visitorIdentifierNumeric (an)
    case visitorIdentifierNumeric = "an"
    /// visitorIdentifierText (at)
    case visitorIdentifierText = "at"
    /// visitorCategory (ac)
    case visitorCategory = "ac"
    /// backgroundMode (bg)
    case backgroundMode = "bg"
    /// onAppAdsTouch (atc)
    case onAppAdsTouch = "atc"
    /// onAppAdsImpression (ati)
    case onAppAdsImpression = "ati"
    /// gpsLatitude (gy)
    case gpsLatitude = "gy"
    /// gpsLongitude (gx)
    case gpsLongitude = "gx"
    /// referrer (ref)
    case referrer = "ref"
}


/// Background modes
///
/// - normal: tracking in foreground
/// - task: tracking in background
/// - fetch: tracking in iOS fetching feature
@objc public enum BackgroundMode: Int {
    /// normal: tracking in foreground
    case normal = 0
    /// task: tracking in background
    case task = 1
    /// fetch: tracking in iOS fetching feature
    case fetch = 2
}

// MARK: - Tracker Delegate

/// Sends different events during hit building
@objc public protocol TrackerDelegate {
    
    /**
     Notify when tracker needs first launch approval
     
     - parameter message: approval message for confidentiality
     */
    @objc optional func trackerNeedsFirstLaunchApproval(_ message: String)
    
    /**
     Notify when hit has been built
     
     - parameter status: status of hit building
     - parameter message: query string or error message
     */
    @objc optional func buildDidEnd(_ status: HitStatus, message: String)
    
    /**
     Notify when hit has been sent
     
     - parameter status: status of hit sending
     - parameter message: querystring or http response message
     */
    @objc optional func sendDidEnd(_ status: HitStatus, message: String)
    
    /**
     Notify when hit has been saved in device local storage
     
     - parameter message: the saved hit
     */
    @objc optional func saveDidEnd(_ message: String)
    
    /**
     Notify when a partner has been called
     
     - parameter response: the response received from the partner
     */
    @objc optional func didCallPartner(_ response: String)
    
    /**
     Notify when a warning has been detected
     
     - parameter message: the warning message
     */
    @objc optional func warningDidOccur(_ message: String)
    
    /**
     Notify when a critical error has been detected
     
     - parameter message: the error message
     */
    @objc optional func errorDidOccur(_ message: String)
    
}

// MARK: - Tracker

/// Wrapper class for tracking usage of your application
public class Tracker: NSObject {
    
    @objc internal weak var _delegate: TrackerDelegate? = nil
    
    /// Tracker current delegate
    @objc public var delegate: TrackerDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
            if LifeCycle.firstSession {
                _delegate?.trackerNeedsFirstLaunchApproval?("Tracker first launch")
            }
        }
    }
    
    /// Contains tracker configuration
    @objc var configuration: Configuration
    
    /// Contains parameters
    @objc lazy var buffer: Buffer = Buffer(tracker: self)
    
    /// Dispatcher
    @objc lazy var dispatcher: Dispatcher = Dispatcher(tracker: self)
    
    #if os(iOS) && !AT_EXTENSION
    /// Sets Tracker in debug mode and display debugger window
    @objc public var enableDebugger: Bool = false {
        didSet {
            if enableDebugger == true {
                if (UIApplication.shared.windows.count == 0) {
                    NotificationCenter.default.addObserver(self, selector: #selector(Tracker.displayDebuggerOnMainThread), name: UIWindow.didBecomeKeyNotification, object: nil)
                } else {
                    self.performSelector(onMainThread: #selector(self.displayDebugger), with: nil, waitUntilDone: false)
                }
            } else {
                Debugger.sharedInstance.deinitDebugger()
            }
        }
    }
    
    @objc func displayDebuggerOnMainThread() {
        self.performSelector(onMainThread: #selector(self.displayDebugger), with: nil, waitUntilDone: false)
    }
    
    /**
     Display the debugger window
     */
    @objc func displayDebugger() {
        Debugger.sharedInstance.initDebugger(offlineMode: self.configuration.parameters["storage"] ?? "never")
    }
    #endif
    
    @objc internal lazy var businessObjects: [String: BusinessObject] = [String: BusinessObject]()
    
    //MARK: Offline
    /// Return Offline instance
    @objc fileprivate(set) public lazy var offline: Offline = Offline(tracker: self)
    
    //MARK: Context Tracking
    /// Return Context instance
    @objc fileprivate(set) public lazy var context: Context = Context(tracker: self)
    
    //MARK: NuggAd Tracking
    /// Return NuggAd instance
    @objc fileprivate(set) public lazy var nuggAds: NuggAds = NuggAds(tracker: self)
    
    //MARK: GPS Tracking
    /// Return GPS tracking instance
    /// - Deprecated : location is now only available as a screen object property.
    @objc @available(*, deprecated, message: "location is now only available as a screen object property (> 2.5.0).")
    fileprivate(set) public lazy var locations: Locations = Locations(tracker: self)
    
    //MARK: Publisher Tracking
    /// Return Publisher instance
    @objc fileprivate(set) public lazy var publishers: Publishers = Publishers(tracker: self)
    
    //MARK: SelfPromotion Tracking
    /// Return SelfPromotions instance
    @objc fileprivate(set) public lazy var selfPromotions: SelfPromotions = SelfPromotions(tracker: self)
    
    //MARK: Identified Visitor Tracking
    /// Return Identified visitor instance
    @objc fileprivate(set) public lazy var identifiedVisitor: IdentifiedVisitor = IdentifiedVisitor(tracker: self)
    
    //MARK: Screen Tracking
    /// Get Screens instances
    @objc fileprivate(set) public lazy var screens: Screens = Screens(tracker: self)
    
    //MARK: Dynamic Screen Tracking
    /// Dynamic Screen tracking
    @objc fileprivate(set) public lazy var dynamicScreens: DynamicScreens = DynamicScreens(tracker: self)
    
    //MARK: Touch Tracking
    /// Return gestures instance
    @objc fileprivate(set) public lazy var gestures: Gestures = Gestures(tracker: self)
    
    //MARK: Custom Object Tracking
    /// Return CustomObjects instance
    @objc fileprivate(set) public lazy var customObjects: CustomObjects = CustomObjects(tracker: self)
    
    //MARK: ECommerce Tracking
    /// Return ECommerce instance
    @objc fileprivate(set) public lazy var ecommerce: ECommerce = ECommerce(tracker: self)
    
    //MARK: AVInsights Tracking
    /// Return AVInsights instance
    @objc fileprivate(set) public lazy var avInsights: AVInsights = AVInsights(tracker: self)
    
    //MARK: Events Tracking
    /// Return Events instance
    @objc fileprivate(set) public lazy var events: Events = Events(tracker: self)
    
    //MARK: CustomVar Tracking
    /// Return CustomVar instance
    /// - Deprecated : customVars is now only available as a screen object property.
    @objc @available(*, deprecated, message: "customVars is now only available as a screen object property (> 2.5.0).")
    fileprivate(set) public lazy var customVars: CustomVars = CustomVars(tracker: self)
    
    //MARK: Order Tracking
    /// Return Order instance
    @objc fileprivate(set) public lazy var orders: Orders = Orders(tracker: self)
    
    //MARK: Aisle Tracking
    /// Return Aisle instance
    /// - Deprecated : aisles is now only available as a screen object property.
    @available(*, deprecated, message: "aisles is now only available as a screen object property (> 2.5.0).")
    fileprivate(set) public lazy var aisles: Aisles = Aisles(tracker: self)
    
    //MARK: Cart Tracking
    /// Return Cart instance
    @objc fileprivate(set) public lazy var cart: Cart = Cart(tracker: self)
    
    //MARK: Product Tracking
    /// Return Products instance
    @objc fileprivate(set) public lazy var products: Products = Products(tracker: self)
    
    /// Campaign Tracking. Campaign is now available as a screen object property but you may use this method for notification tracking
    @objc fileprivate(set) public lazy var campaigns: Campaigns = Campaigns(tracker: self)
    
    //MARK: Internal Search Tracking
    /// Return InternalSearch instance
    /// - Deprecated : internalSearch is now only available as a screen object property.
    @objc @available(*, deprecated, message: "internalSearch is now only available as a screen object property (> 2.5.0).")
    fileprivate(set) public lazy var internalSearches: InternalSearches = InternalSearches(tracker: self)
    
    //MARK: Custom tree structure Tracking
    /// Return CustomTreeStructures instance
    /// - Deprecated : customTreeStructures is now only available as a screen object property.
    @objc @available(*, deprecated, message: "customTreeStructures is now only available as a screen object property (> 2.5.0).")
    fileprivate(set) public lazy var customTreeStructures: CustomTreeStructures = CustomTreeStructures(tracker: self)
    
    //MARK: Richmedia Tracking
    /// Return MediaPlayers instance
    @objc fileprivate(set) public lazy var mediaPlayers: MediaPlayers = MediaPlayers(tracker: self)
    /// Campaign Tracking. Campaign is now available as a screen object property but you may use this method for notification tracking
    @objc fileprivate(set) public lazy var mvTestings: MvTestings = MvTestings(tracker: self)
    
    
    /// SDK Version
    @objc fileprivate(set) public lazy var sdkVersion = TechnicalContext.sdkVersion
    
    /// Custom User-Agent
    @objc internal var userAgent = ""
    
    /// Application version
    @objc private var _applicationVersion = "";
    @objc internal var applicationVersion : String {
        get {
            return _applicationVersion
        }
        set {
            let po = ParamOption()
            po.persistent = true
            if newValue == "" {
                handleNotStringParameterSetting("apvr", value: "[\"" + TechnicalContext.applicationVersion + "\"]", options: po)
            } else {
                handleNotStringParameterSetting("apvr", value: "[\"" + newValue + "\"]", options: po)
            }
            _applicationVersion = newValue
        }
    };
    
    //MARK: - Initializer
    
    
    @objc func registerIfNeeded(needed: Bool) {
        if needed {
            ATInternet.sharedInstance.registerTracker(UUID().uuidString, tracker: self)
        }
    }
    
    
    /// Initialisation with default configuration
    public convenience override init() {
        self.init(configuration: Configuration().parameters, registerNeeded: true)
    }
    
    /// Initialisation with default configuration
    convenience init(registerNeeded: Bool) {
        self.init(configuration: Configuration().parameters, registerNeeded: registerNeeded)
    }
    
    
    /// Initialisation with a custom configuration
    ///
    /// - Parameter configuration: map that contains key/values. See TrackerConfigurationKeys
    @objc public convenience init(configuration: [String: String]) {
        self.init(configuration: configuration, registerNeeded: true)
    }
    
    /// Initialisation with a custom configuration
    ///
    /// - Parameter configuration: map that contains key/values. See TrackerConfigurationKeys
    /// - Parameter registerNeeded: if registrering tracker to ATInternet trackers is needed
    @objc init(configuration: [String: String], registerNeeded: Bool) {
        
        // Set the custom configuration
        self.configuration = Configuration(customConfiguration: configuration)
        
        super.init()
        
        if(!LifeCycle.isInitialized && !ATInternet.optOut) {
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationDidEnterBackground), name:NSNotification.Name(rawValue: "UIApplicationDidEnterBackgroundNotification"), object: nil)
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationWillResignActive), name:NSNotification.Name(rawValue: "UIApplicationWillResignActiveNotification"), object: nil)
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationActive), name:NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"), object: nil)
            
            LifeCycle.applicationActive(self.configuration.parameters)
        }
        
        let ud = UserDefaults.standard
        ud.setValue(false, forKey: CampaignKeys.ATCampaignAdded.rawValue)
        ud.synchronize()
        
        self.registerIfNeeded(needed: registerNeeded)
    }
    
    /**
     Called when application goes to background
     should save the timestamp to know if we have to start a new session on the next launch
     */
    @objc func applicationDidEnterBackground() {
        TechnicalContext.applicationState = TechnicalContext.ApplicationState.background
        LifeCycle.applicationDidEnterBackground()
    }
    
    /**
     Called when application goes to inactive
     */
    @objc func applicationWillResignActive() {
        TechnicalContext.applicationState = TechnicalContext.ApplicationState.inactive
    }
    
    /**
     Called when app is active
     Should create a new SessionId if necessary
     */
    @objc func applicationActive() {
        TechnicalContext.applicationState = TechnicalContext.ApplicationState.active
        LifeCycle.applicationActive(self.configuration.parameters)
    }
    
    // MARK: - Configuration
    
    /// Get the current configuration (read-only)
    @objc public var config: [String:String] {
        get {
            return self.configuration.parameters
        }
    }
    
    /// Set a new configuration
    ///
    /// - Parameters:
    ///   - configuration: A dictionary that contains new key/values. see TrackerConfigurationKeys.
    ///   - override: if true: the old configuration is full cleared - all default keys _MUST_ be set (optional, default: false)
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setConfig(_ configuration: [String: String], override: Bool = false, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        
        var keyCount = 0
        
        if(override) {
            self.configuration.parameters.removeAll(keepingCapacity: false)
        }
        
        for (key, value) in configuration {
            keyCount = keyCount + 1
            if (sync) {
                if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
                    self.configuration.parameters[key] = value
                    if let identifier = self.configuration.parameters["identifier"], identifier != "" {
                        self.buffer.recomputeUserId()
                    }
                } else {
                    delegate?.warningDidOccur?(String(format: "Configuration %@ is read only. Value will not be updated", key))
                }
            } else {
                if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
                    let configurationOperation = BlockOperation(block: {
                        self.configuration.parameters[key] = value
                        if let identifier = self.configuration.parameters["identifier"], identifier != "" {
                            self.buffer.recomputeUserId()
                        }
                    })
                    
                    if(completionHandler != nil && keyCount == configuration.count) {
                        configurationOperation.completionBlock = {
                            completionHandler!(true)
                        }
                    }
                    
                    TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
                } else {
                    if(completionHandler != nil && keyCount == configuration.count) {
                        completionHandler!(false)
                    }
                    delegate?.warningDidOccur?(String(format: "Configuration %@ is read only. Value will not be updated", key))
                }
            }
        }
    }
    
    /// Set one new key/value pair
    ///
    /// - Parameters:
    ///   - key: see TrackerConfigurationKeys
    ///   - value: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setConfig(_ key: String, value: String, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        if (sync) {
            if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
                self.configuration.parameters[key] = value
                if let identifier = self.configuration.parameters["identifier"], identifier != "" {
                    self.buffer.recomputeUserId()
                }
            } else {
                delegate?.warningDidOccur?(String(format: "Configuration %@ is read only. Value will not be updated", key))
            }
        } else {
            if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
                let configurationOperation = BlockOperation(block: {
                    self.configuration.parameters[key] = value
                    if let identifier = self.configuration.parameters["identifier"], identifier != "" {
                        self.buffer.recomputeUserId()
                    }
                })
                
                if(completionHandler != nil) {
                    configurationOperation.completionBlock = {
                        completionHandler!(true)
                    }
                }
                
                TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
            } else {
                if(completionHandler != nil) {
                    completionHandler!(false)
                }
                delegate?.warningDidOccur?(String(format: "Configuration %@ is read only. Value will not be updated", key))
            }
        }
    }
    
    /// Set a new log
    ///
    /// - Parameters:
    ///   - log: ATInternet subdomain value
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setLog(_ log: String, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Log, value: log, sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new secure log
    ///
    /// - Parameters:
    ///   - securedLog: ATInternet secured subdomain value
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setSecuredLog(_ securedLog: String, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.LogSSL, value: securedLog, sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new domain
    ///
    /// - Parameters:
    ///   - domain: ATInternet collect domain value
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setDomain(_ domain: String, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Domain, value: domain, sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new site ID
    ///
    /// - Parameters:
    ///   - siteId: ATInternet site identifier
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setSiteId(_ siteId: Int, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Site, value: String(siteId), sync: sync, completionHandler: completionHandler)
    }
    
    /// Set the offline mode
    ///
    /// - Parameters:
    ///   - offlineMode: (required, always, never)
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    public func setOfflineMode(_ offlineMode: OfflineModeKey, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.OfflineMode, value: offlineMode.rawValue, sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable the secure mode
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    /// - Deprecated : Since 2.16.0, secure mode is forced
    @objc @available(*, deprecated, message: "since 2.16.0, secure mode forced")
    public func setSecureModeEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        delegate?.warningDidOccur?("Useless method, secure mode forced")
    }
    
    /// Set a new identifier type
    ///
    /// - Parameters:
    ///   - identifierType: IdentifierTypeKey
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    public func setIdentifierType(_ identifierType: IdentifierTypeKey, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Identifier, value: identifierType.rawValue, sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable hash user id (SHA-256 with salt to ensure anonymity)
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setHashUserIdEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.HashUserId, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable ignore limited ad tracking
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setIgnoreLimitedAdTrackingEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.IgnoreLimitedAdTracking, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable send hits when opt out
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setSendHitWhenOptOutEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.SendHitWhenOptOut, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new Plugin
    ///
    /// - Parameters:
    ///   - pluginNames: list of PluginKey
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    public func setPlugins(_ pluginNames: [PluginKey], sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        let newValue = pluginNames.map({$0.rawValue}).joined(separator: ",")
        setConfig(TrackerConfigurationKeys.Plugins, value: newValue, sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable background task
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setBackgroundTaskEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.EnableBackgroundTask, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Ensures that all hits are sent only in foreground if set to true. (default: false)
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @available(*, deprecated, message: "use setSendOnApplicationState instead")
    @objc public func setSendOnlyWhenAppActive(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.SendOnlyWhenAppActive, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Ensures that all hits are sent only in allowed states
    ///
    /// - Parameters:
    ///   - state: allowed state to send hit
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    public func setSendOnApplicationState(_ state: SendApplicationState, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.SendOnApplicationState, value: String(state.rawValue), sync: sync, completionHandler: completionHandler)
    }
    
    /// Set new pixel path
    ///
    /// - Parameters:
    ///   - pixelPath: request path to get pixel
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setPixelPath(_ pixelPath: String, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.PixelPath, value: pixelPath, sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable persistent identified visitor (identification data available for all sessions)
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setPersistentIdentifiedVisitorEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.PersistIdentifiedVisitor, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Enable the campaign persistance
    ///
    /// - Parameters:
    ///   - enabled: store last or first campaign
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setCampaignLastPersistenceEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.CampaignLastPersistence, value: String(enabled), sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new campaign lifetime
    ///
    /// - Parameters:
    ///   - lifetime: campaign lifetime
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setCampaignLifetime(_ lifetime: Int, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.CampaignLifetime, value: String(lifetime), sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new Session duration
    ///
    /// - Parameters:
    ///   - duration: Duration between two application openings after which a new session is started
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @objc public func setSessionBackgroundDuration(_ duration: Int, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.SessionBackgroundDuration, value: String(duration), sync: sync, completionHandler: completionHandler)
    }
    
    /// Set a new Max Hit Size
    ///
    /// - Parameters:
    ///   - maxHitSize: new max hit size
    @objc public func setMaxHitSize(_ maxHitSize: Int) {
        if maxHitSize < 1_600 {
            self.configuration.parameters[TrackerConfigurationKeys.MaxHitSize] = String(1_600)
        } else {
            self.configuration.parameters[TrackerConfigurationKeys.MaxHitSize] = String(maxHitSize)
        }
    }
    
    /// Set a new uuid duration
    ///
    /// - Parameters:
    ///   - uuidDuration: new uuid duration
    @objc public func setUUIDDuration(_ uuidDuration: Int) {
        self.configuration.parameters[TrackerConfigurationKeys.UUIDDuration] = String(uuidDuration)
    }
    
    /// Set a new uuid expiration mode
    ///
    /// - Parameters:
    ///   - uuidExpirationMode: UUIDExpirationModeKey
    public func setUUIDExpirationMode(_ uuidExpirationMode: UUIDExpirationModeKey) {
        self.configuration.parameters[TrackerConfigurationKeys.UUIDExpirationMode] = uuidExpirationMode.rawValue
    }
    
    /// Set a new proxy type
    ///
    /// - Parameters:
    ///   - proxyType: ProxyTypeKey
    public func setProxyType(_ proxyType: ProxyTypeKey) {
        self.configuration.parameters[TrackerConfigurationKeys.ProxyType] = proxyType.rawValue
    }
    
    /// Set a new proxy address
    ///
    /// - Parameters:
    ///   - proxyAddress: new proxy address
    public func setProxyAddress(_ proxyAdress: String) {
        self.configuration.parameters[TrackerConfigurationKeys.ProxyAddress] = proxyAdress
    }
    
    // MARK: - Parameter
    
    /**
     Add a parameter in the hit querystring
     
     - parameter key: parameter key
     - parameter value: parameter value
     */
    fileprivate func processSetParam(_ key: String, value: @escaping ()->(String)) {
        // Check whether the parameter is not in read only mode                 buffer.volatileParameters[key] = Param(key: key, value: value)
        if(!ReadOnlyParam.list.contains(key)) {
            buffer.volatileParameters[key] = Param(key: key, value: value)
        } else {
            delegate?.warningDidOccur?(String(format: "Parameter %@ is read only. Value will not be updated", key))
        }
    }
    
    /**
     Add a parameter in the hit querystring
     
     - parameter key: parameter key
     - parameter value: parameter value
     - parameter options: parameter options
     */
    fileprivate func processSetParam(_ key: String, value: @escaping ()->(String), options: ParamOption) {
        guard !ReadOnlyParam.list.contains(key) else {
            delegate?.warningDidOccur?(String(format: "Parameter %@ is read only. Value will not be updated", key))
            return
        }
        
        let param = Param(key: key, value: value, options: options)
        var newValues = [() -> String]()
        if param.isPersistent {
            if options.append {
                if let existingParam = buffer.persistentParameters[key] {
                    newValues = existingParam.values
                }
                if let existingParam = buffer.volatileParameters[key] {
                    existingParam.values.append(value)
                }
            } else {
                buffer.volatileParameters.removeValue(forKey: key)
            }
            
            newValues.append(value)
            param.values = newValues
            buffer.persistentParameters[key] = param
        } else {
            if options.append {
                if let existingParam = buffer.volatileParameters[key] {
                    newValues = existingParam.values
                }
                else if let existingParam = buffer.persistentParameters[key] {
                    newValues = Array.init(existingParam.values)
                }
            }
            newValues.append(value)
            param.values = newValues
            buffer.volatileParameters[key] = param
        }
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: string parameter value
    /// - Returns: the current tracker
    @objc @discardableResult
    public func setParam(_ key: String, value: @escaping ()->(String)) -> Tracker {
        processSetParam(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: string parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @objc @discardableResult
    public func setParam(_ key: String, value: @escaping ()->(String), options: ParamOption) -> Tracker {
        processSetParam(key, value: value, options: options)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: string parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setStringParam:value:)
    public func setParam(_ key: String, value: String) -> Tracker {
        // If string is not JSON
        if (value.toJSONObject() == nil) {
            processSetParam(key, value: {value})
        } else {
            processSetParam(key, value: {value})
        }
        
        return self
    }
    
    /// Add a property in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: string property value
    ///   - persistent: persistent option
    /// - Returns: the current tracker
    @discardableResult
    @objc public func setProp(_ key: String, value: String, persistent: Bool) -> Tracker {
        let opts = ParamOption()
        opts.encode = true
        opts.persistent = persistent
        opts.property = true
        return setParam(key, value: {value}, options: opts)
    }
    
    /// Add properties in the hit querystring
    ///
    /// - Parameters:
    ///   - props: properties map
    ///   - persistent: persistent option
    /// - Returns: the current tracker
    @discardableResult
    @objc public func setProps(_ props: [String: String], persistent: Bool) -> Tracker {
        for (k,v) in props {
            setProp(k, value: v, persistent: persistent)
        }
        return self
    }
    
    /// get a property
    ///
    /// - Parameters:
    ///   - key: parameter key
    /// - Returns: param object
    @discardableResult
    @objc public func getProp(_ key: String) -> Param? {
        if let p = getParam(key), p.isProperty {
            return p
        }
        return nil
    }
    
    /// get all properties
    ///
    /// - Returns: param object list
    @discardableResult
    @objc public func getProps() -> [Param] {
        let params = getParams()
        var properties = [Param]()
        for p in params {
            if p.isProperty {
                properties.append(p)
            }
        }
        return properties
    }
    
    /// remove property from the hit querystring
    ///
    /// - Parameters:
    ///   - key: property key
    @objc public func delProp(_ key: String) {
        if let p = getProp(key) {
            unsetParam(p.key)
        }
    }
    
    /// remove all properties
    @objc public func delProps() {
        var keys = [String]()
        keys.append(contentsOf: buffer.volatileParameters.keys)
        keys.append(contentsOf: buffer.persistentParameters.keys)
        for k in keys {
            delProp(k)
        }
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: string parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setStringParam:value:options:)
    public func setParam(_ key: String, value: String, options: ParamOption) -> Tracker {
        // If string is not JSON
        if (value.toJSONObject() == nil) {
            processSetParam(key, value: {value}, options: options)
        } else {
            processSetParam(key, value: {value}, options: options)
        }
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: int parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setIntParam:value:)
    public func setParam(_ key: String, value: Int) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: int parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setIntParam:value:options:)
    public func setParam(_ key: String, value: Int, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, options: options)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: float parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setFloatParam:value:)
    public func setParam(_ key: String, value: Float) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: float parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setFloatParam:value:options:)
    public func setParam(_ key: String, value: Float, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, options: options)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: double parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setDoubleParam:value:)
    public func setParam(_ key: String, value: Double) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: double parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setDoubleParam:value:options:)
    public func setParam(_ key: String, value: Double, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, options: options)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: bool parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setBoolParam:value:)
    public func setParam(_ key: String, value: Bool) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: bool parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setBoolParam:value:options:)
    public func setParam(_ key: String, value: Bool, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, options: options)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: array parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setArrayParam:value:)
    public func setParam(_ key: String, value: [Any]) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: array parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setArrayParam:value:options:)
    public func setParam(_ key: String, value: [Any], options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, options: options)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: dictionary parameter value
    /// - Returns: the current tracker
    @discardableResult
    @objc(setDictionaryParam:value:)
    public func setParam(_ key: String, value: [String: Any]) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value)
        
        return self
    }
    
    /// Add a parameter in the hit querystring
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: dictionary parameter value
    ///   - options: parameter options
    /// - Returns: the current tracker
    @discardableResult
    @objc(setDictionaryParam:value:options:)
    public func setParam(_ key: String, value: [String: Any], options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, options: options)
        
        return self
    }
    
    /// Set a not string type parameter
    ///
    /// - Parameters:
    ///   - key: parameter key
    ///   - value: parameter value
    ///   - type: parameter type
    ///   - options: parameter options
    @objc func handleNotStringParameterSetting(_ key: String, value: Any, options: ParamOption? = nil) {
        var stringValue: (value: String, success: Bool)
        if let optOptions = options {
            stringValue = Tool.convertToString(value, separator: optOptions.separator)
            if (stringValue.success) {
                processSetParam(key, value: {stringValue.value}, options: optOptions)
            } else {
                delegate?.warningDidOccur?(String(format: "Parameter %@ could not be inserted in hit. Parameter will be ignored", key))
            }
        } else {
            stringValue = Tool.convertToString(value)
            if (stringValue.success) {
                processSetParam(key, value: {stringValue.value})
            } else {
                delegate?.warningDidOccur?(String(format: "Parameter %@ could not be inserted in hit. Parameter will be ignored", key))
            }
        }
    }
    
    /// get a parameter
    ///
    /// - Parameters:
    ///   - key: parameter key
    /// - Returns: param object
    func getParam(_ key: String) -> Param? {
        if let p = buffer.volatileParameters[key] {
            return p
        }
        return buffer.persistentParameters[key]
    }
    
    /// get all parameters
    ///
    /// - Returns: param object list
    func getParams() -> [Param] {
        var params = [Param]()
        params.append(contentsOf: buffer.volatileParameters.values)
        params.append(contentsOf: buffer.persistentParameters.values)
        return params
    }
    
    /// Remove a parameter from the hit querystring
    ///
    /// - Parameter param: type
    @objc public func unsetParam(_ param: String) {
        buffer.volatileParameters.removeValue(forKey: param)
        buffer.persistentParameters.removeValue(forKey: param)
    }
    
    /// Remove the screen context: Use only for specific issue mark screenA, mark touchA, dont mark screenB, mark touchB. touchB will be no longer attached to screenA
    @objc public func resetScreenContext() {
        TechnicalContext.screenName = nil
        TechnicalContext.level2 = nil
        TechnicalContext.isLevel2Int = false
    }
    
    // MARK: - Dispatch
    
    /// Sends all tracking objects added
    @objc public func dispatch() {
        
        if(businessObjects.count > 0) {
            
            var onAppAds = [BusinessObject]()
            var customObjects = [BusinessObject]()
            var screenObjects = [BusinessObject]()
            var salesTrackerObjects = [BusinessObject]()
            var internalSearchObjects = [BusinessObject]()
            var products = [BusinessObject]()
            
            // Order object by timestamp
            let sortedObjects = businessObjects.sorted {
                a, b in return a.1.timeStamp < b.1.timeStamp
            }
            
            for(_, object) in sortedObjects {
                
                if(!(object is Product)) {
                    dispatchObjects(&products, customObjects: &customObjects)
                }
                
                // Dispatch onAppAds before sending other object
                if(!(object is OnAppAd || object is ScreenInfo || object is AbstractScreen || object is InternalSearch || object is Cart || object is Order)
                    || (object is OnAppAd && (object as! OnAppAd).action == OnAppAd.OnAppAdAction.touch)) {
                    dispatchObjects(&onAppAds, customObjects: &customObjects)
                }
                
                if let ad = object as? OnAppAd {
                    ///If ad impression, then add to temp list
                    if(ad.action == OnAppAd.OnAppAdAction.view) {
                        onAppAds.append(ad)
                    }
                    else {
                        // Send onAppAd touch hit
                        customObjects.append(ad)
                        dispatcher.dispatch(customObjects)
                        customObjects.removeAll(keepingCapacity: false)
                    }
                } else if object is Product {
                    products.append(object)
                } else if (object is CustomObject || object is NuggAd) {
                    customObjects.append(object)
                } else if (object is Order || object is Cart) {
                    salesTrackerObjects.append(object)
                } else if (object is ScreenInfo) {
                    screenObjects.append(object)
                } else if (object is InternalSearch) {
                    internalSearchObjects.append(object)
                } else if (object is AbstractScreen) {
                    onAppAds += customObjects
                    onAppAds += screenObjects
                    onAppAds += internalSearchObjects
                    
                    // Sales tracker
                    var orders = [BusinessObject]()
                    var cart: Cart?
                    
                    if(salesTrackerObjects.count > 0) {
                        for(_, value) in salesTrackerObjects.enumerated() {
                            switch(value) {
                            case let crt as Cart:
                                cart = crt
                            default:
                                orders.append(value)
                                break
                            }
                        }
                    }
                    
                    if(cart != nil) {
                        if (((object as! AbstractScreen).isBasketScreen) || orders.count > 0) {
                            onAppAds.append(cart!)
                        }
                    }
                    
                    onAppAds += orders
                    onAppAds.append(object)
                    
                    dispatcher.dispatch(onAppAds)
                    
                    screenObjects.removeAll(keepingCapacity: false)
                    salesTrackerObjects.removeAll(keepingCapacity: false)
                    internalSearchObjects.removeAll(keepingCapacity: false)
                    onAppAds.removeAll(keepingCapacity: false)
                    customObjects.removeAll(keepingCapacity: false)
                } else {
                    
                    if(object is Gesture && (object as! Gesture).action == Gesture.GestureAction.search) {
                        onAppAds += internalSearchObjects
                        internalSearchObjects.removeAll(keepingCapacity: false)
                    }
                    
                    onAppAds += customObjects
                    onAppAds += [object]
                    dispatcher.dispatch(onAppAds)
                    
                    onAppAds.removeAll(keepingCapacity: false)
                    customObjects.removeAll(keepingCapacity: false)
                }
            }
            
            // S'il reste des publicités / autopromo à envoyer, on envoie
            dispatchObjects(&onAppAds, customObjects: &customObjects)
            
            // S'il reste des produits vus à envoyer
            dispatchObjects(&products, customObjects: &customObjects)
            
            if(customObjects.count > 0 || internalSearchObjects.count > 0 || screenObjects.count > 0 || salesTrackerObjects.count > 0) {
                customObjects += internalSearchObjects
                customObjects += screenObjects
                customObjects += salesTrackerObjects
                
                dispatcher.dispatch(customObjects)
                
                customObjects.removeAll(keepingCapacity: false)
                internalSearchObjects.removeAll(keepingCapacity: false)
                screenObjects.removeAll(keepingCapacity: false)
                salesTrackerObjects.removeAll(keepingCapacity: false)
            }
            
        } else {
            dispatcher.dispatch(nil)
        }
    }
    
    /**
     Dispatch objects with their customObjects
     */
    func dispatchObjects(_ objects: inout [BusinessObject], customObjects: inout [BusinessObject]) {
        if(objects.count > 0) {
            objects += customObjects
            dispatcher.dispatch(objects)
            customObjects.removeAll(keepingCapacity: false)
            objects.removeAll(keepingCapacity: false)
        }
    }
    
    //MARK: - User identifier management
    
    ///  Get the user id
    ///
    /// - Returns: the user id depending on configuration (uuid, idfv)
    @objc public func getUserId() -> String {
        let ignoreLimitedAdTracking = self.configuration.parameters["ignoreLimitedAdTracking"]?.toBool() ?? false
        let uuidDuration = self.configuration.parameters["UUIDDuration"]?.toInt() ?? 397
        let uuidExpirationMode = self.configuration.parameters["UUIDExpirationMode"] ?? "fixed"
        
        if let hash = self.configuration.parameters["hashUserId"] {
            if hash.toBool() {
                return TechnicalContext.userId(self.configuration.parameters["identifier"], ignoreLimitedAdTracking: ignoreLimitedAdTracking, uuidDuration: uuidDuration, uuidExpirationMode: uuidExpirationMode).sha256Value
            }
        }
        
        return TechnicalContext.userId(self.configuration.parameters["identifier"], ignoreLimitedAdTracking: ignoreLimitedAdTracking, uuidDuration: uuidDuration, uuidExpirationMode: uuidExpirationMode)
    }
    
    
    /// Set a custom user id
    ///
    /// - Parameter userId: the userID. if hashUserId is enabled, the hash will be performed on this userID
    @objc public func setUserId(userId: String) {
        let param = ParamOption()
        param.persistent = true
        handleNotStringParameterSetting(HitParam.userID.rawValue, value: userId, options: param)
    }
    
    /// Get lifecycle metrics
    ///
    /// - Returns: the map which contains lifecycle metrics computed by the SDK
    @objc public func getLifecycleMetrics() -> [String : Any] {
        return LifeCycle.getMetricsMap()
    }
    
    /// Get last crash informations
    ///
    /// - Returns: the map which contains lifecycle metrics computed by the SDK
    @objc public func getCrashInformation() -> [String : Any] {
        if let map = Crash.recover() as? [String : Any] {
            if let crashMap = map["crash"] as? [String : Any] {
                return crashMap
            }
        }
        return [:]
    }
    
    // MARK: - Do not track
    
    
    /// Disable user identification.
    @objc @available(*, deprecated, message: "Use ATInternet.optOut instead")
    public class var optOut: Bool {
        get {
            return TechnicalContext.optOut
        } set {
            let optOutOperation = BlockOperation(block: {
                TechnicalContext.optOut = newValue
            })
            
            TrackerQueue.sharedInstance.queue.addOperation(optOutOperation)
        }
    }
    
    /// Disable user identification.
    @objc @available(*, deprecated, message: "Use ATInternet.optOut instead")
    public class var doNotTrack: Bool {
        get {
            return Tracker.optOut
        } set {
            Tracker.optOut = newValue
        }
    }
    
    // MARK: - Crash
    
    fileprivate static var _handleCrash: Bool = false
    
    /// Set tracker crash handler
    /// Use only if you don't already use another crash analytics solution
    /// Once enabled, tracker crash handler can't be disabled until tracker instance termination
    @objc public class var handleCrash: Bool {
        get {
            return _handleCrash
        } set {
            if !_handleCrash {
                _handleCrash = newValue
                
                if _handleCrash {
                    Crash.handle()
                }
            }
        }
    }
}

// MARK: - Tracker Queue
/// Operation queue
class TrackerQueue: NSObject {
    struct Static {
        static var instance: TrackerQueue?
    }
    
    private static var __once: () = {
        Static.instance = TrackerQueue()
    }()
    /**
     Private initializer (cannot instantiate BuilderQueue)
     */
    fileprivate override init() {
        
    }
    
    /// TrackerQueue singleton
    @objc class var sharedInstance: TrackerQueue {
        _ = TrackerQueue.__once
        
        return Static.instance!
    }
    
    /// Queue
    @objc lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "TrackerQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = QualityOfService.background
        return queue
    }()
}
