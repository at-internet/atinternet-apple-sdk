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
    }
    
    @objc public var type: String
    
    init(type: String) {
        self.type = type
    }
    
    func getAdditionalEvents() -> [Event] {
        return [Event]()
    }
}

public class Events: BusinessObject {
    
    var eventLists: [Event] = [Event]()
    
    /**
     Add an event
     - parameter type: event type label
     - parameter data: event data content
     - returns: a new Event
     */
    public func add(type: String, data: [String : Any]) -> Event {
        let ev = Event(type: type)
        ev._data = data
        return add(event: ev)
    }
    
    /**
     Add an event
     - parameter event: event instance
     - returns: the event instance added
     */
    public func add(event: Event) -> Event {
        self.eventLists.append(event)
        self.tracker.businessObjects[id] = self
        return event
    }
    
    /**
     Send all stored events
     */
    public func send() {
        self.tracker.dispatcher.dispatch([self])
    }
    
    override func setParams() {
        var eventsArr = [[String : Any]]()
        
        for e in self.eventLists {
            
            if e.data.count != 0 {
                eventsArr.append(["event" : e.type, "data" : e.data])
            }
            
            let additionalEvents = e.getAdditionalEvents()
            
            for ev in additionalEvents {
                eventsArr.append(["event" : ev.type, "data" : ev.data])
            }

        }
        self.eventLists.removeAll()
        
        let optEncode = ParamOption()
        optEncode.encode = true
        _ = self.tracker.setParam("events", value: Tool.JSONStringify(eventsArr, prettyPrinted: false), options: optEncode)
                        .setParam("col", value: "2")
    }
}
