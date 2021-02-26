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
    
    public enum VisitorMode: String {
        case optOut = "optOut"
        case optIn = "optIn"
        case noConsent = "noConsent"
        case exempt = "exempt"
        case none = "none"
    }
    
    private static let PrivacyModeKey = "ATPrivacyMode"
    
    private static let PrivacyModeExpirationTimestampKey = "ATPrivacyModeExpirationTimestamp"
    
    private static let PrivacyVisitorConsentKey = "ATPrivacyVisitorConsent"
    
    private static let PrivacyUserIdKey = "ATPrivacyUserId"
    
    private static var includeBufferByMode : [String: [String]] = [
        VisitorMode.none.rawValue : ["*"],
        VisitorMode.optIn.rawValue : ["*"],
        VisitorMode.optOut.rawValue : ["idclient", "ts", "olt", "cn", "click", "type"],
        VisitorMode.noConsent.rawValue : ["idclient", "ts", "olt", "cn", "click", "type"],
        VisitorMode.exempt.rawValue : ["idclient", "p", "olt", "vtag", "ptag", "ts", "click", "type", "cn", "apvr", "dg", "mfmd", "model", "manufacturer", "os", "stc_crash_*"]
    ]
    
    private static var visitorConsentByMode : [String: Bool] = [
        VisitorMode.none.rawValue : true,
        VisitorMode.optIn.rawValue : true,
        VisitorMode.optOut.rawValue : false,
        VisitorMode.noConsent.rawValue : false,
        VisitorMode.exempt.rawValue : false
    ]
    
    private static var userIdByMode : [String: String?] = [
        VisitorMode.none.rawValue : nil,
        VisitorMode.optIn.rawValue : nil,
        VisitorMode.optOut.rawValue : "opt-out",
        VisitorMode.noConsent.rawValue : "Consent-NO",
        VisitorMode.exempt.rawValue : nil
    ]
    
    private static let defaultDuration = 397;

    private static let specificKeys = ["stc", "events", "context"]
    
    private static let JSONParameters = ["events", "context"]

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
        let userDefaults = UserDefaults.standard
        if visitorMode != VisitorMode.optIn.rawValue && visitorMode != VisitorMode.none.rawValue {
            userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.numeric.rawValue)
            userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.text.rawValue)
            userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.category.rawValue)
        }
        
        userDefaults.setValue(visitorMode, forKey: PrivacyModeKey)
        userDefaults.setValue(Int64(Date().timeIntervalSince1970 * 1000) + Int64(duration * 86400000), forKey: PrivacyModeExpirationTimestampKey)
        userDefaults.setValue(visitorConsent, forKey: PrivacyVisitorConsentKey)
        userDefaults.setValue(customUserId, forKey: PrivacyUserIdKey)
        userDefaults.synchronize()
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
        let userDefaults = UserDefaults.standard
        if let privacyModeExpirationTs = userDefaults.object(forKey: PrivacyModeExpirationTimestampKey) as? Int64 {
            if (Int64(Date().timeIntervalSince1970 * 1000) >= privacyModeExpirationTs) {
                userDefaults.removeObject(forKey: PrivacyModeKey)
                userDefaults.removeObject(forKey: PrivacyModeExpirationTimestampKey)
                userDefaults.removeObject(forKey: PrivacyVisitorConsentKey)
                userDefaults.removeObject(forKey: PrivacyUserIdKey)
                userDefaults.synchronize()
            }
        }
        return userDefaults.string(forKey: PrivacyModeKey) ?? VisitorMode.none.rawValue
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
        includeBufferByMode[visitorMode]?.append(contentsOf: keys.map {$0.lowercased()})
    }
    
    class func apply(parameters: [String : (String, String)]) -> [String : (String, String)] {
        let currentPrivacyMode = getVisitorModeString()
        let includeBufferKeys = includeBufferByMode[currentPrivacyMode] ?? includeBufferByMode[VisitorMode.optOut.rawValue] ?? [String]()
        
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
                visitorModeValue = userDefaults.string(forKey: PrivacyModeKey)
                visitorConsentValue = userDefaults.bool(forKey: PrivacyVisitorConsentKey) ? "1" : "0"
                if let uid = userDefaults.value(forKey: PrivacyUserIdKey) as? String {
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
                let stcFlattened = Tool.toFlatten(src: objValue, lowercase: true)
                var stcResult = [String: (Any, String)]()
                
                for includeKey in includedStcKeys {
                    for stcKey in stcFlattened.keys {
                        let completeKey = "stc_" + stcKey
                        if let wildcardIndex = includeKey.firstIndex(of: "*") {
                            if completeKey.starts(with: includeKey[..<wildcardIndex]) {
                                stcResult[stcKey] = stcFlattened[stcKey]
                            }
                        } else if completeKey == includeKey {
                            stcResult[stcKey] = stcFlattened[stcKey]
                        }
                    }
                }
                return ("&stc=" + Tool.toObject(src: stcResult).toJSON().percentEncodedString, stc.1)
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
                    let objectFlattened = Tool.toFlatten(src: obj, lowercase: true)
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
                    arrResult.append(Tool.toObject(src: objectResult))
                }
                return ("&" + paramKey + "=" + Tool.JSONStringify(arrResult).percentEncodedString, param.1)
            }
        }
        return param
    }
}
