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
//  Parameter.swift
//  Tracker
//

import Foundation

/// Plugin parameter
class PluginParam: NSObject {
    
    /// Returns all the parameters which needs custom handler
    class func list(_ tracker: Tracker) -> [String: Plugin.Type] {
        let dic = [String: Plugin.Type]()
        /*
        if let optPlugin = tracker.configuration.parameters["plugins"] {
            if (optPlugin.range(of: "tvtracking") != nil) {
                dic["tvt"] = TVTrackingPlugin.self
            }
        }*/
        
        return dic
    }
}

/// Read only parameter
class ReadOnlyParam: NSObject {
    /// Set of all parameters which value cannot be updated
    class var list: Set<String> {
        get {
            return [
                "vtag",
                "lng",
                "mfmd",
                "os",
                "hl",
                "r",
                "car",
                "cn",
                "ts",
                "olt"
            ]
        }
    }
}

/// Slice ready parameter
class SliceReadyParam: NSObject {
    
    /// Set of all parameters which can be sliced
    class var list: Set<String> {
        get {
            return [
                "stc",
                "ati",
                "atc",
                "pdtl",
                "events"
            ]
        }
    }
}

/// Hit parameter
public class Param: NSObject {
    /// Parameter key (Querystring variable)
    internal(set) public var key: String
    /// Parameter value
    internal(set) public var values: [(() -> String)]!
    /// Parameter options
    lazy var options: ParamOption? = ParamOption()
    /// Description (&p=v)
    var text: String {
        var str = "&\(key)="
        for val in self.values {
            str += "\(val()) "
        }
        return str
    }
    
    public var isPersistent: Bool {
        return self.options?.persistent ?? false;
    }
    
    var isProperty: Bool {
        return self.options?.property ?? false;
    }
    
    /**
    Default initializer
    
    - returns: a parameter with no key and no value
    */
    convenience override init() {
        self.init(key: "", value: {""});
    }
    
    /**
    Init a parameter with a key and a closure to execute as value
    
    - parameter key: of the parameter
    - parameter closure: to be executed by the hit builder
    
    - returns: a parameter
    */
    convenience init(key: String, value:@escaping () -> String) {
        self.init(key: key, value: value, options: nil);
    }
    
    /**
    Init a parameter with a key, a closure to execute as value and options
    
    - parameter key: of the parameter
    - parameter closure: to be executed by the hit builder
    - parameter options:
    
    - returns: a parameter
    */
    init(key: String, value:@escaping () -> String, options: ParamOption?) {
        self.key = key
        self.values = [value]
        super.init()
        self.options = options
    }
}

/// Parameter option
@objcMembers public class ParamOption: NSObject {
    /// Enum to customize parameter options
    ///
    /// - none: Undefined
    /// - first: First parameter
    /// - last: Last parameter (/!\ Cannot override the referrer parameter position, it must be the last if it's defined)
    /// - before: Before an other parameter (use {@link #setRelativeParameterKey(String)} with that)
    /// - after: After an other parameter (use {@link #setRelativeParameterKey(String)} with that)
    public enum RelativePosition {
        /// Undefined
        case none
        /// First parameter
        case first
        /// Last parameter (/!\ Cannot override the referrer parameter position, it must be the last if it's defined)
        case last
        /// Before an other parameter (use {@link #setRelativeParameterKey(String)} with that)
        case before
        /// After an other parameter (use {@link #setRelativeParameterKey(String)} with that)
        case after
    }
    
    /// Parameter relative position in hit
    public var relativePosition: RelativePosition
    /// Relative parameter
    public var relativeParameterKey: String?
    /// Separator to be used when the value of the parameter is of type Array
    public var separator: String
    /// Indicates if value must be percent encoded or not
    public var encode: Bool
    /// Indicates if parameter must be reused in future hits
    public var persistent: Bool
    /// Indicates if value must be appended to the old value of parameter
    public var append: Bool
    
    var property: Bool
    
    /**
    Default initializer
    
    - returns: a parameter option
    */
    public override init() {
        relativeParameterKey = ""
        relativePosition = RelativePosition.none
        separator = ","
        encode = false
        persistent = false
        append = false
        property = false
    }
}
