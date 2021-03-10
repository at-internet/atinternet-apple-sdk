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
//  Privacy.swift
//  ATInternetTracker
//

import Foundation

/// Toolbox: utility methods
public class Privacy: NSObject {
    
    private static let stcSeparator = "/"
    
    public enum VisitorMode: String {
        case optOut = "optOut"
        case optIn = "optIn"
        case noConsent = "noConsent"
        case exempt = "exempt"
        case none = "none"
    }
    
    public enum StorageFeature: String {
        case campaign = "campaign"
        case userId = "userId"
        case crash = "crash"
        case lifecycle = "lifecycle"
        case identifiedVisitor = "identifiedVisitor"
        case privacy = "privacy"
    }
    
    enum PrivacyKeys: String, EnumCollection {
        case PrivacyMode = "ATPrivacyMode"
        case PrivacyModeExpirationTimestamp = "ATPrivacyModeExpirationTimestamp"
        case PrivacyVisitorConsent = "ATPrivacyVisitorConsent"
        case PrivacyUserId = "ATPrivacyUserId"
    }
    
    private static var includeBufferByMode : [String: Set<String>] = [
        VisitorMode.none.rawValue : ["*"],
        VisitorMode.optIn.rawValue : ["*"],
        VisitorMode.optOut.rawValue : ["idclient", "ts", "olt", "cn", "click", "type"],
        VisitorMode.noConsent.rawValue : ["idclient", "ts", "olt", "cn", "click", "type"],
        VisitorMode.exempt.rawValue : ["idclient", "p", "olt", "vtag", "ptag", "ts", "click", "type", "cn", "apvr", "dg", "mfmd", "model", "manufacturer", "os", "ref", "stc/crash/*"]
    ]
    
    private static var includeStorageFeatureByMode : [String: Set<StorageFeature>] = [
        VisitorMode.none.rawValue : [StorageFeature.campaign, StorageFeature.userId, StorageFeature.crash, StorageFeature.lifecycle, StorageFeature.identifiedVisitor, StorageFeature.privacy],
        VisitorMode.optIn.rawValue : [StorageFeature.campaign, StorageFeature.userId, StorageFeature.crash, StorageFeature.lifecycle, StorageFeature.identifiedVisitor, StorageFeature.privacy],
        VisitorMode.optOut.rawValue : [StorageFeature.privacy],
        VisitorMode.noConsent.rawValue : [],
        VisitorMode.exempt.rawValue : [StorageFeature.privacy, StorageFeature.userId, StorageFeature.crash]
    ]
    
    private static let storageKeysByFeature : [StorageFeature: Set<String>] = [
        StorageFeature.campaign : [
            CampaignKeys.ATCampaign.rawValue,
            CampaignKeys.ATCampaignDate.rawValue,
            CampaignKeys.ATCampaignAdded.rawValue],
        
        StorageFeature.userId : [
            TechnicalContext.TechnicalContextKeys.UserIDV1.rawValue,
            TechnicalContext.TechnicalContextKeys.UserIDV2.rawValue,
            TechnicalContext.TechnicalContextKeys.UserID.rawValue,
            TechnicalContext.TechnicalContextKeys.UserIDGenerationTimestamp.rawValue],
        
        StorageFeature.privacy : [
            PrivacyKeys.PrivacyMode.rawValue,
            PrivacyKeys.PrivacyModeExpirationTimestamp.rawValue,
            PrivacyKeys.PrivacyVisitorConsent.rawValue,
            PrivacyKeys.PrivacyUserId.rawValue],
        
        StorageFeature.identifiedVisitor : [
            IdentifiedVisitorHelperKey.text.rawValue,
            IdentifiedVisitorHelperKey.numeric.rawValue,
            IdentifiedVisitorHelperKey.category.rawValue,
        ],
        
        StorageFeature.crash : [],
        
        StorageFeature.lifecycle : [
            LifeCycle.LifeCycleKey.FirstSessionDateV1.rawValue,
            LifeCycle.LifeCycleKey.LastSessionV1.rawValue,
            LifeCycle.LifeCycleKey.FirstSession.rawValue,
            LifeCycle.LifeCycleKey.LastSession.rawValue,
            LifeCycle.LifeCycleKey.FirstSessionDate.rawValue,
            LifeCycle.LifeCycleKey.SessionCount.rawValue,
            LifeCycle.LifeCycleKey.LastApplicationVersion.rawValue,
            LifeCycle.LifeCycleKey.ApplicationUpdate.rawValue,
            LifeCycle.LifeCycleKey.SessionCountSinceUpdate.rawValue,
        ]
    ]
    
