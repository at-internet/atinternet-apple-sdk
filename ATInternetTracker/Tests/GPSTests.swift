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
@testable import ATInternetTracker

class GPSTests: XCTestCase {
    
    lazy var location: Location = Location(tracker: Tracker())
    lazy var locations: Locations = Locations(tracker: Tracker())
    
    func testInitLocation() {
        XCTAssertTrue(location.latitude == 0.0, "La latitude doit être égale à 0")
        XCTAssertTrue(location.longitude == 0.0, "La longitude doit être égale à 0")
    }
    
    func testSetLocation() {
        let screen = locations.tracker.screens.add("Home")
        screen.setParams()
        location = locations.add(40.0, longitude: 50.0)
        location.setParams()
        
        XCTAssertEqual(locations.tracker.buffer.volatileParameters.count, 3, "Le nombre de paramètres volatiles doit être égal à 3")
        
        XCTAssert(locations.tracker.buffer.volatileParameters["p"]?.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(locations.tracker.buffer.volatileParameters["p"]?.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")
                
        XCTAssert(locations.tracker.buffer.volatileParameters["gy"]?.key == "gy", "Le 4ème paramètre doit être gy")
        XCTAssert(locations.tracker.buffer.volatileParameters["gy"]?.values[0]() == "40.00", "La valeur du 4ème paramètre doit être 40")
        
        XCTAssert(locations.tracker.buffer.volatileParameters["gx"]?.key == "gx", "Le 5ème paramètre doit être gx")
        XCTAssert(locations.tracker.buffer.volatileParameters["gx"]?.values[0]() == "50.00", "La valeur du 5ème paramètre doit être 50")
    }
    
    func testSetLongLocation() {
        let screen = locations.tracker.screens.add("Home")
        screen.setParams()
        location = locations.add(40.12345, longitude: 50.6789)
        location.setParams()
        
        XCTAssertEqual(locations.tracker.buffer.volatileParameters.count, 3, "Le nombre de paramètres volatiles doit être égal à 3")
        XCTAssert(locations.tracker.buffer.volatileParameters["p"]?.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(locations.tracker.buffer.volatileParameters["p"]?.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")
        
        XCTAssert(locations.tracker.buffer.volatileParameters["gy"]?.key == "gy", "Le 4ème paramètre doit être gy")
        XCTAssert(locations.tracker.buffer.volatileParameters["gy"]?.values[0]() == "40.12", "La valeur du 4ème paramètre doit être 40.12")
        
        XCTAssert(locations.tracker.buffer.volatileParameters["gx"]?.key == "gx", "Le 5ème paramètre doit être gx")
        XCTAssert(locations.tracker.buffer.volatileParameters["gx"]?.values[0]() == "50.68", "La valeur du 5ème paramètre doit être 50.68")
    }
}
