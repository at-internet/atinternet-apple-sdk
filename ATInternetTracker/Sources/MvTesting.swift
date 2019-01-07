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
//  MvTesting.swift
//  Tracker
//

import Foundation

/// Wrapper class to manage SalesTracker Order feature
public class MvTesting: BusinessObject {
    
    /// Test
    @objc public var test: String = ""
    
    /// WaveId
    @objc public var waveId: Int = -1
    
    /// WaveId
    @objc public var creation: String = ""
    
    /// Custom variables
    @objc public lazy var variables: MvTestingVars = MvTestingVars()
    
    /// Send
    @objc public func send() {
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        _ = tracker.setParam("type", value: "mvt")
            .setParam("abmvc", value: String(format: "%@-%d-%@", self.test, self.waveId, self.creation), options: encodingOption)
        
        for(i, mvtVar) in variables.list.enumerated() {
            _ = tracker.setParam("abmv" + String(i + 1), value: String(format: "%@-%@", mvtVar.variable, mvtVar.version), options: encodingOption)
        }
        
    }
}

/// Wrapper class to manage MvTestings instances
public class MvTestings: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
     MvTestings initializer
     - parameter tracker: the tracker instance
     - returns: MvTestings instance
     */
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    /// Add an mvtesting
    ///
    /// - Parameters:
    ///   - test: mvtesting test
    ///   - waveId: mvtesting wave id
    ///   - creation: mvtesting creation
    /// - Returns: MvTesting instance
    @objc public func add(_ test: String, waveId: Int, creation: String) -> MvTesting {
        let mvtesting = MvTesting(tracker: tracker)
        mvtesting.test = test
        mvtesting.waveId = waveId
        mvtesting.creation = creation
        tracker.businessObjects[mvtesting.id] = mvtesting
        
        return mvtesting
    }
}

/// Wrapper class for tracking mvtesting variables
public class MvTestingVar: NSObject {
    
    /// Custom var variable
    @objc public var variable: String = ""
    /// Custom var version
    @objc public var version: String = ""
    
    /// initializer
    ///
    /// - Parameters:
    ///   - variable: var variable
    ///   - version: var version
    init(variable: String, version: String) {
        self.variable = variable
        self.version = version
    }
}

/// Wrapper class to manage MvTestingVar instances
public class MvTestingVars: NSObject {
    
    /// Custom var list
    lazy var list: [MvTestingVar] = []
    
    /// Add a custom var
    ///
    /// - Parameters:
    ///   - variable: var variable
    ///   - version: var version
    /// - Returns: the MvTestingVar instance
    @objc public func add(_ variable: String, version: String) ->  MvTestingVar {
        let customVar = MvTestingVar(variable: variable, version: version)
        
        list.append(customVar)
        
        return customVar
    }
}
