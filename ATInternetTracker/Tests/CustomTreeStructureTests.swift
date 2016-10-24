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
//  CustomTreeStructureTests.swift
//  Tracker
//

import UIKit
import XCTest

class CustomTreeStructureTests: XCTestCase {

    lazy var cts: CustomTreeStructure = CustomTreeStructure(tracker: Tracker())
    lazy var ctss: CustomTreeStructures = CustomTreeStructures(tracker: Tracker())
    
    func testSetCustomTree() {
        cts.category1 = 1
        cts.category2 = 2
        cts.category3 = 3
        cts.setEvent()
        
        XCTAssertEqual(cts.tracker.buffer.volatileParameters.count, 1, "Le nombre de paramètres volatiles doit être égal à 1")
        XCTAssert(cts.tracker.buffer.volatileParameters[0].key == "ptype", "Le premier paramètre doit être ptype")
        XCTAssert(cts.tracker.buffer.volatileParameters[0].value() == "1-2-3", "La valeur du premier paramètre doit être 1-2-3")
    }
    
    func testAddCustomTree() {
        ctss.tracker = cts.tracker
        cts = ctss.add(1)
        
        XCTAssert(ctss.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(cts.category1 == 1, "la catégorie 1 de l'arbo perso doit être égale à 1")
        XCTAssert((ctss.tracker.businessObjects[cts.id] as! CustomTreeStructure).category1 == 1, "la catégorie 1 de l'arbo perso doit être égale à 1")
    }

}
