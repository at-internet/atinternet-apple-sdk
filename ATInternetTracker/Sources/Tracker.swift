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
import CoreData

#if !os(watchOS)
import UIKit
#else
import WatchKit
#endif

/// Build or send status of the hit
@objc public enum HitStatus: Int {
    case Failed = 0
    case Success = 1
}

/// Standard parameters
public enum HitParam: String {
    case Screen = "p"
    case Level2 = "s2"
    case JSON = "stc"
    case UserID = "idclient"
    case HitType = "type"
    case Action = "action"
    case Touch = "click"
    case TouchScreen = "pclick"
    case TouchLevel2 = "s2click"
    case VisitorIdentifierNumeric = "an"
    case VisitorIdentifierText = "at"
    case VisitorCategory = "ac"
    case BackgroundMode = "bg"
    case OnAppAdsTouch = "atc"
    case OnAppAdsImpression = "ati"
    case GPSLatitude = "gy"
    case GPSLongitude = "gx"
    case Referrer = "ref"
}

/// Background modes
public enum BackgroundMode {
    case Normal
    case Task
    case Fetch
}

// MARK: - Tracker Delegate

/// Tracker's delegate
@objc public protocol TrackerDelegate {
    
    /**
    First launch of the tracker
    
    - parameter message: approval message for confidentiality
    */
    optional func trackerNeedsFirstLaunchApproval(message: String)
    
    /**
    Building of hit done
    
    - parameter status: result of hit building
    - parameter message: info about hit building
    */
    optional func buildDidEnd(status: HitStatus, message: String)
    
    /**
    Sending of hit done
    
    - parameter status: sending result
    - parameter message: information about sending result
    */
    optional func sendDidEnd(status: HitStatus, message: String)
    
    /**
    Saving of hit done (offline)
    
    - parameter message: information about saving result
    */
    optional func saveDidEnd(message: String)
    
    /**
    Partner call done
    
    - parameter response: the response received from the partner
    */
    optional func didCallPartner(response: String)
    
    /**
    Received a warning message (does not stop hit sending)
    
    - parameter message: the warning message
    */
    optional func warningDidOccur(message: String)
    
    /**
    Received an error message (stop hit sending)
    
    - parameter message: the error message
    */
    optional func errorDidOccur(message: String)
    
}

@objc public protocol IAutoTracker {
    
    /**
    Called when a screen has been detected
     */
    optional func screenWasDetected(screen: Screen) -> ()
    
    /**
     Called when a gesture has been detected
     */
    optional func gestureWasDetected(gesture: Gesture) -> ()
}

#if os(iOS) && AT_SMART_TRACKER

public class AutoTracker: Tracker {
    
    /// Private variables
    private var _token: String?
    private var _enableAutoTracking: Bool = false
    private var _enableLiveTagging: Bool = false
    
    /// Checks whether swizzling has already been activated
    private static var eventDetectionEnabled = false
    
    static var isConfigurationLoaded = false
    
    /// Screen orientation
    internal var orientation: UIDeviceOrientation?
    
    /// Smart SDK toolbar
    private var toolbar: SmartToolBarController?
    
    /// Token for authentication
    public var token: String? {
        get {
            return _token
        } set {
            if token == nil && newValue != "" {
                _token = newValue
                self.liveManager = LiveNetworkManager()
                self.liveManager!.initState()
                self.socketSender = SocketSender(liveManager: liveManager!, token: _token!)
                liveManager!.sender = socketSender
            } else {
                self.delegate?.warningDidOccur?("Setting the token twice is not allowed")
            }
        }
    }
    
    /// Sets Auto Tracker in debug mode
    public lazy var debug: Bool = false
    
    var socketSender: SocketSender?
    
    var liveManager: LiveNetworkManager?
    
    /// Enable the socket connexion to send events
    public var enableLiveTagging: Bool {
        get {
            return _enableLiveTagging
        } set {
            assert(NSThread.isMainThread(),"You should set enableLiveTagging in the main thread to ensure the framework stability")
            assert(token != nil && token != "", "you must provide a token before enabling live tagging")
            
            _enableLiveTagging = newValue
            enableEventDetection(_enableLiveTagging)
            _enableLiveTagging == true ? socketSender?.open() : socketSender?.close()
        }
    }
    
