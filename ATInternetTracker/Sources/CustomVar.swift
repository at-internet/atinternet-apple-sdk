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
//  CustomVar.swift
//  Tracker
//

import Foundation

public class CustomVar: ScreenInfo {
    
    /// Custom var types
    @objc public enum CustomVarType: Int {
        case App = 0
        case Screen = 1
    }
    
    /// Custom var identifier
    var varId: Int = 1
    
    /// Custom var type
    var type: CustomVarType = CustomVarType.App
    
    /// Custom var value
    var value: String = ""
    
    init(varId: Int, value: String, type: CustomVar.CustomVarType) {
        super.init()
        
        self.varId = varId
        self.value = value
        self.type = type
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /**
     Convert CustomVar Type Enum Int values to String values
     */
    private func getCustomVarTypeRawValue(value: Int) -> String {
        switch value {
        case 0:
            return "x"
        case 1:
            return "f"
        default:
            return "x"
        }
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        if (varId < 1) {
            varId = 1
        }
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        let key = getCustomVarTypeRawValue(self.type.rawValue) + String(varId)
        tracker.setParam(key, value: value, options: encodingOption)
    }
    
}

public class CustomVars: NSObject {
    
    /// Tracker instance
    var tracker: Tracker!
    
    /// Screen instance
    var screen: AbstractScreen!
    
    /**
    CustomVars initializer
    - parameter tracker: the tracker instance
    - returns: CustomVars instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    init(screen: AbstractScreen) {
        self.screen = screen
        self.tracker = screen.tracker
    }
    
    /**
    Set a custom var
    - parameter varId: identifier of the custom variable
    - parameter value: of the custom variable
    - parameter type: of custom variable (site, page)
    - returns: tracker instance
    */
    public func add(varId: Int, value: String, type: CustomVar.CustomVarType) -> CustomVar {
        let customVar = CustomVar(varId: varId, value: value, type: type)
        customVar.tracker = self.tracker
        
        if screen != nil {
            screen!._customVars[customVar.id] = customVar
        } else {
            self.tracker.businessObjects[customVar.id] = customVar
        }
        
        return customVar
    }
    
    /**
     Remove a custom variable
     - parameter customVarId: the custom variable identifier
     */
    public func remove(customVarId: String) {
        if(screen != nil) {
            screen!._customVars.removeValueForKey(customVarId)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is CustomVar && (value as! CustomVar).id == customVarId) {
                    self.tracker.businessObjects.removeValueForKey(value.id)
                    break
                }
            }
        }
    }
    
    /**
     Remove all the custom variables
     */
    public func removeAll() {
        if(screen != nil) {
            screen!._customVars.removeAll(keepCapacity: false)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is CustomVar) {
                    self.tracker.businessObjects.removeValueForKey(value.id)
                }
            }
        }
    }
    
}