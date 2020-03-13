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
//  TechnicalContext.swift
//  Tracker
//
#if os(iOS) && canImport(CoreTelephony)
import CoreTelephony
#endif

#if canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(WebKit)
import WebKit
#endif

/// Contextual information from user device
class TechnicalContext: NSObject {
    /// SDK Version
    class var sdkVersion: String {
        get {
            #if os(watchOS) || os(tvOS)
            return "1.14.0"
            #else
            return "2.17.0"
            #endif
        }
    }
    
    enum ConnexionType: String {
        case
        offline = "offline",
        gprs = "gprs",
        edge = "edge",
        twog = "2g",
        threeg = "3g",
        threegplus = "3g+",
        fourg = "4g",
        wifi = "wifi",
        unknown = "unknown"
    }
    
    enum TechnicalContextKeys: String, EnumCollection {
        case OptOut = "ATDoNotTrack"
        case DoNotTrack = "ATDoNotSendHit"
        case UserIDV1 = "ATIdclient"
        case UserIDV2 = "ApplicationUniqueIdentifier"
        case UserID = "ATApplicationUniqueIdentifier"
    }
    
    enum ApplicationState: EnumCollection {
        case active
        case inactive
        case background
    }
    
    /// Name of the last tracked screen
    static var screenName: String? = nil
    /// ID of the last level2 id set in parameters
    static var level2: Int = -1
    
