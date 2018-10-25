//
//  EventsTests.swift
//  TrackerTests
//
//  Created by nsagnette on 26/10/2018.
//

import XCTest

class EventsTests: XCTestCase {
    
    lazy var events: Events

    override func setUp() {
        super.setUp()
        Events(tracker: Tracker())
    }
    
    func testSetParamsOne() {
        events.add(action: "act", data: ["test1" : "value1"])
        events.setParams()
        
        XCTAssertEqual(events.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssertEqual(events.tracker.buffer.volatileParameters["col"]!.values.count, 1, "Le nombre de valeurs dans col doit être égal à 1")
        XCTAssert(events.tracker.buffer.volatileParameters["col"]!.values[0]() == "2", "La valeur de col paramètre doit être 2")
        
        XCTAssertEqual(events.tracker.buffer.volatileParameters["events"]!.values.count, 1, "Le nombre de valeurs dans events doit être égal à 1")
        
        let evts = ATJSON.parse(events.tracker.buffer.volatileParameters["events"]!.values[0]())
        
        XCTAssertEqual(evts.array.count, 1, "Le nombre d'events doit être égal à 1")
        
        let evt = evts[0]
        XCTAssertEqual(evt.dictionaryObject.count, 2, "Le nombre de proprietes dans l'event doit être égal à 2")
        XCTAssertEqual(evt.dictionaryObject["action"], "act", "La propriété action doit etre égale a act")
        
        let data = evt.dictionaryObject["data"] as [String : Any]
        XCTAssertEqual(data.count, 1, "Le nombre de proprietes dans data doit être égal à 1")
    }
}
