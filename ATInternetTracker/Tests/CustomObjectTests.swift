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

import XCTest
@testable import ATInternetTracker

class CustomObjectTests: XCTestCase {
    
    lazy var stc: CustomObject = CustomObject(tracker: Tracker())
    lazy var stcs: CustomObjects = CustomObjects(tracker: Tracker())
    
    func lookupParam(key: String, params: [ (key: String, value: (String, String)) ]) -> (key: String, value: (String, String)) {
        return params.filter({ (tuple) -> Bool in
            return tuple.key == key
        })[0]
    }
    
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
        stc.setParams()
        
        XCTAssertEqual(stc.tracker.buffer.volatileParameters.count, 1, "Le nombre de paramètres volatiles doit être égal à 1")
        XCTAssert(stc.tracker.buffer.volatileParameters["stc"]?.key == "stc", "Le premier paramètre doit être stc")
        XCTAssert(stc.tracker.buffer.volatileParameters["stc"]?.values[0]() == "{\"legume\":\"carotte\"}", "La valeur du premier paramètre doit être {\"legume\":\"carotte\"}")
    }
    
    func testAppendStringCustomObject() {
        stc.tracker.setParam("stc", value: "{\"legumes\":[\"tomate\",\"choux\",\"carotte\"]}")
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        
        stc.tracker.setParam("stc", value: "{\"fruits\":[\"pomme\",\"poire\",\"cerise\"]}", options: option)
        
        let builder = Builder(tracker: stc.tracker)
        let params: [String : (String, String)] = builder.prepareQuery()
        
        XCTAssertTrue(params["stc"] != nil, "Le paramètre doit être stc")
        
        let stcQuery = params["stc"]?.0
        let index = stcQuery!.index(stcQuery!.startIndex, offsetBy: 5)
        let stcEncoded = String(stcQuery![index...])
        let obj = stcEncoded.percentDecodedString.toJSONObject() as! Dictionary<String, Any>
        XCTAssertTrue(obj["legumes"] != nil, "le stc doit contenir les clefs inserees")
        XCTAssertTrue(obj["fruits"] != nil, "le stc doit contenir les clefs inserees")
        
        let arrayLegumes = obj["legumes"]! as! Array<String>
        let arrayFruits = obj["fruits"]! as! Array<String>
        
        XCTAssertTrue(arrayLegumes[0] == "tomate")
        XCTAssertTrue(arrayLegumes[1] == "choux")
        XCTAssertTrue(arrayLegumes[2] == "carotte")
        
        XCTAssertTrue(arrayFruits[0] == "pomme")
        XCTAssertTrue(arrayFruits[1] == "poire")
        XCTAssertTrue(arrayFruits[2] == "cerise")
    }
    
    func testAppendDictionaryCustomObject() {
        _ = stc.tracker.setParam("stc", value: ["legumes" : ["tomate", "choux", "carotte"]])
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        
        _ = stc.tracker.setParam("stc", value: ["fruits" : ["pomme", "poire", "cerise"]], options: option)
        
        
        let builder = Builder(tracker: stc.tracker)
        let params: [String : (String, String)] = builder.prepareQuery()
        
        let stcQuery = params["stc"]?.0
        let index = stcQuery!.index(stcQuery!.startIndex, offsetBy: 5)
        let stcEncoded = String(stcQuery![index...])
        let obj = stcEncoded.percentDecodedString.toJSONObject() as! Dictionary<String, Any>
        XCTAssertTrue(obj["legumes"] != nil, "le stc doit contenir les clefs inserees")
        XCTAssertTrue(obj["fruits"] != nil, "le stc doit contenir les clefs inserees")
        
        let arrayLegumes = obj["legumes"]! as! Array<String>
        let arrayFruits = obj["fruits"]! as! Array<String>
        
        XCTAssertTrue(arrayLegumes[0] == "tomate")
        XCTAssertTrue(arrayLegumes[1] == "choux")
        XCTAssertTrue(arrayLegumes[2] == "carotte")
        
        XCTAssertTrue(arrayFruits[0] == "pomme")
        XCTAssertTrue(arrayFruits[1] == "poire")
        XCTAssertTrue(arrayFruits[2] == "cerise")
    }
}

