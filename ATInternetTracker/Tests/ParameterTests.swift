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
//  ParameterTests.swift
//  Tracker
//

import UIKit
import XCTest

import Tracker

class ParameterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // On vérifie que qu'il est possible d'instancier plusieurs fois un Paramètre
    func testMultiInstance() {
        let page = Param(key: "p", value: {"home"}, type: .String)
        let xtCustom = Param(key: "stc", value: {"{\"crash\":1}"}, type: .JSON)
        XCTAssert(page !== xtCustom, "page et xtCustom ne doivent pas pointer vers la même référence")
    }
    
    // On vérifie les différents paramètres après une initialisation par défaut
    func testParameterValuesAfterInit() {
        let param = Param()
        
        XCTAssertEqual(param.key, "", "le paramètre key doit être une chaine vide")
        XCTAssert(param.value() == "", "le paramètre value doit être égal à ''")
        XCTAssert(param.options == nil, "le paramètre options doit être nil")
    }
    
    // On vérifie que les paramètres key et value ont bien été affectés
    func testParameterValuesAfterInitWithKeyAndValue() {
        let param = Param(key: "p", value: {"Home"}, type: .String)
        
        XCTAssertEqual(param.key, "p", "le paramètre key doit être égal à p")
        XCTAssert(param.value() == "Home", "le paramètre value doit être égal à Home")
    }
    
    // On vérifie que les paramètres key, value et relativeParameter ont bien été affectés
    func testParameterValuesAfterInitWithKeyAndValueAtFirstPosition() {
        let paramOptions = ParamOption()
        paramOptions.relativePosition = ParamOption.RelativePosition.first
        
        let param = Param(key: "p", value: {"Home"}, type: .String, options: paramOptions)
        
        XCTAssertEqual(param.key, "p", "le paramètre key doit être égal à p")
        XCTAssert(param.value() == "Home", "le paramètre value doit être égale à Home")
        XCTAssert(param.options?.relativePosition == ParamOption.RelativePosition.first, "l'option relativePosition doit être égale à first")
        XCTAssert(param.options?.relativeParameterKey == "", "l'option relativeParameter doit être égale à ''")
    }
    
    // On vérifie que les paramètres key, value et relativeParameter ont bien été affectés
    // On vérifie que si le paramètre a une position last, le relativeParameter est nil
    func testParameterValuesAfterInitWithKeyAndValueAtLastPosition() {
        let paramOptions = ParamOption()
        paramOptions.relativePosition = ParamOption.RelativePosition.last
        
        let param = Param(key: "p", value: {"Home"}, type: .String, options: paramOptions)
        
        XCTAssertEqual(param.key, "p", "le paramètre key doit être égal à p")
        XCTAssert(param.value() == "Home", "le paramètre value doit être égale à Home")
        XCTAssert(param.options?.relativePosition == ParamOption.RelativePosition.last, "l'option relativePosition doit être égale à last")
        XCTAssert(param.options?.relativeParameterKey == "", "l'option relativeParameter doit être égale à ''")

    }
    
    // On vérifie que les paramètres key, value et relativeParameter ont bien été affectés
    func testParameterValuesAfterInitWithKeyAndValueBeforeReferrerParameter() {
        let paramOptions = ParamOption()
        paramOptions.relativePosition = ParamOption.RelativePosition.before
        paramOptions.relativeParameterKey = "ref"
        
        let param = Param(key: "p", value: {"Home"}, type: .String, options: paramOptions)
        
        XCTAssertEqual(param.key, "p", "le paramètre key doit être égal à p")
        XCTAssert(param.value() == "Home", "le paramètre value doit être égale à Home")
        XCTAssert(param.options?.relativePosition == ParamOption.RelativePosition.before, "l'option relativePosition doit être égale à before")
        XCTAssert(param.options?.relativeParameterKey == "ref", "l'option relativeParameter doit être égale à 'ref'")
    }
    
    // On vérifie que les paramètres key, value et relativeParameter ont bien été affectés
    func testParameterValuesAfterInitWithKeyAndValueAfterXTCustomParameter() {
        let paramOptions = ParamOption()
        paramOptions.relativePosition = ParamOption.RelativePosition.after
        paramOptions.relativeParameterKey = "stc"
        
        let param = Param(key: "p", value: {"Home"}, type: .String, options: paramOptions)
        
        XCTAssertEqual(param.key, "p", "le paramètre key doit être égal à p")
        XCTAssert(param.value() == "Home", "le paramètre value doit être égale à Home")
        XCTAssert(param.options?.relativePosition == ParamOption.RelativePosition.after, "l'option relativePosition doit être égale à after")
        XCTAssert(param.options?.relativeParameterKey == "stc", "l'option relativeParameter doit être égale à 'stc'")
    }
    
    // On vérifie que la liste des paramètres en lecture seule contient les 10 clés à ne pas surcharger (sujet à modification)
    func testReadOnlyParametersKeys() {
        XCTAssertEqual(11, ReadOnlyParam.list.count, "Il doit y avoir 10 clés de paramètres en lecture seule")
    }
}
