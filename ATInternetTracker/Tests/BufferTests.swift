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
//  BufferTests.swift
//  Tracker
//

import UIKit
import XCTest

class BufferTests: XCTestCase {
    
    // On instancie deux objets de type Parameter
    let paramPer = Param(key:"model", value:{"[apple]-[ipad4,4]"}, type: .string)
    let paramVol = Param(key:"p", value: {"home"}, type: .string)
    
    // On instancie deux tableaux contenant des objets de type Parameter
    let arrayPer = [Param(key:"key0p", value: {"value0p"}, type: .string), Param(key:"key1p", value: {"value1p"}, type: .string)]
    let arrayVol = [Param(key:"key0v", value: {"value0v"}, type: .string), Param(key:"key1v", value: {"value1v"}, type: .string)]
    
    // Instance de buffer utilisée pour les tests
    let buffer = Buffer(tracker: Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid", "sessionBackgroundDuration":"60" ]))

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // On vérifie qu'il est possible d'ajouter un paramètre persistant dans le buffer
    func testAddParamPer() {
        buffer.persistentParameters.append(paramPer)
        #if os(iOS)
        XCTAssertEqual(buffer.persistentParameters.count, 15, "persistentParameters doit contenir un élément")
        #elseif os(tvOS)
         XCTAssertEqual(buffer.persistentParameters.count, 14, "persistentParameters doit contenir un élément")
        #endif
    }
    
    // On vérifie qu'il est possible d'ajouter un paramètre volatile dans le buffer
    func testAddParamVol() {
        buffer.volatileParameters.append(paramVol)
        XCTAssertEqual(buffer.volatileParameters.count, 1, "volatileParameters doit contenir un élément")
    }
    
    // On vérifie qu'il est possible de récupérer un paramètre persistant depuis le buffer
    func testGetParamPer() {
        buffer.persistentParameters.append(paramPer)
        
        let pos = Tool.findParameterPosition(paramPer.key, arrays: buffer.persistentParameters)
        
        let param: Param = buffer.persistentParameters[pos.first!.index]
        var testOK = true
        if (param.key != paramPer.key || param.value() != paramPer.value()) {
            testOK = false
        }
        XCTAssert(testOK, "param et paramPer doivent avoir la même valeur pour key et value")
    }
    
    // On vérifie qu'il est possible de récupérer un paramètre volatile depuis le buffer
    func testGetParamVol() {
        buffer.volatileParameters.append(paramVol)
        let param: Param = buffer.volatileParameters[0]
        var testOK = true
        if (param.key != paramVol.key || param.value() != paramVol.value()) {
            testOK = false
        }
        XCTAssert(testOK, "param et paramVol doivent avoir la même valeur pour key et value")
    }
    
    // On vérifie qu'il est possible d'affecter un tableau de paramètres persistants
    func testAddArrayPer() {
        buffer.persistentParameters = arrayPer
        XCTAssertEqual(buffer.persistentParameters.count, 2, "persistentParameters doit contenir deux éléments")
    }
    
    // On vérifie qu'il est possible d'affecter un tableau de paramètres volatiles
    func testAddArrayVol() {
        buffer.volatileParameters = arrayVol
        XCTAssertEqual(buffer.volatileParameters.count, 2, "volatileParameters doit contenir deux éléments")
    }
    
    // On vérifie qu'il est possible de récupérer le tableau de paramètres persistants
    func testGetArrayPer() {
        buffer.persistentParameters = arrayPer
        var testOK = true
        var i = 0
        for param in buffer.persistentParameters {
            if (param.key != arrayPer[i].key || param.value() != arrayPer[i].value()) {
                testOK = false
            }
            i += 1
        }
        if (buffer.persistentParameters.count != arrayPer.count) {
            testOK = false
        }
        XCTAssert(testOK, "persistentParameters et arrayPer doivent être identiques")
    }
    
    // On vérifie qu'il est possible de récupérer le tableau de paramètres volatiles
    func testGetArrayVol() {
        buffer.volatileParameters = arrayVol
        var testOK = true
        var i = 0
        for param in buffer.volatileParameters {
            if (param.key != arrayVol[i].key || param.value() != arrayVol[i].value()) {
                testOK = false
            }
            i += 1
        }
        if (buffer.volatileParameters.count != arrayVol.count) {
            testOK = false
        }
        XCTAssert(testOK, "volatileParameters et arrayVol doivent être identiques")
    }

    // On vérifie qu'il est possible d'instancier plusieurs fois Buffer
    func testMultiInstance() {
        let buffer1 = Buffer(tracker: Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]))
        let buffer2 = Buffer(tracker: Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]))
        XCTAssert(buffer1 !== buffer2, "buffer1 et buffer2 ne doivent pas pointer vers la même référence")
    }


}
