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
//  AisleTests.swift
//  Tracker
//

import UIKit
import XCTest

class AisleTests: XCTestCase {

    lazy var aisle: Aisle = Aisle(tracker: Tracker())
    lazy var aisles: Aisles = Aisles(tracker: Tracker())
    
    func testSetAisle() {
        aisle.level1 = "Vêtement"
        aisle.level2 = "Chaussures"
        aisle.level3 = "Basket"
        aisle.setEvent()
        
        XCTAssertEqual(aisle.tracker.buffer.volatileParameters.count, 1, "Le nombre de paramètres volatiles doit être égal à 1")
        XCTAssert(aisle.tracker.buffer.volatileParameters[0].key == "aisl", "Le premier paramètre doit être aisle")
        XCTAssert(aisle.tracker.buffer.volatileParameters[0].value() == "Vêtement::Chaussures::Basket", "La valeur du premier paramètre doit être Vêtement::Chaussures::Basket")
    }
    
    func testAddAisle() {
        aisles.tracker = aisle.tracker
        aisle = aisles.add("chaussure")
        
        XCTAssert(aisles.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(aisle.level1 == "chaussure", "le niveau 1 du rayon doit être égal à chaussure")
        XCTAssert((aisles.tracker.businessObjects[aisle.id] as! Aisle).level1 == "chaussure", "le niveau 1 du rayond doit être égal à Godasse")
    }
}
