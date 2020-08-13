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


/// Global context tracking
public class Context: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    // MARK: - Level 2
    
    internal var _level2: String? = nil
    
    /// Global level 2
    @objc public var level2: Int {
        get {
            if let l = level2String {
                return Int(l) ?? -1
            }
            return -1
        }
        set {
            if newValue >= 0 {
                level2String = String(newValue)
            } else {
                level2String = nil
            }
        }
    }
    
    @objc public var level2String: String? {
        get {
            return _level2
        }
       set {
           _level2 = newValue
           
           if let l = _level2{
               let option = ParamOption()
               option.persistent = true;
               
               _ = tracker.setParam(HitParam.level2.rawValue, value: l, options: option)
           } else {
               tracker.unsetParam(HitParam.level2.rawValue)
           }
        }
    }
    
    // MARK: - Background Mode
    
    internal var _backgroundMode: BackgroundMode = BackgroundMode.normal
    
    /// Tracker background mode. See BackgroundMode
    @objc public var backgroundMode: BackgroundMode {
        get {
            return _backgroundMode
        }
        set {
            _backgroundMode = newValue
            
            let option = ParamOption()
            option.persistent = true
            
            switch _backgroundMode {
                case .fetch:
                    _ = tracker.setParam(HitParam.backgroundMode.rawValue, value: "fetch", options: option)
                case .task:
                    _ = tracker.setParam(HitParam.backgroundMode.rawValue, value: "task", options: option)
                default:
                    tracker.unsetParam(HitParam.backgroundMode.rawValue)
            }
        }
    }
}
