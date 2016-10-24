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
//  CustomVarTests.swift
//  Tracker
//

import UIKit
import XCTest

class CustomVarTests: XCTestCase {

    lazy var customVar: CustomVar = CustomVar(tracker: Tracker())
    lazy var customVars: CustomVars = CustomVars(tracker: Tracker())
    
    func testSetCustomVarSite() {
        let screen = customVars.tracker.screens.add("Home")
        screen.setEvent()
        customVar = customVars.add(123, value: "coucou", type: .App)
        customVar.setEvent()
        
        XCTAssertEqual(customVars.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        XCTAssert(customVars.tracker.buffer.volatileParameters[0].key == "type", "Le premier paramètre doit être type")
        XCTAssert(customVars.tracker.buffer.volatileParameters[0].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters[1].key == "action", "Le second paramètre doit être action")
        XCTAssert(customVars.tracker.buffer.volatileParameters[1].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters[2].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(customVars.tracker.buffer.volatileParameters[2].value() == "Home", "La valeur du troisième paramètre doit être Home")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters[4].key == "x123", "Le 4ème paramètre doit être x123")
        XCTAssert(customVars.tracker.buffer.volatileParameters[4].value() == "coucou", "La valeur du 4ème paramètre doit être coucou")
    }
    
    func testSetCustomVarPage() {
        let screen = customVars.tracker.screens.add("Home")
        screen.setEvent()
        customVar = customVars.add(123, value: "coucou", type: .Screen)
        customVar.setEvent()
        
        XCTAssertEqual(customVars.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        XCTAssert(customVars.tracker.buffer.volatileParameters[0].key == "type", "Le premier paramètre doit être type")
        XCTAssert(customVars.tracker.buffer.volatileParameters[0].value() == "screen", "La valeur du premier paramètre doit être screen")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters[1].key == "action", "Le second paramètre doit être action")
        XCTAssert(customVars.tracker.buffer.volatileParameters[1].value() == "view", "La valeur du second paramètre doit être view")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters[2].key == "p", "Le troisième paramètre doit être p")
        XCTAssert(customVars.tracker.buffer.volatileParameters[2].value() == "Home", "La valeur du troisième paramètre doit être Home")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters[4].key == "f123", "Le 4ème paramètre doit être f123")
        XCTAssert(customVars.tracker.buffer.volatileParameters[4].value() == "coucou", "La valeur du 4ème paramètre doit être coucou")
    }

}
