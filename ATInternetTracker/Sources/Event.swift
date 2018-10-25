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
    
    var dataObjectList = [[String : Any]]()
    
    @objc public var action: String
    
    init(action: String) {
        self.action = action
    }
    
    public func setDataObject(dataObject: [String : Any]) -> Event {
        self.dataObjectList.removeAll()
        self.dataObjectList.append(dataObject)
        
        return self
    }
}

public class Events: BusinessObject {
    var singleEvent: Event? = nil
    var eventLists: [Event] = [Event]()
    
    func sendSingle(event: Event){
        self.singleEvent = event
        self.tracker.dispatcher.dispatch([self])
        
        /// Reinsertion de l'instance dans les business objects si la liste des events a envoyer n'est pas vide pour le dispatch
        if self.eventLists.count > 0 {
            self.tracker.businessObjects[id] = self
        }
    }
    
    /**
     Add an event
     - parameter action: event action label
     - parameter data: event data content
     - returns: a new Event
     */
    public func add(action: String, data: [String : Any]) -> Event {
        var array = [[String : Any]]()
        array.append(data)
        return add(action: action, dataObjectsList: array)
    }
    
    /**
     Add an event
     - parameter action: event action label
     - parameter dataObjectsList: event data content list
     - returns: a new Event
     */
    public func add(action: String, dataObjectsList: [[String : Any]]) -> Event {
        let e = Event(action: action)
        e.dataObjectList = dataObjectsList
        return add(event: e)
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
        _ = self.tracker.setParam("col", value: "2")
        
        var eventsArr = [[String : Any]]()
        
        /// Single event
        if let optSingleEvent = self.singleEvent {
            if optSingleEvent.dataObjectList.count == 0 {
                eventsArr.append(["action" : optSingleEvent.action, "data" : [String : Any]()])
            } else {
                for data in optSingleEvent.dataObjectList {
                    eventsArr.append(["action" : optSingleEvent.action, "data" : data])
                }
            }
            self.eventLists = self.eventLists.filter{
                $0 != self.singleEvent
            }
            self.singleEvent = nil
        } else {
            for e in self.eventLists {
                if e.dataObjectList.count == 0 {
                    eventsArr.append(["action" : e.action, "data" : [String : Any]()])
                } else {
                    for data in e.dataObjectList {
                        eventsArr.append(["action" : e.action, "data" : data])
                    }
                }
            }
            self.eventLists.removeAll()
        }
        
        let optEncode = ParamOption()
        optEncode.encode = true
        _ = self.tracker.setParam("events", value: Tool.JSONStringify(eventsArr, prettyPrinted: false), options: optEncode)
    }
}
