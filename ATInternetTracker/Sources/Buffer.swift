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
//  Buffer.swift
//  Tracker
//

import Foundation

/// Buffer that stores hit parameters
class Buffer: NSObject {
    /// Tracker instance
    var tracker: Tracker
    /// Dictionary that contains persistent parameters (context variables, etc.)
    var persistentParameters: [String:Param]
    /// Dictionary that contains volatile parameters (page, global indicators, etc.)
    var volatileParameters: [String:Param]
    
    /**
    Buffer initialization
    
    - returns: a buffer instance
    */
    public init(tracker: Tracker) {
        self.tracker = tracker
        persistentParameters = [:]
        volatileParameters = [:]
        
        super.init()
        
        addContextVariables()
    }
    
    /**
    Add context variables to the hit
    */
    func addContextVariables() {
        let persistentOption = ParamOption()
        persistentOption.persistent = true
        
        let persistentOptionWithEncoding = ParamOption()
        persistentOptionWithEncoding.persistent = true
        persistentOptionWithEncoding.encode = true
        
        // Add SDK version
        let sdkVersion = TechnicalContext.sdkVersion
        self.persistentParameters["vtag"] = Param(key: "vtag", value: {sdkVersion}, options: persistentOption)
        // Add Platform type
        #if os(iOS)
        self.persistentParameters["ptag"] = Param(key: "ptag", value: {"ios"}, options: persistentOption)
        #elseif os(watchOS)
        self.persistentParameters["ptag"] = Param(key: "ptag", value: {"watchos"}, options: persistentOption)
        #else
        self.persistentParameters["ptag"] = Param(key: "ptag", value: {"tvos"}, options: persistentOption)
        #endif
        // Add device language
        self.persistentParameters["lng"] = Param(key: "lng", value: {TechnicalContext.language}, options: persistentOption)
        // Add device information
        let device = "[apple]-[" + TechnicalContext.device + "]"
        self.persistentParameters["mfmd"] = Param(key: "mfmd", value: {device}, options: persistentOption)
        // Add OS information
        let operatingSystem = TechnicalContext.operatingSystem
        self.persistentParameters["os"] = Param(key: "os", value: {operatingSystem}, options: persistentOption)
        // Add application identifier
        let applicationIdentifier = TechnicalContext.applicationIdentifier
        self.persistentParameters["apid"] = Param(key: "apid", value: {applicationIdentifier}, options: persistentOption)
        // Add application version
        var applicationVersion = TechnicalContext.applicationVersion
        
        if !applicationVersion.isEmpty {
            applicationVersion = "[" + applicationVersion + "]"
        }
        
        self.persistentParameters["apvr"] = Param(key: "apvr", value: {applicationVersion}, options: persistentOptionWithEncoding)
        // Add local hour
        self.persistentParameters["hl"] = Param(key: "hl", value: {TechnicalContext.localHour}, options: persistentOption)
        // Add screen resolution
        self.persistentParameters["r"] = Param(key: "r", value: {TechnicalContext.screenResolution}, options: persistentOption)
        #if os(iOS)
        // Add carrier
        self.persistentParameters["car"] = Param(key: "car", value: {TechnicalContext.carrier}, options: persistentOptionWithEncoding)
        #endif
        // Add connexion information
        self.persistentParameters["cn"] = Param(key: "cn", value: {TechnicalContext.connectionType.rawValue}, options: persistentOptionWithEncoding)
        // Add time stamp for cache
        self.persistentParameters["ts"] = Param(key: "ts", value: {String(format:"%f", Date().timeIntervalSince1970 )}, options: persistentOption)
        // Add download SDK source
        self.persistentParameters["dls"] = Param(key: "dls", value: {TechnicalContext.downloadSource(self.tracker)}, options: persistentOption)
        // Add unique user id
        self.persistentParameters["idclient"] = Param(key: "idclient", value: {TechnicalContext.userId(self.tracker.configuration.parameters["identifier"])}, options: persistentOption)
    }

    #if os(iOS) && AT_SMART_TRACKER
    // Add AutoTracker
    func addAutoTrackingContextVariable() {
        if self.tracker is AutoTracker && (self.tracker as! AutoTracker).enableAutoTracking {
            let persistentOption = ParamOption()
            self.volatileParameters["auto"] = Param(key: "auto", value: {"1"}, options: persistentOption)
        }
    }
    #endif
}