    /// Enables Auto Tracking
    public var enableAutoTracking: Bool {
        get {
            return _enableAutoTracking
        } set {
            _enableAutoTracking = newValue
            
            if _enableAutoTracking {
                if token == "" {
                    self.delegate?.warningDidOccur?("No token provided")
                    Configuration.smartSDKMapping = nil
                    AutoTracker.isConfigurationLoaded = true
                } else {
                    fetchMappingConfig()
                }
            }
            
            enableEventDetection(_enableAutoTracking)
        }
    }
    
    private func fetchMappingConfig() {
        let version = TechnicalContext.applicationVersion
        let s3Client = ApiS3Client(token: token!, version: version, store: UserDefaultSimpleStorage(), networkService: S3NetworkService())
        s3Client.fetchMapping { (mapping: ATJSON?) in
            Configuration.smartSDKMapping = mapping
            if let _ = mapping {
                s3Client.saveSmartSDKMapping(mapping!)
            } else {
                self.delegate?.warningDidOccur?("No livetagging configuration loaded")
            }
            AutoTracker.isConfigurationLoaded = true
        }
    }

    private func enableEventDetection(enabled: Bool) {
        if enabled == true {
            if AutoTracker.eventDetectionEnabled == false {
                
                AutoTracker.eventDetectionEnabled = true
                
                removeNotifications()
                addNotifications()
                registerCurrentOrientation()
                
                UIApplication.at_swizzle()
                UIViewController.at_unswizzle_instances()
                UIViewController.at_swizzle()
                UIRefreshControl.at_swizzle()
                UISwitch.at_swizzle()

            }
            // time consuming, so last call of the init
            if enableLiveTagging {
                self.performSelectorOnMainThread(#selector(addToolbar), withObject: nil, waitUntilDone: false)
            }
        } else {
            if AutoTracker.eventDetectionEnabled == true && self.enableAutoTracking == false && self.enableLiveTagging == false {
                
                AutoTracker.eventDetectionEnabled = false
                
                removeNotifications()
                
                UIViewController.at_swizzle()
                UIViewController.at_unswizzle_instances()
                UIApplication.at_swizzle()
                UIRefreshControl.at_swizzle()
                UISwitch.at_swizzle()
                self.toolbar?.toolbar.removeFromSuperview()
            }
        }
    }
    
    func registerCurrentOrientation() {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        if orientation == .Portrait || orientation == .PortraitUpsideDown {
            UIViewControllerContext.sharedInstance.currentOrientation = UIViewControllerContext.UIViewControllerOrientation.Portrait
        } else {
            UIViewControllerContext.sharedInstance.currentOrientation = UIViewControllerContext.UIViewControllerOrientation.Landscape
        }
    }
    
    init() {
        super.init(configuration: Configuration().parameters)
        self.registerFont("OpenSans-Regular")
        self.registerFont("Montserrat-Bold")
        self.registerFont("Montserrat-Regular")
        
        if let autoTrack = self.configuration.parameters[TrackerConfigurationKeys.AutoTracking] {
            if autoTrack == "true" {
                self.enableAutoTracking = true
            }
        }
        
        if let token = self.configuration.parameters[TrackerConfigurationKeys.AutoTrackerToken] {
            self.token = token
        }
    }
    
    /**
     Listen to app notifications (orientation, lifecycle ...)
     */
    private func addNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        notificationCenter.addObserver(self, selector: #selector(AutoTracker.deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AutoTracker.applicationDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AutoTracker.windowBecomeVisible(_:)), name: UIWindowDidBecomeKeyNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AutoTracker.UIApplicationWillTerminate(_:)), name: UIApplicationWillTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AutoTracker.appWillGoBg(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    func windowBecomeVisible(notification: NSNotification) {
        if let delegate = UIApplication.sharedApplication().keyWindow {
            if let _ = delegate.window {
                addToolbar("keyWindow")
            }
        }
    }

    /**
     Removes listeners
     */
    private func removeNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        notificationCenter.removeObserver(self)
    }
    
