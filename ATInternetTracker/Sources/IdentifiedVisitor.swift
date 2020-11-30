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
enum IdentifiedVisitorHelperKey: String, EnumCollection {
    case configuration = "persistIdentifiedVisitor"
    case numeric = "ATIdentifiedVisitorNumeric"
    case text = "ATIdentifiedVisitorText"
    case category = "ATIdentifiedVisitorCategory"
}

/// Wrapper class for identified visitor tracking
public class IdentifiedVisitor: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    let option = ParamOption()
    let userDefaults = UserDefaults.standard
    
    /**
    IdentifiedVisitor initializer
    - parameter tracker: the tracker instance
    - returns: IdentifiedVisitor instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
        option.persistent = true;
    }
    
    /// Set Identified visitor ID (numeric) for the current session
    ///
    /// - Parameter visitorId: numeric identifier
    /// - Returns: the tracker instance
    @discardableResult
    @objc(setInt:)
    public func set(_ visitorId: Int) -> Tracker {
        _ = unset()
        save(HitParam.visitorIdentifierNumeric.rawValue, keyPersistent: IdentifiedVisitorHelperKey.numeric.rawValue, value: String(visitorId))
        
        return self.tracker
    }
    
    /// Set Identified visitor for the current session
    ///
    /// - Parameters:
    ///   - visitorId: numeric identifier
    ///   - visitorCategory: visitorCategory
    /// - Returns: the tracker instance
    @discardableResult
    @objc(setInt:visitorCategory:)
    public func set(_ visitorId: Int, visitorCategory: Int) -> Tracker {
        return set(visitorId, visitorCategory: String(visitorCategory))
    }
    
    /// Set Identified visitor for the current session
    ///
    /// - Parameters:
    ///   - visitorId: numeric identifier
    ///   - visitorCategory: visitorCategory
    /// - Returns: the tracker instance
    @discardableResult
    @objc(setInt:visitorCategoryString:)
    public func set(_ visitorId: Int, visitorCategory: String) -> Tracker {
        _ = set(visitorId)
        save(HitParam.visitorCategory.rawValue, keyPersistent: IdentifiedVisitorHelperKey.category.rawValue, value: visitorCategory)
        
        return self.tracker
    }
    
    /// Set Identified visitor for the current session
    ///
    /// - Parameter visitorId: visitorId textual identifier
    /// - Returns: the tracker instance
    @discardableResult
    @objc(setString:)
    public func set(_ visitorId: String) -> Tracker {
        _ = unset()
        save(HitParam.visitorIdentifierText.rawValue, keyPersistent: IdentifiedVisitorHelperKey.text.rawValue, value: visitorId)
        
        return self.tracker
    }
    
    /// Set Identified visitor for the current session
    ///
    /// - Parameters:
    ///   - visitorId: visitorId textual identifier
    ///   - visitorCategory: visitorCategory
    /// - Returns: the tracker instance
    @discardableResult
    @objc(setString:visitorCategory:)
    public func set(_ visitorId: String, visitorCategory: Int) -> Tracker {
        return set(visitorId, visitorCategory: String(visitorCategory))
    }
    
    /// Set Identified visitor for the current session
    ///
    /// - Parameters:
    ///   - visitorId: visitorId textual identifier
    ///   - visitorCategory: visitorCategory
    /// - Returns: the tracker instance
    @discardableResult
    @objc(setString:visitorCategoryString:)
    public func set(_ visitorId: String, visitorCategory: String) -> Tracker {
        _ = set(visitorId)
        save(HitParam.visitorCategory.rawValue, keyPersistent: IdentifiedVisitorHelperKey.category.rawValue, value: visitorCategory)
        
        return self.tracker
    }
    
    /// Unset identified visitor data. Identified visitor parameters won’t appear in next hits
    ///
    /// - Returns: tracker instance
    @discardableResult
    @objc
    public func unset() -> Tracker {
        tracker.unsetParam(HitParam.visitorIdentifierNumeric.rawValue)
        tracker.unsetParam(HitParam.visitorIdentifierText.rawValue)
        tracker.unsetParam(HitParam.visitorCategory.rawValue)
        userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.numeric.rawValue)
        userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.text.rawValue)
        userDefaults.removeObject(forKey: IdentifiedVisitorHelperKey.category.rawValue)
        userDefaults.synchronize()
        
        return self.tracker
    }
    
    /**
    Save identified visitor specific data to buffer or user defaults
    - parameter key: parameter name
    - parameter value: string parameter value
    */
    fileprivate func save(_ keyParameter: String, keyPersistent: String, value: String) {
        if let conf = tracker.configuration.parameters[IdentifiedVisitorHelperKey.configuration.rawValue] {
            if conf.lowercased() == "true" {
                userDefaults.set(value.encrypt, forKey: keyPersistent)
                userDefaults.synchronize()
            } else {
                _ = tracker.setParam(keyParameter, value: value, options: option)
            }
        } else {
            _ = tracker.setParam(keyParameter, value: value, options: option)
        }
    }
}
