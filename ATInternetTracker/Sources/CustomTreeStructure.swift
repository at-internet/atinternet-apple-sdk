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
//  CustomTreeStructure.swift
//  Tracker
//

import Foundation


/// Wrapper class for custom tree structure tracking
public class CustomTreeStructure: ScreenInfo {
    /// Custom tree structure first category label
    @objc public var category1: Int = 0
    /// Custom tree structure first category label
    @objc public var category2: Int = 0
    /// Custom tree structure first category label
    @objc public var category3: Int = 0
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    
    /// Create a new CustomTreeStructure
    ///
    /// - Parameter category1: first custom tree structure category
    @objc public init(category1: Int) {
        super.init()
        
        self.category1 = category1
    }
    
    /// Create a new CustomTreeStructure
    ///
    /// - Parameters:
    ///   - category1: first custom tree structure category
    ///   - category2: second custom tree structure category
    @objc public convenience init(category1: Int, category2: Int) {
        self.init(category1: category1)
        
        self.category2 = category2
    }
    
    /// Create a new CustomTreeStructure
    ///
    /// - Parameters:
    ///   - category1: first custom tree structure category
    ///   - category2: second custom tree structure category
    ///   - category3: third custom tree structure category
    @objc public convenience init(category1: Int, category2: Int, category3: Int) {
        self.init(category1: category1, category2: category2)
        
        self.category3 = category3
    }
    
    /// Set parameters in buffer
    override func setParams() {
        _ = tracker.setParam("ptype", value: String(format: "%d-%d-%d", category1, category2, category3))
    }
}


/// Wrapper class to manage custom tree structure instances
public class CustomTreeStructures: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    CustomTreeStructures initializer
    - parameter tracker: the tracker instance
    - returns: CustomTreeStructures instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    /// Add a custom tree structure info to screen hit
    ///
    /// - Parameters:
    ///   - category1: category1 label
    /// - Returns: CustomTreeStructure instance
    public func add(_ category1: Int) -> CustomTreeStructure {
        let cts = CustomTreeStructure(tracker: tracker)
        cts.category1 = category1
        tracker.businessObjects[cts.id] = cts
        
        return cts
    }

    /// Add a custom tree structure info to screen hit
    ///
    /// - Parameters:
    ///   - category1: category1 label
    ///   - category2: category2 label
    /// - Returns: CustomTreeStructure instance
    public func add(_ category1: Int, category2: Int) -> CustomTreeStructure {
        let cts = add(category1)
        cts.category2 = category2
        
        return cts
    }
    
    /// Add a custom tree structure info to screen hit
    ///
    /// - Parameters:
    ///   - category1: category1 label
    ///   - category2: category2 label
    ///   - category3: category3 label
    /// - Returns: CustomTreeStructure instance
    public func add(_ category1: Int, category2: Int, category3: Int) -> CustomTreeStructure {
        let cts = add(category1, category2: category2)
        cts.category3 = category3
        
        return cts
    }
}