    /**
     Application is going background
     */
    @objc func appWillGoBg(notification: NSNotification) {
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            self.liveManager?.deviceStoppedLive()
        }
    }
    
    /**
     Device orientation detection
     
     - parameter notification: notification
     */
    @objc func deviceOrientationDidChange(notification: NSNotification) {
        let currentOrientation = UIDevice.currentDevice().orientation
        if orientation == nil {
            orientation = currentOrientation
        } else {
            if currentOrientation != orientation && currentOrientation != UIDeviceOrientation.FaceUp && currentOrientation != UIDeviceOrientation.FaceDown && UIViewControllerContext.sharedInstance.currentViewController != nil {
                let deviceRotation = DeviceRotationEvent(orientation: currentOrientation)
                deviceRotation.viewController = UIViewControllerContext.sharedInstance.currentViewController
                EventManager.sharedInstance.addEvent(DeviceRotationOperation(rotationEvent: deviceRotation))
            }
        }
        
        if currentOrientation != UIDeviceOrientation.FaceUp && currentOrientation != UIDeviceOrientation.FaceDown {
            orientation = currentOrientation
        }
        
        
        toolbar?.rotateIfNeeded()
    }
    
    @objc func applicationDidBecomeActive(application: UIApplication) {
        if enableAutoTracking && token != nil && token != "" {
            fetchMappingConfig()
        }
    }
    
    @objc func UIApplicationWillTerminate(application: UIApplication) {
        if self.enableLiveTagging == true {
            self.liveManager?.deviceStoppedLive()
        }
    }
    
    func addToolbar(age: String) {
        if toolbar == nil && socketSender != nil && liveManager != nil && UIApplication.sharedApplication().keyWindow != nil{
            toolbar = SmartToolBarController(socket:self.socketSender!, networkManager: self.liveManager!)
            self.liveManager!.toolbar = toolbar
        }
    }
    
    /**
     Register font for SmartTracker toolbar
     */
    func registerFont(font: String) {
        let fontPath = NSBundle(forClass: Tracker.self).pathForResource(font, ofType: ".ttf")
        let dataFont = NSData(contentsOfFile: fontPath!)
        let provider = CGDataProviderCreateWithCFData(dataFont!)
        let fontRef = CGFontCreateWithDataProvider(provider!)
        CTFontManagerRegisterGraphicsFont(fontRef, nil)
    }
}
    
#endif

// MARK: - Tracker

/// Wrapper class for tracking usage of your application
public class Tracker: NSObject {
    
    internal weak var _delegate: TrackerDelegate? = nil
    
