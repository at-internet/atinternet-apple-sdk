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
//  Event.swift
//  Tracker
//

import Foundation

public class Event: NSObject {
    
    var _data = [String : Any]()
    var data : [String : Any] {
        get {
            return self._data
        }
        set {
            self._data = newValue
        }
    }
    
    @objc public var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func getAdditionalEvents() -> [Event] {
        return [Event]()
    }
}

public class Events: BusinessObject {
    
    var eventLists: [Event] = [Event]()
    
    /**
     Add an event
     - parameter name: event type label
     - parameter data: event data content
     - returns: a new Event
     */
    @objc public func add(name: String, data: [String : Any]) -> Event {
        let ev = Event(name: name)
        ev._data = data
        return add(event: ev)
    }
    
    /**
     Add an event
     - parameter event: event instance
     - returns: the event instance added
     */
    @objc public func add(event: Event) -> Event {
        self.eventLists.append(event)
        self.tracker.businessObjects[id] = self
        return event
    }
    
    /**
     Send all stored events
     */
    @objc public func send() {
        self.tracker.dispatcher.dispatch([self])
    }
    
    override func setParams() {
        var eventsArr = [[String : Any]]()
        
        for e in self.eventLists {
            
            var data = toFlatten(src: e.data, lowercase: true)
            if e.data.count != 0 {
                eventsArr.append(["name" : e.name.lowercased(), "data" : toObject(src: data)])
            }
            
            let additionalEvents = e.getAdditionalEvents()
            
            for ev in additionalEvents {
                data = toFlatten(src: ev.data, lowercase: true)
                eventsArr.append(["name" : ev.name.lowercased(), "data" : toObject(src: data)])
            }

        }
        self.eventLists.removeAll()
        
        let optEncode = ParamOption()
        optEncode.encode = true
        _ = self.tracker.setParam("events", value: Tool.JSONStringify(eventsArr, prettyPrinted: false), options: optEncode)
                        .setParam("col", value: "2")
        
        let pageContext = getPageContext()
        if pageContext.count != 0 {
            _ = self.tracker.setParam("context", value: Tool.JSONStringify([["data": pageContext]], prettyPrinted: false), options: optEncode)
        }
    }
    
    private func getPageContext() -> [String: Any] {
        var pageContext = [String: Any]()
        
        /// Page
        if let s = TechnicalContext.screenName {
            var pageObj = [String: Any]()
            let splt = s.components(separatedBy: "::")
            pageObj["$"] = splt[splt.count - 1]
            for (i,c) in splt.dropLast().enumerated() {
                pageObj["chapter" + String(i+1)] = c
            }
            pageContext["page"] = pageObj
        }
        
        /// Level 2
        if let level2 = TechnicalContext.level2 {
            if let level2Int = Int(level2), level2Int >= 0 && TechnicalContext.isLevel2Int {
                pageContext["site"] = ["level2_id": level2Int]
            } else {
                pageContext["site"] = ["level2": level2]
            }
        }
        
        return pageContext
    }
    
    private func toFlatten(src: [String : Any], lowercase: Bool) -> [String: (Any, String)] {
        var dst = [String : (Any, String)]()
        doFlatten(src: src, prefix: "", dst: &dst, lowercase: lowercase)
        return dst
    }
    
    private func doFlatten(src: [String: Any], prefix: String, dst: inout [String : (Any, String)], lowercase: Bool) {
        for (k,v) in src {
            let key = prefix == "" ? k : prefix + "_" + k
            if v is [String : Any] {
                doFlatten(src: v as! [String : Any], prefix: key, dst: &dst, lowercase: lowercase)
            } else {
                let parts = key.components(separatedBy: "_")
                var finalPrefix = ""
                var s = ""
                let last = parts.count - 1
                
                for (i, part) in parts.enumerated() {
                    let t = splitPrefixKey(key: part)
                    
                    if t.0 != "" {
                        finalPrefix = t.0
                    }
                    
                    if i > 0 {
                        s.append("_")
                    }
                    s.append(lowercase ? t.1.lowercased() : t.1)
                    
                    /// test -> test_$ on existing key if the current key is not complete
                    if i != last && dst[s] != nil {
                        dst[s + "_$"] = dst.removeValue(forKey: s)
                        continue
                    }
                    ///
                    
                    /// test -> test_$ on current key if the current key is complete
                    if i == last && dst[s] == nil && containsKeyPrefix(keys: dst.keys, prefix: s) {
                        s.append("_$")
                    }
                    ///
                }
                
                dst[s] = (v, lowercase ? finalPrefix.lowercased() : finalPrefix)
            }
        }
    }
    
    private func toObject(src: [String : (Any, String)]) -> [String: Any] {
        return src.reduce(into: [:]) { (acc, arg1) in
           let (key, (value, prefix)) = arg1
            let parts = key.components(separatedBy: "_")
            
            var path = ""
            for (i, part) in parts.enumerated() {
                if i != 0 {
                    path += "_"
                }
                
                if i == parts.count - 1 {
                    acc.setValue(value: value, forKeyPath: path + prefix + part)
                    return
                }
                
                path += part
            }
        }
    }
    
    private func splitPrefixKey(key: String) -> (String, String) {
        if key.count < 2 || key[key.index(key.startIndex, offsetBy: 1)] != ":" {
            return ("", key)
        }
        
        if key.count < 4 || key[key.index(key.startIndex, offsetBy: 3)] != ":" {
            return (key[0..<2], key[2...])
        }
        
        return (key[0..<4], key[4...])
    }
    
    private func containsKeyPrefix(keys: Dictionary<String, (Any, String)>.Keys, prefix: String) -> Bool {
        for (_, key) in keys.enumerated() {
            if key.hasPrefix(prefix) {
                return true
            }
        }
        return false
    }
    
}
