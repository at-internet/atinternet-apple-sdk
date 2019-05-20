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
//  EventsTests.swift
//  Tracker
//

import XCTest

class EventsTests: XCTestCase {
    
    lazy var events: Events = Events(tracker: Tracker())

    override func setUp() {
        super.setUp()
    }
    
    func testSetParamsOne() {
        _ = events.add(name: "act", data: ["test1" : "value1"])
        events.setParams()
        
        XCTAssertEqual(events.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssertEqual(events.tracker.buffer.volatileParameters["col"]!.values.count, 1, "Le nombre de valeurs dans col doit être égal à 1")
        XCTAssert(events.tracker.buffer.volatileParameters["col"]!.values[0]() == "2", "La valeur de col paramètre doit être 2")
        
        XCTAssertEqual(events.tracker.buffer.volatileParameters["events"]!.values.count, 1, "Le nombre de valeurs dans events doit être égal à 1")
        
        let evts = ATJSON.parse(events.tracker.buffer.volatileParameters["events"]!.values[0]())
        
        XCTAssertEqual(evts.array!.count, 1, "Le nombre d'events doit être égal à 1")
        
        let evt = evts[0]
        XCTAssertEqual(evt.dictionaryObject!.count, 2, "Le nombre de proprietes dans l'event doit être égal à 2")
        XCTAssertEqual(evt.dictionaryObject!["name"] as! String, "act", "La propriété name doit etre égale a act")
        
        let data = evt.dictionaryObject!["data"] as! [String : Any]
        XCTAssertEqual(data.count, 1, "Le nombre de proprietes dans data doit être égal à 1")
    }
}
