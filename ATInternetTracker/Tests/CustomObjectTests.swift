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
//  CustomObjectTests.swift
//  Tracker
//

import UIKit
import XCTest

class CustomObjectTests: XCTestCase {
    
    lazy var stc: CustomObject = CustomObject(tracker: Tracker())
    lazy var stcs: CustomObjects = CustomObjects(tracker: Tracker())
    
    func testInitCustomObject() {
        XCTAssertTrue(stc.json == "{}", "L'object JSON doit etre vide")
    }
    
    func testAddStringCustomObject() {
        stc = stcs.add("{\"legume\":\"carotte\"}")
        XCTAssert(stcs.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(stc.json == "{\"legume\":\"carotte\"}", "Le JSON doit etre égal à {\"legume\":\"carotte\"}")
        XCTAssert((stcs.tracker.businessObjects[stc.id] as! CustomObject).json == "{\"legume\":\"carotte\"}", "Le JSON doit etre égal à {\"legume\":\"carotte\"}")
    }
    
    func testAddDictonaryCustomObject() {
        stc = stcs.add(["legume": "carotte"])
        XCTAssert(stcs.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(stc.json == "{\"legume\":\"carotte\"}", "Le JSON doit etre égal à {\"legume\":\"carotte\"}")
        XCTAssert((stcs.tracker.businessObjects[stc.id] as! CustomObject).json == "{\"legume\":\"carotte\"}", "Le JSON doit etre égal à {\"legume\":\"carotte\"}")
    }
    
    func testSendCustomObject() {
        stc.json = "{\"legume\":\"carotte\"}"
        stc.setEvent()
        
        XCTAssertEqual(stc.tracker.buffer.volatileParameters.count, 1, "Le nombre de paramètres volatiles doit être égal à 1")
        XCTAssert(stc.tracker.buffer.volatileParameters[0].key == "stc", "Le premier paramètre doit être stc")
        XCTAssert(stc.tracker.buffer.volatileParameters[0].value() == "{\"legume\":\"carotte\"}", "La valeur du premier paramètre doit être {\"legume\":\"carotte\"}")
    }
    
    func testAppendStringCustomObject() {
        stc.tracker.setParam("stc", value: "{\"legumes\":[\"tomate\",\"choux\",\"carotte\"]}")
        
        let option = ParamOption()
        option.append = true
        
        stc.tracker.setParam("stc", value: "{\"fruits\":[\"pomme\",\"poire\",\"cerise\"]}", options: option)
        
        let builder = Builder(tracker: stc.tracker, volatileParameters: stc.tracker.buffer.volatileParameters, persistentParameters: stc.tracker.buffer.persistentParameters)
        let param: [(param: Param, str: String)] = builder.prepareQuery()
        
        let p0: (param: Param, str: String) = (param.filter() {
            return ($0 as (param: Param, str: String)).param.key == "stc"
            }).first!
        
        XCTAssertTrue(p0.param.key == HitParam.JSON.rawValue, "Le paramètre doit être stc")
        XCTAssertTrue(p0.str == "&stc=%7B%22legumes%22%3A%5B%22tomate%22%2C%22choux%22%2C%22carotte%22%5D%2C%22fruits%22%3A%5B%22pomme%22%2C%22poire%22%2C%22cerise%22%5D%7D", "Le paramètre doit être égal à &stc=%7B%22legumes%22%3A%5B%22tomate%22%2C%22choux%22%2C%22carotte%22%5D%2C%22fruits%22%3A%5B%22pomme%22%2C%22poire%22%2C%22cerise%22%5D%7D")
    }
    
    func testAppendDisctionaryCustomObject() {
        stc.tracker.setParam("stc", value: ["legumes" : ["tomate", "choux", "carotte"]])
        
        let option = ParamOption()
        option.append = true
        
        stc.tracker.setParam("stc", value: ["fruits" : ["pomme", "poire", "cerise"]], options: option)

            
        let builder = Builder(tracker: stc.tracker, volatileParameters: stc.tracker.buffer.volatileParameters, persistentParameters: stc.tracker.buffer.persistentParameters)
        let param: [(param: Param, str: String)] = builder.prepareQuery()
        
        let p0: (param: Param, str: String) = (param.filter() {
            return ($0 as (param: Param, str: String)).param.key == "stc"
            }).first!
        
        XCTAssertTrue(p0.param.key == HitParam.JSON.rawValue, "Le paramètre doit être stc")
        XCTAssertTrue(p0.str == "&stc=%7B%22legumes%22%3A%5B%22tomate%22%2C%22choux%22%2C%22carotte%22%5D%2C%22fruits%22%3A%5B%22pomme%22%2C%22poire%22%2C%22cerise%22%5D%7D", "Le paramètre doit être égal à &stc=%7B%22legumes%22%3A%5B%22tomate%22%2C%22choux%22%2C%22carotte%22%5D%2C%22fruits%22%3A%5B%22pomme%22%2C%22poire%22%2C%22cerise%22%5D%7D")
    }
}
