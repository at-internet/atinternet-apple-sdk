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

public enum OfflineModeKey: String {
    case always = "always"
    case never = "never"
    case required = "required"
}

public enum PluginKey: String {
    case tvTracking = "tvtracking"
    case nuggAd = "nuggad"
}

public enum IdentifierTypeKey: String {
    case uuid = "uuid"
    case idfv = "idfv"
}

public class TrackerConfigurationKeys: NSObject {
    public static let SessionBackgroundDuration = "sessionBackgroundDuration"
    public static let CampaignLifetime = "campaignLifetime"
    public static let CampaignLastPersistence = "campaignLastPersistence"
    public static let TvTrackingURL = "tvtURL"
    public static let TvTrackingVisitDuration = "tvtVisitDuration"
    public static let TvTrackingSpotValidityTime = "tvtSpotValidityTime"
    public static let PersistIdentifiedVisitor = "persistIdentifiedVisitor"
    public static let HashUserId = "hashUserId"
    public static let EnableBackgroundTask = "enableBackgroundTask"
    public static let OfflineMode = "storage"
    public static let Log = "log"
    public static let LogSSL = "logSSL"
    public static let Domain = "domain"
    public static let PixelPath = "pixelPath"
    public static let Site = "site"
    public static let Secure = "secure"
    public static let Identifier = "identifier"
    public static let DownloadSource = "downloadSource"
    public static let Plugins = "plugins"
    public static let AutoTracking = "enableAutoTracking"
    public static let AutoTrackerToken = "autoTrackerToken"
}

/// Tracker configuraiton
class Configuration: NSObject {

    /// Dictionary of configuration parameters
    var parameters = [String: String]()
    
    static var smartSDKMapping: ATJSON?

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
        let bundle = Bundle(for: object_getClass(self))
        let path = bundle.path(forResource: "DefaultConfiguration", ofType: "plist")
        if let optPath = path {
            let defaultConf = NSDictionary(contentsOfFile: optPath)
            if let optDefaultConf = defaultConf as? [String: String] {
                parameters = optDefaultConf
            }
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