    /// Enable or disable user identification
    class var optOut: Bool {
        get {
            let userDefaults = UserDefaults.standard
            
            if (userDefaults.object(forKey: TechnicalContextKeys.OptOut.rawValue) == nil) {
                return false
            } else {
                return userDefaults.bool(forKey: TechnicalContextKeys.OptOut.rawValue)
            }
        } set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: TechnicalContextKeys.OptOut.rawValue)
            userDefaults.synchronize()
        }
    }
    
    /// Enable or disable hit tracking
    class var doNotTrack: Bool {
        get {
            let userDefaults = UserDefaults.standard
            
            if (userDefaults.object(forKey: TechnicalContextKeys.DoNotTrack.rawValue) == nil) {
                return false
            } else {
                return userDefaults.bool(forKey: TechnicalContextKeys.DoNotTrack.rawValue)
            }
        } set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: TechnicalContextKeys.DoNotTrack.rawValue)
            userDefaults.synchronize()
        }
    }
    
    static var applicationState: ApplicationState = ApplicationState.inactive
    
    /// Unique user id
    class func userId(_ identifier: String?, ignoreLimitedAdTracking: Bool) -> String {
        
        if(!self.doNotTrack) {
            
            let uuid: () -> String = {
                if UserDefaults.standard.object(forKey: TechnicalContextKeys.UserIDV1.rawValue) != nil {
                    return UserDefaults.standard.object(forKey: TechnicalContextKeys.UserIDV1.rawValue) as! String
                } else if UserDefaults.standard.object(forKey: TechnicalContextKeys.UserIDV2.rawValue) != nil {
                    return UserDefaults.standard.object(forKey: TechnicalContextKeys.UserIDV2.rawValue) as! String
                } else if UserDefaults.standard.object(forKey: TechnicalContextKeys.UserID.rawValue) == nil {
                    let UUID = Foundation.UUID().uuidString
                    UserDefaults.standard.set(UUID, forKey: TechnicalContextKeys.UserID.rawValue)
                    UserDefaults.standard.synchronize()
                    return UUID
                } else {
                    return UserDefaults.standard.object(forKey: TechnicalContextKeys.UserID.rawValue) as! String
                }
            }
            
            let idfa: () -> String = {
                if let ASIdentifierManagerClass = NSClassFromString("ASIdentifierManager") {
                    let sharedManagerSelector = NSSelectorFromString("sharedManager")
                    if let sharedManagerIMP = ASIdentifierManagerClass.method(for: sharedManagerSelector) {
                        typealias sharedManagerCType = @convention(c) (AnyObject, Selector) -> AnyObject?
                        let getSharedManager = unsafeBitCast(sharedManagerIMP, to: sharedManagerCType.self)
                        if let sharedManager = getSharedManager(ASIdentifierManagerClass.self, sharedManagerSelector) {
                            let advertisingTrackingEnabledSelector = NSSelectorFromString("isAdvertisingTrackingEnabled")
                            if let isTrackingEnabledIMP = sharedManager.method(for: advertisingTrackingEnabledSelector) {
                                typealias isTrackingEnabledCType = @convention(c) (AnyObject, Selector) -> Bool
                                let getIsTrackingEnabled = unsafeBitCast(isTrackingEnabledIMP, to: isTrackingEnabledCType.self)
                                let isTrackingEnabled = getIsTrackingEnabled(self, advertisingTrackingEnabledSelector)
                                if isTrackingEnabled {
                                    let advertisingIdentifierSelector = NSSelectorFromString("advertisingIdentifier")
                                    if let advertisingIdentifierIMP = sharedManager.method(for: advertisingIdentifierSelector) {
                                        typealias adIdentifierCType = @convention(c) (AnyObject, Selector) -> NSUUID
                                        let getIdfa = unsafeBitCast(advertisingIdentifierIMP, to: adIdentifierCType.self)
                                        return getIdfa(self, advertisingIdentifierSelector).uuidString
                                    }
                                } else {
                                    if ignoreLimitedAdTracking {
                                        return uuid()
                                    }
                                    return "opt-out"
                                }
                            }
                        }
                    }
                }
                return ""
            }
            
            if let optIdentifier = identifier {
                switch(optIdentifier.lowercased())
                {
                case "idfv":
                    #if !os(watchOS) && canImport(UIKit)
                    return UIDevice.current.identifierForVendor?.uuidString ?? ""
                    #else
                    return ""
                    #endif
                case "idfa":
                    return idfa()
                default:
                    return uuid()
                }
            } else {
                return uuid()
            }
            
        } else {
            return "opt-out"
        }
    }
    
    /// Device language (eg. en_US)
    class var language: String {
        get {
            return Locale.autoupdatingCurrent.identifier.lowercased()
        }
    }
    
    /// Device type (eg. iphone3,1)
    class var device: String {
        get {
            var size : Int = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: Int(size))
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            return String(format: "%@", String.init(cString: machine).lowercased())
        }
    }
    
    class var model: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
    }
    
    /// Device OS (name + version)
    @objc class var operatingSystem: String {
        get {
            #if canImport(WatchKit)
            return String(format: "[%@]-[%@]", WKInterfaceDevice.current().systemName.removeSpaces().lowercased(), WKInterfaceDevice.current().systemVersion)
            #elseif canImport(UIKit)
            return String(format: "[%@]-[%@]", UIDevice.current.systemName.removeSpaces().lowercased(), UIDevice.current.systemVersion)
            #else
            return ""
            #endif
        }
    }
    
    /// Application localized name
    class var applicationName: String {
        let defaultAppName = TechnicalContext.applicationIdentifier
        if let info = Bundle.main.infoDictionary,  let name = info[String(kCFBundleNameKey)] as? String {
            if !name.isEmpty {
                return name
            }
        }
        if let localizedDic = Bundle.main.localizedInfoDictionary, let name = localizedDic[String(kCFBundleNameKey)] as? String {
            if !name.isEmpty {
                return name
            }
        }
        
        return defaultAppName
    }
    
    /// Application identifier (eg. com.atinternet.testapp)
     class var applicationIdentifier: String {
        get {
            let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
            
            if let optIdentifier = identifier {
                return String(format:"%@", optIdentifier)
            } else {
                return "noApplicationIdentifier"
            }
        }
    }
    
    /// Application version (eg. 5.0)
    class var applicationVersion: String {
        get {
            let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            
            if let optVersion = version {
                return String(format:"%@", optVersion)
            } else {
                return ""
            }
        }
    }
    
    /// Local hour (eg. 23x59x59)
    class var localHour: String {
        get {
            let hourFormatter = DateFormatter()
            hourFormatter.locale = LifeCycle.locale
            hourFormatter.dateFormat = "HH'x'mm'x'ss"
            
            return hourFormatter.string(from: Date())
        }
    }
    
    /// Screen resolution (eg. 1024x768)
    class var screenResolution: String {
        get {
            #if canImport(WatchKit)
            let screenBounds = WKInterfaceDevice.current().screenBounds
            let screenScale = WKInterfaceDevice.current().screenScale
            #elseif canImport(UIKit)
            let screenBounds = UIScreen.main.bounds
            let screenScale = UIScreen.main.scale
            #else
            let screenBounds = 0
            let screenScale = 0
            #endif
                
            return String(format:"%ix%i", Int(screenBounds.size.width * screenScale), Int(screenBounds.size.height * screenScale))
        }
    }
    
    /// Carrier
    @objc class var carrier: String {
        get {
            #if os(iOS) && canImport(CoreTelephony)
            let networkInfo = CTTelephonyNetworkInfo()
            let provider = networkInfo.subscriberCellularProvider
            
            if let optProvider = provider {
                let carrier = optProvider.carrierName
                
                if carrier != nil {
                    return carrier!
                }
            } else {
                return ""
            }
            #endif
            return ""
        }
    }
    
    /// Download Source
    class func downloadSource(_ tracker: Tracker) -> String {
        if let optDls = tracker.configuration.parameters["downloadSource"] {
            return optDls
        } else {
            return "ext"
        }
    }
    
    #if os(iOS) && canImport(WebKit)
    static var webView : WKWebView?
    #endif
    
    @objc static var _defaultUserAgent: String?
    @objc class var defaultUserAgent: String? {
        get {
            if _defaultUserAgent == nil {
                #if os(iOS) && canImport(WebKit)
                if self.webView == nil {
                    if Thread.isMainThread {
                       self.webView = WKWebView(frame: .zero)
                    } else {
                        DispatchQueue.main.sync {
                            self.webView = WKWebView(frame: .zero)
                        }
                    }
                }
                if self.webView != nil && !Thread.isMainThread {
                    let semaphore = DispatchSemaphore(value: 0)
                    DispatchQueue.main.sync {
                        self.webView!.evaluateJavaScript("navigator.userAgent") { (data, error) in
                            if let dataStr = data as? String {
                                _defaultUserAgent = dataStr
                            }
                            semaphore.signal()
                        }
                    }
                    _ = semaphore.wait(timeout: .distantFuture)
                }
                #endif
            }
            if _defaultUserAgent != nil {
                return String(format: "%@ %@/%@", _defaultUserAgent!, applicationName, applicationVersion)
            }
            return _defaultUserAgent
        }
    }
    
    /// Get user agent async
    static func getUserAgentAsync(completionHandler: @escaping ((String) -> Void)) {
        if _defaultUserAgent == nil {
            #if os(iOS) && canImport(WebKit)
            if self.webView == nil {
                if Thread.isMainThread {
                   self.webView = WKWebView(frame: .zero)
                } else {
                    DispatchQueue.main.sync {
                        self.webView = WKWebView(frame: .zero)
                    }
                }
            }
            if self.webView != nil {
                if Thread.isMainThread {
                    self.webView!.evaluateJavaScript("navigator.userAgent") { (data, error) in
                        if let dataStr = data as? String {
                            _defaultUserAgent = dataStr
                            completionHandler(String(format: "%@ %@/%@", _defaultUserAgent!, applicationName, applicationVersion))
                        } else {
                            completionHandler("")
                        }
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.webView!.evaluateJavaScript("navigator.userAgent") { (data, error) in
                            if let dataStr = data as? String {
                                _defaultUserAgent = dataStr
                                completionHandler(String(format: "%@ %@/%@", _defaultUserAgent!, applicationName, applicationVersion))
                            } else {
                                completionHandler("")
                            }
                        }
                    }
                }
            }
            #endif
            return
        }
        if _defaultUserAgent != nil {
            completionHandler(String(format: "%@ %@/%@", _defaultUserAgent!, applicationName, applicationVersion))
        } else {
            completionHandler("")
        }
    }

    #if os(watchOS)
    class var connectionType: ConnexionType {
        get {
            return ConnexionType.unknown
        }
    }
    #else
    /// Connexion type (3G, 4G, Edge, Wifi ...)
    class var connectionType: ConnexionType {
        get {
            let reachability = ATReachability.reachabilityForInternetConnection()
            
            if let optReachability = reachability {
                if(optReachability.currentReachabilityStatus == ATReachability.NetworkStatus.reachableViaWiFi) {
                    return ConnexionType.wifi
                } else if(optReachability.currentReachabilityStatus == ATReachability.NetworkStatus.notReachable) {
                    return ConnexionType.offline
                } else {
                    #if os(iOS) && canImport(CoreTelephony)
                    let telephonyInfo = CTTelephonyNetworkInfo()
                    let radioType = telephonyInfo.currentRadioAccessTechnology
                    
                    if(radioType != nil) {
                        switch(radioType!) {
                        case CTRadioAccessTechnologyGPRS:
                            return ConnexionType.gprs
                        case CTRadioAccessTechnologyEdge:
                            return ConnexionType.edge
                        case CTRadioAccessTechnologyCDMA1x:
                            return ConnexionType.twog
                        case CTRadioAccessTechnologyWCDMA:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyCDMAEVDORev0:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyCDMAEVDORevA:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyCDMAEVDORevB:
                            return ConnexionType.threeg
                        case CTRadioAccessTechnologyeHRPD:
                            return ConnexionType.threegplus
                        case CTRadioAccessTechnologyHSDPA:
                            return ConnexionType.threegplus
                        case CTRadioAccessTechnologyHSUPA:
                            return ConnexionType.threegplus
                        case CTRadioAccessTechnologyLTE:
                            return ConnexionType.fourg
                        default:
                            return ConnexionType.unknown
                        }
                    } else {
                        return ConnexionType.unknown
                    }
                    #else
                        return ConnexionType.unknown
                    #endif
                }
            } else {
                return ConnexionType.unknown
            }
        }
    }
    #endif
}
