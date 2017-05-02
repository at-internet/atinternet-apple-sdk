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
//  EventTests.swift
//  Tracker
//

import UIKit
import XCTest

class EventTests: XCTestCase {

    let tracker = Tracker()
    
    func testSetEvent() {
        _ = tracker.event.set("cat", action: "act", label: "lab")
        
        let p0 = tracker.buffer.volatileParameters["type"]!
        let p1 = tracker.buffer.volatileParameters["action"]!
        let p2 = tracker.buffer.volatileParameters["p"]!
        let p3 = tracker.buffer.volatileParameters["stc"]!
        
        XCTAssertTrue(p0.key == HitParam.hitType.rawValue, "Le paramètre doit être type")
        XCTAssertTrue(p0.values[0]() == "cat", "Le paramètre doit avoir la valeur cat")
        
        XCTAssertTrue(p1.key == HitParam.action.rawValue, "Le paramètre doit être action")
        XCTAssertTrue(p1.values[0]() == "act", "Le paramètre doit avoir la valeur act")
        
        XCTAssertTrue(p2.key == HitParam.screen.rawValue, "Le paramètre doit être page")
        XCTAssertTrue(p2.values[0]() == "lab", "Le paramètre doit avoir la valeur lab")
        
        XCTAssertTrue(p3.key == HitParam.json.rawValue, "Le paramètre doit être stc")
        XCTAssertTrue(p3.values[0]() == "{}", "Le paramètre ne doit pas avoir de valeur")
    }
    
    func testSetEventJSON() {
        let json = "{ \"key0\": \"value0\", \"key1\": \"value1\" }"
        _ = tracker.event.set("cat", action: "act", label: "lab", value:json)
        
        let p0 = tracker.buffer.volatileParameters["type"]!
        let p1 = tracker.buffer.volatileParameters["action"]!
        let p2 = tracker.buffer.volatileParameters["p"]!
        let p3 = tracker.buffer.volatileParameters["stc"]!
        
        XCTAssertTrue(p0.key == HitParam.hitType.rawValue, "Le paramètre doit être type")
        XCTAssertTrue(p0.values[0]() == "cat", "Le paramètre doit avoir la valeur cat")
        
        XCTAssertTrue(p1.key == HitParam.action.rawValue, "Le paramètre doit être action")
        XCTAssertTrue(p1.values[0]() == "act", "Le paramètre doit avoir la valeur act")
        
        XCTAssertTrue(p2.key == HitParam.screen.rawValue, "Le paramètre doit être page")
        XCTAssertTrue(p2.values[0]() == "lab", "Le paramètre doit avoir la valeur lab")
        
        XCTAssertTrue(p3.key == HitParam.json.rawValue, "Le paramètre doit être stc")
        XCTAssertTrue(p3.values[0]() == json, "Le paramètre doit avoir la valeur de json")
    }

}