    /// Tracker's delegate
    public var delegate: TrackerDelegate? {
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
    var configuration: Configuration
    
    /// Contains parameters
    lazy var buffer: Buffer = Buffer(tracker: self)
    
    /// Dispatcher
    lazy var dispatcher: Dispatcher = Dispatcher(tracker: self)
    
    #if os(iOS) && !AT_EXTENSION
    /// Sets Tracker in debug mode and display debugger window
    public var enableDebugger: Bool = false {
        didSet {
            if enableDebugger == true {
                
                let q = dispatch_queue_create("com.atinternet.Tracker.debuggerQueue", DISPATCH_QUEUE_SERIAL)
                
                dispatch_async(q, {
                    while(UIApplication.sharedApplication().windows.count == 0) {
                         NSThread.sleepForTimeInterval(0.2)
                    }
                    
                    self.performSelectorOnMainThread(#selector(self.displayDebugger), withObject: nil, waitUntilDone: false)
                })
            } else {
                Debugger.sharedInstance.deinitDebugger()
            }
        }
    }
    
    /**
     Display the debugger window
     */
    func displayDebugger() {
        Debugger.sharedInstance.initDebugger()
    }
    #endif
    
    internal lazy var businessObjects: [String: BusinessObject] = [String: BusinessObject]()
    
    //MARK: Offline
    private(set) public lazy var offline: Offline = Offline(tracker: self)
    
    //MARK: Context Tracking
    /// Context tracking
    private(set) public lazy var context: Context = Context(tracker: self)
    
    //MARK: NuggAd Tracking
    /// NuggAd tracking
    private(set) public lazy var nuggAds: NuggAds = NuggAds(tracker: self)
    
    //MARK: GPS Tracking
    /// GPS tracking
    @available(*, deprecated=2.5.0, message="location is now only available as a screen object property.")
    private(set) public lazy var locations: Locations = Locations(tracker: self)
    
    //MARK: Publisher Tracking
    /// Publisher tracking
    private(set) public lazy var publishers: Publishers = Publishers(tracker: self)
    
    //MARK: SelfPromotion Tracking
    /// SelfPromotion tracking
    private(set) public lazy var selfPromotions: SelfPromotions = SelfPromotions(tracker: self)
    
    //MARK: Identified Visitor Tracking
    /// Identified visitor tracking
    private(set) public lazy var identifiedVisitor: IdentifiedVisitor = IdentifiedVisitor(tracker: self)
    
    //MARK: Screen Tracking
    /// Screen tracking
    private(set) public lazy var screens: Screens = Screens(tracker: self)
    
    //MARK: Dynamic Screen Tracking
    /// Dynamic Screen tracking
    private(set) public lazy var dynamicScreens: DynamicScreens = DynamicScreens(tracker: self)
    
    //MARK: Touch Tracking
    /// Touch tracking
    private(set) public lazy var gestures: Gestures = Gestures(tracker: self)
    
    //MARK: Custom Object Tracking
    private(set) public lazy var customObjects: CustomObjects = CustomObjects(tracker: self)
    
    //MARK: TV Tracking
    private(set) public lazy var tvTracking: TVTracking = TVTracking(tracker: self)
    
    //MARK: Event Tracking
    /// Event tracking
    private(set) lazy var event: Event = Event(tracker: self)
    
    //MARK: CustomVar Tracking
    /// CustomVar tracking
    @available(*, deprecated=2.5.0, message="customVars is now only available as a screen object property.")
    private(set) public lazy var customVars: CustomVars = CustomVars(tracker: self)
    
    //MARK: Order Tracking
    /// Order tracking
    private(set) public lazy var orders: Orders = Orders(tracker: self)
    
    //MARK: Aisle Tracking
    /// Aisle tracking
    @available(*, deprecated=2.5.0, message="aisles is now only available as a screen object property.")
    private(set) public lazy var aisles: Aisles = Aisles(tracker: self)
    
    //MARK: Cart Tracking
    /// Cart tracking
    private(set) public lazy var cart: Cart = Cart(tracker: self)
    
    //MARK: Product Tracking
    /// Product tracking
    private(set) public lazy var products: Products = Products(tracker: self)
    
    //MARK: Campaign Tracking
    /// Campaign tracking
     @available(*, deprecated=2.5.0, message="campaign is now only available as a screen object property.")
    private(set) public lazy var campaigns: Campaigns = Campaigns(tracker: self)
    
    //MARK: Internal Search Tracking
    /// Internal Search tracking
     @available(*, deprecated=2.5.0, message="internalSearch is now only available as a screen object property.")
    private(set) public lazy var internalSearches: InternalSearches = InternalSearches(tracker: self)
    
    //MARK: Custom tree structure Tracking
    /// Custom tree structure  tracking
    @available(*, deprecated=2.5.0, message="customTreeStructures is now only available as a screen object property.")
    private(set) public lazy var customTreeStructures: CustomTreeStructures = CustomTreeStructures(tracker: self)
    
    //MARK: Richmedia Tracking
    /// Richmedia tracking
    private(set) public lazy var mediaPlayers: MediaPlayers = MediaPlayers(tracker: self)

    
    //MARK: - Initializer
    
    /**
    Default tracker initializer
    
    - returns: a Tracker
    */
    public convenience override init() {
        self.init(configuration: Configuration().parameters)
    }
    
    /**
    Tracker initializer with custom configuration
    
    - parameter configuration: custom configuration
    
    - returns: a Tracker
    */
    public init(configuration: [String: String]) {
        
        // Set the custom configuration
        self.configuration = Configuration(customConfiguration: configuration)
        
        super.init()
        
        if(!LifeCycle.isInitialized) {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationDidEnterBackground), name:"UIApplicationDidEnterBackgroundNotification", object: nil)
            notificationCenter.addObserver(self, selector: #selector(Tracker.applicationActive), name:"UIApplicationDidBecomeActiveNotification", object: nil)
            
            LifeCycle.applicationActive(self.configuration.parameters)
        }
    }
    
    /**
     Called when application goes to background
     should save the timestamp to know if we have to start a new session on the next launch
     */
    @objc func applicationDidEnterBackground() {
        LifeCycle.applicationDidEnterBackground()
    }
    
    /**
     Called when app is active
     Should create a new SessionId if necessary
     */
    @objc func applicationActive() {
        LifeCycle.applicationActive(self.configuration.parameters)
    }
    
    // MARK: - Configuration
    
    /// Get the current configuration (read-only)
    public var config: [String:String] {
        get {
            return self.configuration.parameters
        }
    }
    
    /** 
    Override current tracker configuration

    - parameter configuration: new configuration for the tracker
    */
    public func setConfig(configuration: [String: String], override: Bool, completionHandler: ((isSet: Bool) -> Void)?) {
        
        var keyCount = 0
        
        if(override) {
            self.configuration.parameters.removeAll(keepCapacity: false)
        }
        
        for (key, value) in configuration {
            keyCount = keyCount + 1
            if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
                let configurationOperation = NSBlockOperation(block: {
                    self.configuration.parameters[key] = value
                })
                
                if(completionHandler != nil && keyCount == configuration.count) {
                    configurationOperation.completionBlock = {
                        completionHandler!(isSet: true)
                    }
                }
                
                TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
            } else {
                if(completionHandler != nil && keyCount == configuration.count) {
                    completionHandler!(isSet: false)
                }
                delegate?.warningDidOccur?(String(format: "Configuration %@ is read only. Value will not be updated", key))
            }
        }
    }
    
