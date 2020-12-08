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
//  Configuration.swift
//  Tracker
//

import Foundation


/// OfflineModeKey
///
/// - always: Hits are always stored
/// - never: Hits are never stored
/// - required: Hits are stored if no connection available
public enum OfflineModeKey: String {
    /// Hits are always stored
    case always = "always"
    /// Hits are never stored
    case never = "never"
    /// Hits are stored if no connection available
    case required = "required"
}

/// Plugin keys
///
/// - nuggAd: NuggAd
public enum PluginKey: String {
    case nuggAd = "nuggad"
}

/// Identifier Types
///
/// - uuid: The tracker will generate an uuid
/// - idfv: The tracker will use the identifier for vendor
public enum IdentifierTypeKey: String {
    /// The tracker will generate an uuid
    case uuid = "uuid"
    /// The tracker will use the identifier for vendor
    case idfv = "idfv"
    /// The tracker will use the identifier for advertiser
    case idfa = "idfa"
}

/// UUID expiration Types
///
/// - fixed: The expiration date keep its value until expiration
/// - relative: The expiration date renewed every time
public enum UUIDExpirationModeKey: String {
    case fixed = "fixed"
    case relative = "relative"
}

/// Proxy types
///
/// - none: No proxy
/// - http
/// - https
/// - socks
public enum ProxyTypeKey: String {
    case none = "none"
    case http = "http"
    case https = "https"
    case socks = "socks"
}

/// States
///
/// - active: hits are send only when the application is active
/// - activeOrInactive: hits are send when the application is active or inactive
/// - all: hits are send when the application is in every state
public enum SendApplicationState: String {
    case activeOnly = "activeOnly"
    case activeOrInactive = "activeOrInactive"
    case all = "all"
}

/// Tracker configuration keys helper - used to make easier Tracker creation by providing few static parameters
@objcMembers
public class TrackerConfigurationKeys: NSObject {
    /// sessionBackgroundDuration
    public static let SessionBackgroundDuration = "sessionBackgroundDuration"
    /// campaignLifetime
    public static let CampaignLifetime = "campaignLifetime"
    /// campaignLastPersistence
    public static let CampaignLastPersistence = "campaignLastPersistence"
    /// persistIdentifiedVisitor
    public static let PersistIdentifiedVisitor = "persistIdentifiedVisitor"
    /// hashUserId
    public static let HashUserId = "hashUserId"
    /// enableBackgroundTask
    public static let EnableBackgroundTask = "enableBackgroundTask"
    /// storage
    public static let OfflineMode = "storage"
    /// log
    public static let Log = "log"
    /// logSSL
    public static let LogSSL = "logSSL"
    /// domain
    public static let Domain = "domain"
    /// pixelPath
    public static let PixelPath = "pixelPath"
    /// site
    public static let Site = "site"
    /// secure
    public static let Secure = "secure"
    /// identifier
    public static let Identifier = "identifier"
    /// downloadSource
    public static let DownloadSource = "downloadSource"
    /// plugins
    public static let Plugins = "plugins"
    /// send only when host App is in state "active" (foreground)
    @available(*, deprecated, message: "Use 'sendOnApplicationState' property instead")
    public static let SendOnlyWhenAppActive = "sendOnlyWhenAppActive"
    /// Allowed states to send hits
    public static let SendOnApplicationState = "sendOnApplicationState"
    /// Automatic send sales tracker hits from sales insights data (Sales Insights)
    public static let AutoSalesTracker = "autoSalesTracker"
    /// collect domain (events only)
    public static let CollectDomain = "collectDomain"
    /// ignore limited ad tracking
    public static let IgnoreLimitedAdTracking = "ignoreLimitedAdTracking"
    /// send hits when opt out
    public static let SendHitWhenOptOut = "sendHitWhenOptOut"
    /// max hit size
    public static let MaxHitSize = "maxHitSize"
    /// UUID Duration
    public static let UUIDDuration = "UUIDDuration"
    /// UUID ExpirationMode
    public static let UUIDExpirationMode = "UUIDExpirationMode"
    /// Proxy type
    public static let ProxyType = "proxyType"
    /// Proxy address
    public static let ProxyAddress = "proxyAddress"
}

/// Tracker configuraiton
class Configuration: NSObject {

    /// Dictionary of configuration parameters
    var parameters = [String: String]()

    /// Read only configuration
    class ReadOnlyConfiguration {
        /// Set of all configuration which value cannot be updated
        class var list: Set<String> {
            get {
                return [
                    "atreadonlytest"
//                    "plugins"
                ]
            }
        }
    }
    
    /**
    Init with default configuration set in the tag delivery ui
    
    - returns: a configuration
    */
    override init() {
        super.init()
        guard let selfObject = object_getClass(self) else {
            print("Default Tracker Configuration not found")
            return
        }
        let bundle = Bundle(for: selfObject)
        let path = bundle.path(forResource: "DefaultConfiguration", ofType: "plist")
        if let optPath = path {
            let defaultConf = NSDictionary(contentsOfFile: optPath)
            if let optDefaultConf = defaultConf as? [String: String] {
                parameters = optDefaultConf
            }
        } else {
            print("no path found for DefaultConfiguration file")
        }
    }
    
    /**
    Init with custom configuration
    
    - parameter a: dictionnary containing the custom configuration
    
    - returns: a configuration
    */
    convenience init(customConfiguration: [String: String]) {
        self.init()
        for key in customConfiguration.keys {
            parameters[key] = customConfiguration[key]
        }
    }
}