    private static let visitorConsentByMode : [String: Bool] = [
        VisitorMode.none.rawValue : true,
        VisitorMode.optIn.rawValue : true,
        VisitorMode.optOut.rawValue : false,
        VisitorMode.noConsent.rawValue : false,
        VisitorMode.exempt.rawValue : false
    ]
    
    private static let userIdByMode : [String: String?] = [
        VisitorMode.none.rawValue : nil,
        VisitorMode.optIn.rawValue : nil,
        VisitorMode.optOut.rawValue : "opt-out",
        VisitorMode.noConsent.rawValue : "Consent-NO",
        VisitorMode.exempt.rawValue : nil
    ]
    
    private static let defaultDuration = 397;

    private static let specificKeys = ["stc", "events", "context"]
    
    private static let JSONParameters = ["events", "context"]
    
    private static var inNoConsentMode = false

    private override init () {

    }
    
    /**
     Set user OptOut
    */
    @objc public class func setVisitorOptOut() {
        setVisitorMode(VisitorMode.optOut)
    }

    /**
     Set user OptIn
     */
    @objc public class func setVisitorOptIn() {
        setVisitorMode(VisitorMode.optIn)
    }
    
    /**
     Set User Privacy mode
     
     - parameter visitorMode: selected mode from user context
     */
    public class func setVisitorMode(_ visitorMode: VisitorMode) {
        setVisitorMode(visitorMode.rawValue)
    }
    
    /**
     Set User Privacy mode
     
     - parameter visitorMode: selected mode from user context
     */
    @objc public class func setVisitorMode(_ visitorMode: String) {
        setVisitorMode(visitorMode, duration: self.defaultDuration)
    }
    
    /**
     Set User Privacy mode
     
     - parameter visitorMode: selected mode from user context
     - parameter duration: storage validity for privacy information (in days)
     */
    public class func setVisitorMode(_ visitorMode: VisitorMode, duration: Int) {
        setVisitorMode(visitorMode.rawValue, duration: duration)
    }
    
    /**
     Set User Privacy custom mode
     
     - parameter visitorMode: selected mode from user context
     - parameter duration: storage validity for privacy information (in days)
     */
    @objc public class func setVisitorMode(_ visitorMode: String, duration: Int) {
        if let visitorConsent = self.visitorConsentByMode[visitorMode] {
            if let userId = self.userIdByMode[visitorMode] {
                setVisitorMode(visitorMode, visitorConsent: visitorConsent, customUserId: userId, duration: duration)
            } else {
                setVisitorMode(visitorMode, visitorConsent: visitorConsent, customUserId: nil, duration: duration)
            }
        } else {
            setVisitorMode(visitorMode, visitorConsent: true, customUserId: nil, duration: duration)
        }
    }
    
    /**
     Set User Privacy custom mode
     
     - parameter visitorMode: selected mode from user context
     - parameter visitorConsent: visitor consent to tracking
     - parameter customUserId: optional custom user id
     */
    @objc public class func setVisitorMode(_ visitorMode: String, visitorConsent: Bool, customUserId: String?) {
        setVisitorMode(visitorMode, visitorConsent: visitorConsent, customUserId: customUserId, duration: self.defaultDuration)
    }
    
    /**
     Set User Privacy mode
     
     - parameter visitorMode: selected mode from user context
     - parameter visitorConsent: visitor consent to tracking
     - parameter customUserId: optional custom user id
     - parameter duration: storage validity for privacy information (in days)
     */
    @objc public class func setVisitorMode(_ visitorMode: String, visitorConsent: Bool, customUserId: String?, duration: Int) {
        inNoConsentMode = visitorMode.caseInsensitiveCompare(VisitorMode.noConsent.rawValue) == .orderedSame
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: TechnicalContext.TechnicalContextKeys.OptOut.rawValue)
        userDefaults.removeObject(forKey: TechnicalContext.TechnicalContextKeys.DoNotTrack.rawValue)
        userDefaults.synchronize()
        
