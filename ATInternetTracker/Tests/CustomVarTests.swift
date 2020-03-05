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
@testable import ATInternetTracker

class CustomVarTests: XCTestCase {

    lazy var customVar: CustomVar = CustomVar(tracker: Tracker())
    lazy var customVars: CustomVars = CustomVars(tracker: Tracker())
    
    func testSetCustomVarSite() {
        let screen = customVars.tracker.screens.add("Home")
        screen.setParams()
        customVar = customVars.add(123, value: "coucou", type: .app)
        customVar.setParams()
        
        XCTAssertEqual(customVars.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters["p"]!.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(customVars.tracker.buffer.volatileParameters["p"]!.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters["x123"]!.key == "x123", "Le 4ème paramètre doit être x123")
        XCTAssert(customVars.tracker.buffer.volatileParameters["x123"]!.values[0]() == "coucou", "La valeur du 4ème paramètre doit être coucou")
    }
    
    func testSetCustomVarPage() {
        let screen = customVars.tracker.screens.add("Home")
        screen.setParams()
        customVar = customVars.add(123, value: "coucou", type: .screen)
        customVar.setParams()
        
        XCTAssertEqual(customVars.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters["p"]!.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(customVars.tracker.buffer.volatileParameters["p"]!.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")
        
        XCTAssert(customVars.tracker.buffer.volatileParameters["f123"]!.key == "f123", "Le 4ème paramètre doit être f123")
        XCTAssert(customVars.tracker.buffer.volatileParameters["f123"]!.values[0]() == "coucou", "La valeur du 4ème paramètre doit être coucou")
    }

}