    /**
    Set a configuration key
    
    - parameter key: configuration parameter key
    - parameter value: configuration parameter value
    */
    public func setConfig(key: String, value: String, completionHandler: ((isSet: Bool) -> Void)?) {
        if (!Configuration.ReadOnlyConfiguration.list.contains(key)) {
            let configurationOperation = NSBlockOperation(block: {
                self.configuration.parameters[key] = value
            })
            
            if(completionHandler != nil) {
                configurationOperation.completionBlock = {
                    completionHandler!(isSet: true)
                }
            }
            
            TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        } else {
            if(completionHandler != nil) {
                completionHandler!(isSet: false)
            }
            delegate?.warningDidOccur?(String(format: "Configuration %@ is read only. Value will not be updated", key))
        }
    }
    
    public func setLog(log: String, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Log, value: log, completionHandler: completionHandler)
    }
    public func setSecuredLog(securedLog: String, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.LogSSL, value: securedLog, completionHandler: completionHandler)
    }
    public func setDomain(domain: String, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Domain, value: domain, completionHandler: completionHandler)
    }
    public func setSiteId(siteId: Int, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Site, value: String(siteId), completionHandler: completionHandler)
    }
    public func setOfflineMode(offlineMode: OfflineModeKey, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.OfflineMode, value: offlineMode.rawValue, completionHandler: completionHandler)
    }
    public func setSecureModeEnabled(enabled: Bool, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Secure, value: String(enabled), completionHandler: completionHandler)
    }
    public func setIdentifierType(identifierType: IdentifierTypeKey, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.Identifier, value: identifierType.rawValue, completionHandler: completionHandler)
    }
    public func setHashUserIdEnabled(enabled: Bool, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.HashUserId, value: String(enabled), completionHandler: completionHandler)
    }
    public func setPlugins(pluginNames: [PluginKey], completionHandler: ((isSet: Bool) -> Void)?) {
        let newValue = pluginNames.map({$0.rawValue}).joinWithSeparator(",")
        setConfig(TrackerConfigurationKeys.Plugins, value: newValue, completionHandler: completionHandler)
    }
    public func setBackgroundTaskEnabled(enabled: Bool, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.EnableBackgroundTask, value: String(enabled), completionHandler: completionHandler)
    }
    public func setPixelPath(pixelPath: String, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.PixelPath, value: pixelPath, completionHandler: completionHandler)
    }
    public func setPersistentIdentifiedVisitorEnabled(enabled: Bool, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.PersistIdentifiedVisitor, value: String(enabled), completionHandler: completionHandler)
    }
    public func setTvTrackingUrl(url: String, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.TvTrackingURL, value: url, completionHandler: completionHandler)
    }
    public func setTvTrackingVisitDuration(visitDuration: Int, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.TvTrackingVisitDuration, value: String(visitDuration), completionHandler: completionHandler)
    }
    public func setTvTrackingSpotValidityTime(time: Int, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.TvTrackingSpotValidityTime, value: String(time), completionHandler: completionHandler)
    }
    public func setCampaignLastPersistenceEnabled(enabled: Bool, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.CampaignLastPersistence, value: String(enabled), completionHandler: completionHandler)
    }
    public func setCampaignLifetime(lifetime: Int, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.CampaignLifetime, value: String(lifetime), completionHandler: completionHandler)
    }
    public func setSessionBackgroundDuration(duration: Int, completionHandler: ((isSet: Bool) -> Void)?) {
        setConfig(TrackerConfigurationKeys.SessionBackgroundDuration, value: String(duration), completionHandler: completionHandler)
    }
    
    // MARK: - Parameter
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: parameter value
    */
    private func setParam(key: String, value: ()->(String), type: Param.ParamType) {
        // Check whether the parameter is not in read only mode
        if(!ReadOnlyParam.list.contains(key)) {
            let param = Param(key: key, value: value, type: type)
            let positions = Tool.findParameterPosition(key, arrays: buffer.persistentParameters, buffer.volatileParameters)
            
            // Check if parameter is already set
            if(positions.count > 0) {
                // If found, replace first parameter with new value and delete others in appropriate buffer array
                for(index, position) in positions.enumerate() {
                    if(index == 0) {
                        (position.arrayIndex == 0) ? (buffer.persistentParameters[position.index] = param)
                            : (buffer.volatileParameters[position.index] = param)
                    } else {
                        (position.arrayIndex == 0) ? buffer.persistentParameters.removeAtIndex(position.index) : buffer.volatileParameters.removeAtIndex(position.index)
                    }
                }
            } else {
                // If not found, append parameter to volatile buffer
                buffer.volatileParameters.append(param)
            }
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
    private func setParam(key: String, value: ()->(String), type: Param.ParamType, options: ParamOption) {
        // Check whether the parameter is not in read only mode
        if(!ReadOnlyParam.list.contains(key)) {
            let param = Param(key: key, value: value, type: type, options: options)
            let positions = Tool.findParameterPosition(key, arrays: buffer.persistentParameters, buffer.volatileParameters)
            
            if(options.append) {
                // Check if parameter is already set
                for(_, position) in positions.enumerate() {
                    // If new parameter is set to be persistent we move old parameters into the right buffer array
                    if(options.persistent) {
                        // If old parameter was in volatile buffer, we place it into the persistent buffer
                        if(position.arrayIndex > 0) {
                            let existingParam = buffer.volatileParameters[position.index]
                            buffer.volatileParameters.removeAtIndex(position.index)
                            buffer.persistentParameters.append(existingParam)
                        }
                    } else {
                        if(position.arrayIndex == 0) {
                            let existingParam = buffer.persistentParameters[position.index]
                            buffer.persistentParameters.removeAtIndex(position.index)
                            buffer.volatileParameters.append(existingParam)
                        }
                    }
                }
                
                (options.persistent) ? buffer.persistentParameters.append(param) : buffer.volatileParameters.append(param)
            } else {
                // Check if parameter is already set
                if(positions.count > 0) {
                    // If found, replace first parameter with new value and delete others in appropriate buffer array
                    for(index, position) in positions.enumerate() {
                        if(index == 0) {
                            if(position.arrayIndex == 0) {
                                // If parameter is set to be persistent and is already persistent, we change its value. If not, we place the parameter in the volatile buffer
                                if(options.persistent) {
                                    buffer.persistentParameters[position.index] = param
                                } else {
                                    buffer.persistentParameters.removeAtIndex(position.index)
                                    buffer.volatileParameters.append(param)
                                }
                            } else {
                                if(options.persistent) {
                                    buffer.volatileParameters.removeAtIndex(position.index)
                                    buffer.persistentParameters.append(param)
                                } else {
                                    buffer.volatileParameters[position.index] = param
                                }
                            }
                        } else {
                            (position.arrayIndex == 0) ? buffer.persistentParameters.removeAtIndex(position.index) : buffer.volatileParameters.removeAtIndex(position.index)
                        }
                    }
                } else {
                    // If not found, append parameter to buffer
                    (options.persistent) ? buffer.persistentParameters.append(param) : buffer.volatileParameters.append(param)
                }
            }
        } else {
            delegate?.warningDidOccur?(String(format: "Parameter %@ is read only. Value will not be updated", key))
        }
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    */
    public func setParam(key: String, value: ()->(String)) -> Tracker {
        setParam(key, value: value, type: .Closure)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    - parameter options: parameter options
    */
    public func setParam(key: String, value: ()->(String), options: ParamOption) -> Tracker {
        setParam(key, value: value, type: .Closure, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    */
    @objc(setStringParam::)
    public func setParam(key: String, value: String) -> Tracker {
        // If string is not JSON
        if (value.toJSONObject() == nil) {
            setParam(key, value: {value}, type: .String)
        } else {
            setParam(key, value: {value}, type: .JSON)
        }
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: string parameter value
    - parameter options: parameter options
    */
    @objc(setStringParam:::)
    public func setParam(key: String, value: String, options: ParamOption) -> Tracker {
        // If string is not JSON
        if (value.toJSONObject() == nil) {
            setParam(key, value: {value}, type: .String, options: options)
        } else {
            setParam(key, value: {value}, type: .JSON, options: options)
        }
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: int parameter value
    */
    @objc(setIntParam::)
    public func setParam(key: String, value: Int) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Integer)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: int parameter value
    - parameter options: parameter options
    */
    @objc(setIntParam:::)
    public func setParam(key: String, value: Int, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Integer, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: float parameter value
    */
    @objc(setFloatParam::)
    public func setParam(key: String, value: Float) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Float)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: float parameter value
    - parameter options: parameter options
    */
    @objc(setFloatParam:::)
    public func setParam(key: String, value: Float, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Float, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: double parameter value
    */
    @objc(setDoubleParam::)
    public func setParam(key: String, value: Double) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Double)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: double parameter value
    - parameter options: parameter options
    */
    @objc(setDoubleParam:::)
    public func setParam(key: String, value: Double, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Double, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: bool parameter value
    */
    @objc(setBoolParam::)
    public func setParam(key: String, value: Bool) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Bool)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: bool parameter value
    - parameter options: parameter options
    */
    @objc(setBoolParam:::)
    public func setParam(key: String, value: Bool, options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Bool, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: array parameter value
    */
    @objc(setArrayParam::)
    public func setParam(key: String, value: [AnyObject]) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Array)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: array parameter value
    - parameter options: parameter options
    */
    @objc(setArrayParam:::)
    public func setParam(key: String, value: [AnyObject], options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .Array, options: options)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: dictionary parameter value
    */
    @objc(setDictionaryParam::)
    public func setParam(key: String, value: [String: AnyObject]) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .JSON)
        
        return self
    }
    
    /**
    Add a parameter in the hit querystring
    
    - parameter key: parameter key
    - parameter value: dictionary parameter value
    - parameter options: parameter options
    */
    @objc(setDictionaryParam:::)
    public func setParam(key: String, value: [String: AnyObject], options: ParamOption) -> Tracker {
        self.handleNotStringParameterSetting(key, value: value, type: .JSON, options: options)
        
        return self
    }
    
    /**
    Set a not string type parameter
    
    - parameter key: parameter key
    - parameter value: parameter value
    - parameter options: parameter options
    */
    func handleNotStringParameterSetting(key: String, value: AnyObject, type: Param.ParamType, options: ParamOption? = nil) {
        var stringValue: (value: String, success: Bool)
        if let optOptions = options {
            stringValue = Tool.convertToString(value, separator: optOptions.separator)
            if (stringValue.success) {
                setParam(key, value: {stringValue.value}, type: type, options: optOptions)
            } else {
                delegate?.warningDidOccur?(String(format: "Parameter %@ could not be inserted in hit. Parameter will be ignored", key))
            }
        } else {
            stringValue = Tool.convertToString(value)
            if (stringValue.success) {
                setParam(key, value: {stringValue.value}, type: type)
            } else {
                delegate?.warningDidOccur?(String(format: "Parameter %@ could not be inserted in hit. Parameter will be ignored", key))
            }
        }
    }
    
    /**
    Remove a parameter from the hit querystring
    
    - parameter parameter: type
    */
    public func unsetParam(param: String) {
        let positions = Tool.findParameterPosition(param, arrays: buffer.persistentParameters, buffer.volatileParameters)
        
        // Check if parameter is already set in buffer
        if(positions.count > 0) {
            for(_, position) in positions.enumerate() {
                if(position.arrayIndex == 0) {
                    buffer.persistentParameters.removeAtIndex(position.index);
                } else {
                    buffer.volatileParameters.removeAtIndex(position.index);
                }
            }
        }
        
        switch param {
            case HitParam.Level2.rawValue:
                context._level2 = 0
            case HitParam.BackgroundMode.rawValue:
                context._backgroundMode = .Normal
            default:
                break
        }
    }

    // MARK: - Dispatch
    /**
    Send the built hit
    */
    public func dispatch() {
        
        if(businessObjects.count > 0) {
            
            var onAppAds = [BusinessObject]()
            var customObjects = [BusinessObject]()
            var screenObjects = [BusinessObject]()
            var salesTrackerObjects = [BusinessObject]()
            var internalSearchObjects = [BusinessObject]()
            var products = [BusinessObject]()
            
            // Order object by timestamp
            let sortedObjects = businessObjects.sort {
                a, b in return a.1.timeStamp  < b.1.timeStamp
            }
            
            for(_, object) in sortedObjects {
                
                if(!(object is Product)) {
                    dispatchObjects(&products, customObjects: &customObjects)
                }
                
                // Dispatch onAppAds before sending other object
                if(!(object is OnAppAd || object is ScreenInfo || object is AbstractScreen || object is InternalSearch || object is Cart || object is Order)
                    || (object is OnAppAd && (object as! OnAppAd).action == OnAppAd.OnAppAdAction.Touch)) {
                    dispatchObjects(&onAppAds, customObjects: &customObjects)
                }
                
                if let ad = object as? OnAppAd {
                    ///If ad impression, then add to temp list
                    if(ad.action == OnAppAd.OnAppAdAction.View) {
                        onAppAds.append(ad)
                    }
                    else {
                        // Send onAppAd touch hit
                        customObjects.append(ad)
                        dispatcher.dispatch(customObjects)
                        customObjects.removeAll(keepCapacity: false)
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
                        for(_, value) in salesTrackerObjects.enumerate() {
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
                    
                    screenObjects.removeAll(keepCapacity: false)
                    salesTrackerObjects.removeAll(keepCapacity: false)
                    internalSearchObjects.removeAll(keepCapacity: false)
                    onAppAds.removeAll(keepCapacity: false)
                    customObjects.removeAll(keepCapacity: false)
                } else {

                    if(object is Gesture && (object as! Gesture).action == Gesture.GestureAction.Search) {
                        onAppAds += internalSearchObjects
                        internalSearchObjects.removeAll(keepCapacity: false)
                    }
                    
                    onAppAds += customObjects
                    onAppAds += [object]
                    dispatcher.dispatch(onAppAds)
                    
                    onAppAds.removeAll(keepCapacity: false)
                    customObjects.removeAll(keepCapacity: false)
                }
            }
            
            // S'il reste des publicités / autopromo à envoyer, on envoie
            dispatchObjects(&onAppAds, customObjects: &customObjects)
            
            // S'il reste des produits vus à envoyer
            dispatchObjects(&products, customObjects: &customObjects)
            
            if(customObjects.count > 0 || internalSearchObjects.count > 0 || screenObjects.count > 0) {
                customObjects += internalSearchObjects
                customObjects += screenObjects
                
                dispatcher.dispatch(customObjects)
                
                customObjects.removeAll(keepCapacity: false)
                internalSearchObjects.removeAll(keepCapacity: false)
                screenObjects.removeAll(keepCapacity: false)
            }
            
        } else {
            dispatcher.dispatch(nil)
        }
    }
    
    /**
    Dispatch objects with their customObjects
    */
    func dispatchObjects(inout  objects: [BusinessObject], inout customObjects: [BusinessObject]) {
        if(objects.count > 0) {
            objects += customObjects
            dispatcher.dispatch(objects)
            customObjects.removeAll(keepCapacity: false)
            objects.removeAll(keepCapacity: false)
        }
    }
    
    //MARK: - User identifier management
    
    /**
    Gets the user id
    
    - returns: the user id depending on configuration (uuid, idfv)
    */
    public func getUserId() -> String {
        if let hash = self.configuration.parameters["hashUserId"] {
            if (hash == "true") {
                return TechnicalContext.userId(self.configuration.parameters["identifier"]).sha256Value
            } else {
                return TechnicalContext.userId(self.configuration.parameters["identifier"])
            }
        } else {
            return TechnicalContext.userId(self.configuration.parameters["identifier"])
        }
    }
    
    // MARK: - Do not track
    
    /**
    Enable or disable tracking
    */
    public class var doNotTrack: Bool {
        get {
            return TechnicalContext.doNotTrack
        } set {
            let dotNotTrackOperation = NSBlockOperation(block: {
                TechnicalContext.doNotTrack = newValue
            })
            
            TrackerQueue.sharedInstance.queue.addOperation(dotNotTrackOperation)
        }
    }
    
    // MARK: - Crash
    
    private static var _handleCrash: Bool = false
    
    /// Set tracker crash handler
    /// Use only if you don't already use another crash analytics solution
    /// Once enabled, tracker crash handler can't be disabled until tracker instance termination
    public class var handleCrash: Bool {
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
    /**
    Private initializer (cannot instantiate BuilderQueue)
    */
    private override init() {
        
    }
    
    /// TrackerQueue singleton
    class var sharedInstance: TrackerQueue {
        struct Static {
            static var instance: TrackerQueue?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = TrackerQueue()
        }
        
        return Static.instance!
    }
    
    /// Queue
    lazy var queue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "TrackerQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = NSQualityOfService.Background
        return queue
        }()
}
