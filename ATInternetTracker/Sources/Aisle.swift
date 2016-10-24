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
//  Aisle.swift
//  Tracker
//

import UIKit

public class Aisle: ScreenInfo {
    
    /// Aisle level1 label
    public var level1: String?
    
    /// Aisle level2 label
    public var level2: String?
    
    /// Aisle level3 label
    public var level3: String?
    
    /// Aisle level4 label
    public var level4: String?
    
    /// Aisle level5 label
    public var level5: String?
    
    /// Aisle level6 label
    public var level6: String?
    
    /// Set parameters in buffer
    override func setEvent() {
        var value: String?
        
        if let optLevel1 = level1 {
            value = optLevel1
        }
        
        if let optLevel2 = level2 {
            if(value == nil) {
                value = optLevel2
            } else {
                value! += "::" + optLevel2
            }
        }
        
        if let optLevel3 = level3 {
            if(value == nil) {
                value = optLevel3
            } else {
                value! += "::" + optLevel3
            }
        }
        
        if let optLevel4 = level4 {
            if(value == nil) {
                value = optLevel4
            } else {
                value! += "::" + optLevel4
            }
        }
        
        if let optLevel5 = level5 {
            if(value == nil) {
                value = optLevel5
            } else {
                value! += "::" + optLevel5
            }
        }
        
        if let optLevel6 = level6 {
            if(value == nil) {
                value = optLevel6
            } else {
                value! += "::" + optLevel6
            }
        }
        
        if(value != nil) {
            let encodeOption = ParamOption()
            encodeOption.encode = true
            tracker.setParam("aisl", value: value!, options: encodeOption)
        }
    }
}

public class Aisles {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Aisle initializer
    - parameter tracker: the tracker instance
    - returns: Aisle instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    /**
    Add tagging data for an aisle
    - parameter level1: level1 label
    - returns: Aisle instance
    */
    public func add(level1: String) -> Aisle {
        return _add(level1, level2: nil, level3: nil, level4: nil, level5: nil, level6: nil)
    }
    
    /**
    Add tagging data for an aisle
    - parameter level1: level1 label
    - parameter level2: level2 label
    - returns: Aisle instance
    */
    public func add(level1: String, level2: String) -> Aisle {
        return _add(level1, level2: level2, level3: nil, level4: nil, level5: nil, level6: nil)
    }
    
    /**
    Add tagging data for an aisle
    - parameter level1: level1 label
    - parameter level2: level2 label
    - parameter level3: level3 label
    - returns: Aisle instance
    */
    public func add(level1: String, level2: String, level3: String) -> Aisle {
        return _add(level1, level2: level2, level3: level3, level4: nil, level5: nil, level6: nil)
    }
    
    /**
    Add tagging data for an aisle
    - parameter level1: level1 label
    - parameter level2: level2 label
    - parameter level3: level3 label
    - parameter level4: level4 label
    - returns: Aisle instance
    */
    public func add(level1: String, level2: String, level3: String, level4: String) -> Aisle {
        return _add(level1, level2: level2, level3: level3, level4: level4, level5: nil, level6: nil)
    }
    
    /**
    Add tagging data for an aisle
    - parameter level1: level1 label
    - parameter level2: level2 label
    - parameter level3: level3 label
    - parameter level4: level4 label
    - parameter level5: level5 label
    - returns: Aisle instance
    */
    public func add(level1: String, level2: String, level3: String, level4: String, level5: String) -> Aisle {
        return _add(level1, level2: level2, level3: level3, level4: level4, level5: level5, level6: nil)
    }
    
    /**
    Add tagging data for an aisle
    - parameter level1: level1 label
    - parameter level2: level2 label
    - parameter level3: level3 label
    - parameter level4: level4 label
    - parameter level5: level5 label
    - parameter level6: level6 label
    - returns: Aisle instance
    */
    public func add(level1: String, level2: String, level3: String, level4: String, level5: String, level6: String) -> Aisle {
        return _add(level1, level2: level2, level3: level3, level4: level4, level5: level5, level6: level6)
    }
    
    private func _add(level1: String?, level2: String?, level3: String?, level4: String?, level5: String?, level6: String?) -> Aisle {
        let aisle = Aisle(tracker: tracker)
        aisle.level1 = level1
        aisle.level2 = level2
        aisle.level3 = level3
        aisle.level4 = level4
        aisle.level5 = level5
        aisle.level6 = level6
        
        tracker.businessObjects[aisle.id] = aisle
        return aisle
    }
}
