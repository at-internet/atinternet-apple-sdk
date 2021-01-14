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
    
    private static var includeBufferByMode : [VisitorMode:[String]] = [
        VisitorMode.none : ["*"],
        VisitorMode.optIn : ["*"],
        VisitorMode.optOut : ["idclient", "ts", "olt", "cn", "click", "type"],
        VisitorMode.noConsent : ["idclient", "ts", "olt", "cn", "click", "type"],
        VisitorMode.exempt : ["idclient", "p", "olt", "vtag", "ptag", "ts", "click", "type", "cn", "apvr", "mfmd", "model", "manufacturer", "os", "stc_crash_*"]
    ]
    

    private static let specificKeys = ["stc", "events", "context"]
    
    private static let JSONParameters = ["events", "context"]

    private override init () {

    }
    
    /**
     Set user OptOut
    */
    public class func setVisitorOptOut() {
        setVisitorMode(VisitorMode.optOut);
    }

    /**
     Set user OptIn
     */
    public class func setVisitorOptIn() {
        setVisitorMode(VisitorMode.optIn);
    }
    
    /**
     Set User Privacy mode
     
     - parameter visitorMode: selected mode from user context
     */
    public class func setVisitorMode(_ visitorMode: VisitorMode) {
        setVisitorMode(visitorMode, duration: 397);
    }
    
    /**
     Set User Privacy mode
     
     - parameter visitorMode: selected mode from user context
     - parameter duration: storage validity for privacy information (in days)
     */
    public class func setVisitorMode(_ visitorMode: VisitorMode, duration: Int) {
        let userDefaults = UserDefaults.standard
        if visitorMode != VisitorMode.optIn && visitorMode != VisitorMode.none {
            userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.numeric.rawValue)
            userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.text.rawValue)
            userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.category.rawValue)
        }
        userDefaults.setValue(visitorMode.rawValue, forKey: PrivacyModeKey)
        userDefaults.setValue((Int(Date().timeIntervalSince1970) * 1000) + (duration * 86400000), forKey: PrivacyModeExpirationTimestampKey)
        userDefaults.synchronize()
    }
    
    /**
     Get current User Privacy mode
     
     - returns: user privacy mode
     */
    public class func getVisitorMode() -> VisitorMode {
        let userDefaults = UserDefaults.standard
        let privacyModeExpirationTs = userDefaults.integer(forKey: PrivacyModeExpirationTimestampKey)
        if ((Int(Date().timeIntervalSince1970) * 1000) >= privacyModeExpirationTs) {
            userDefaults.setValue(VisitorMode.none.rawValue, forKey: PrivacyModeKey)
            userDefaults.setValue(-1, forKey: PrivacyModeExpirationTimestampKey)
            userDefaults.synchronize()
        }
        return VisitorMode.init(rawValue: userDefaults.string(forKey: PrivacyModeKey) ?? VisitorMode.none.rawValue) ?? VisitorMode.none
    }
    
    /**
         Swift incompatibility to call similar method with variadic arguments (https://bugs.swift.org/browse/SR-128)
     */
    public class func extendIncludeBuffer(_ keys: String...) {
        includeBufferByMode[getVisitorMode()]?.append(contentsOf: keys.map {$0.lowercased()});
    }
    
    public class func extendIncludeBuffer(_ visitorMode: VisitorMode, keys: String...) {
        includeBufferByMode[visitorMode]?.append(contentsOf: keys.map {$0.lowercased()});
    }
    
    class func apply(parameters: [String : (String, String)]) -> [String : (String, String)] {
        let currentPrivacyMode = getVisitorMode()
        let includeBufferKeys = includeBufferByMode[currentPrivacyMode] ?? [String]()
        
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
        
        switch currentPrivacyMode {
        case .optIn:
            result["vc"] = ("&vc=1", ",")
            result["vm"] = ("&vm=optin", ",")
        case .optOut:
            result["vc"] = ("&vc=0", ",")
            result["vm"] = ("&vm=optout", ",")
            result["idclient"] = ("&idclient=opt-out", ",")
        case .noConsent:
            result["vc"] = ("&vc=0", ",")
            result["vm"] = ("&vm=no-consent", ",")
            result["idclient"] = ("&idclient=Consent-NO", ",")
        case .exempt:
            result["vc"] = ("&vc=0", ",")
            result["vm"] = ("&vm=exempt", ",")
        case .none:
            break
        }

        return result;
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
