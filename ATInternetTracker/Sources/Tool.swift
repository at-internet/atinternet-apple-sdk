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
    class func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: (prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : [])) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
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
    class func findParameterPosition(parameterKey: String, arrays: [Param]...) -> [(index: Int, arrayIndex: Int)] {
        var indexes: [(index: Int, arrayIndex: Int)] = []
        for(arrayIndex, array) in arrays.enumerate() {
            for (parameterIndex, parameter) in array.enumerate() {
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
    class func convertToString(value: AnyObject, separator: String = ",") -> (value: String, success: Bool) {
        switch(value) {
        case let optArray as [AnyObject]:
            var stringFromArray = ""
            var convertSuccess = true
            
            for(index, val) in optArray.enumerate() {
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
        case let optDictionnary as [String: AnyObject]:
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
    class func daysBetweenDates(fromDate: NSDate, toDate: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let unitFlags = NSCalendarUnit.Day
        let dateComponents = calendar?.components(unitFlags, fromDate: fromDate, toDate: toDate, options: NSCalendarOptions(rawValue: 0))
        
        if let optDate = dateComponents {
            return optDate.day
        }
        
        return 0
    }
    
    /**
    Gets the number of minutes between two dates
    
    - parameter fromDate:
    - parameter toDate:
    
    - returns: the number of minutes between fromDate and toDate
    */
    class func minutesBetweenDates(fromDate: NSDate, toDate: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let unitFlags = NSCalendarUnit.Minute
        let dateComponents = calendar?.components(unitFlags, fromDate: fromDate, toDate: toDate, options: NSCalendarOptions(rawValue: 0))
        
        if let optDate = dateComponents {
            return optDate.minute
        }
        
        return 0
    }
    
    /**
     Gets the number of seconds between two dates
     
     - parameter fromDate:
     - parameter toDate:
     
     - returns: the number of seconds between fromDate and toDate
     */
    class func secondsBetweenDates(fromDate: NSDate, toDate: NSDate) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let unitFlags = NSCalendarUnit.Second
        let dateComponents = calendar?.components(unitFlags, fromDate: fromDate, toDate: toDate, options: NSCalendarOptions(rawValue: 0))
        
        if let optDate = dateComponents {
            return optDate.second
        }
        
        return 0
    }
    
    /**
    Append parameter values from buffer
    
    - parameter parameter: key
    - parameter volatile: parameters
    - parameter peristent: parameters
    
    - returns: parameter value
    */
    class func appendParameterValues(parameterKey: String, volatileParameters: [Param], persistentParameters: [Param]) -> String {
        let paramPositions = Tool.findParameterPosition(parameterKey, arrays: volatileParameters, persistentParameters)
        var value = ""
        
        if(paramPositions.count > 0) {
            for(tuple) in paramPositions.enumerate() {
                let param = tuple.element.arrayIndex == 0 ? volatileParameters[tuple.element.index] : persistentParameters[tuple.element.index]
                
                if(tuple.index > 0) {
                    if let optOption = param.options {
                        value += optOption.separator
                    } else {
                        value += ","
                    }
                }
                
                value += param.value();
            }
        }
        
        return value;
    }
    
    /**
    Copy an array of parameter into a new one
    
    - parameter array: to copy
    :returned: copy of array
    */
    class func copyParamArray(array: [Param]) -> [Param] {
        var newArray: [Param] = []
        
        for(_, param) in array.enumerate() {
            let copyParam = Param(key: param.key, value: param.value, type: param.type, options: param.options)
            newArray.append(copyParam)
        }
        
        return newArray
    }
}


