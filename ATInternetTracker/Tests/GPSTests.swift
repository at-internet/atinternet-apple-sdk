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
//  GPSTests.swift
//  Tracker
//

import UIKit
import XCTest

class GPSTests: XCTestCase {
    
    lazy var location: Location = Location(tracker: Tracker())
    lazy var locations: Locations = Locations(tracker: Tracker())
    
    func testInitLocation() {
        XCTAssertTrue(location.latitude == 0.0, "La latitude doit être égale à 0")
        XCTAssertTrue(location.longitude == 0.0, "La longitude doit être égale à 0")
    }
    
    func testSetLocation() {
        let screen = locations.tracker.screens.add("Home")
        screen.setEvent()
        location = locations.add(40.0, longitude: 50.0)
        location.setEvent()
        
        XCTAssertEqual(locations.tracker.buffer.volatileParameters.count, 6, "Le nombre de paramètres volatiles doit être égal à 6")
        XCTAssert(locations.tracker.buffer.volatileParameters[0].key == "type", "Le premier paramètre doit être type")
        XCTAssert(locations.tracker.buffer.volatileParameters[0].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[1].key == "action", "Le second paramètre doit être action")
        XCTAssert(location.tracker.buffer.volatileParameters[1].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[2].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(locations.tracker.buffer.volatileParameters[2].value() == "Home", "La valeur du troisième paramètre doit être Home")
                
        XCTAssert(locations.tracker.buffer.volatileParameters[4].key == "gy", "Le 4ème paramètre doit être gy")
        XCTAssert(locations.tracker.buffer.volatileParameters[4].value() == "40.00", "La valeur du 4ème paramètre doit être 40")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[5].key == "gx", "Le 5ème paramètre doit être gx")
        XCTAssert(locations.tracker.buffer.volatileParameters[5].value() == "50.00", "La valeur du 5ème paramètre doit être 50")
    }
    
    func testSetLongLocation() {
        let screen = locations.tracker.screens.add("Home")
        screen.setEvent()
        location = locations.add(40.12345, longitude: 50.6789)
        location.setEvent()
        
        XCTAssertEqual(locations.tracker.buffer.volatileParameters.count, 6, "Le nombre de paramètres volatiles doit être égal à 6")
        XCTAssert(locations.tracker.buffer.volatileParameters[0].key == "type", "Le premier paramètre doit être type")
        XCTAssert(locations.tracker.buffer.volatileParameters[0].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[1].key == "action", "Le second paramètre doit être action")
        XCTAssert(locations.tracker.buffer.volatileParameters[1].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[2].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(locations.tracker.buffer.volatileParameters[2].value() == "Home", "La valeur du troisième paramètre doit être Home")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[4].key == "gy", "Le 4ème paramètre doit être gy")
        XCTAssert(locations.tracker.buffer.volatileParameters[4].value() == "40.12", "La valeur du 4ème paramètre doit être 40.12")
        
        XCTAssert(locations.tracker.buffer.volatileParameters[5].key == "gx", "Le 5ème paramètre doit être gx")
        XCTAssert(locations.tracker.buffer.volatileParameters[5].value() == "50.68", "La valeur du 5ème paramètre doit être 50.68")
    }
}
