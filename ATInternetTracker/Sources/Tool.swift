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
//  Tool.swift
//  Tracker
//

import Foundation

/// Toolbox: utility methods
class Tool: NSObject {
    
    /**
    Convert a dictionary into a json string
    
    - parameter object: to convert to json
    - parameter format: of returned string (pretty printed or raw)
    
    - returns: a json string
    */
    class func JSONStringify(_ value: Any, prettyPrinted: Bool = false) -> String {
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: (prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : [])) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }
        }
        return ""
    }    
    
    /**
    Finds the position of a parameter within parameter arrays for a given parameter key
    
    - parameter parameter: key
    - parameter arrays: of parameters where to search for key
    
    - returns: The position of the parameter and the index of the array where the parameter was found. (-1,-1)if not found
    */
    class func findParameterPosition(_ parameterKey: String, arrays: [Param]...) -> [(index: Int, arrayIndex: Int)] {
        var indexes: [(index: Int, arrayIndex: Int)] = []
        for(arrayIndex, array) in arrays.enumerated() {
            for (parameterIndex, parameter) in array.enumerated() {
                if parameter.key == parameterKey {
                    indexes.append((index: parameterIndex, arrayIndex: arrayIndex))
                }
            }
        }
        return indexes
    }
    
    /**
    Converts the parameter value into a string
    
    - parameter value: value of the parameter
    - parameter separator: character to use as a separator inside the string value
    
    - returns: a string value and a boolean which indicates whether the conversion was successful or not
    */
    class func convertToString(_ value: Any, separator: String = ",") -> (value: String, success: Bool) {
        switch(value) {
        case let optArray as [Any]:
            var stringFromArray = ""
            var convertSuccess = true
            
            for(index, val) in optArray.enumerated() {
                if (index > 0) {
                    (stringFromArray += separator)
                }
                
                let stringValue = convertToString(val)
                stringFromArray += stringValue.value
                
                if(!stringValue.success) {
                    convertSuccess = stringValue.success
                }
            }
            return (stringFromArray, convertSuccess)
        case let optDictionnary as [String: Any]:
            let json = Tool.JSONStringify(optDictionnary)
            return json == "" ? ("", false) : (json, true)
        case let optString as String:
            return (optString, true)
        case let optNumber as NSNumber:
            if optNumber.isBool {
                return optNumber.boolValue ? ("true", true) : ("false", true)
            } else {
                return (optNumber.stringValue, true)
            }
        default:
            return ("", false)
        }
    }
    
    /**
    Gets the number of days between two dates
    
    - parameter fromDate:
    - parameter toDate:
    
    - returns: the number of days between fromDate and toDate
    */
    class func daysBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        return calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    }
    
    /**
    Gets the number of minutes between two dates
    
    - parameter fromDate:
    - parameter toDate:
    
    - returns: the number of minutes between fromDate and toDate
    */
    class func minutesBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        return calendar.dateComponents([.minute], from: fromDate, to: toDate).minute ?? 0
    }
    
    /**
     Gets the number of seconds between two dates
     
     - parameter fromDate:
     - parameter toDate:
     
     - returns: the number of seconds between fromDate and toDate
     */
    class func secondsBetweenDates(_ fromDate: Date, toDate: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        return calendar.dateComponents([.second], from: fromDate, to: toDate).second ?? 0
    }
    
    /**
    Append parameter values from buffer
    
    - parameter parameter: key
    - parameter volatile: parameters
    - parameter peristent: parameters
    
    - returns: parameter value
    */
    class func appendParameterValues(_ parameterKey: String, volatileParameters: [String:Param], persistentParameters: [String:Param]) -> String {
        let allParameters = [volatileParameters, persistentParameters]
        var value = ""
        for dictionaryOfParams in allParameters {
            if let param = dictionaryOfParams[parameterKey] {
                for (index, closureValue) in param.values.enumerated() {
                    if index == 0 {
                        value += closureValue()
                    }
                    else {
                        value += param.options?.separator ?? ","
                        value += closureValue()
                    }
                }
            }
        }
        
        return value
    }
    
    class func toFlatten(src: [String : Any], lowercase: Bool, separator: String) -> [String: (Any, String)] {
        var dst = [String : (Any, String)]()
        doFlatten(src: src, prefix: "", dst: &dst, lowercase: lowercase, separator: separator)
        return dst
    }
    
    private class func doFlatten(src: [String: Any], prefix: String, dst: inout [String : (Any, String)], lowercase: Bool, separator: String) {
        for (k,v) in src {
            let key = prefix == "" ? k : prefix + separator + k
            if v is [String : Any] {
                doFlatten(src: v as! [String : Any], prefix: key, dst: &dst, lowercase: lowercase, separator: separator)
            } else {
                let parts = key.components(separatedBy: separator)
                var finalPrefix = ""
                var s = ""
                let last = parts.count - 1
                
                for (i, part) in parts.enumerated() {
                    let t = splitPrefixKey(key: part)
                    
                    if t.0 != "" {
                        finalPrefix = t.0
                    }
                    
                    if i > 0 {
                        s.append(separator)
                    }
                    s.append(lowercase ? t.1.lowercased() : t.1)
                    
                    /// test -> test_$ on existing key if the current key is not complete
                    if i != last && dst[s] != nil {
                        dst[s + separator + "$"] = dst.removeValue(forKey: s)
                        continue
                    }
                    ///
                    
                    /// test -> test_$ on current key if the current key is complete
                    if i == last && dst[s] == nil && containsKeyPrefix(keys: dst.keys, prefix: s + separator) {
                        s.append(separator)
                        s.append("$")
                    }
                    ///
                }
                
                dst[s] = (v, lowercase ? finalPrefix.lowercased() : finalPrefix)
            }
        }
    }
    
    class func toObject(src: [String : (Any, String)], separator: String) -> [String: Any] {
        return src.reduce(into: [:]) { (acc, arg1) in
           let (key, (value, prefix)) = arg1
            let parts = key.components(separatedBy: separator)
            
            var path = ""
            for (i, part) in parts.enumerated() {
                if i != 0 {
                    path += separator
                }
                
                if i == parts.count - 1 {
                    acc.setValue(value: value, forKeyPath: path + prefix + part, separator: separator)
                    return
                }
                
                path += part
            }
        }
    }
    
    private class func splitPrefixKey(key: String) -> (String, String) {
        if key.count < 2 || key[key.index(key.startIndex, offsetBy: 1)] != ":" {
            return ("", key)
        }
        
        if key.count < 4 || key[key.index(key.startIndex, offsetBy: 3)] != ":" {
            return (key[0..<2], key[2...])
        }
        
        return (key[0..<4], key[4...])
    }
    
    private class func containsKeyPrefix(keys: Dictionary<String, (Any, String)>.Keys, prefix: String) -> Bool {
        for (_, key) in keys.enumerated() {
            if key.hasPrefix(prefix) {
                return true
            }
        }
        return false
    }
}