        /// Update storage
        if includeStorageFeatureByMode[visitorMode] == nil {
            includeStorageFeatureByMode[visitorMode] = includeStorageFeatureByMode[VisitorMode.exempt.rawValue]
        }
        clearStorageFromVisitorMode(visitorMode)
        _ = storeData(StorageFeature.privacy, pairs:(PrivacyKeys.PrivacyMode.rawValue, visitorMode),
                  (PrivacyKeys.PrivacyModeExpirationTimestamp.rawValue, Int64(Date().timeIntervalSince1970 * 1000) + Int64(duration * 86400000)),
                  (PrivacyKeys.PrivacyVisitorConsent.rawValue, visitorConsent),
                  (PrivacyKeys.PrivacyUserId.rawValue, customUserId))
        
        if let optIncludeStorageFeature = includeStorageFeatureByMode[visitorMode], optIncludeStorageFeature.contains(StorageFeature.lifecycle) {
            if (!LifeCycle.isInitialized) {
                LifeCycle.initLifeCycle()
            }
        } else {
            LifeCycle.isInitialized = false;
        }
    }
    
    /**
     Get current User Privacy mode
     
     - returns: user privacy mode
     */
    @available(*, deprecated, message: "Use 'getVisitorModeString()' method instead")
    public class func getVisitorMode() -> VisitorMode {
        return VisitorMode.init(rawValue: getVisitorModeString()) ?? VisitorMode.none
    }
    
    /**
     Get current User Privacy mode
     
     - returns: user privacy mode
     */
    @objc public class func getVisitorModeString() -> String {
        /// Specific case : no consent must not be stored in device
        if (Privacy.inNoConsentMode) {
            return VisitorMode.noConsent.rawValue;
        }
        
        let userDefaults = UserDefaults.standard
        if let privacyModeExpirationTs = userDefaults.object(forKey: PrivacyKeys.PrivacyModeExpirationTimestamp.rawValue) as? Int64 {
            if (Int64(Date().timeIntervalSince1970 * 1000) >= privacyModeExpirationTs) {
                userDefaults.removeObject(forKey: PrivacyKeys.PrivacyMode.rawValue)
                userDefaults.removeObject(forKey: PrivacyKeys.PrivacyModeExpirationTimestamp.rawValue)
                userDefaults.removeObject(forKey: PrivacyKeys.PrivacyVisitorConsent.rawValue)
                userDefaults.removeObject(forKey: PrivacyKeys.PrivacyUserId.rawValue)
                userDefaults.synchronize()
            }
        }
        return userDefaults.string(forKey: PrivacyKeys.PrivacyMode.rawValue) ?? VisitorMode.none.rawValue
    }
    
    /// Swift incompatibility to call similar method with variadic arguments (https://bugs.swift.org/browse/SR-128)
    public class func extendIncludeBuffer(_ keys: String...) {
        extendIncludeBuffer(getVisitorModeString(), keys: keys)
    }
    
    public class func extendIncludeBuffer(_ visitorMode: VisitorMode, keys: String...) {
        extendIncludeBuffer(visitorMode.rawValue, keys: keys)
    }
    
    public class func extendIncludeBuffer(visitorMode: String, keys: String...) {
        extendIncludeBuffer(visitorMode, keys: keys)
    }
    
    /// Swift incompatibility to call similar method with variadic arguments (https://bugs.swift.org/browse/SR-128)
    @objc public class func extendIncludeBuffer(_ keys: [String]) {
        extendIncludeBuffer(getVisitorModeString(), keys: keys)
    }
    
    @objc public class func extendIncludeBuffer(_ visitorMode: String, keys: [String]) {
        if includeBufferByMode[visitorMode] == nil {
            includeBufferByMode[visitorMode] = includeBufferByMode[VisitorMode.optOut.rawValue]
        }
        keys.forEach { (k) in
            includeBufferByMode[visitorMode]?.insert(k.lowercased())
        }
    }
    
    public class func extendIncludeStorage(visitorMode: String, storageFeatureKeys: StorageFeature...) {
        var a = [String]()
        storageFeatureKeys.forEach { (s) in
            a.append(s.rawValue)
        }
        extendIncludeStorage(visitorMode, storageFeatureKeys: a)
    }
    
    /**
     Extend include buffer for visitor mode set in parameter (Only for exempt or custom)
     
     - parameter visitorMode: selected mode from user context
     - parameter storageFeatureKeys: data can be stored/kept
     */
    @objc public class func extendIncludeStorage(_ visitorMode: String, storageFeatureKeys: [String]) {
        let mode = VisitorMode.init(rawValue: visitorMode)
        guard mode == nil || mode == VisitorMode.exempt else {
            return
        }
        
        if includeStorageFeatureByMode[visitorMode] == nil {
            includeStorageFeatureByMode[visitorMode] = includeStorageFeatureByMode[VisitorMode.exempt.rawValue]
        }
        storageFeatureKeys.forEach { (s) in
            if let k = StorageFeature.init(rawValue: s) {
                includeStorageFeatureByMode[visitorMode]?.insert(k)
            }
        }
    }
    
    class func canGetStoredData(_ storageFeature: StorageFeature) -> Bool {
        let visitorMode = getVisitorModeString()
        guard let optIncludeStorageFeature = includeStorageFeatureByMode[visitorMode] else {
            return false
        }
        return optIncludeStorageFeature.contains(storageFeature)
    }
    
    class func storeData(_ storageFeature: StorageFeature, pairs: (String, Any?)...) -> Bool {
        let visitorMode = getVisitorModeString()
        if let optIncludeStorage = includeStorageFeatureByMode[visitorMode], optIncludeStorage.contains(storageFeature) {
            let userDefaults = UserDefaults.standard
            
            pairs.forEach { (p) in
                if let o = p.1 {
                    userDefaults.set(o, forKey: p.0)
                } else {
                    userDefaults.removeObject(forKey: p.0)
                }
            }
            userDefaults.synchronize()
            return true
        }
        
        return false
    }
    
    private class func clearStorageFromVisitorMode(_ visitorMode: String) {
        let userDefaults = UserDefaults.standard
        storageKeysByFeature.forEach { (entry) in
            if let optIncludeStorage = includeStorageFeatureByMode[visitorMode], optIncludeStorage.contains(entry.key) {
                return
            }
            entry.value.forEach { (key) in
                userDefaults.removeObject(forKey: key)
            }
        }
        userDefaults.synchronize()
    }
    
    class func apply(parameters: [String : (String, String)]) -> [String : (String, String)] {
        let currentPrivacyMode = getVisitorModeString()
        let includeBufferKeys = includeBufferByMode[currentPrivacyMode] ?? includeBufferByMode[VisitorMode.optOut.rawValue] ?? Set<String>()
        
        var result = [String : (String, String)]()
        var specificIncludedKeys = [String: [String]]()
        
        for includeBufferKey in includeBufferKeys {
            let key = includeBufferKey.lowercased()
            
            /// WILDCARD
            if key == "*" {
                result.append(parameters)
                break
            }
            
            /// SPECIFIC
            for specificKey in specificKeys {
                if !key.starts(with: specificKey) {
                    continue
                }
                
                if specificIncludedKeys[specificKey] == nil {
                    specificIncludedKeys[specificKey] = [String]()
                }
                
                specificIncludedKeys[specificKey]?.append(key)
                break
            }
            
            if let value = parameters[key] {
                result[key] = value
            }
        }

        /// STC
        if let includedStcKeys = specificIncludedKeys["stc"] {
            if let stc = parameters["stc"] {
                result["stc"] = applyToStc(stc, includedStcKeys: includedStcKeys)
            }
        }

        /// JSONParameter
        for jsonParameter in JSONParameters {
            if let includeJSONParameterKeys = specificIncludedKeys[jsonParameter] {
                if let jsonParam = parameters[jsonParameter] {
                    result[jsonParameter] = applyToJSONParameter(jsonParameter, param: jsonParam, includedKeys: includeJSONParameterKeys)
                }
            }
        }
        
        if currentPrivacyMode != VisitorMode.none.rawValue {
            var visitorModeValue: String?
            var mode : VisitorMode?
            switch currentPrivacyMode {
            case VisitorMode.optIn.rawValue:
                mode = .optIn
                visitorModeValue = "optin"
            case VisitorMode.optOut.rawValue:
                mode = .optOut
                visitorModeValue = "optout"
            case VisitorMode.noConsent.rawValue:
                mode = .noConsent
                visitorModeValue = "no-consent"
            case VisitorMode.exempt.rawValue:
                mode = .exempt
                visitorModeValue = "exempt"
            default: break
            }
            
            var visitorConsentValue: String?
            var userIdValue: String?
            if let optMode = mode {
                visitorConsentValue = (visitorConsentByMode[optMode.rawValue] ?? true) ? "1" : "0"
                userIdValue = userIdByMode[optMode.rawValue] ?? nil
            } else {
                /// CUSTOM
                let userDefaults = UserDefaults.standard
                visitorModeValue = userDefaults.string(forKey: PrivacyKeys.PrivacyMode.rawValue)
                visitorConsentValue = userDefaults.bool(forKey: PrivacyKeys.PrivacyVisitorConsent.rawValue) ? "1" : "0"
                if let uid = userDefaults.value(forKey: PrivacyKeys.PrivacyUserId.rawValue) as? String {
                    userIdValue = String(uid)
                }
            }
            
            if let vm = visitorModeValue {
                if let vc = visitorConsentValue {
                    result["vc"] = (String(format: "&vc=%@", vc), ",")
                }
                if let uid = userIdValue {
                    result["idclient"] = (String(format: "&idclient=%@", uid), ",")
                }
                result["vm"] = (String(format:"&vm=%@", vm), ",")
            }
        }

        return result
    }
    
    private class func applyToStc(_ stc: (String, String), includedStcKeys: [String]) -> (String, String) {
        if let equalsCharIndex = stc.0.firstIndex(of: "=") {
            
            let value = String(stc.0[stc.0.index(after: equalsCharIndex)...]).percentDecodedString
            if let objValue = value.toJSONObject() as? [String: Any] {
                let stcFlattened = Tool.toFlatten(src: objValue, lowercase: true, separator: stcSeparator)
                var stcResult = [String: (Any, String)]()
                
                for includeKey in includedStcKeys {
                    for stcKey in stcFlattened.keys {
                        let completeKey = "stc" + stcSeparator + stcKey
                        if let wildcardIndex = includeKey.firstIndex(of: "*") {
                            if completeKey.starts(with: includeKey[..<wildcardIndex]) {
                                stcResult[stcKey] = stcFlattened[stcKey]
                            }
                        } else if completeKey == includeKey {
                            stcResult[stcKey] = stcFlattened[stcKey]
                        }
                    }
                }
                return ("&stc=" + Tool.toObject(src: stcResult, separator: stcSeparator).toJSON().percentEncodedString, stc.1)
            }
        }
        return stc
    }
    
    private class func applyToJSONParameter(_ paramKey: String, param: (String, String), includedKeys: [String]) -> (String, String) {
        if let equalsCharIndex = param.0.firstIndex(of: "=") {
            let value = String(param.0[param.0.index(after: equalsCharIndex)...]).percentDecodedString
            if let arrValue = value.toJSONObject() as? [[String: Any]] {
                var arrResult = [[String: Any]]()
                for obj in arrValue {
                    let objectFlattened = Tool.toFlatten(src: obj, lowercase: true, separator: Events.propertySeparator)
                    var objectResult = [String: (Any, String)]()
                    for includeKey in includedKeys {
                        for key in objectFlattened.keys {
                            let completeKey = paramKey + "_" + key
                            if let wildcardIndex = includeKey.firstIndex(of: "*") {
                                if completeKey.starts(with: includeKey[..<wildcardIndex]) {
                                    objectResult[key] = objectFlattened[key]
                                }
                            } else if completeKey == includeKey {
                                objectResult[key] = objectFlattened[key]
                            }
                        }
                    }
                    arrResult.append(Tool.toObject(src: objectResult, separator: Events.propertySeparator))
                }
                return ("&" + paramKey + "=" + Tool.JSONStringify(arrResult).percentEncodedString, param.1)
            }
        }
        return param
    }
}
