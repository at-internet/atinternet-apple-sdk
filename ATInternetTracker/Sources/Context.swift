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
//  Context
//  Tracker
//

import Foundation

public class Context: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    // MARK: - Level 2
    
    internal var _level2: Int? = nil
    
    /// Tracker level 2
    public var level2: Int? {
        get {
            return _level2
        }
        set {
            _level2 = newValue
            
            if let _level2 = _level2 {
                let option = ParamOption()
                option.persistent = true;
                
                tracker.setParam(HitParam.Level2.rawValue, value: _level2, options: option)
            } else {
                tracker.unsetParam(HitParam.Level2.rawValue)
            }
        }
    }
    
    // MARK: - Background Mode
    
    internal var _backgroundMode: BackgroundMode? = nil
    
    /// Tracker background mode
    public var backgroundMode: BackgroundMode? {
        get {
            return _backgroundMode
        }
        set {
            _backgroundMode = newValue
            
            let option = ParamOption()
            option.persistent = true
            
            if let _backgroundMode = _backgroundMode {
                switch _backgroundMode {
                case .Fetch:
                    tracker.setParam(HitParam.BackgroundMode.rawValue, value: "fetch", options: option)
                case .Task:
                    tracker.setParam(HitParam.BackgroundMode.rawValue, value: "task", options: option)
                default:
                    tracker.unsetParam(HitParam.BackgroundMode.rawValue)
                }
            }
        }
    }
}
