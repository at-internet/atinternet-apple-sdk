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
//  BusinessObject.swift
//  Tracker
//

import Foundation


/// Super class for object tracking. Not recommended for normal use. If you need special markers you can subclass BusinessObject.
open class BusinessObject: NSObject {
    /// Tracker instance
    var tracker: Tracker!
    /// Screen ID
    let id: String = UUID().uuidString
    /// Creation date
    var timeStamp : UInt64 = UInt64(0)
    
    /**
    Default initializer
     */
    override init() {
        super.init()
    }
    
    /**
    BusinessObject initializer
    - parameter tracker: the tracker instance
    - returns: BusinessObject instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
        var info = mach_timebase_info()
        mach_timebase_info(&info)
        self.timeStamp = mach_absolute_time() * UInt64(info.numer) / UInt64(info.denom)
    }
    
    /// Set parameters in buffer
    func setParams() {
        
    }
}
