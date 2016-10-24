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
//  IdentifiedVisitor.swift
//  Tracker
//

import Foundation

/// NSUserDefaults and configuration keys for persistent identified visitor data
enum IdentifiedVisitorHelperKey: String {
    case Configuration = "persistIdentifiedVisitor"
    case Numeric = "ATIdentifiedVisitorNumeric"
    case Text = "ATIdentifiedVisitorText"
    case Category = "ATIdentifiedVisitorCategory"
}
 
public class IdentifiedVisitor: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    let option = ParamOption()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    /**
    IdentifiedVisitor initializer
    - parameter tracker: the tracker instance
    - returns: IdentifiedVisitor instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
        option.persistent = true;
    }
    
    /**
    Set Identified visitor ID (numeric) for all next hits
    - parameter visitorID: numeric visitor identifier
    - returns: tracker instance
    */
    @objc(setInt:)
    public func set(visitorId: Int) -> Tracker {
        unset()
        save(HitParam.VisitorIdentifierNumeric.rawValue, keyPersistent: IdentifiedVisitorHelperKey.Numeric.rawValue, value: visitorId)
        
        return self.tracker
    }
    
    /**
    Set Identified visitor ID (numeric) with category for all next hits
    - parameter visitorID: numeric visitor identifier
    - parameter visitorCategory: visitor category identifier
    - returns: tracker instance
    */
    @objc(setInt::)
    public func set(visitorId: Int, visitorCategory: Int) -> Tracker {
        set(visitorId)
        save(HitParam.VisitorCategory.rawValue, keyPersistent: IdentifiedVisitorHelperKey.Category.rawValue, value: visitorCategory)
        
        return self.tracker
    }
    
    /**
    Set Identified visitor ID (text) for all next hits
    - parameter visitorID: text visitor identifier
    - returns: tracker instance
    */
    @objc(setString:)
    public func set(visitorId: String) -> Tracker {
        unset()
        save(HitParam.VisitorIdentifierText.rawValue, keyPersistent: IdentifiedVisitorHelperKey.Text.rawValue, value: visitorId)
        
        return self.tracker
    }
    
    /**
    Set Identified visitor ID (text) with category for all next hits
    - parameter visitorID: text visitor identifier
    - parameter visitorCategory: visitor category identifier
    - returns: tracker instance
    */
    @objc(setString::)
    public func set(visitorId: String, visitorCategory: Int) -> Tracker {
        set(visitorId)
        save(HitParam.VisitorCategory.rawValue, keyPersistent: IdentifiedVisitorHelperKey.Category.rawValue, value: visitorCategory)
        
        return self.tracker
    }
    
    /**
    Unset identified visitor ID. Identified visitor ID (numeric and text) and category parameters won't appear in next hits
    - returns: tracker instance
    */
    public func unset() -> Tracker {
        tracker.unsetParam(HitParam.VisitorIdentifierNumeric.rawValue)
        tracker.unsetParam(HitParam.VisitorIdentifierText.rawValue)
        tracker.unsetParam(HitParam.VisitorCategory.rawValue)
        userDefaults.removeObjectForKey(IdentifiedVisitorHelperKey.Numeric.rawValue)
        userDefaults.removeObjectForKey(IdentifiedVisitorHelperKey.Text.rawValue)
        userDefaults.removeObjectForKey(IdentifiedVisitorHelperKey.Category.rawValue)
        userDefaults.synchronize()
        
        return self.tracker
    }
    
    /**
    Save identified visitor specific data to buffer or user defaults
    - parameter key: parameter name
    - parameter value: integer parameter value
    */
    private func save(keyParameter: String, keyPersistent: String, value: Int) {
        save(keyParameter, keyPersistent: keyPersistent, value: String(value))
    }
    
    /**
    Save identified visitor specific data to buffer or user defaults
    - parameter key: parameter name
    - parameter value: string parameter value
    */
    private func save(keyParameter: String, keyPersistent: String, value: String) {
        if let conf = tracker.configuration.parameters[IdentifiedVisitorHelperKey.Configuration.rawValue] {
            if conf.lowercaseString == "true" {
                userDefaults.setObject(value, forKey: keyPersistent)
                userDefaults.synchronize()
            } else {
                tracker.setParam(keyParameter, value: value, options: option)
            }
        } else {
            tracker.setParam(keyParameter, value: value, options: option)
        }
    }
}